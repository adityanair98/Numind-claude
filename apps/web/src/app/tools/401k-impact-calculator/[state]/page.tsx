import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { k401ImpactShortcut } from "@/lib/content/shortcuts";
import { k401ImpactFAQs } from "@/lib/content/faqs";
import { K401ImpactCalculatorWidget } from "../K401ImpactCalculatorWidget";
import { states, getStateBySlug, getStateTaxRate } from "@/data/states";
import { computeK401Impact } from "@/lib/calculators/k401Impact";

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
 * Combined effective marginal rate for a typical 22%-fed-bracket earner
 * in this state. Fed 22% + state effective rate ≈ true marginal-tax savings
 * on each pre-tax 401(k) dollar.
 */
function combinedMarginalRate(state: ReturnType<typeof getStateBySlug>): number {
  if (!state) return 22;
  return 22 + getStateTaxRate(state) * 100;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { state } = await params;
  const stateData = getStateBySlug(state);
  if (!stateData) return {};

  const marginal = combinedMarginalRate(stateData);
  const title = `${stateData.name} 401(k) Take-Home Impact Calculator | Numind`;
  const description = `See how much your 401(k) contribution actually costs your ${stateData.abbreviation} paycheck. Combined federal + state marginal rate of ~${marginal.toFixed(1)}% means every $100 you contribute only feels like ~$${(100 - marginal).toFixed(0)}. Free, no sign-up.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/401k-impact-calculator/${state}`,
    },
    openGraph: {
      title,
      description,
      url: `https://numind.app/tools/401k-impact-calculator/${state}`,
      type: "website",
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getStateFAQs(
  stateData: NonNullable<ReturnType<typeof getStateBySlug>>,
) {
  const stateRate = getStateTaxRate(stateData);
  const marginal = combinedMarginalRate(stateData);
  const noStateTax = stateData.incomeTaxType === "none";

  // Reference scenario: $5,000/month gross, 6% contribution rate
  const ref = computeK401Impact({
    monthlyGross: 5000,
    contributionPct: 6,
    marginalRate: marginal,
    matchRate: 50,
    matchCap: 6,
  });

  return [
    {
      question: `Do I save state tax on 401(k) contributions in ${stateData.name}?`,
      answer: noStateTax
        ? `${stateData.name} has no state income tax, so your 401(k) tax break is just the federal portion — typically 22% for middle earners. ${stateData.notes}`
        : `Yes. Traditional 401(k) contributions reduce your ${stateData.abbreviation} taxable income too, so you save federal tax (~22%) plus ${stateData.name}'s ~${(stateRate * 100).toFixed(2)}% state rate. Combined marginal rate is ~${marginal.toFixed(1)}%.`,
    },
    {
      question: `How much does a 6% 401(k) contribution cost my paycheck in ${stateData.name}?`,
      answer: `On a $5,000/month gross income in ${stateData.name}, a 6% pre-tax contribution puts $${ref.monthlyContribution.toFixed(0)} into your 401(k). After the ~${marginal.toFixed(1)}% combined tax savings, the actual paycheck hit feels like ~${fmt(ref.netPaycheckCost)}/month. The employer match (50% up to 6%) adds another ${fmt(ref.employerMatch)}/month on top.`,
    },
    {
      question: `Is the 401(k) tax break bigger in ${stateData.name} or in a no-tax state?`,
      answer: noStateTax
        ? `${stateData.name} is a no-tax state. Your 401(k) tax break here is the federal portion only — same as Texas, Florida, Nevada, etc. High-tax states like California or NY get a bigger break because they also defer state tax.`
        : `${stateData.name}'s ~${(stateRate * 100).toFixed(2)}% state tax means your 401(k) tax break is ~${marginal.toFixed(1)}% combined (federal + state) — meaningfully better than the ~22% break someone in a no-tax state like Texas gets on the same contribution.`,
    },
    {
      question: `Does the employer match depend on what state I'm in?`,
      answer: `No — the employer match is set by your company's plan, not by state law. A typical match in any state is "50% on the first 6%" (i.e. employer contributes 3% of salary if you contribute 6%). Always contribute at least up to the cap; that's pure free money.`,
    },
    ...k401ImpactFAQs.slice(0, 2),
  ];
}

export default async function State401kImpactPage({ params }: Props) {
  const { state } = await params;
  const stateData = getStateBySlug(state);

  if (!stateData) {
    notFound();
  }

  const stateFAQs = getStateFAQs(stateData);
  const stateRate = getStateTaxRate(stateData);
  const marginal = combinedMarginalRate(stateData);
  const noStateTax = stateData.incomeTaxType === "none";

  return (
    <CalculatorShell
      slug={`401k-impact-calculator/${stateData.slug}`}
      name={`${stateData.name} 401(k) Paycheck Impact Calculator`}
      tagline={`See your true ${stateData.abbreviation} take-home cost of a 401(k) contribution — fed + state tax breaks combined (~${marginal.toFixed(1)}% marginal rate)`}
      calculator={
        <K401ImpactCalculatorWidget
          defaultMarginalRate={marginal.toFixed(1)}
        />
      }
      shortcut={k401ImpactShortcut}
      faqs={stateFAQs}
      relatedSlugs={["paycheck-calculator", "investment-calculator", "salary-calculator"]}
    >
      {/* State-specific content block — SEO + AIO */}
      <section className="mb-section">
        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          The {stateData.name} 401(k) Math
        </h2>
        <p className="text-brand-muted leading-relaxed mb-4">
          A pre-tax 401(k) contribution reduces both federal and state taxable
          income. {noStateTax
            ? `Since ${stateData.name} has no state income tax, your only tax break is the federal portion (~22% for typical earners). You still benefit fully from the federal deferral — and from the employer match, which is independent of state.`
            : `${stateData.name}'s effective state rate of ~${(stateRate * 100).toFixed(2)}% stacks on top of the 22% federal bracket, giving you a combined marginal tax break of ~${marginal.toFixed(1)}% on every pre-tax dollar contributed. That's a bigger immediate break than someone in a no-tax state gets on the same contribution.`}
        </p>
        <div className="rounded-card bg-brand-bg p-card text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-brand-muted">Federal marginal (typical 22% bracket)</span>
            <span className="font-medium text-brand-navy">22.0%</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">{stateData.name} state effective rate</span>
            <span className="font-medium text-brand-navy">
              {noStateTax ? "—" : `${(stateRate * 100).toFixed(2)}%`}
            </span>
          </div>
          <div className="flex justify-between border-t border-brand-navy/10 pt-2">
            <span className="text-brand-muted">Combined marginal rate</span>
            <span className="font-bold text-brand-navy">
              {marginal.toFixed(1)}%
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">
              Net paycheck cost of $100 contribution
            </span>
            <span className="font-medium text-brand-navy">
              ~${(100 - marginal).toFixed(0)}
            </span>
          </div>
        </div>
        <p className="mt-3 text-sm text-brand-muted leading-relaxed">
          {stateData.notes}{" "}
          The calculator above is pre-filled with this combined marginal rate —
          adjust if your federal bracket is different (12% for lower earners,
          24-37% for higher earners).
        </p>
      </section>
    </CalculatorShell>
  );
}
