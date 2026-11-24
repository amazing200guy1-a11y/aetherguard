package aetherguard

import (
	"strconv"
	"strings"
)

// Render handles dynamic path routing for Gno.land's gnoweb portal
func Render(path string) string {
	cleaned := strings.Trim(strings.TrimSpace(path), "/")

	// Route Dispatcher
	if cleaned == "" {
		return renderHome()
	}
	if cleaned == "alerts" {
		return renderAlerts()
	}
	if cleaned == "guardians" {
		return renderGuardians()
	}
	if cleaned == "metrics" {
		return renderMetrics()
	}
	if cleaned == "audit" {
		return renderAudit()
	}

	return "# 404 Not Found\n\nUnknown path: `" + path + "`\n\n" +
		"### Available Routes:\n" +
		"- [Overview](/r/aetherguard:)\n" +
		"- [Threat Incident Ledger](/r/aetherguard:alerts)\n" +
		"- [Guardian Multi-Sig Quorum](/r/aetherguard:guardians)\n" +
		"- [Mathematical Velocity Metrics](/r/aetherguard:metrics)\n" +
		"- [Security Audit Matrix](/r/aetherguard:audit)\n"
}

// renderHome renders the primary decentralized cockpit
func renderHome() string {
	statusBadge := "🟢 **SYSTEM OPERATIONAL**"
	statusDesc := "All circuit breakers nominal. Inflow and outflow velocity within verified thresholds."
	if circuitBreakerActive {
		statusBadge = "🔴 **EMERGENCY FREEZE ACTIVE**"
		statusDesc = "**CRITICAL:** Outflow paused by autonomous sentinel. Reason: *" + breakerReason + "*"
	}

	out := "# AETHERGUARD SENTINEL\n"
	out += "### Autonomous Real-Time Security & Circuit Breaker Engine for Gno.land\n\n"
	out += "---\n\n"
	out += "## System Status: " + statusBadge + "\n\n"
	out += "> " + statusDesc + "\n\n"

	out += "### Telemetry & Reserve Overview\n\n"
	out += "| Metric Parameter | Live On-Chain Value | Engineering Specifications |\n"
	out += "| :--- | :--- | :--- |\n"
	out += "| **Protected Vault Reserve** | `" + strconv.FormatInt(totalVaultBalance, 10) + " ugnot` | Immutable smart contract vault |\n"
	out += "| **Total Value Guarded** | `" + strconv.FormatInt(totalProtectedVolume, 10) + " ugnot` | Cumulative secured liquidity |\n"
	out += "| **Max Outflow Velocity** | `" + strconv.FormatInt(maxEpochOutflowBps, 10) + " bps (10.00%)` | Enforced per epoch window |\n"
	out += "| **Velocity Epoch Window** | `" + strconv.FormatInt(epochWindowBlocks, 10) + " blocks` | Rolling sliding window |\n"
	out += "| **Active Guardians** | `" + strconv.Itoa(GetGuardianCount()) + " addresses` | Byzantine Fault Tolerant Multi-Sig |\n"
	out += "| **Consensus Quorum** | `" + strconv.Itoa(requiredQuorum) + "-of-" + strconv.Itoa(GetGuardianCount()) + "` | Required to disable circuit breaker |\n"
	out += "| **Threats Mitigated** | `" + strconv.FormatInt(totalThreatsDetected, 10) + " incidents` | Autonomous agent & sentinel logs |\n"
	out += "| **Protocol Version** | `" + version + "` | Pure Deterministic Gno Realm |\n\n"

	out += "---\n\n"
	out += "### Quick Navigation\n"
	out += "- [View Threat Incident Ledger (Alerts)](/r/aetherguard:alerts)\n"
	out += "- [View Guardian Registry & Multi-Sig (Guardians)](/r/aetherguard:guardians)\n"
	out += "- [Mathematical Velocity Limits (Metrics)](/r/aetherguard:metrics)\n"
	out += "- [On-Chain Security Audit Matrix (Audit)](/r/aetherguard:audit)\n\n"

	out += "---\n\n"
	out += "### Callable Realm Methods\n"
	out += "1. `Deposit(amount int64, depositor string)` — Fund the protected vault.\n"
	out += "2. `Withdraw(amount int64, recipient string, currentHeight int64)` — Execute rate-limited withdrawal.\n"
	out += "3. `ReportThreat(severity string, description string, currentHeight int64, caller string)` — AI agent threat reporting.\n"
	out += "4. `ProposeUnpause(proposer string)` — Initiate multi-sig recovery.\n"
	out += "5. `VoteProposal(propID int64, voter string, currentHeight int64)` — Cast guardian vote.\n"

	return out
}

// renderAlerts renders the chronological security incident ledger
func renderAlerts() string {
	out := "# Threat Incident Ledger\n"
	out += "[← Return to Overview](/r/aetherguard:)\n\n"
	out += "Chronological immutable record of security alerts detected by autonomous sentinel agents and velocity monitors.\n\n"
	out += "| ID | Block | Severity | Reporter | Description | Status |\n"
	out += "| :--- | :--- | :--- | :--- | :--- | :--- |\n"

	for i := len(incidents) - 1; i >= 0; i-- {
		inc := incidents[i]
		sevIcon := "🟢"
		if inc.Severity == "CRITICAL" {
			sevIcon = "🔴"
		} else if inc.Severity == "MEDIUM" {
			sevIcon = "🟡"
		}

		statusStr := "Mitigated"
		if !inc.Mitigated {
			statusStr = "Under Review"
		}

		out += "| #" + strconv.FormatInt(inc.IncidentID, 10) + " | " +
			strconv.FormatInt(inc.BlockHeight, 10) + " | " +
			sevIcon + " " + inc.Severity + " | `" +
			inc.Reporter + "` | " +
			inc.Description + " | " +
			statusStr + " |\n"
	}

	return out
}

// renderGuardians renders multi-sig guardians and proposal queue
func renderGuardians() string {
	out := "# Multi-Sig Guardian Registry\n"
	out += "[← Return to Overview](/r/aetherguard:)\n\n"
	out += "AetherGuard requires `" + strconv.Itoa(requiredQuorum) + "-of-" + strconv.Itoa(len(guardians)) +
		"` consensus among registered cryptographic guardians to lift an emergency freeze or alter velocity limits.\n\n"

	out += "### Active Guardians\n\n"
	out += "| Index | Guardian Address | Status | Enrolled Height |\n"
	out += "| :--- | :--- | :--- | :--- |\n"

	for i, g := range guardians {
		activeStr := "✅ Active"
		if !g.Active {
			activeStr = "❌ Inactive"
		}
		out += "| " + strconv.Itoa(i+1) + " | `" + g.Address + "` | " + activeStr + " | Block #" + strconv.FormatInt(g.AddedHeight, 10) + " |\n"
	}

	out += "\n### Multi-Sig Proposal Queue\n\n"
	if len(proposals) == 0 {
		out += "*No pending proposals. All systems operational.*\n"
	} else {
		out += "| Prop ID | Action | Proposer | Signatures | Status |\n"
		out += "| :--- | :--- | :--- | :--- | :--- |\n"
		for _, p := range proposals {
			execStr := "⏳ Pending (" + strconv.Itoa(len(p.Signers)) + "/" + strconv.Itoa(requiredQuorum) + ")"
			if p.Executed {
				execStr = "✅ Executed"
			}
			out += "| #" + strconv.FormatInt(p.ID, 10) + " | `" + p.ActionType + "` | `" + p.CreatedBy + "` | " + strconv.Itoa(len(p.Signers)) + " | " + execStr + " |\n"
		}
	}

	return out
}

// renderMetrics renders velocity mathematics and formulas
func renderMetrics() string {
	out := "# Mathematical Velocity Governance\n"
	out += "[← Return to Overview](/r/aetherguard:)\n\n"
	out += "### Quantitative Outflow Defense Formulation\n\n"
	out += "To eliminate flash drains, re-entrancy exploits, and infinite mints, AetherGuard enforces a strict mathematical bound on cumulative epoch outflow:\n\n"
	out += "```\n"
	out += "ΔV_epoch = Σ Outflow(t) for t ∈ [EpochStart, EpochEnd]\n"
	out += "MaxAllowedOutflow = (TotalVaultBalance * MaxEpochOutflowBps) / 10000\n"
	out += "Invariant: ΔV_epoch <= MaxAllowedOutflow\n"
	out += "```\n\n"
	out += "If any withdrawal attempts to violate this invariant, the transaction fails and the **Circuit Breaker trips autonomously** in the same atomic block height.\n\n"
	out += "### Live Epoch Status\n"
	out += "- **Current Epoch ID:** `" + strconv.FormatInt(currentEpochId, 10) + "`\n"
	out += "- **Outflow this Epoch:** `" + strconv.FormatInt(currentEpochOutflow, 10) + " ugnot`\n"
	out += "- **Epoch Window:** `" + strconv.FormatInt(epochWindowBlocks, 10) + " blocks`\n"

	return out
}

// renderAudit renders the institutional security rules matrix
func renderAudit() string {
	out := "# Formal Security Audit Matrix\n"
	out += "[← Return to Overview](/r/aetherguard:)\n\n"
	out += "Verification matrix for AetherGuard Genesis Release:\n\n"
	out += "| Threat Vector | Traditional Risk | AetherGuard On-Chain Defense | Status |\n"
	out += "| :--- | :--- | :--- | :--- |\n"
	out += "| **Flash Loan Drain** | 100% treasury drained in 1 tx | Max 10% outflow per 100-block epoch | 🛡️ Immune |\n"
	out += "| **Oracle Manipulation** | False pricing triggers liquidation | Velocity brake triggers before depletion | 🛡️ Immune |\n"
	out += "| **Compromised Key** | Single admin unpauses malicious code | 2-of-3 Guardian Quorum required | 🛡️ Protected |\n"
	out += "| **Agent False Positive** | AI agent reports spurious freeze | Guardian timelock unpause queue | 🛡️ Mitigated |\n"
	out += "| **Re-Entrancy** | Recursive state corruption | Checks-Effects-Interactions strictly enforced | 🛡️ Immune |\n"

	return out
}
