/** 2025 Federal Income Tax Brackets (Single filer) */
export interface TaxBracket {
  min: number;
  max: number;
  rate: number;
}

export const federalBrackets2025Single: TaxBracket[] = [
  { min: 0, max: 11_925, rate: 0.10 },
  { min: 11_925, max: 48_475, rate: 0.12 },
  { min: 48_475, max: 103_350, rate: 0.22 },
  { min: 103_350, max: 197_300, rate: 0.24 },
  { min: 197_300, max: 250_525, rate: 0.32 },
  { min: 250_525, max: 626_350, rate: 0.35 },
  { min: 626_350, max: Infinity, rate: 0.37 },
];

export const federalBrackets2025MFJ: TaxBracket[] = [
  { min: 0, max: 23_850, rate: 0.10 },
  { min: 23_850, max: 96_950, rate: 0.12 },
  { min: 96_950, max: 206_700, rate: 0.22 },
  { min: 206_700, max: 394_600, rate: 0.24 },
  { min: 394_600, max: 501_050, rate: 0.32 },
  { min: 501_050, max: 751_600, rate: 0.35 },
  { min: 751_600, max: Infinity, rate: 0.37 },
];

/** 2025 Federal Income Tax Brackets (Head of Household) */
export const federalBrackets2025HoH: TaxBracket[] = [
  { min: 0, max: 17_000, rate: 0.10 },
  { min: 17_000, max: 64_850, rate: 0.12 },
  { min: 64_850, max: 103_350, rate: 0.22 },
  { min: 103_350, max: 197_300, rate: 0.24 },
  { min: 197_300, max: 250_500, rate: 0.32 },
  { min: 250_500, max: 626_350, rate: 0.35 },
  { min: 626_350, max: Infinity, rate: 0.37 },
];

/** Standard deduction for 2025 */
export const standardDeduction2025 = {
  single: 15_000,
  mfj: 30_000, // married filing jointly
  mfs: 15_000, // married filing separately
  hoh: 22_500, // head of household
};

export type FilingStatus = "single" | "mfj" | "mfs" | "hoh";

/** Compute progressive tax from brackets */
export function computeProgressiveTax(taxableIncome: number, brackets: TaxBracket[]): number {
  let tax = 0;
  for (const bracket of brackets) {
    if (taxableIncome <= bracket.min) break;
    const taxableInBracket = Math.min(taxableIncome, bracket.max) - bracket.min;
    tax += taxableInBracket * bracket.rate;
  }
  return tax;
}
