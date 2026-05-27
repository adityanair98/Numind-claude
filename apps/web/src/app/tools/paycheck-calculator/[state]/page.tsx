import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { paycheckShortcut } from "@/lib/content/shortcuts";
import { paycheckFAQs } from "@/lib/content/faqs";
import { PaycheckCalculatorWidget } from "../PaycheckCalculatorWidget";
import { states, getStateBySlug, getStateTaxRate } from "@/data/states";

export async function generateStaticParams() {
  return states.map((s) => ({ state: s.slug }));
}

type Props = {
  params: Promise<{ state: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { state } = await params;
  const stateData = getStateBySlug(state);
  if (!stateData) return {};

  const title = `${stateData.name} Paycheck Calculator 2025 — Take-Home Pay After Taxes`;
  const description = `Calculate your take-home pay in ${stateData.name}. ${stateData.notes} Includes federal tax, ${stateData.abbreviation} state tax, Social Security, and Medicare. Free, no sign-up.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/paycheck-calculator/${state}`,
    },
    openGraph: { title, description, url: `https://numind.app/tools/paycheck-calculator/${state}`, type: "website" },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getTaxSummary(stateData: NonNullable<ReturnType<typeof getStateBySlug>>) {
  const rate = getStateTaxRate(stateData);
  if (stateData.incomeTaxType === "none") {
    return `${stateData.name} has no state income tax, meaning you keep more of your paycheck compared to most states. You still pay federal income tax, Social Security (6.2%), and Medicare (1.45%).`;
  }
  if (stateData.incomeTaxType === "flat") {
    return `${stateData.name} has a flat ${(rate * 100).toFixed(2)}% state income tax. On top of that, you pay federal income tax, Social Security (6.2%), and Medicare (1.45%).`;
  }
  return `${stateData.name} has progressive state income tax with an effective rate around ${(rate * 100).toFixed(1)}%. ${stateData.notes} On top of state tax, you pay federal income tax, Social Security (6.2%), and Medicare (1.45%).`;
}

function getStateFAQs(stateData: NonNullable<ReturnType<typeof getStateBySlug>>) {
  const rate = getStateTaxRate(stateData);
  const noTax = stateData.incomeTaxType === "none";

  return [
    {
      question: `What is the state income tax rate in ${stateData.name}?`,
      answer: noTax
        ? `${stateData.name} does not have a state income tax on wages. ${stateData.notes}`
        : `${stateData.notes} The effective rate is approximately ${(rate * 100).toFixed(1)}% for typical earners.`,
    },
    {
      question: `How much is a $75,000 salary after taxes in ${stateData.name}?`,
      answer: noTax
        ? `On a $75,000 salary in ${stateData.name}, you won't pay state income tax. After federal tax (~12% effective) and FICA (~7.65%), your take-home is roughly $58,000-$60,000 depending on filing status and deductions.`
        : `On a $75,000 salary in ${stateData.name}, you'll pay approximately ${(rate * 100).toFixed(1)}% in state tax, plus federal tax (~12% effective) and FICA (~7.65%). Use the calculator above for your exact take-home pay.`,
    },
    {
      question: `Does ${stateData.name} have any local income taxes?`,
      answer: ["new-york", "ohio", "pennsylvania", "maryland", "indiana", "michigan", "kentucky"].includes(stateData.slug)
        ? `Yes, some cities and counties in ${stateData.name} impose local income taxes. This calculator covers state-level taxes — check your local municipality for additional withholding.`
        : `Most localities in ${stateData.name} do not impose a separate local income tax. This calculator accounts for federal and state-level taxes.`,
    },
    ...paycheckFAQs.slice(0, 2),
  ];
}

export default async function StatePaycheckPage({ params }: Props) {
  const { state } = await params;
  const stateData = getStateBySlug(state);

  if (!stateData) {
    notFound();
  }

  const stateFAQs = getStateFAQs(stateData);

  return (
    <CalculatorShell
      slug={`paycheck-calculator/${stateData.slug}`}
      name={`${stateData.name} Paycheck Calculator`}
      tagline={`Calculate your ${stateData.abbreviation} take-home pay after federal, state, and FICA taxes`}
      calculator={<PaycheckCalculatorWidget defaultState={stateData.slug} />}
      shortcut={paycheckShortcut}
      faqs={stateFAQs}
      relatedSlugs={["salary-calculator", "rent-calculator", "loan-calculator"]}
    >
      {/* State-specific content for SEO */}
      <section className="mb-section">
        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          {stateData.name} Income Tax Overview
        </h2>
        <p className="text-brand-muted leading-relaxed mb-4">
          {getTaxSummary(stateData)}
        </p>
        <div className="rounded-card bg-brand-bg p-card text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-brand-muted">Tax type</span>
            <span className="font-medium text-brand-navy capitalize">{stateData.incomeTaxType === "none" ? "No income tax" : `${stateData.incomeTaxType} income tax`}</span>
          </div>
          {stateData.incomeTaxType !== "none" && (
            <div className="flex justify-between">
              <span className="text-brand-muted">{stateData.incomeTaxType === "flat" ? "Tax rate" : "Effective rate (est.)"}</span>
              <span className="font-medium text-brand-navy">{(getStateTaxRate(stateData) * 100).toFixed(2)}%</span>
            </div>
          )}
          <div className="flex justify-between">
            <span className="text-brand-muted">Social Security</span>
            <span className="font-medium text-brand-navy">6.20%</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Medicare</span>
            <span className="font-medium text-brand-navy">1.45%</span>
          </div>
        </div>
      </section>
    </CalculatorShell>
  );
}
