export interface BNPLResult {
  /** Total cost of the BNPL plan as advertised (no late fees) */
  totalCost: number;
  /** Cost including one missed payment with $35 late fee */
  costWithLateFee: number;
  /** Surcharge percentage if late fee is applied */
  surchargePercent: number;
  /** Per-payment amount */
  paymentAmount: number;
}

/**
 * BNPL plan cost calculator. Standard plans: 4 payments, no interest if paid on time.
 * Late fee is industry-standard $35 (or 25% of payment, whichever is greater) for many BNPL services.
 */
export function computeBNPL(
  purchasePrice: number,
  numPayments: number = 4,
  lateFee: number = 35
): BNPLResult {
  if (purchasePrice <= 0 || numPayments <= 0) {
    return {
      totalCost: 0,
      costWithLateFee: 0,
      surchargePercent: 0,
      paymentAmount: 0,
    };
  }
  const paymentAmount = purchasePrice / numPayments;
  const totalCost = purchasePrice;
  const costWithLateFee = purchasePrice + lateFee;
  const surchargePercent = (lateFee / purchasePrice) * 100;
  return {
    totalCost,
    costWithLateFee,
    surchargePercent,
    paymentAmount,
  };
}

/** Sum stacked BNPL monthly burden — invisible debt across multiple plans. */
export function computeStackedBNPL(monthlyPayments: number[]): number {
  return monthlyPayments.reduce((sum, p) => sum + (isFinite(p) ? p : 0), 0);
}
