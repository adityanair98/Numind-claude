import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { salaryShortcut } from "@/lib/content/shortcuts";
import { salaryFAQs } from "@/lib/content/faqs";
import { SalaryCalculatorWidget } from "../SalaryCalculatorWidget";
import { salaryAmounts, getSalaryAmountBySlug } from "@/data/salary-amounts";
import { convertSalary, estimateAfterTax } from "@/lib/calculators/salary";
import { AnimatedAnswer } from "@/components/calculator/AnimatedAnswer";

export async function generateStaticParams() {
  return salaryAmounts.map((s) => ({ slug: s.slug }));
}

type Props = {
  params: Promise<{ slug: string }>;
};

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtHourly(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const data = getSalaryAmountBySlug(slug);
  if (!data) return {};

  const conversion = convertSalary(data.amount, data.type);

  const title =
    data.type === "hourly"
      ? `$${data.amount}/Hour is ${fmt(conversion.annual)}/Year — Salary Conversion`
      : `${fmt(data.amount)}/Year is ${fmtHourly(conversion.hourly)}/Hour — Salary Conversion`;

  const description =
    data.type === "hourly"
      ? `$${data.amount} an hour is ${fmt(conversion.annual)} a year, ${fmt(conversion.monthly)} a month, or ${fmt(conversion.biweekly)} biweekly. See the full breakdown plus after-tax estimate.`
      : `${fmt(data.amount)} a year is ${fmtHourly(conversion.hourly)}/hour, ${fmt(conversion.monthly)}/month, or ${fmt(conversion.biweekly)} biweekly. Full salary breakdown plus after-tax estimate.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/salary-calculator/${slug}`,
    },
    openGraph: { title, description, url: `https://numind.app/tools/salary-calculator/${slug}`, type: "website" },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getAmountFAQs(data: NonNullable<ReturnType<typeof getSalaryAmountBySlug>>, conversion: ReturnType<typeof convertSalary>) {
  if (data.type === "hourly") {
    return [
      {
        question: `How much is $${data.amount} an hour annually?`,
        answer: `$${data.amount} per hour equals ${fmt(conversion.annual)} per year, assuming a standard 40-hour work week and 52 weeks per year (2,080 total hours).`,
      },
      {
        question: `What is $${data.amount}/hour monthly after taxes?`,
        answer: `Before taxes, $${data.amount}/hour is about ${fmt(conversion.monthly)} per month. After a typical ~25% effective tax rate, that's roughly ${fmt(estimateAfterTax(conversion.annual) / 12)} per month take-home.`,
      },
      {
        question: `Is $${data.amount} an hour a good salary?`,
        answer: `At ${fmt(conversion.annual)} per year, $${data.amount}/hour is ${conversion.annual > 59000 ? "above" : conversion.annual > 45000 ? "near" : "below"} the U.S. median household income of about $59,000. Whether it's enough depends on your location and cost of living.`,
      },
      ...salaryFAQs.slice(0, 2),
    ];
  }
  return [
    {
      question: `What is ${fmt(data.amount)} a year per hour?`,
      answer: `${fmt(data.amount)} per year equals ${fmtHourly(conversion.hourly)} per hour, assuming a standard 40-hour work week and 52 weeks per year (2,080 total hours).`,
    },
    {
      question: `How much is ${fmt(data.amount)} a year per month?`,
      answer: `${fmt(data.amount)} annually divided by 12 months gives you ${fmt(conversion.monthly)} per month before taxes. After a ~25% effective tax rate, that's roughly ${fmt(estimateAfterTax(conversion.annual) / 12)} take-home per month.`,
    },
    {
      question: `What is the biweekly pay for a ${fmt(data.amount)} salary?`,
      answer: `A ${fmt(data.amount)} annual salary works out to ${fmt(conversion.biweekly)} per biweekly paycheck (26 pay periods per year). Note: biweekly is every 2 weeks, not twice a month — that's semi-monthly (24 periods).`,
    },
    ...salaryFAQs.slice(0, 2),
  ];
}

export default async function SalaryAmountPage({ params }: Props) {
  const { slug } = await params;
  const data = getSalaryAmountBySlug(slug);

  if (!data) {
    notFound();
  }

  const conversion = convertSalary(data.amount, data.type);
  const afterTax = estimateAfterTax(conversion.annual);
  const amountFAQs = getAmountFAQs(data, conversion);

  const answerText =
    data.type === "hourly"
      ? `$${data.amount} an hour is ${fmt(conversion.annual)} a year.`
      : `${fmt(data.amount)} a year is ${fmtHourly(conversion.hourly)} per hour.`;

  return (
    <CalculatorShell
      slug={`salary-calculator/${data.slug}`}
      name={`${data.label} — Salary Breakdown`}
      tagline={answerText}
      calculator={<SalaryCalculatorWidget />}
      shortcut={salaryShortcut}
      faqs={amountFAQs}
      relatedSlugs={["paycheck-calculator", "rent-calculator"]}
    >
      {/* Answer-first content block for SEO & AIO */}
      <section className="mb-section">
        {/* Animated hero answer */}
        <div className="mb-4 rounded-card bg-brand-navy p-card text-center">
          <p className="text-sm text-white/60 mb-1">
            {data.type === "hourly" ? `$${data.amount}/hour is` : `${fmt(data.amount)}/year is`}
          </p>
          <p className="font-display text-3xl font-bold text-white sm:text-4xl">
            {data.type === "hourly" ? (
              <AnimatedAnswer
                value={conversion.annual}
                formatStyle="currency"
              />
            ) : (
              <AnimatedAnswer
                value={Math.round(conversion.hourly * 100) / 100}
                formatStyle="currency-decimal"
              />
            )}
            <span className="text-lg font-normal text-white/50">
              {data.type === "hourly" ? " /year" : " /hour"}
            </span>
          </p>
        </div>

        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          {data.type === "hourly" ? `$${data.amount}/Hour` : fmt(data.amount)} Salary Breakdown
        </h2>
        <div className="rounded-card bg-brand-bg p-card space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-brand-muted">Hourly</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmtHourly(conversion.hourly)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Weekly</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmt(conversion.weekly)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Biweekly (26 pay periods)</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmt(conversion.biweekly)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Monthly</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmt(conversion.monthly)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Annual</span>
            <span className="font-bold text-brand-navy tabular-nums">{fmt(conversion.annual)}</span>
          </div>
          <hr className="border-brand-navy/10" />
          <div className="flex justify-between">
            <span className="text-brand-muted">After tax (est. ~25%)</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmt(afterTax)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Monthly take-home (est.)</span>
            <span className="font-medium text-brand-navy tabular-nums">{fmt(afterTax / 12)}</span>
          </div>
        </div>
        <p className="mt-3 text-sm text-brand-muted leading-relaxed">
          Based on a standard 40-hour work week and 52 weeks per year (2,080 hours total).
          The after-tax estimate uses a ~25% effective rate — your actual rate depends on
          filing status, state, and deductions. Use our{" "}
          <a href="/tools/paycheck-calculator" className="text-brand-blue underline underline-offset-2">
            paycheck calculator
          </a>{" "}
          for a detailed breakdown.
        </p>
      </section>
    </CalculatorShell>
  );
}
