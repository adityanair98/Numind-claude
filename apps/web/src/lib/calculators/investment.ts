export interface InvestmentResult {
  finalBalance: number;
  totalContributed: number;
  totalInterest: number;
  /** Years to double (Rule of 72) */
  yearsToDouble: number;
}

/**
 * Compound interest with monthly contributions.
 * A = P(1 + r/n)^(nt) + PMT × [((1 + r/n)^(nt) − 1) / (r/n)]
 */
export function computeInvestment(
  principal: number,
  monthlyContribution: number,
  annualRate: number,
  years: number
): InvestmentResult {
  const n = 12; // monthly compounding
  const r = annualRate / 100;
  const rn = r / n;
  const nt = n * years;

  let finalBalance: number;
  if (r === 0) {
    finalBalance = principal + monthlyContribution * nt;
  } else {
    const compoundFactor = Math.pow(1 + rn, nt);
    const principalGrowth = principal * compoundFactor;
    const contributionGrowth = monthlyContribution * ((compoundFactor - 1) / rn);
    finalBalance = principalGrowth + contributionGrowth;
  }

  const totalContributed = principal + monthlyContribution * 12 * years;
  const totalInterest = finalBalance - totalContributed;
  const yearsToDouble = r > 0 ? 72 / (r * 100) : Infinity;

  return {
    finalBalance,
    totalContributed,
    totalInterest,
    yearsToDouble,
  };
}
