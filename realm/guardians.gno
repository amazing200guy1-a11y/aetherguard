package aetherguard

import (
	"errors"
	"strconv"
)

// Guardian defines a trusted security controller
type Guardian struct {
	Address     string
	AddedHeight int64
	Active      bool
}

// Proposal tracks multi-sig actions (e.g. Unpause, Parameter Tuning)
type Proposal struct {
	ID          int64
	ActionType  string // "UNPAUSE", "UPDATE_VELOCITY_BPS", "ADD_GUARDIAN"
	TargetParam int64
	TargetAddr  string
	Signers     []string
	Executed    bool
	CreatedBy   string
}

var (
	guardians      []Guardian
	proposals      []Proposal
	requiredQuorum int = 2 // 2-of-N consensus required
)

// IsGuardian checks if an address is an active guardian
func IsGuardian(addr string) bool {
	for _, g := range guardians {
		if g.Address == addr && g.Active {
			return true
		}
	}
	return false
}

// ProposeUnpause initiates a multi-sig proposal to reset the circuit breaker
func ProposeUnpause(proposer string) (int64, error) {
	if !IsGuardian(proposer) {
		return 0, errors.New("unauthorized: caller is not an active guardian")
	}

	propID := int64(len(proposals) + 1)
	newProp := Proposal{
		ID:          propID,
		ActionType:  "UNPAUSE",
		TargetParam: 0,
		TargetAddr:  "",
		Signers:     []string{proposer},
		Executed:    false,
		CreatedBy:   proposer,
	}

	proposals = append(proposals, newProp)
	return propID, nil
}

// VoteProposal casts a guardian signature on a pending proposal
func VoteProposal(propID int64, voter string, currentHeight int64) (string, error) {
	if !IsGuardian(voter) {
		return "", errors.New("unauthorized: caller is not an active guardian")
	}

	if propID <= 0 || propID > int64(len(proposals)) {
		return "", errors.New("invalid proposal ID")
	}

	prop := &proposals[propID-1]
	if prop.Executed {
		return "", errors.New("proposal already executed")
	}

	// Check if voter already signed
	for _, signer := range prop.Signers {
		if signer == voter {
			return "", errors.New("guardian has already voted on this proposal")
		}
	}

	prop.Signers = append(prop.Signers, voter)

	// Check Quorum
	if len(prop.Signers) >= requiredQuorum {
		prop.Executed = true

		if prop.ActionType == "UNPAUSE" {
			circuitBreakerActive = false
			breakerReason = "Normal operations resumed via Guardian Consensus (Prop #" + strconv.FormatInt(propID, 10) + ")"
			
			incidents = append(incidents, ThreatIncident{
				IncidentID:  int64(len(incidents) + 1),
				BlockHeight: currentHeight,
				Severity:    "LOW",
				Reporter:    voter,
				Description: "Circuit Breaker disabled via Multi-Sig Quorum. Realm resumed.",
				Mitigated:   true,
			})
			return "QUORUM_REACHED: circuit breaker disabled, realm unpaused", nil
		}
	}

	return "vote_recorded: current_votes=" + strconv.Itoa(len(prop.Signers)) + "/" + strconv.Itoa(requiredQuorum), nil
}

// GetGuardianCount returns total active guardians
func GetGuardianCount() int {
	count := 0
	for _, g := range guardians {
		if g.Active {
			count++
		}
	}
	return count
}

// GetRequiredQuorum returns required signatures
func GetRequiredQuorum() int {
	return requiredQuorum
}
