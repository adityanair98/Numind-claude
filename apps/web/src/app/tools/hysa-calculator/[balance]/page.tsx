import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { hysaShortcut } from "@/lib/content/shortcuts";
import { hysaFAQs } from "@/lib/content/faqs";
import { HysaCalculatorWidget } from "../HysaCalculatorWidget";
import { hysaBalances, getHysaBalanceBySlug } from "@/data/hysa-balances";
import { computeHysa } from "@/lib/calculators/hysa";

export async function generateStaticParams() {
  return hysaBalances.map((b) => ({ balance: b.slug }));
}

type Props = {
  params: Promise<{ balance: string }>;
};

function fmt(n: number): string {
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

function fmtDecimal(n: number): string {
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { balance } = await params;
  const balanceData = getHysaBalanceBySlug(balance);
  if (!balanceData) return {};

  const ref = computeHysa({
    balance: balanceData.balance,
    apy: 4.5,
    bigBankApy: 0.01,
  });

  const title = `How Much Interest Does ${balanceData.label} Earn in a HYSA? | Numind`;
  const description = `${balanceData.label} in a high-yield savings account at 4.5% APY earns about ${fmt(ref.annualInterest)}/year — vs ~${fmtDecimal(ref.bigBankAnnualInterest)} at a big-bank rate. Free calculator, no sign-up.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/hysa-calculator/${balance}`,
    },
    openGraph: {
      title,
      description,
      url: `https://numind.app/tools/hysa-calculator/${balance}`,
      type: "website",
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getBalanceFAQs(
  balanceData: NonNullable<ReturnType<typeof getHysaBalanceBySlug>>,
) {
  const ref4 = computeHysa({
    balance: balanceData.balance,
    apy: 4.0,
    bigBankApy: 0.01,
  });
  const ref45 = computeHysa({
    balance: balanceData.balance,
    apy: 4.5,
    bigBankApy: 0.01,
  });
  const ref5 = computeHysa({
    balance: balanceData.balance,
    apy: 5.0,
    bigBankApy: 0.01,
  });

  return [
    {
      question: `How much interest does ${balanceData.label} earn at a 4.5% APY?`,
      answer: `At 4.5% APY (a typical 2025 high-yield savings rate), ${balanceData.label} earns about ${fmt(ref45.annualInterest)}/year — or roughly ${fmtDecimal(ref45.monthlyInterest)}/month. Annual interest scales linearly with APY: at 4.0% it's ${fmt(ref4.annualInterest)}/year, at 5.0% it's ${fmt(ref5.annualInterest)}/year.`,
    },
    {
      question: `Is ${balanceData.label} too much to keep in savings?`,
      answer:
        balanceData.balance >= 250000
          ? `Yes, potentially. The FDIC insurance limit is $250,000 per depositor per bank. For a balance of ${balanceData.label}, you'd want to either split across multiple banks (or banking partners via fintech sweep networks) or move excess into a brokerage settlement fund or Treasury bills — both currently yield in the same 4-5% range, both with low credit risk.`
          : `Not necessarily, but most personal-finance writers suggest keeping 3-6 months of expenses in savings (emergency fund) and investing anything beyond that for higher long-run returns. ${balanceData.label} is a reasonable emergency fund for anyone with monthly expenses around ${fmt(balanceData.balance / 4)}-${fmt(balanceData.balance / 3)}.`,
    },
    {
      question: `Is ${balanceData.label} in a HYSA insured?`,
      answer: `Yes — up to $250,000 per depositor per FDIC-insured bank (per the FDIC). ${balanceData.balance > 250000 ? `Your full balance of ${balanceData.label} exceeds the per-bank limit, so spread across multiple banks (or use a fintech with a sweep network) to keep everything insured.` : `Your full balance of ${balanceData.label} is well under the limit and fully insured at a single FDIC bank.`}`,
    },
    {
      question: `How long until ${balanceData.label} doubles in a HYSA?`,
      answer: `Use the Rule of 72: years to double ≈ 72 ÷ APY. At a 4.5% APY, ${balanceData.label} doubles to ${fmt(balanceData.balance * 2)} in about ${(72 / 4.5).toFixed(1)} years. At 5%, it's ${(72 / 5).toFixed(1)} years. (Tax on the interest will slow this slightly in a taxable account.)`,
    },
    ...hysaFAQs.slice(0, 2),
  ];
}

export default async function HysaBalancePage({ params }: Props) {
  const { balance } = await params;
  const balanceData = getHysaBalanceBySlug(balance);

  if (!balanceData) {
    notFound();
  }

  const balanceFAQs = getBalanceFAQs(balanceData);
  const ref45 = computeHysa({
    balance: balanceData.balance,
    apy: 4.5,
    bigBankApy: 0.01,
  });

  return (
    <CalculatorShell
      slug={`hysa-calculator/${balanceData.slug}`}
      name={`How Much Interest Does ${balanceData.label} Earn in a HYSA?`}
      tagline={`Annual interest, monthly cash flow, and big-bank gap on a ${balanceData.label} high-yield savings balance`}
      calculator={
        <HysaCalculatorWidget defaultBalance={balanceData.balance.toString()} />
      }
      shortcut={hysaShortcut}
      faqs={balanceFAQs}
      relatedSlugs={["investment-calculator", "loan-calculator", "balance-transfer-calculator"]}
    >
      {/* Balance-specific content — SEO + AIO */}
      <section className="mb-section">
        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          {balanceData.label} at 4.5% APY — Snapshot
        </h2>
        <div className="rounded-card bg-brand-bg p-card text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-brand-muted">Annual interest at 4.5% APY</span>
            <span className="font-bold text-brand-navy">{fmt(ref45.annualInterest)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Monthly interest</span>
            <span className="font-medium text-brand-navy">
              {fmtDecimal(ref45.monthlyInterest)}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Big-bank (0.01% APY) annual interest</span>
            <span className="font-medium text-brand-navy">
              {fmtDecimal(ref45.bigBankAnnualInterest)}
            </span>
          </div>
          <div className="flex justify-between border-t border-brand-navy/10 pt-2">
            <span className="text-brand-muted">
              Annual gap (HYSA &minus; big-bank)
            </span>
            <span className="font-bold text-brand-navy">{fmt(ref45.annualGap)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Years to double (Rule of 72)</span>
            <span className="font-medium text-brand-navy">
              {ref45.yearsToDouble.toFixed(1)} years
            </span>
          </div>
        </div>
        <p className="mt-3 text-sm text-brand-muted leading-relaxed">
          Moving {balanceData.label} from a big-bank 0.01% savings account to a
          4.5% HYSA is essentially free money — about{" "}
          <strong className="text-brand-navy">{fmt(ref45.annualGap)}/year</strong>{" "}
          of additional interest, with the same FDIC insurance and same liquidity.
          Best-in-class HYSAs (Ally, Marcus, Discover, SoFi, etc.) sit near 4.5%
          APY in 2025; the rate moves with the Federal Funds Rate.
        </p>
      </section>
    </CalculatorShell>
  );
}
