import {
  computeProgressiveTax,
  federalBrackets2025Single,
  federalBrackets2025MFJ,
  federalBrackets2025HoH,
  standardDeduction2025,
  type FilingStatus,
  type TaxBracket,
} from "@/data/tax-brackets";
import { getStateTaxRate, type StateData } from "@/data/states";

/** Social Security wage base for 2025 */
const SS_WAGE_BASE = 168_600;
const SS_RATE = 0.062;
const MEDICARE_RATE = 0.0145;
const ADDITIONAL_MEDICARE_THRESHOLD = 200_000;
const ADDITIONAL_MEDICARE_RATE = 0.009;

export type PayFrequency = "weekly" | "biweekly" | "semimonthly" | "monthly";

export interface PaycheckResult {
  grossAnnual: number;
  federalTax: number;
  stateTax: number;
  socialSecurity: number;
  medicare: number;
  totalDeductions: number;
  preTaxDeductions: number;
  netAnnual: number;
  netPerPeriod: number;
  effectiveTaxRate: number;
  periods: number;
}

const periodsPerYear: Record<PayFrequency, number> = {
  weekly: 52,
  biweekly: 26,
  semimonthly: 24,
  monthly: 12,
};

function getBrackets(filing: FilingStatus): TaxBracket[] {
  switch (filing) {
    case "mfj":
      return federalBrackets2025MFJ;
    case "hoh":
      return federalBrackets2025HoH;
    case "single":
    case "mfs":
    default:
      return federalBrackets2025Single;
  }
}

function getStandardDeduction(filing: FilingStatus): number {
  return standardDeduction2025[filing];
}

export function computePaycheck(
  grossAnnual: number,
  filing: FilingStatus,
  state: StateData | null,
  frequency: PayFrequency,
  preTax401kPercent = 0,
): PaycheckResult {
  const periods = periodsPerYear[frequency];

  // Pre-tax deductions (401k)
  const preTaxDeductions = grossAnnual * (preTax401kPercent / 100);
  const adjustedGross = grossAnnual - preTaxDeductions;

  // Federal income tax
  const standardDeduction = getStandardDeduction(filing);
  const taxableIncome = Math.max(0, adjustedGross - standardDeduction);
  const federalTax = computeProgressiveTax(taxableIncome, getBrackets(filing));

  // State income tax (simplified: effective rate on adjusted gross)
  const stateTaxRate = state ? getStateTaxRate(state) : 0;
  const stateTax = adjustedGross * stateTaxRate;

  // FICA — Social Security
  const ssWages = Math.min(grossAnnual, SS_WAGE_BASE);
  const socialSecurity = ssWages * SS_RATE;

  // FICA — Medicare (includes additional Medicare tax)
  let medicare = grossAnnual * MEDICARE_RATE;
  if (grossAnnual > ADDITIONAL_MEDICARE_THRESHOLD) {
    medicare += (grossAnnual - ADDITIONAL_MEDICARE_THRESHOLD) * ADDITIONAL_MEDICARE_RATE;
  }

  const totalDeductions = federalTax + stateTax + socialSecurity + medicare + preTaxDeductions;
  const netAnnual = grossAnnual - totalDeductions;
  const netPerPeriod = netAnnual / periods;

  const effectiveTaxRate = grossAnnual > 0
    ? ((federalTax + stateTax + socialSecurity + medicare) / grossAnnual) * 100
    : 0;

  return {
    grossAnnual,
    federalTax,
    stateTax,
    socialSecurity,
    medicare,
    totalDeductions,
    preTaxDeductions,
    netAnnual,
    netPerPeriod,
    effectiveTaxRate,
    periods,
  };
}
