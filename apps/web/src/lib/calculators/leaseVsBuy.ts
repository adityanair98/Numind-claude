export interface LeaseVsBuyResult {
  /** Total spent on lease over the term */
  leaseTotalCost: number;
  /** Total payments made if buying */
  buyTotalPayments: number;
  /** Net cost of buying (payments minus car's value at end) */
  buyNetCost: number;
  /** Difference between lease cost and buy net cost (positive = buying cheaper) */
  difference: number;
  /** Which option is cheaper */
  winner: "lease" | "buy" | "tie";
}

/**
 * Compare leasing vs buying a car over the same period.
 * Buying counts the car's residual value as cost offset.
 */
export function computeLeaseVsBuy(
  monthlyLease: number,
  leaseMonths: number,
  monthlyBuyPayment: number,
  buyMonths: number,
  residualValueAfterTerm: number
): LeaseVsBuyResult {
  const leaseTotalCost = monthlyLease * leaseMonths;
  const buyTotalPayments = monthlyBuyPayment * buyMonths;
  const buyNetCost = buyTotalPayments - residualValueAfterTerm;
  const difference = leaseTotalCost - buyNetCost;

  let winner: "lease" | "buy" | "tie";
  if (Math.abs(difference) < 100) winner = "tie";
  else if (difference > 0) winner = "buy";
  else winner = "lease";

  return {
    leaseTotalCost,
    buyTotalPayments,
    buyNetCost,
    difference: Math.abs(difference),
    winner,
  };
}
