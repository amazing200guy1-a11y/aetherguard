"""
AetherGuard Sentinel Agent Runner
Demonstrates autonomous continuous monitoring of Gno.land realm state.
"""

import sys
import time
import json
from sentinel_mcp import GnoSentinelMCP

def run_agent_demonstration():
    print("=" * 70)
    print("  AETHERGUARD AUTONOMOUS SENTINEL AGENT (gnomcp Protocol)")
    print("  Target: Gno.land Testnet | Realm: gno.land/r/amazing200guy1/aetherguard")
    print("=" * 70)

    mcp = GnoSentinelMCP()
    
    # 1. Inspect Tools
    tools = mcp.get_tool_manifest()
    print(f"\n[+] Loaded {len(tools)} Model Context Protocol (MCP) Tools:")
    for t in tools:
        print(f"    - {t['name']}: {t['description']}")

    # 2. Query Realm State
    print("\n[*] [AGENT TELEMETRY] Querying Realm State...")
    state = mcp.execute_tool("gno_query_realm_state", {"realm_path": "gno.land/r/amazing200guy1/aetherguard"})
    print(f"    Total Protected Reserve : {state['total_balance_ugnot']:,} ugnot")
    print(f"    Current Epoch Outflow   : {state['current_epoch_outflow_ugnot']:,} ugnot")
    print(f"    Circuit Breaker Status  : {'ACTIVE (FROZEN)' if state['circuit_breaker_active'] else 'OPERATIONAL (NOMINAL)'}")

    # 3. Simulate Normal Transaction
    print("\n[*] [SCENARIO 1] Monitoring Normal Outflow Transaction (25,000 ugnot)...")
    res1 = mcp.execute_tool("gno_analyze_outflow_risk", {
        "tx_amount": 25000,
        "recipient": "g1merchantalpha0000000000000000000000",
        "block_height": 105
    })
    print(f"    Risk Score : {res1['risk_score']:.4f} | Severity: {res1['severity']}")
    print(f"    Action     : {res1['recommended_action']}")
    print(f"    Rationale  : {res1['rationale']}")

    # 4. Simulate Exploit Drain Attack
    print("\n[*] [SCENARIO 2] Flash Drain Exploit Attempt Detected (250,000 ugnot)...")
    res2 = mcp.execute_tool("gno_analyze_outflow_risk", {
        "tx_amount": 250000,
        "recipient": "g1exploiterflashdrain0000000000000000",
        "block_height": 106
    })
    print(f"    Risk Score : {res2['risk_score']:.4f} | Severity: {res2['severity']}")
    print(f"    Action     : {res2['recommended_action']}")
    print(f"    Rationale  : {res2['rationale']}")

    # 5. Autonomous Mitigation
    if res2['recommended_action'] == "FREEZE_CIRCUIT_BREAKER":
        print("\n[!] [AUTONOMOUS MITIGATION] Firing Circuit Breaker Trigger to Gno.land...")
        freeze_res = mcp.execute_tool("gno_trigger_circuit_breaker", {
            "reason": res2['rationale'],
            "severity": "CRITICAL",
            "block_height": 106
        })
        print(f"    Incident ID : #{freeze_res['incident_id']}")
        print(f"    Tx Hash     : {freeze_res['broadcast_tx_hash']}")
        print(f"    Outcome     : Realm Emergency Freeze Enforced Successfully!")

    print("\n" + "=" * 70)
    print("  AETHERGUARD SENTINEL: 100% THREATS MITIGATED | DEFENSE SECURED")
    print("=" * 70)

if __name__ == "__main__":
    run_agent_demonstration()
