import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { houseAffordabilityShortcut } from "@/lib/content/shortcuts";
import { houseAffordabilityFAQs } from "@/lib/content/faqs";
import { HouseAffordabilityCalculatorWidget } from "../HouseAffordabilityCalculatorWidget";
import {
  states,
  getStateBySlug,
  getPropertyTaxRate,
} from "@/data/states";
import { computeHouseAffordability } from "@/lib/calculators/houseAffordability";

export async function generateStaticParams() {
  return states.map((s) => ({ state: s.slug }));
}

type Props = {
  params: Promise<{ state: string }>;
};

function fmt(n: number): string {
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

/**
 * Per-state taxes + insurance annual percent.
 * Property tax: from Tax Foundation per-state data.
 * Insurance: ~0.5% nationwide baseline (homeowners insurance on the home's value).
 * Sum is what the calculator's "Taxes + Insurance (annual)" field defaults to.
 */
function stateTaxInsAnnualPct(state: ReturnType<typeof getStateBySlug>): number {
  if (!state) return 1.5;
  const propertyTax = getPropertyTaxRate(state) * 100; // → percent
  const insurance = 0.5;
  return Math.round((propertyTax + insurance) * 10) / 10;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { state } = await params;
  const stateData = getStateBySlug(state);
  if (!stateData) return {};

  const title = `How Much House Can I Afford in ${stateData.name}? Free Calculator | Numind`;
  const description = `Estimate your max home purchase price in ${stateData.name}. Includes ${stateData.abbreviation} property tax (~${(getPropertyTaxRate(stateData) * 100).toFixed(2)}%), homeowners insurance, the 28% rule, and PMI. Free, no sign-up.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/house-affordability-calculator/${state}`,
    },
    openGraph: {
      title,
      description,
      url: `https://numind.app/tools/house-affordability-calculator/${state}`,
      type: "website",
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getStateFAQs(
  stateData: NonNullable<ReturnType<typeof getStateBySlug>>,
) {
  const ptRate = getPropertyTaxRate(stateData);
  const taxInsPct = stateTaxInsAnnualPct(stateData);

  // Two reference scenarios at common income levels in this state.
  const refLow = computeHouseAffordability({
    monthlyGross: 6000,
    ratePercent: 6.5,
    downPercent: 10,
    taxInsAnnualPct: taxInsPct,
  });
  const refHigh = computeHouseAffordability({
    monthlyGross: 10000,
    ratePercent: 6.5,
    downPercent: 20,
    taxInsAnnualPct: taxInsPct,
  });

  return [
    {
      question: `What's the average property tax rate in ${stateData.name}?`,
      answer: `${stateData.name}'s effective property tax rate on owner-occupied homes is about ${(ptRate * 100).toFixed(2)}% per year (Tax Foundation 2024). On a ${fmt(400000)} home, that's roughly ${fmt(400000 * ptRate)} in annual property tax.`,
    },
    {
      question: `How much house can I afford on a $72,000 salary in ${stateData.name}?`,
      answer: `On $72,000/year ($6,000/month gross) at a 6.5% mortgage rate with 10% down — using ${stateData.name}'s typical ${(ptRate * 100).toFixed(2)}% property tax plus ~0.5% insurance — you can support a home around ${fmt(refLow.maxPurchasePrice)}. Total monthly housing cost would be ~${fmt(refLow.monthlyPI + refLow.monthlyTaxIns)} (Fannie Mae 28% rule).`,
    },
    {
      question: `How much house can I afford on a $120,000 salary in ${stateData.name}?`,
      answer: `On $120,000/year ($10,000/month gross) at a 6.5% mortgage rate with 20% down in ${stateData.name}, you can support a home around ${fmt(refHigh.maxPurchasePrice)} (28% rule, including ${stateData.abbreviation} property taxes and insurance). At 20% down you skip PMI entirely.`,
    },
    {
      question: `Do I need PMI when buying a home in ${stateData.name}?`,
      answer: `Yes — federal lender rules apply nationwide. If your down payment is under 20% on a conventional loan, expect to pay PMI (typically 0.3-1.5% of the loan annually) until you reach 20% equity. State doesn't change this; lender, credit score, and loan type do.`,
    },
    ...houseAffordabilityFAQs.slice(0, 2),
  ];
}

export default async function StateHouseAffordabilityPage({ params }: Props) {
  const { state } = await params;
  const stateData = getStateBySlug(state);

  if (!stateData) {
    notFound();
  }

  const stateFAQs = getStateFAQs(stateData);
  const ptRate = getPropertyTaxRate(stateData);
  const taxInsPct = stateTaxInsAnnualPct(stateData);

  return (
    <CalculatorShell
      slug={`house-affordability-calculator/${stateData.slug}`}
      name={`How Much House Can I Afford in ${stateData.name}?`}
      tagline={`Max purchase price for ${stateData.abbreviation} buyers — includes state-specific property tax (~${(ptRate * 100).toFixed(2)}%) and insurance`}
      calculator={
        <HouseAffordabilityCalculatorWidget
          defaultTaxInsAnnualPct={taxInsPct.toString()}
        />
      }
      shortcut={houseAffordabilityShortcut}
      faqs={stateFAQs}
      relatedSlugs={["rent-calculator", "loan-calculator", "paycheck-calculator"]}
    >
      {/* State-specific content block — SEO + AIO */}
      <section className="mb-section">
        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          Why {stateData.name} Property Tax Matters Here
        </h2>
        <p className="text-brand-muted leading-relaxed mb-4">
          {stateData.name}&apos;s effective property tax rate is about{" "}
          <strong className="text-brand-navy">{(ptRate * 100).toFixed(2)}%</strong>{" "}
          per year on owner-occupied housing (Tax Foundation 2024). That feeds
          directly into the PITI math: a {stateData.abbreviation} home costs
          you ~{(ptRate * 100).toFixed(2)}% of its purchase price in annual
          property tax, plus ~0.5% for homeowners insurance — so the &ldquo;Taxes
          + Insurance&rdquo; default on the calculator is set to{" "}
          {taxInsPct.toFixed(1)}%.
        </p>
        <div className="rounded-card bg-brand-bg p-card text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-brand-muted">Effective property tax</span>
            <span className="font-medium text-brand-navy">
              {(ptRate * 100).toFixed(2)}% / year
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Homeowners insurance (typical)</span>
            <span className="font-medium text-brand-navy">~0.50% / year</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">
              Taxes + insurance, combined (default)
            </span>
            <span className="font-medium text-brand-navy">
              {taxInsPct.toFixed(1)}% / year
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">
              On a {fmt(400000)} home, annual tax + insurance
            </span>
            <span className="font-medium text-brand-navy">
              {fmt(400000 * (ptRate + 0.005))}
            </span>
          </div>
        </div>
        <p className="mt-3 text-sm text-brand-muted leading-relaxed">
          {stateData.propertyTaxRate &&
          stateData.propertyTaxRate > 0.018
            ? `${stateData.name} is in the higher tier nationally for property tax. That eats into how much house your income can support — even on the same income and rate, you'll afford less house here than in a low-tax state.`
            : stateData.propertyTaxRate && stateData.propertyTaxRate < 0.007
              ? `${stateData.name} is among the lower property-tax states. More of your PITI budget can go toward principal and interest — so the same income supports a noticeably larger home than in a high-tax state.`
              : `${stateData.name}'s property tax falls in the middle of the national range.`}
        </p>
      </section>
    </CalculatorShell>
  );
}
