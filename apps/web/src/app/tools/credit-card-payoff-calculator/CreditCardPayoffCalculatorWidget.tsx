"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeCCPayoff } from "@/lib/calculators/ccPayoff";

function money(n: number): string {
  if (!isFinite(n) || n <= 0) return "$0";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

function monthsLabel(m: number): string {
  if (!isFinite(m)) return "—";
  const years = Math.floor(m / 12);
  const remMonths = m - years * 12;
  if (years === 0) return `${m} month${m === 1 ? "" : "s"}`;
  if (remMonths === 0) return `${years} year${years === 1 ? "" : "s"}`;
  return `${years} yr ${remMonths} mo`;
}

interface CreditCardPayoffCalculatorWidgetProps {
  /** Pre-fill starting balance (used by /[balance] programmatic pages) */
  defaultBalance?: string;
  /** Pre-fill the monthly-payment input (so the page shows a reasonable example for that balance) */
  defaultMonthlyPayment?: string;
}

export function CreditCardPayoffCalculatorWidget({
  defaultBalance,
  defaultMonthlyPayment,
}: CreditCardPayoffCalculatorWidgetProps = {}) {
  const [balance, setBalance] = useState(defaultBalance ?? "5000");
  const [apr, setApr] = useState("22");
  const [monthlyPayment, setMonthlyPayment] = useState(
    defaultMonthlyPayment ?? "200"
  );

  const result = useMemo(
    () =>
      computeCCPayoff({
        balance: parseFloat(balance) || 0,
        apr: parseFloat(apr) || 0,
        monthlyPayment: parseFloat(monthlyPayment) || 0,
      }),
    [balance, apr, monthlyPayment]
  );

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-3">
        <CalculatorInput
          label="Current Balance"
          value={balance}
          onChange={setBalance}
          prefix="$"
          placeholder="5000"
        />
        <CalculatorInput
          label="APR"
          value={apr}
          onChange={setApr}
          suffix="%"
          placeholder="22"
        />
        <CalculatorInput
          label="Monthly Payment"
          value={monthlyPayment}
          onChange={setMonthlyPayment}
          prefix="$"
          placeholder="200"
        />
      </div>

      <CalculatorOutput
        label={result.unpayable ? "Payoff Time" : "Time to Debt-Free"}
        value={result.unpayable ? "Never" : monthsLabel(result.months)}
        period={result.unpayable ? "payment ≤ monthly interest" : `at $${monthlyPayment}/month`}
        breakdown={[
          { label: "Monthly interest charge", value: money(result.monthlyInterest) },
          { label: "First-month principal slice", value: money(result.principalSlice) },
          {
            label: "Total interest paid",
            value: result.unpayable ? "∞" : money(result.totalInterest),
            highlight: !result.unpayable,
          },
          {
            label: "Total paid (principal + interest)",
            value: result.unpayable ? "∞" : money(result.totalPaid),
          },
        ]}
      />

      {!result.unpayable && result.months > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          At ${monthlyPayment}/month, your{" "}
          <strong className="text-brand-navy">{money(parseFloat(balance))}</strong>{" "}
          balance at {apr}% APR takes {monthsLabel(result.months)} to clear — and{" "}
          {money(result.totalInterest)} of your total payments go to interest.
          Every extra $50/month roughly cuts another year off a $5,000 balance.
        </p>
      )}
      {result.unpayable && (
        <p className="text-sm text-brand-muted leading-relaxed">
          Your monthly payment doesn&apos;t even cover the monthly interest charge
          ({money(result.monthlyInterest)}/month). The balance will grow over time.
          You need to pay at least more than the interest each month to make any
          payoff progress.
        </p>
      )}
    </div>
  );
}
