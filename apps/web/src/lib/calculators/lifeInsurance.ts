export interface LifeInsuranceResult {
  /** Simple 10× annual salary baseline */
  baseline10x: number;
  /** DIME-adjusted: salary × 10 + mortgage − savings */
  adjustedCoverage: number;
  /** Approximate annual premium estimate (rough $0.55-$1.00 per $1k of coverage) */
  estimatedAnnualPremium: number;
  /** Approximate monthly premium */
  estimatedMonthlyPremium: number;
}

/**
 * Life insurance coverage estimator using the 10× salary rule
 * and DIME method (Debt + Income + Mortgage + Education).
 *
 * Premium estimate uses a rough $0.65 per $1,000 of coverage annually
 * — typical for healthy 30-40 year olds with 20-year term policies.
 * Actual rates vary widely by age, health, gender, term length, etc.
 */
export function computeLifeInsurance(
  annualSalary: number,
  mortgageBalance: number = 0,
  currentSavings: number = 0,
  educationCosts: number = 0
): LifeInsuranceResult {
  if (annualSalary <= 0) {
    return {
      baseline10x: 0,
      adjustedCoverage: 0,
      estimatedAnnualPremium: 0,
      estimatedMonthlyPremium: 0,
    };
  }

  const baseline10x = annualSalary * 10;
  const adjustedCoverage = Math.max(
    0,
    baseline10x + mortgageBalance + educationCosts - currentSavings,
  );

  // Rough estimate: $0.65 per $1,000 coverage annually for healthy adults
  const estimatedAnnualPremium = (adjustedCoverage / 1000) * 0.65;
  const estimatedMonthlyPremium = estimatedAnnualPremium / 12;

  return {
    baseline10x,
    adjustedCoverage,
    estimatedAnnualPremium,
    estimatedMonthlyPremium,
  };
}
