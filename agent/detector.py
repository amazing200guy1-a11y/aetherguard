"""
AetherGuard Sentinel: Autonomous Anomaly & Velocity Detector
Mathematical evaluation of Gno.land realm outflow transactions.
"""

from typing import List, Dict, Any, Tuple
import math

class VelocityRiskDetector:
    """
    Evaluates real-time withdrawal velocity and transaction patterns
    to detect smart contract exploits, flash drains, and re-entrancy anomalies.
    """

    def __init__(self, max_velocity_bps: int = 1000, epoch_blocks: int = 100):
        # 1000 bps = 10.00%
        self.max_velocity_bps = max_velocity_bps
        self.epoch_blocks = epoch_blocks

    def calculate_outflow_velocity(self, total_balance: int, epoch_outflow: int, incoming_tx_amount: int) -> float:
        """
        Calculates projected velocity ratio (outflow / total balance).
        """
        if total_balance <= 0:
            return 1.0  # Infinite risk if balance depleted
        projected_outflow = epoch_outflow + incoming_tx_amount
        return projected_outflow / float(total_balance)

    def analyze_transaction_risk(
        self,
        total_balance: int,
        epoch_outflow: int,
        tx_amount: int,
        block_height: int,
        recipient: str,
        recent_txs: List[Dict[str, Any]]
    ) -> Tuple[float, str, str]:
        """
        Calculates composite risk score R ∈ [0.0, 1.0].
        Returns (risk_score, severity, rationale).
        """
        max_allowed_ratio = self.max_velocity_bps / 10000.0
        projected_ratio = self.calculate_outflow_velocity(total_balance, epoch_outflow, tx_amount)

        # Velocity Breach Metric
        velocity_score = min(1.0, projected_ratio / max_allowed_ratio) if max_allowed_ratio > 0 else 1.0

        # Temporal Clustering Metric (transactions within last 5 blocks)
        recent_burst_count = sum(
            1 for tx in recent_txs if abs(block_height - tx.get("block_height", 0)) <= 5
        )
        burst_score = min(1.0, recent_burst_count / 5.0)

        # Concentration Metric (single recipient dominance)
        recipient_total = sum(
            tx.get("amount", 0) for tx in recent_txs if tx.get("recipient") == recipient
        ) + tx_amount
        projected_total_outflow = epoch_outflow + tx_amount
        concentration_score = (
            (recipient_total / projected_total_outflow) if projected_total_outflow > 0 else 0.0
        )

        # Composite Mathematical Risk Formula:
        # R = 0.50 * Velocity + 0.30 * Burst + 0.20 * Concentration
        composite_risk = (0.50 * velocity_score) + (0.30 * burst_score) + (0.20 * concentration_score)
        composite_risk = round(min(1.0, max(0.0, composite_risk)), 4)

        # Severity Classification
        if projected_ratio > max_allowed_ratio or composite_risk >= 0.85:
            severity = "CRITICAL"
            rationale = (
                f"EXPLOIT_PATTERN_DETECTED: Projected outflow velocity {projected_ratio*100:.2f}% "
                f"exceeds protocol cap {max_allowed_ratio*100:.2f}%. Burst: {recent_burst_count} txs."
            )
        elif composite_risk >= 0.50:
            severity = "MEDIUM"
            rationale = (
                f"ELEVATED_VELOCITY: Projected outflow {projected_ratio*100:.2f}% approaching threshold. "
                f"Recipient concentration {concentration_score*100:.1f}%."
            )
        else:
            severity = "LOW"
            rationale = "NORMAL_TRANSACTION: Outflow velocity and distribution within safe bounds."

        return composite_risk, severity, rationale
