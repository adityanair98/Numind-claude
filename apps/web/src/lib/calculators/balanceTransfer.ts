export interface BalanceTransferInputs {
  /** Balance being transferred */
  balance: number;
  /** Old card APR as percent (e.g. 22 for 22%) */
  oldApr: number;
  /** Length of 0% promotional period in months (e.g. 18) */
  promoMonths: number;
  /** Transfer fee as percent of balance (e.g. 3 for 3%) */
  feePct: number;
}

export interface BalanceTransferResult {
  /** Dollar fee charged by the new card to accept the transfer */
  fee: number;
  /** Interest you'd have paid on the OLD card during the promo period */
  interestSaved: number;
  /** Net benefit: interest saved minus fee. Negative = fee outweighs savings. */
  netBenefit: number;
  /** Monthly payment needed to clear (balance + fee) before promo ends */
  requiredMonthly: number;
  /** Breakeven APR — old APR at which interest-saved = fee (worth-it threshold) */
  breakevenApr: number;
  /** Whether the transfer is worth it given current inputs */
  worthIt: boolean;
}

/**
 * Balance transfer math:
 *   fee            = balance × feePct%
 *   interest saved = balance × oldApr × promoMonths / 12
 *   net benefit    = interest saved − fee
 *   required mo.   = (balance + fee) / promoMonths
 *   breakeven APR  = feePct × 12 / promoMonths
 */
export function computeBalanceTransfer(
  inputs: BalanceTransferInputs
): BalanceTransferResult {
  const { balance, oldApr, promoMonths, feePct } = inputs;
  if (balance <= 0 || promoMonths <= 0) {
    return {
      fee: 0,
      interestSaved: 0,
      netBenefit: 0,
      requiredMonthly: 0,
      breakevenApr: 0,
      worthIt: false,
    };
  }

  const fee = (balance * feePct) / 100;
  const interestSaved = (balance * oldApr * promoMonths) / (100 * 12);
  const netBenefit = interestSaved - fee;
  const requiredMonthly = (balance + fee) / promoMonths;
  const breakevenApr = (feePct * 12) / promoMonths;
  const worthIt = netBenefit > 0;

  return {
    fee,
    interestSaved,
    netBenefit,
    requiredMonthly,
    breakevenApr,
    worthIt,
  };
}
