export interface StateData {
  name: string;
  abbreviation: string;
  slug: string;
  incomeTaxType: "progressive" | "flat" | "none";
  /** Flat tax rate (for flat-tax states) */
  flatRate?: number;
  /** Effective average rate used for estimation (for progressive states) */
  effectiveRate?: number;
  /**
   * Average effective property tax rate (Tax Foundation 2024 per-state averages,
   * as decimal — e.g. 0.0061 = 0.61% of assessed value annually).
   */
  propertyTaxRate?: number;
  notes: string;
}

/**
 * Simplified state income tax data for 2025.
 * Progressive states use a single effective rate for estimation.
 * For a full paycheck calculator, you'd want the actual bracket tables per state.
 * Property tax rates come from the Tax Foundation's 2024 effective-rate-on-owner-occupied
 * housing report — used for the house-affordability calculator.
 */
export const states: StateData[] = [
  { name: "Alabama", abbreviation: "AL", slug: "alabama", incomeTaxType: "progressive", effectiveRate: 0.04, propertyTaxRate: 0.0040, notes: "Progressive rates from 2% to 5%." },
  { name: "Alaska", abbreviation: "AK", slug: "alaska", incomeTaxType: "none", propertyTaxRate: 0.0104, notes: "No state income tax." },
  { name: "Arizona", abbreviation: "AZ", slug: "arizona", incomeTaxType: "flat", flatRate: 0.025, propertyTaxRate: 0.0063, notes: "Flat 2.5% rate." },
  { name: "Arkansas", abbreviation: "AR", slug: "arkansas", incomeTaxType: "progressive", effectiveRate: 0.039, propertyTaxRate: 0.0064, notes: "Progressive rates from 2% to 3.9%." },
  { name: "California", abbreviation: "CA", slug: "california", incomeTaxType: "progressive", effectiveRate: 0.065, propertyTaxRate: 0.0075, notes: "Highest state income tax. Progressive rates from 1% to 13.3%." },
  { name: "Colorado", abbreviation: "CO", slug: "colorado", incomeTaxType: "flat", flatRate: 0.044, propertyTaxRate: 0.0055, notes: "Flat 4.4% rate." },
  { name: "Connecticut", abbreviation: "CT", slug: "connecticut", incomeTaxType: "progressive", effectiveRate: 0.055, propertyTaxRate: 0.0214, notes: "Progressive rates from 3% to 6.99%." },
  { name: "Delaware", abbreviation: "DE", slug: "delaware", incomeTaxType: "progressive", effectiveRate: 0.05, propertyTaxRate: 0.0059, notes: "Progressive rates from 2.2% to 6.6%." },
  { name: "District of Columbia", abbreviation: "DC", slug: "district-of-columbia", incomeTaxType: "progressive", effectiveRate: 0.065, propertyTaxRate: 0.0061, notes: "Progressive rates from 4% to 10.75%." },
  { name: "Florida", abbreviation: "FL", slug: "florida", incomeTaxType: "none", propertyTaxRate: 0.0091, notes: "No state income tax." },
  { name: "Georgia", abbreviation: "GA", slug: "georgia", incomeTaxType: "flat", flatRate: 0.0549, propertyTaxRate: 0.0092, notes: "Flat 5.49% rate." },
  { name: "Hawaii", abbreviation: "HI", slug: "hawaii", incomeTaxType: "progressive", effectiveRate: 0.065, propertyTaxRate: 0.0032, notes: "Progressive rates from 1.4% to 11%." },
  { name: "Idaho", abbreviation: "ID", slug: "idaho", incomeTaxType: "flat", flatRate: 0.058, propertyTaxRate: 0.0067, notes: "Flat 5.8% rate." },
  { name: "Illinois", abbreviation: "IL", slug: "illinois", incomeTaxType: "flat", flatRate: 0.0495, propertyTaxRate: 0.0227, notes: "Flat 4.95% rate." },
  { name: "Indiana", abbreviation: "IN", slug: "indiana", incomeTaxType: "flat", flatRate: 0.0305, propertyTaxRate: 0.0084, notes: "Flat 3.05% rate." },
  { name: "Iowa", abbreviation: "IA", slug: "iowa", incomeTaxType: "flat", flatRate: 0.038, propertyTaxRate: 0.0157, notes: "Flat 3.8% rate." },
  { name: "Kansas", abbreviation: "KS", slug: "kansas", incomeTaxType: "progressive", effectiveRate: 0.046, propertyTaxRate: 0.0143, notes: "Progressive rates from 3.1% to 5.7%." },
  { name: "Kentucky", abbreviation: "KY", slug: "kentucky", incomeTaxType: "flat", flatRate: 0.04, propertyTaxRate: 0.0083, notes: "Flat 4% rate." },
  { name: "Louisiana", abbreviation: "LA", slug: "louisiana", incomeTaxType: "flat", flatRate: 0.03, propertyTaxRate: 0.0056, notes: "Flat 3% rate." },
  { name: "Maine", abbreviation: "ME", slug: "maine", incomeTaxType: "progressive", effectiveRate: 0.058, propertyTaxRate: 0.0136, notes: "Progressive rates from 5.8% to 7.15%." },
  { name: "Maryland", abbreviation: "MD", slug: "maryland", incomeTaxType: "progressive", effectiveRate: 0.05, propertyTaxRate: 0.0107, notes: "Progressive rates from 2% to 5.75%." },
  { name: "Massachusetts", abbreviation: "MA", slug: "massachusetts", incomeTaxType: "flat", flatRate: 0.05, propertyTaxRate: 0.0123, notes: "Flat 5% rate (9% surtax on income over $1M)." },
  { name: "Michigan", abbreviation: "MI", slug: "michigan", incomeTaxType: "flat", flatRate: 0.0425, propertyTaxRate: 0.0154, notes: "Flat 4.25% rate." },
  { name: "Minnesota", abbreviation: "MN", slug: "minnesota", incomeTaxType: "progressive", effectiveRate: 0.062, propertyTaxRate: 0.0112, notes: "Progressive rates from 5.35% to 9.85%." },
  { name: "Mississippi", abbreviation: "MS", slug: "mississippi", incomeTaxType: "flat", flatRate: 0.047, propertyTaxRate: 0.0081, notes: "Flat 4.7% rate." },
  { name: "Missouri", abbreviation: "MO", slug: "missouri", incomeTaxType: "progressive", effectiveRate: 0.042, propertyTaxRate: 0.0098, notes: "Progressive rates up to 4.95%." },
  { name: "Montana", abbreviation: "MT", slug: "montana", incomeTaxType: "progressive", effectiveRate: 0.052, propertyTaxRate: 0.0084, notes: "Progressive rates from 4.7% to 5.9%." },
  { name: "Nebraska", abbreviation: "NE", slug: "nebraska", incomeTaxType: "progressive", effectiveRate: 0.052, propertyTaxRate: 0.0173, notes: "Progressive rates from 2.46% to 5.84%." },
  { name: "Nevada", abbreviation: "NV", slug: "nevada", incomeTaxType: "none", propertyTaxRate: 0.0059, notes: "No state income tax." },
  { name: "New Hampshire", abbreviation: "NH", slug: "new-hampshire", incomeTaxType: "none", propertyTaxRate: 0.0218, notes: "No state income tax on wages (interest/dividends tax repealed)." },
  { name: "New Jersey", abbreviation: "NJ", slug: "new-jersey", incomeTaxType: "progressive", effectiveRate: 0.055, propertyTaxRate: 0.0249, notes: "Progressive rates from 1.4% to 10.75%." },
  { name: "New Mexico", abbreviation: "NM", slug: "new-mexico", incomeTaxType: "progressive", effectiveRate: 0.042, propertyTaxRate: 0.0080, notes: "Progressive rates from 1.7% to 5.9%." },
  { name: "New York", abbreviation: "NY", slug: "new-york", incomeTaxType: "progressive", effectiveRate: 0.06, propertyTaxRate: 0.0173, notes: "Progressive rates from 4% to 10.9%. NYC residents pay additional 3.1-3.9%." },
  { name: "North Carolina", abbreviation: "NC", slug: "north-carolina", incomeTaxType: "flat", flatRate: 0.0425, propertyTaxRate: 0.0082, notes: "Flat 4.25% rate." },
  { name: "North Dakota", abbreviation: "ND", slug: "north-dakota", incomeTaxType: "progressive", effectiveRate: 0.018, propertyTaxRate: 0.0098, notes: "Very low rates from 0% to 2.5%." },
  { name: "Ohio", abbreviation: "OH", slug: "ohio", incomeTaxType: "progressive", effectiveRate: 0.032, propertyTaxRate: 0.0156, notes: "Progressive rates up to 3.5%. No tax on first $26,050." },
  { name: "Oklahoma", abbreviation: "OK", slug: "oklahoma", incomeTaxType: "progressive", effectiveRate: 0.04, propertyTaxRate: 0.0090, notes: "Progressive rates from 0.25% to 4.75%." },
  { name: "Oregon", abbreviation: "OR", slug: "oregon", incomeTaxType: "progressive", effectiveRate: 0.075, propertyTaxRate: 0.0093, notes: "Progressive rates from 4.75% to 9.9%. No sales tax." },
  { name: "Pennsylvania", abbreviation: "PA", slug: "pennsylvania", incomeTaxType: "flat", flatRate: 0.0307, propertyTaxRate: 0.0153, notes: "Flat 3.07% rate." },
  { name: "Rhode Island", abbreviation: "RI", slug: "rhode-island", incomeTaxType: "progressive", effectiveRate: 0.045, propertyTaxRate: 0.0163, notes: "Progressive rates from 3.75% to 5.99%." },
  { name: "South Carolina", abbreviation: "SC", slug: "south-carolina", incomeTaxType: "progressive", effectiveRate: 0.05, propertyTaxRate: 0.0057, notes: "Progressive rates from 0% to 6.3%." },
  { name: "South Dakota", abbreviation: "SD", slug: "south-dakota", incomeTaxType: "none", propertyTaxRate: 0.0124, notes: "No state income tax." },
  { name: "Tennessee", abbreviation: "TN", slug: "tennessee", incomeTaxType: "none", propertyTaxRate: 0.0071, notes: "No state income tax." },
  { name: "Texas", abbreviation: "TX", slug: "texas", incomeTaxType: "none", propertyTaxRate: 0.0190, notes: "No state income tax." },
  { name: "Utah", abbreviation: "UT", slug: "utah", incomeTaxType: "flat", flatRate: 0.0465, propertyTaxRate: 0.0060, notes: "Flat 4.65% rate." },
  { name: "Vermont", abbreviation: "VT", slug: "vermont", incomeTaxType: "progressive", effectiveRate: 0.055, propertyTaxRate: 0.0190, notes: "Progressive rates from 3.35% to 8.75%." },
  { name: "Virginia", abbreviation: "VA", slug: "virginia", incomeTaxType: "progressive", effectiveRate: 0.048, propertyTaxRate: 0.0082, notes: "Progressive rates from 2% to 5.75%." },
  { name: "Washington", abbreviation: "WA", slug: "washington", incomeTaxType: "none", propertyTaxRate: 0.0098, notes: "No state income tax." },
  { name: "West Virginia", abbreviation: "WV", slug: "west-virginia", incomeTaxType: "progressive", effectiveRate: 0.042, propertyTaxRate: 0.0058, notes: "Progressive rates from 2.36% to 5.12%." },
  { name: "Wisconsin", abbreviation: "WI", slug: "wisconsin", incomeTaxType: "progressive", effectiveRate: 0.053, propertyTaxRate: 0.0185, notes: "Progressive rates from 3.5% to 7.65%." },
  { name: "Wyoming", abbreviation: "WY", slug: "wyoming", incomeTaxType: "none", propertyTaxRate: 0.0061, notes: "No state income tax." },
];

export function getStateBySlug(slug: string): StateData | undefined {
  return states.find((s) => s.slug === slug);
}

/** Get effective state income tax rate for a state */
export function getStateTaxRate(state: StateData): number {
  if (state.incomeTaxType === "none") return 0;
  if (state.incomeTaxType === "flat") return state.flatRate ?? 0;
  return state.effectiveRate ?? 0;
}

/** Get effective property tax rate for a state (decimal, e.g. 0.0091 = 0.91%). */
export function getPropertyTaxRate(state: StateData): number {
  return state.propertyTaxRate ?? 0.011;
}
