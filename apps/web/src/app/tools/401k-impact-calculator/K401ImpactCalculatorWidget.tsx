"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeK401Impact } from "@/lib/calculators/k401Impact";

function money(n: number): string {
  if (!isFinite(n) || n <= 0) return "$0";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

interface K401ImpactCalculatorWidgetProps {
  /** Pre-fill marginal-rate default (used by state pages to add state-tax bump on top of fed 22%) */
  defaultMarginalRate?: string;
}

export function K401ImpactCalculatorWidget({
  defaultMarginalRate,
}: K401ImpactCalculatorWidgetProps = {}) {
  const [monthlyGross, setMonthlyGross] = useState("5000");
  const [contributionPct, setContributionPct] = useState("6");
  const [marginalRate, setMarginalRate] = useState(
    defaultMarginalRate ?? "22"
  );
  const [matchRate, setMatchRate] = useState("50");
  const [matchCap, setMatchCap] = useState("6");

  const result = useMemo(
    () =>
      computeK401Impact({
        monthlyGross: parseFloat(monthlyGross) || 0,
        contributionPct: parseFloat(contributionPct) || 0,
        marginalRate: parseFloat(marginalRate) || 0,
        matchRate: parseFloat(matchRate) || 0,
        matchCap: parseFloat(matchCap) || 0,
      }),
    [monthlyGross, contributionPct, marginalRate, matchRate, matchCap]
  );

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Monthly Gross Income"
          value={monthlyGross}
          onChange={setMonthlyGross}
          prefix="$"
          placeholder="5000"
        />
        <CalculatorInput
          label="Contribution Rate"
          value={contributionPct}
          onChange={setContributionPct}
          suffix="%"
          placeholder="6"
        />
        <CalculatorInput
          label="Marginal Tax Rate"
          value={marginalRate}
          onChange={setMarginalRate}
          suffix="%"
          placeholder="22"
        />
        <CalculatorInput
          label="Employer Match Rate"
          value={matchRate}
          onChange={setMatchRate}
          suffix="%"
          placeholder="50"
        />
        <CalculatorInput
          label="Match Cap (% of salary)"
          value={matchCap}
          onChange={setMatchCap}
          suffix="%"
          placeholder="6"
        />
      </div>

      <CalculatorOutput
        label="Net Paycheck Cost"
        value={money(result.netPaycheckCost)}
        period="per month"
        breakdown={[
          { label: "Your monthly contribution", value: money(result.monthlyContribution) },
          { label: "Income tax saved (pre-tax benefit)", value: money(result.monthlyTaxSaved) },
          { label: "Employer match captured", value: money(result.employerMatch), highlight: true },
          { label: "Total going into your 401(k)", value: money(result.totalIntoAccount) },
        ]}
      />

      {result.monthlyContribution > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {contributionPct}% pre-tax contribution on {money(parseFloat(monthlyGross))}{" "}
          monthly gross only feels like{" "}
          <strong className="text-brand-navy">{money(result.netPaycheckCost)}/month</strong>{" "}
          in lost take-home — because the IRS effectively chips in{" "}
          {money(result.monthlyTaxSaved)} via the tax break. Your employer adds another{" "}
          {money(result.employerMatch)} on top.
          {result.underMatchCap &&
            " You're contributing below the match cap — bumping up to that level captures more free money."}
        </p>
      )}
    </div>
  );
}
