export interface MembershipResult {
  /** Uses needed to break even (round up to whole number) */
  breakevenUses: number;
  /** Net monthly/annual saving given the actual usage */
  netSaving: number;
  /** True if usage exceeds break-even */
  isWorthIt: boolean;
  /** Annual fee equivalent */
  annualFeeEquivalent: number;
}

/**
 * Calculate when a membership program (DashPass, Costco, Uber One, etc.) pays for itself.
 * Works for monthly or annual fees — just keep units consistent.
 */
export function computeMembership(
  fee: number,
  savingPerUse: number,
  expectedUses: number,
  feeIsMonthly: boolean = true
): MembershipResult {
  if (fee <= 0 || savingPerUse <= 0) {
    return {
      breakevenUses: 0,
      netSaving: 0,
      isWorthIt: false,
      annualFeeEquivalent: 0,
    };
  }
  const breakevenUses = Math.ceil(fee / savingPerUse);
  const netSaving = expectedUses * savingPerUse - fee;
  const annualFeeEquivalent = feeIsMonthly ? fee * 12 : fee;
  return {
    breakevenUses,
    netSaving,
    isWorthIt: expectedUses >= breakevenUses,
    annualFeeEquivalent,
  };
}
