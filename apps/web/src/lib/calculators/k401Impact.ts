export interface K401ImpactInputs {
  /** Gross monthly income (pre-tax) */
  monthlyGross: number;
  /** Contribution rate as percent of gross (e.g. 6 for 6%) */
  contributionPct: number;
  /** Marginal income tax rate as percent (federal + state combined) */
  marginalRate: number;
  /** Employer match rate as percent (e.g. 50 for "50% match"). 0 if none. */
  matchRate: number;
  /** Cap of employer match as percent of salary (e.g. 6 means match up to 6% contribution) */
  matchCap: number;
}

export interface K401ImpactResult {
  /** Your monthly contribution */
  monthlyContribution: number;
  /** Monthly income-tax savings from going pre-tax */
  monthlyTaxSaved: number;
  /** Net paycheck cost (contribution − tax saved) */
  netPaycheckCost: number;
  /** Monthly employer match captured */
  employerMatch: number;
  /** Total monthly into the 401(k) (your contribution + employer match) */
  totalIntoAccount: number;
  /** True if your contribution is above the match cap (you're not maxing the free money) */
  underMatchCap: boolean;
}

/**
 * 401(k) paycheck-impact math:
 *   contribution    = gross × contribution%
 *   tax saved       = contribution × marginal rate
 *   net cost        = contribution − tax saved
 *   employer match  = gross × min(contribution%, matchCap%) × matchRate%
 */
export function computeK401Impact(inputs: K401ImpactInputs): K401ImpactResult {
  const { monthlyGross, contributionPct, marginalRate, matchRate, matchCap } = inputs;
  if (monthlyGross <= 0 || contributionPct <= 0) {
    return {
      monthlyContribution: 0,
      monthlyTaxSaved: 0,
      netPaycheckCost: 0,
      employerMatch: 0,
      totalIntoAccount: 0,
      underMatchCap: false,
    };
  }

  const monthlyContribution = monthlyGross * (contributionPct / 100);
  const monthlyTaxSaved = monthlyContribution * (marginalRate / 100);
  const netPaycheckCost = monthlyContribution - monthlyTaxSaved;

  // Employer match: matched up to the cap. If user contributes less than cap, match scales linearly.
  const matchedContributionPct = Math.min(contributionPct, matchCap);
  const employerMatch =
    monthlyGross * (matchedContributionPct / 100) * (matchRate / 100);

  const totalIntoAccount = monthlyContribution + employerMatch;
  const underMatchCap = contributionPct < matchCap && matchCap > 0 && matchRate > 0;

  return {
    monthlyContribution,
    monthlyTaxSaved,
    netPaycheckCost,
    employerMatch,
    totalIntoAccount,
    underMatchCap,
  };
}
