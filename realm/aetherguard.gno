package aetherguard

import (
	"errors"
	"strconv"
	"strings"
	"time"
)

// State variables for AetherGuard Autonomous Circuit Breaker Realm
var (
	// Realm metadata
	realmOwner     string = "g1sentinelmaster000000000000000000000000"
	realmName      string = "AetherGuard Sentinel"
	version        string = "v1.0.4-genesis"
	initialized    bool   = false

	// Circuit Breaker & Safety Configuration
	circuitBreakerActive bool  = false
	lastBreakerTrigger   int64 = 0
	breakerReason        string = "None. Realm operational."

	// Velocity Rate Limiting Parameters (in basis points: 10000 = 100%)
	// Default: max 10% outflow allowed per epoch window (100 blocks)
	maxEpochOutflowBps  int64 = 1000 // 10.00%
	epochWindowBlocks   int64 = 100  // 100 blocks per velocity epoch
	currentEpochId      int64 = 0
	currentEpochOutflow int64 = 0
	totalVaultBalance   int64 = 1000000 // 1,000,000 ugnot initial reserve
	totalProtectedVolume int64 = 0

	// Security Threat Counter
	totalThreatsDetected int64 = 0
)

// ThreatLog records autonomous sentinel incident detections
type ThreatIncident struct {
	IncidentID  int64
	BlockHeight int64
	Severity    string // "LOW", "MEDIUM", "CRITICAL"
	Reporter    string
	Description string
	Mitigated   bool
}

var incidents []ThreatIncident

// init initializes default realm state
func init() {
	if !initialized {
		initialized = true
		currentEpochId = 1
		incidents = make([]ThreatIncident, 0)
		guardians = make([]Guardian, 0)
		proposals = make([]Proposal, 0)
		
		// Seed Genesis Guardians (3-of-3 setup initially, threshold 2)
		guardians = append(guardians, Guardian{Address: "g1sentinelmaster000000000000000000000000", AddedHeight: 1, Active: true})
		guardians = append(guardians, Guardian{Address: "g1nodeauditoralpha000000000000000000000", AddedHeight: 1, Active: true})
		guardians = append(guardians, Guardian{Address: "g1aiagentwatchdog0000000000000000000000", AddedHeight: 1, Active: true})
		requiredQuorum = 2

		// Record initial security event
		incidents = append(incidents, ThreatIncident{
			IncidentID:  1,
			BlockHeight: 1,
			Severity:    "LOW",
			Reporter:    "SystemGenesis",
			Description: "AetherGuard Sentinel Realm deployed with Autonomous Circuit Breakers.",
			Mitigated:   true,
		})
	}
}

// Deposit adds funds to the protected vault
func Deposit(amount int64, depositor string) (string, error) {
	if amount <= 0 {
		return "", errors.New("deposit amount must be strictly positive")
	}
	if circuitBreakerActive {
		return "", errors.New("vault is in emergency freeze: deposits halted")
	}

	totalVaultBalance += amount
	totalProtectedVolume += amount

	return "deposit_confirmed: balance=" + strconv.FormatInt(totalVaultBalance, 10), nil
}

// Withdraw executes a protected outflow under dynamic velocity rate-limiting
func Withdraw(amount int64, recipient string, currentHeight int64) (string, error) {
	if amount <= 0 {
		return "", errors.New("withdrawal amount must be strictly positive")
	}

	// 1. Check Circuit Breaker status
	if circuitBreakerActive {
		return "", errors.New("CIRCUIT_BREAKER_ACTIVE: withdrawals frozen by AetherGuard")
	}

	// 2. Solvency check
	if amount > totalVaultBalance {
		return "", errors.New("insufficient vault liquidity")
	}

	// 3. Update epoch window
	epochIndex := currentHeight / epochWindowBlocks
	if epochIndex > currentEpochId {
		currentEpochId = epochIndex
		currentEpochOutflow = 0 // Reset epoch accumulator
	}

	// 4. Mathematical Velocity Check:
	// Allowed max outflow this epoch = (totalVaultBalance * maxEpochOutflowBps) / 10000
	maxAllowed := (totalVaultBalance * maxEpochOutflowBps) / 10000
	if maxAllowed < 1000 {
		maxAllowed = 1000 // Minimum floor
	}

	if currentEpochOutflow+amount > maxAllowed {
		// Automatically trigger circuit breaker due to anomalous outflow velocity!
		TriggerCircuitBreaker(
			"ANOMALOUS_VELOCITY_BREACH: attempted " + strconv.FormatInt(amount, 10) +
				" ugnot in epoch " + strconv.FormatInt(currentEpochId, 10) +
				" (cap=" + strconv.FormatInt(maxAllowed, 10) + ")",
			currentHeight,
			"AutonomousRateLimiter",
		)
		return "", errors.New("RATE_LIMIT_EXCEEDED: circuit breaker tripped automatically")
	}

	// 5. Execute normal withdrawal
	currentEpochOutflow += amount
	totalVaultBalance -= amount

	return "withdrawal_success: recipient=" + recipient + " remaining=" + strconv.FormatInt(totalVaultBalance, 10), nil
}

// TriggerCircuitBreaker autonomously freezes the realm when an exploit or drain is identified
func TriggerCircuitBreaker(reason string, currentHeight int64, caller string) {
	circuitBreakerActive = true
	lastBreakerTrigger = currentHeight
	breakerReason = reason
	totalThreatsDetected++

	incidents = append(incidents, ThreatIncident{
		IncidentID:  int64(len(incidents) + 1),
		BlockHeight: currentHeight,
		Severity:    "CRITICAL",
		Reporter:    caller,
		Description: reason,
		Mitigated:   true,
	})
}

// ReportThreat allows registered AI agents and guardians to log security telemetry
func ReportThreat(severity string, description string, currentHeight int64, caller string) string {
	totalThreatsDetected++
	
	isCritical := strings.ToUpper(severity) == "CRITICAL"
	if isCritical {
		circuitBreakerActive = true
		lastBreakerTrigger = currentHeight
		breakerReason = "AI_AGENT_CRITICAL_ALERT: " + description
	}

	incidents = append(incidents, ThreatIncident{
		IncidentID:  int64(len(incidents) + 1),
		BlockHeight: currentHeight,
		Severity:    severity,
		Reporter:    caller,
		Description: description,
		Mitigated:   isCritical,
	})

	return "threat_logged: incident_id=" + strconv.FormatInt(int64(len(incidents)), 10)
}

// IsBreakerActive returns the real-time freeze state
func IsBreakerActive() bool {
	return circuitBreakerActive
}

// GetVaultBalance returns the current protected reserve
func GetVaultBalance() int64 {
	return totalVaultBalance
}

// GetStats returns telemetry tuple
func GetStats() (int64, int64, bool, int64) {
	return totalVaultBalance, totalThreatsDetected, circuitBreakerActive, totalProtectedVolume
}
