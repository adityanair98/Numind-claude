export interface HouseAffordabilityInputs {
  /** Monthly gross income (pre-tax) */
  monthlyGross: number;
  /** Mortgage rate as percent (e.g. 6.5) */
  ratePercent: number;
  /** Down-payment percent (e.g. 10 for 10%) */
  downPercent: number;
  /** Annual property tax + homeowners insurance as percent of price (default ~1.5%) */
  taxInsAnnualPct: number;
}

export interface HouseAffordabilityResult {
  /** Max PITI per the 28% rule */
  maxPiti: number;
  /** Loan amount supported, given the rate factor and tax/insurance estimate */
  maxLoan: number;
  /** Maximum purchase price (loan + down) */
  maxPurchasePrice: number;
  /** Down-payment dollars on the max price */
  downPayment: number;
  /** Estimated monthly tax + insurance on the max price */
  monthlyTaxIns: number;
  /** Estimated monthly P&I on the max loan */
  monthlyPI: number;
  /** Mortgage rate factor used (per $1 of loan at the given rate, 30-yr amortization) */
  rateFactor: number;
}

/**
 * Standard amortization factor (P&I per $1 of loan) for a 30-year fixed mortgage.
 * Matches the Numind iOS lesson's mental-math rate-factor table.
 */
export function rateFactorFor30Year(ratePercent: number): number {
  const r = ratePercent / 100 / 12;
  const n = 360; // 30 years × 12
  if (r <= 0) return 1 / n;
  return (r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
}

/**
 * Computes the max home you can afford using the Fannie Mae 28% rule:
 *   max PITI = monthlyGross × 0.28
 *   max P&I  = max PITI − monthly tax/insurance
 *   max loan = max P&I ÷ rate factor
 *   max price = max loan ÷ (1 − downPercent)
 * Iterates once because monthly tax/ins is a function of the final price.
 */
export function computeHouseAffordability(
  inputs: HouseAffordabilityInputs
): HouseAffordabilityResult {
  const { monthlyGross, ratePercent, downPercent, taxInsAnnualPct } = inputs;
  if (monthlyGross <= 0 || ratePercent <= 0) {
    return {
      maxPiti: 0,
      maxLoan: 0,
      maxPurchasePrice: 0,
      downPayment: 0,
      monthlyTaxIns: 0,
      monthlyPI: 0,
      rateFactor: 0,
    };
  }

  const rateFactor = rateFactorFor30Year(ratePercent);
  const maxPiti = monthlyGross * 0.28;
  const downFraction = Math.min(Math.max(downPercent / 100, 0), 0.95);

  // Closed-form solve assuming tax+ins scales linearly with purchase price:
  //   piti = price × (1 − down) × rateFactor + price × (taxInsPct / 12)
  //   price = piti / ((1 − down) × rateFactor + taxInsPct/12)
  const taxInsPerDollar = taxInsAnnualPct / 100 / 12;
  const pitiPerDollarOfPrice =
    (1 - downFraction) * rateFactor + taxInsPerDollar;
  if (pitiPerDollarOfPrice <= 0) {
    return {
      maxPiti,
      maxLoan: 0,
      maxPurchasePrice: 0,
      downPayment: 0,
      monthlyTaxIns: 0,
      monthlyPI: 0,
      rateFactor,
    };
  }

  const maxPurchasePrice = maxPiti / pitiPerDollarOfPrice;
  const downPayment = maxPurchasePrice * downFraction;
  const maxLoan = maxPurchasePrice - downPayment;
  const monthlyPI = maxLoan * rateFactor;
  const monthlyTaxIns = maxPurchasePrice * taxInsPerDollar;

  return {
    maxPiti,
    maxLoan,
    maxPurchasePrice,
    downPayment,
    monthlyTaxIns,
    monthlyPI,
    rateFactor,
  };
}
