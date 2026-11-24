package aetherguard

import (
	"strings"
	"testing"
)

func TestDepositAndStats(t *testing.T) {
	initialBal := GetVaultBalance()
	
	msg, err := Deposit(50000, "g1user0001")
	if err != nil {
		t.Fatalf("unexpected deposit error: %v", err)
	}
	if !strings.Contains(msg, "deposit_confirmed") {
		t.Fatalf("expected deposit confirmation, got: %s", msg)
	}

	newBal := GetVaultBalance()
	if newBal != initialBal+50000 {
		t.Fatalf("expected balance %d, got %d", initialBal+50000, newBal)
	}
}

func TestNormalWithdrawal(t *testing.T) {
	// Normal withdrawal within 10% limit (balance is ~1,050,000, 10% is 105,000)
	msg, err := Withdraw(20000, "g1recipient0001", 10)
	if err != nil {
		t.Fatalf("expected normal withdrawal to succeed: %v", err)
	}
	if !strings.Contains(msg, "withdrawal_success") {
		t.Fatalf("unexpected withdrawal output: %s", msg)
	}
}

func TestVelocityBreachTripsCircuitBreaker(t *testing.T) {
	// Ensure breaker starts inactive
	if IsBreakerActive() {
		t.Fatalf("expected breaker to be inactive")
	}

	// Attempt withdrawal of 200,000 (which exceeds the 10% cap)
	_, err := Withdraw(200000, "g1exploiter0001", 20)
	if err == nil {
		t.Fatalf("expected velocity breach error, got nil")
	}

	// Verify breaker is now active!
	if !IsBreakerActive() {
		t.Fatalf("expected circuit breaker to be tripped automatically")
	}

	// Verify subsequent withdrawal is blocked by active breaker
	_, errBlocked := Withdraw(100, "g1user0002", 21)
	if errBlocked == nil {
		t.Fatalf("expected withdrawal to be blocked during freeze")
	}
}

func TestGuardianConsensusUnpause(t *testing.T) {
	if !IsBreakerActive() {
		t.Fatalf("expected breaker to be active for unpause test")
	}

	// 1. Unauthorized caller attempts to propose
	_, errAnon := ProposeUnpause("g1hacker00000000000000000000000000000000")
	if errAnon == nil {
		t.Fatalf("expected unauthorized error for non-guardian")
	}

	// 2. Guardian 1 proposes unpause
	propID, errProp := ProposeUnpause("g1sentinelmaster000000000000000000000000")
	if errProp != nil {
		t.Fatalf("guardian propose failed: %v", errProp)
	}

	// Breaker should still be active (only 1-of-2 votes)
	if !IsBreakerActive() {
		t.Fatalf("breaker should remain active until quorum is reached")
	}

	// 3. Guardian 2 votes to complete quorum (2-of-3)
	msg, errVote := VoteProposal(propID, "g1nodeauditoralpha000000000000000000000", 30)
	if errVote != nil {
		t.Fatalf("guardian vote failed: %v", errVote)
	}
	if !strings.Contains(msg, "QUORUM_REACHED") {
		t.Fatalf("expected quorum reached message, got: %s", msg)
	}

	// Breaker should now be reset!
	if IsBreakerActive() {
		t.Fatalf("expected circuit breaker to be unpaused after quorum reached")
	}
}

func TestRenderDynamicPaths(t *testing.T) {
	// Root Overview
	homeDoc := Render("")
	if !strings.Contains(homeDoc, "AETHERGUARD SENTINEL") {
		t.Fatalf("render home missing header")
	}
	if !strings.Contains(homeDoc, "System Status") {
		t.Fatalf("render home missing status badge")
	}

	// Alerts Route
	alertsDoc := Render("alerts")
	if !strings.Contains(alertsDoc, "Threat Incident Ledger") {
		t.Fatalf("render alerts missing header")
	}

	// Guardians Route
	guardiansDoc := Render("guardians")
	if !strings.Contains(guardiansDoc, "Multi-Sig Guardian Registry") {
		t.Fatalf("render guardians missing header")
	}

	// Metrics Route
	metricsDoc := Render("metrics")
	if !strings.Contains(metricsDoc, "Mathematical Velocity Governance") {
		t.Fatalf("render metrics missing header")
	}

	// Audit Route
	auditDoc := Render("audit")
	if !strings.Contains(auditDoc, "Formal Security Audit Matrix") {
		t.Fatalf("render audit missing header")
	}

	// 404 Route
	unknownDoc := Render("nonexistent-path")
	if !strings.Contains(unknownDoc, "404 Not Found") {
		t.Fatalf("render 404 missing fallback")
	}
}
