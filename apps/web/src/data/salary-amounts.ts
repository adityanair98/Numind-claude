export interface SalaryAmountData {
  slug: string;
  /** The numeric amount */
  amount: number;
  /** "hourly" or "annual" */
  type: "hourly" | "annual";
  /** Display label, e.g. "$25 an Hour" or "$50,000 a Year" */
  label: string;
  /** SEO target query */
  query: string;
}

function fmtAmount(n: number): string {
  return n.toLocaleString("en-US");
}

const hourlyRates = [
  10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 27, 28, 30,
  32, 35, 40, 45, 50,
];

const annualSalaries = [
  25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000,
  80000, 85000, 90000, 100000, 120000, 150000,
];

export const salaryAmounts: SalaryAmountData[] = [
  ...hourlyRates.map((rate) => ({
    slug: `${rate}-per-hour`,
    amount: rate,
    type: "hourly" as const,
    label: `$${rate} an Hour`,
    query: `what is $${rate} an hour annually`,
  })),
  ...annualSalaries.map((salary) => ({
    slug: `${salary}-annual`,
    amount: salary,
    type: "annual" as const,
    label: `$${fmtAmount(salary)} a Year`,
    query: `what is ${fmtAmount(salary)} a year hourly`,
  })),
];

export function getSalaryAmountBySlug(slug: string): SalaryAmountData | undefined {
  return salaryAmounts.find((s) => s.slug === slug);
}
