/** The 28% rule: housing costs should not exceed 28% of gross monthly income. */
const AFFORDABILITY_RATE = 0.28;

export interface RentResult {
  /** Maximum monthly rent under the 28% rule */
  maxRent: number;
  /** Monthly gross income */
  monthlyGross: number;
  /** Annual gross income */
  annualGross: number;
  /** Percent of income going to rent if custom rent is provided */
  rentToIncomePercent?: number;
  /** Debt-to-income ratio if debt is provided */
  dtiPercent?: number;
}

/**
 * Computes rent affordability using the 28% rule.
 *
 * @param annualSalary Gross annual salary
 * @param monthlyDebt Optional total monthly debt payments (for DTI)
 * @param customRent Optional rent to check affordability against
 */
export function computeRentAffordability(
  annualSalary: number,
  monthlyDebt = 0,
  customRent?: number
): RentResult {
  const monthlyGross = annualSalary / 12;
  const maxRent = monthlyGross * AFFORDABILITY_RATE;

  const result: RentResult = {
    maxRent,
    monthlyGross,
    annualGross: annualSalary,
  };

  if (customRent !== undefined && monthlyGross > 0) {
    result.rentToIncomePercent = (customRent / monthlyGross) * 100;
  }

  if (monthlyDebt > 0 && monthlyGross > 0) {
    const totalMonthlyObligations = (customRent ?? maxRent) + monthlyDebt;
    result.dtiPercent = (totalMonthlyObligations / monthlyGross) * 100;
  }

  return result;
}
