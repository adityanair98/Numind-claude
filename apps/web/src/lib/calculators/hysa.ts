export interface HysaInputs {
  /** Account balance (deposit) */
  balance: number;
  /** APY as percent (e.g. 4.5 for 4.5%) */
  apy: number;
  /** Big-bank savings APY to compare against (typically ~0.01) */
  bigBankApy: number;
}

export interface HysaResult {
  /** Annual interest earned at this APY */
  annualInterest: number;
  /** Monthly interest (annual / 12) — useful for visualizing growth pace */
  monthlyInterest: number;
  /** Annual interest at the comparison big-bank rate */
  bigBankAnnualInterest: number;
  /** Difference: extra annual interest the HYSA earns vs the big-bank account */
  annualGap: number;
  /** Years to double via Rule of 72 (informational) */
  yearsToDouble: number;
}

/**
 * High-yield savings math:
 *   annualInterest = balance × apy / 100
 *   yearsToDouble  = 72 / apy (Rule of 72)
 */
export function computeHysa(inputs: HysaInputs): HysaResult {
  const { balance, apy, bigBankApy } = inputs;
  if (balance <= 0 || apy < 0) {
    return {
      annualInterest: 0,
      monthlyInterest: 0,
      bigBankAnnualInterest: 0,
      annualGap: 0,
      yearsToDouble: 0,
    };
  }

  const annualInterest = (balance * apy) / 100;
  const monthlyInterest = annualInterest / 12;
  const bigBankAnnualInterest = (balance * bigBankApy) / 100;
  const annualGap = annualInterest - bigBankAnnualInterest;
  const yearsToDouble = apy > 0 ? 72 / apy : 0;

  return {
    annualInterest,
    monthlyInterest,
    bigBankAnnualInterest,
    annualGap,
    yearsToDouble,
  };
}
