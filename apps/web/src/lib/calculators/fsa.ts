export interface FSAResult {
  /** Tax savings from the FSA election */
  taxSaving: number;
  /** Net financial result (tax saving minus any forfeited unspent funds) */
  netResult: number;
  /** Minimum spending to break even at this election + tax rate */
  breakevenSpend: number;
  /** Amount unspent / forfeited (0 if you spend it all) */
  forfeitedAmount: number;
  /** True if you come out ahead at the projected spend */
  isWorthIt: boolean;
}

/**
 * Calculate the math behind FSA "use it or lose it" elections.
 *
 * The trick: tax savings = election × tax rate. But unspent funds
 * disappear at year-end (some plans allow $640 rollover or 2.5 month
 * grace, but for safety assume full forfeit).
 *
 * Break-even: you must spend at least (1 − tax rate) of your election.
 * In a 25% bracket, you need to use at least 75% of what you elect.
 */
export function computeFSA(
  electionAmount: number,
  taxRatePercent: number,
  projectedSpend: number,
  allowedRollover: number = 0
): FSAResult {
  if (electionAmount <= 0 || taxRatePercent < 0 || taxRatePercent >= 100) {
    return {
      taxSaving: 0,
      netResult: 0,
      breakevenSpend: 0,
      forfeitedAmount: 0,
      isWorthIt: false,
    };
  }

  const taxSaving = electionAmount * (taxRatePercent / 100);
  const breakevenSpend = electionAmount * (1 - taxRatePercent / 100);

  // If you can roll some over, your effective forfeit is less
  const unspent = Math.max(0, electionAmount - projectedSpend);
  const forfeitedAmount = Math.max(0, unspent - allowedRollover);
  const netResult = taxSaving - forfeitedAmount;

  return {
    taxSaving,
    netResult,
    breakevenSpend,
    forfeitedAmount,
    isWorthIt: netResult > 0,
  };
}
