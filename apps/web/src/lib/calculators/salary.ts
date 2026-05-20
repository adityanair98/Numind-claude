/** Standard work hours per year: 40 hours/week x 52 weeks */
const HOURS_PER_YEAR = 2_080;
const WEEKS_PER_YEAR = 52;
const BIWEEKLY_PERIODS = 26;
const MONTHS_PER_YEAR = 12;

export type PayPeriod = "hourly" | "weekly" | "biweekly" | "monthly" | "annual";

export interface SalaryConversion {
  hourly: number;
  weekly: number;
  biweekly: number;
  monthly: number;
  annual: number;
}

/**
 * Converts any pay amount + period into all equivalent periods.
 * Uses the 2,080-hour standard (40 hrs/wk x 52 wks).
 */
export function convertSalary(
  amount: number,
  period: PayPeriod,
  hoursPerWeek = 40
): SalaryConversion {
  const hoursPerYear = hoursPerWeek * WEEKS_PER_YEAR;

  // First, normalize to annual
  let annual: number;
  switch (period) {
    case "hourly":
      annual = amount * hoursPerYear;
      break;
    case "weekly":
      annual = amount * WEEKS_PER_YEAR;
      break;
    case "biweekly":
      annual = amount * BIWEEKLY_PERIODS;
      break;
    case "monthly":
      annual = amount * MONTHS_PER_YEAR;
      break;
    case "annual":
      annual = amount;
      break;
  }

  return {
    hourly: annual / hoursPerYear,
    weekly: annual / WEEKS_PER_YEAR,
    biweekly: annual / BIWEEKLY_PERIODS,
    monthly: annual / MONTHS_PER_YEAR,
    annual,
  };
}

/**
 * Quick after-tax estimate using a flat effective rate.
 * Used for salary pages — not precise, but useful context.
 */
export function estimateAfterTax(annual: number, effectiveRate = 0.25): number {
  return annual * (1 - effectiveRate);
}
