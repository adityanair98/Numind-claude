import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { ccPayoffShortcut } from "@/lib/content/shortcuts";
import { ccPayoffFAQs } from "@/lib/content/faqs";
import { CreditCardPayoffCalculatorWidget } from "../CreditCardPayoffCalculatorWidget";
import { ccBalances, getCCBalanceBySlug } from "@/data/cc-balances";
import { computeCCPayoff } from "@/lib/calculators/ccPayoff";

export async function generateStaticParams() {
  return ccBalances.map((b) => ({ balance: b.slug }));
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

function monthsLabel(m: number): string {
  if (!isFinite(m)) return "never";
  const years = Math.floor(m / 12);
  const remMonths = m - years * 12;
  if (years === 0) return `${m} months`;
  if (remMonths === 0) return `${years} year${years === 1 ? "" : "s"}`;
  return `${years} yr ${remMonths} mo`;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { balance } = await params;
  const balanceData = getCCBalanceBySlug(balance);
  if (!balanceData) return {};

  const title = `How Long to Pay Off ${balanceData.label} in Credit Card Debt? | Numind`;
  const description = `See how many months it takes to pay off a ${balanceData.label} credit card balance at any APR and monthly payment. Includes total interest paid. Free, no sign-up.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://numind.app/tools/credit-card-payoff-calculator/${balance}`,
    },
    openGraph: {
      title,
      description,
      url: `https://numind.app/tools/credit-card-payoff-calculator/${balance}`,
      type: "website",
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

function getBalanceFAQs(
  balanceData: NonNullable<ReturnType<typeof getCCBalanceBySlug>>,
) {
  // Three reference scenarios on this balance at common APRs
  const refMin = computeCCPayoff({
    balance: balanceData.balance,
    apr: 22,
    monthlyPayment: balanceData.exampleMonthlyPayment,
  });
  const refDouble = computeCCPayoff({
    balance: balanceData.balance,
    apr: 22,
    monthlyPayment: balanceData.exampleMonthlyPayment * 2,
  });
  const refLowAPR = computeCCPayoff({
    balance: balanceData.balance,
    apr: 15,
    monthlyPayment: balanceData.exampleMonthlyPayment,
  });

  return [
    {
      question: `How long to pay off ${balanceData.label} at $${balanceData.exampleMonthlyPayment}/month?`,
      answer: refMin.unpayable
        ? `At $${balanceData.exampleMonthlyPayment}/month against a 22% APR ${balanceData.label} balance, payments don't even cover the monthly interest charge of ${fmt(refMin.monthlyInterest)} — the balance grows over time. You need to pay more than the monthly interest to make any progress.`
        : `At $${balanceData.exampleMonthlyPayment}/month and a typical 22% APR, paying off ${balanceData.label} takes about ${monthsLabel(refMin.months)} — and you'll pay roughly ${fmt(refMin.totalInterest)} in interest on top of the principal.`,
    },
    {
      question: `What if I double my payment to $${balanceData.exampleMonthlyPayment * 2}/month?`,
      answer: refDouble.unpayable
        ? `Even at $${balanceData.exampleMonthlyPayment * 2}/month, that's not enough to cover the 22% APR interest on this balance. Try a higher payment or a balance transfer.`
        : `Doubling to $${balanceData.exampleMonthlyPayment * 2}/month at 22% APR cuts payoff to ${monthsLabel(refDouble.months)} — saving roughly ${fmt(refMin.totalInterest - refDouble.totalInterest)} in interest. Rule of thumb: every extra $50/mo cuts about a year off a $5K balance.`,
    },
    {
      question: `How much interest will I pay on ${balanceData.label} at a 15% APR?`,
      answer: refLowAPR.unpayable
        ? `At $${balanceData.exampleMonthlyPayment}/month, even a 15% APR is too high to make progress on ${balanceData.label}. Bump up the payment first.`
        : `At a 15% APR (a great rate from a credit union or personal loan refi) and $${balanceData.exampleMonthlyPayment}/month, ${balanceData.label} takes about ${monthsLabel(refLowAPR.months)} to pay off with roughly ${fmt(refLowAPR.totalInterest)} in interest. Compare to 22% APR: ${fmt(refMin.totalInterest)} in interest. The APR difference matters a lot.`,
    },
    {
      question: `Is a 0% balance transfer worth it for ${balanceData.label}?`,
      answer: `Typical balance transfers charge a 3-5% fee upfront (~${fmt(balanceData.balance * 0.04)} on a ${balanceData.label} balance at 4%), then offer 0% APR for 12-21 months. If you'd otherwise pay ~${fmt(refMin.totalInterest)} in interest over the full payoff at 22% APR, a transfer is usually a strong win — provided you actually pay off the balance during the promo window. Use our balance transfer calculator to compare.`,
    },
    ...ccPayoffFAQs.slice(0, 2),
  ];
}

export default async function CCBalancePayoffPage({ params }: Props) {
  const { balance } = await params;
  const balanceData = getCCBalanceBySlug(balance);

  if (!balanceData) {
    notFound();
  }

  const balanceFAQs = getBalanceFAQs(balanceData);
  const refMin = computeCCPayoff({
    balance: balanceData.balance,
    apr: 22,
    monthlyPayment: balanceData.exampleMonthlyPayment,
  });

  return (
    <CalculatorShell
      slug={`credit-card-payoff-calculator/${balanceData.slug}`}
      name={`${balanceData.label} Credit Card Payoff Calculator`}
      tagline={`How long to pay off ${balanceData.label} at any APR + monthly payment, plus total interest cost`}
      calculator={
        <CreditCardPayoffCalculatorWidget
          defaultBalance={balanceData.balance.toString()}
          defaultMonthlyPayment={balanceData.exampleMonthlyPayment.toString()}
        />
      }
      shortcut={ccPayoffShortcut}
      faqs={balanceFAQs}
      relatedSlugs={["balance-transfer-calculator", "loan-calculator", "investment-calculator"]}
    >
      {/* Balance-specific content block — SEO + AIO */}
      <section className="mb-section">
        <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
          Paying Off {balanceData.label} — What to Expect
        </h2>
        <p className="text-brand-muted leading-relaxed mb-4">
          At the typical credit card APR of 22% (CFPB Consumer Credit Card Market
          Report), a {balanceData.label} balance with a ${balanceData.exampleMonthlyPayment}/month
          payment takes about{" "}
          {refMin.unpayable ? (
            <strong className="text-brand-navy">forever — the payment doesn&apos;t cover monthly interest</strong>
          ) : (
            <>
              <strong className="text-brand-navy">{monthsLabel(refMin.months)}</strong>{" "}
              and costs roughly{" "}
              <strong className="text-brand-navy">{fmt(refMin.totalInterest)}</strong> in interest
            </>
          )}{" "}
          beyond the principal. That&apos;s why minimum payments are a trap on
          balances over a few thousand dollars — most of every payment goes to
          interest, not principal.
        </p>
        <div className="rounded-card bg-brand-bg p-card text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-brand-muted">Starting balance</span>
            <span className="font-medium text-brand-navy">
              {balanceData.label}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Example monthly payment</span>
            <span className="font-medium text-brand-navy">
              ${balanceData.exampleMonthlyPayment}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Assumed APR</span>
            <span className="font-medium text-brand-navy">22%</span>
          </div>
          <div className="flex justify-between">
            <span className="text-brand-muted">Months to payoff</span>
            <span className="font-medium text-brand-navy">
              {refMin.unpayable ? "Never" : monthsLabel(refMin.months)}
            </span>
          </div>
          <div className="flex justify-between border-t border-brand-navy/10 pt-2">
            <span className="text-brand-muted">Total interest paid</span>
            <span className="font-bold text-brand-navy">
              {refMin.unpayable ? "∞" : fmt(refMin.totalInterest)}
            </span>
          </div>
        </div>
        <p className="mt-3 text-sm text-brand-muted leading-relaxed">
          Use the calculator above to test your own APR and monthly payment.
          Every extra $50/month on a {balanceData.label} balance cuts roughly{" "}
          {Math.max(1, Math.round(balanceData.balance / 5000))} year off the
          payoff at 22% APR.
        </p>
      </section>
    </CalculatorShell>
  );
}
