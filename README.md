# AetherGuard Sentinel 🛡️
### Autonomous Real-Time Security & Circuit Breaker Engine for Gno.land

[![Gno.land](https://img.shields.io/badge/Gno.land-Realm%20v1.0.4-blue?style=flat-square)](https://gno.land)
[![gnomcp Protocol](https://img.shields.io/badge/gnomcp-AI%20Agent%20Ready-black?style=flat-square)](https://mcp.gno.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)](LICENSE)
[![Verification](https://img.shields.io/badge/Tests-10%2F10%20Passing-success?style=flat-square)](tests/verify_all.py)

> **Gnome Tavern Hackathon 2026 Submission**  
> **Live Web Cockpit:** [https://amazing200guy1-a11y.github.io/aetherguard/](https://amazing200guy1-a11y.github.io/aetherguard/)  
> **Target Realm Path:** `gno.land/r/amazing200guy1/aetherguard`

---

## Demo

[![Demo Video](https://img.shields.io/badge/Demo-YouTube-red?style=flat-square&logo=youtube)](https://youtube.com/@amazing200guy1)

## 1. Executive Summary

Decentralized finance on high-throughput Layer 1 platforms experiences catastrophic exploits primarily due to three failure modes:
1. **Flash Loan Outflow Drains:** An attacker drains 80–100% of a protocol's treasury in a single atomic transaction.
2. **Oracle Manipulation & Re-entrancy:** Faulty price calculations or recursive calls deplete collateral before operators can react.
3. **Delayed Human Intervention:** Governance voting takes days, while smart contract exploits execute in seconds.

**AetherGuard** introduces an **autonomous, mathematical defense layer** natively built for **Gno.land**:
- **On-Chain Circuit Breaker Realm:** Written in pure, deterministic Gno (`.gno`), enforcing hard mathematical bounds on outflow velocity per epoch window.
- **Native Gno `Render(path string)` Web Engine:** The realm serves its own decentralized website directly on-chain via dynamic path routing (`/`, `/alerts`, `/guardians`, `/metrics`, `/audit`).
- **Autonomous `gnomcp` Sentinel Agent:** An AI sentinel operating via the **Model Context Protocol (MCP)** that continuously inspects mempool telemetry, evaluates anomalous drain patterns, and autonomously fires on-chain circuit breakers before treasury depletion.
- **Byzantine Multi-Sig Quorum:** A 2-of-3 guardian consensus mechanism required to unpause or adjust velocity limits post-mitigation.

---

## 2. Mathematical Velocity Rate-Limiting

AetherGuard implements an epoch-based sliding window defense. For any epoch window $\mathcal{E}$ spanning $W = 100$ blocks, cumulative outflow is strictly bounded:

$$\Delta V_{\mathcal{E}} = \sum_{t \in \mathcal{E}} \text{Outflow}(t)$$

$$\text{MaxAllowedOutflow}_{\mathcal{E}} = \frac{\text{TotalVaultReserve} \times \text{MaxEpochOutflowBps}}{10000}$$

$$\text{Invariant:} \quad \Delta V_{\mathcal{E}} \le \text{MaxAllowedOutflow}_{\mathcal{E}}$$

Where $\text{MaxEpochOutflowBps} = 1000$ (10.00%).

If any transaction attempts to breach this invariant:
1. The transaction reverts atomically.
2. The realm's **Circuit Breaker trips autonomously** in the same execution cycle.
3. All subsequent withdrawals are frozen until verified by the Guardian Multi-Sig.

---

## 3. Architecture Topology

```
+-------------------------------------------------------------------------+
|                         AETHERGUARD ARCHITECTURE                         |
+-------------------------------------------------------------------------+
                                     │
           ┌─────────────────────────┴─────────────────────────┐
           ▼                                                   ▼
┌─────────────────────────────┐                     ┌─────────────────────┐
│    Gno.land Testnet Realm   │                     │  gnomcp AI Sentinel │
│  (gno.land/r/.../aether)    │                     │  (MCP Agent Loop)   │
├─────────────────────────────┤                     ├─────────────────────┤
│ • aetherguard.gno (Core)    │◄─── RPC Telemetry ──┤ • sentinel_mcp.py   │
│ • guardians.gno (Multi-Sig) │                     │ • detector.py       │
│ • render.gno (Web Router)   │──── Trigger Pause ─►│ • run_agent.py      │
│ • aetherguard_test.gno      │                     │                     │
└──────────────┬──────────────┘                     └─────────────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Titanium Web Cockpit      │
│  (Monochromatic Interface)  │
├─────────────────────────────┤
│ • Live Gno RPC Connectivity │
│ • Adena Wallet Integration  │
│ • Interactive Exploit Sim   │
│ • Native Render() Markdown  │
└─────────────────────────────┘
```

---

## 4. Native Gno.land `Render(path string)` Engine

Unlike EVM contracts that require external web servers, Gno realms can render raw Markdown natively through the `Render(path string) string` convention. AetherGuard leverages dynamic route dispatch:

| Route Path | URI Example | Content Rendered |
| :--- | :--- | :--- |
| `""` or `"/"` | `gno.land/r/.../aetherguard:` | Live status badge, reserve overview, and callable methods. |
| `"alerts"` | `gno.land/r/.../aetherguard:alerts` | Chronological immutable ledger of security threats. |
| `"guardians"`| `gno.land/r/.../aetherguard:guardians`| 2-of-3 Multi-Sig Guardian registry and proposal queue. |
| `"metrics"` | `gno.land/r/.../aetherguard:metrics` | Formal mathematical velocity formulations. |
| `"audit"` | `gno.land/r/.../aetherguard:audit` | 5-point formal threat mitigation matrix. |

---

## 5. Model Context Protocol (`gnomcp`) Integration

AetherGuard ships with an autonomous sentinel agent adhering to the **Model Context Protocol (MCP)** specification:

```json
{
  "name": "gno_trigger_circuit_breaker",
  "description": "Autonomously freezes the Gno realm when an exploit pattern is confirmed",
  "parameters": {
    "type": "object",
    "properties": {
      "reason": {"type": "string"},
      "severity": {"type": "string", "enum": ["LOW", "MEDIUM", "CRITICAL"]},
      "block_height": {"type": "integer"}
    },
    "required": ["reason", "severity", "block_height"]
  }
}
```

The agent calculates a composite risk score $R \in [0.0, 1.0]$ based on velocity, burst frequency, and recipient concentration:

$$R = 0.50 \cdot S_{\text{velocity}} + 0.30 \cdot S_{\text{burst}} + 0.20 \cdot S_{\text{concentration}}$$

When $R \ge 0.85$ or velocity exceeds 10%, the agent broadcasts `gno_trigger_circuit_breaker` autonomously.

---

## 6. Directory Structure

```
c:\hackathons\aetherguard\
├── realm/                         # Pure Gno Smart Contract (Realm)
│   ├── aetherguard.gno            # Core Circuit Breaker & Vault Logic
│   ├── render.gno                 # Dynamic on-chain Markdown Web Engine
│   ├── guardians.gno              # Multi-sig Quorum & Timelock Controller
│   ├── aetherguard_test.gno       # Gno Unit Test Suite
│   └── gno.mod                    # Gno Module Definition
├── agent/                         # Autonomous AI Sentinel Agent
│   ├── sentinel_mcp.py            # gnomcp / Gno RPC integration
│   ├── detector.py                # Mathematical risk & drain detector
│   └── run_agent.py               # Autonomous monitoring loop
├── web/                           # Live Titanium Web Cockpit
│   └── index.html                 # Monochromatic aerospace dashboard
├── tests/                         # Automated 10-Point Verification Harness
│   └── verify_all.py              # End-to-end test runner
└── README.md                      # Institutional specification
```

---

## 7. Verification & Testing

Run the automated 10-point verification suite:

```bash
python tests/verify_all.py
```

### Output:
```
=================================================================
  AETHERGUARD PROTOCOL: 10-POINT DEFENSE VERIFICATION SUITE
=================================================================
  [PASS] Test 1: Core Realm State & Circuit Breakers Verified
  [PASS] Test 2: Byzantine Multi-Sig & Quorum Engine Verified
  [PASS] Test 3: Gno.land Native Render(path) Web Router Verified
  [PASS] Test 4: Gno Unit Test Suite Coverage Verified
  [PASS] Test 5: Gno Module Namespace Initialized
  [PASS] Test 6: Mathematical Anomaly Detection & Velocity Bounds Verified
  [PASS] Test 7: Model Context Protocol (MCP) Tools Verified
  [PASS] Test 8: Autonomous On-Chain Mitigation Loop Verified
  [PASS] Test 9: Titanium Web Cockpit & Adena Integration Verified
  [PASS] Test 10: Strict Hackathon Rule Compliance (Zero 'Gno' Prefix) Confirmed
=================================================================
  ALL 10/10 VERIFICATION TESTS PASSED SUCCESSFULLY! (100% COVERAGE)
=================================================================
```

---

## 8. Deployment to Gno.land Testnet

Deploy the realm using `gnokey`:

```bash
# 1. Initialize local keypair
gnokey add sentinel-deployer

# 2. Fund via official faucet (faucet.gno.land)

# 3. Broadcast realm deployment
gnokey maketx addpkg \
  -pkgpath "gno.land/r/amazing200guy1/aetherguard" \
  -pkgdir ./realm \
  -gas-fee 5000ugnot \
  -gas-wanted 5000000 \
  -chainid "portal-loop" \
  -remote "https://rpc.testnet.gno.land" \
  sentinel-deployer
```

---

## 9. Hackathon Compliance Statement

- **Strict Naming Compliance:** The project is named **AetherGuard**, strictly respecting Gno.land's trademark rule prohibiting the "Gno" prefix.
- **Genuine Gno Component:** Features 4 comprehensive Gno files (`.gno`) implementing a stateful realm, multi-sig governance, and native `Render(path)` routing.
- **Public & Open Source:** Released under the permissive MIT License.
