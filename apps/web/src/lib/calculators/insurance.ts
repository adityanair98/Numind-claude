export interface InsuranceResult {
  annualPremium: number;
  worstCaseCost: number;
  absoluteMax: number;
}

export interface PlanComparisonResult {
  planA: InsuranceResult;
  planB: InsuranceResult;
  /** Positive means Plan A costs more in worst case */
  worstCaseDifference: number;
  /** Positive means Plan A costs more at absolute max */
  absoluteMaxDifference: number;
}

export function computePlanCost(
  monthlyPremium: number,
  deductible: number,
  oopMax: number
): InsuranceResult {
  const annualPremium = monthlyPremium * 12;
  const worstCaseCost = annualPremium + deductible;
  const absoluteMax = annualPremium + oopMax;

  return { annualPremium, worstCaseCost, absoluteMax };
}

export function comparePlans(
  premiumA: number,
  deductibleA: number,
  oopMaxA: number,
  premiumB: number,
  deductibleB: number,
  oopMaxB: number
): PlanComparisonResult {
  const planA = computePlanCost(premiumA, deductibleA, oopMaxA);
  const planB = computePlanCost(premiumB, deductibleB, oopMaxB);

  return {
    planA,
    planB,
    worstCaseDifference: planA.worstCaseCost - planB.worstCaseCost,
    absoluteMaxDifference: planA.absoluteMax - planB.absoluteMax,
  };
}
