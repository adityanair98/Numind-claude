"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorSelect } from "@/components/calculator/CalculatorSelect";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computePaycheck, type PayFrequency } from "@/lib/calculators/paycheck";
import { states, getStateBySlug } from "@/data/states";
import type { FilingStatus } from "@/data/tax-brackets";

const filingOptions = [
  { label: "Single", value: "single" },
  { label: "Married Filing Jointly", value: "mfj" },
  { label: "Married Filing Separately", value: "mfs" },
  { label: "Head of Household", value: "hoh" },
];

const frequencyOptions = [
  { label: "Weekly (52/yr)", value: "weekly" },
  { label: "Biweekly (26/yr)", value: "biweekly" },
  { label: "Semi-monthly (24/yr)", value: "semimonthly" },
  { label: "Monthly (12/yr)", value: "monthly" },
];

const stateOptions = [
  { label: "Select a state", value: "" },
  ...states.map((s) => ({ label: s.name, value: s.slug })),
];

function fmt(n: number): string {
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

interface PaycheckCalculatorWidgetProps {
  /** Pre-select a state (used by state-specific pages) */
  defaultState?: string;
}

export function PaycheckCalculatorWidget({ defaultState }: PaycheckCalculatorWidgetProps) {
  const [salary, setSalary] = useState("75000");
  const [filing, setFiling] = useState<FilingStatus>("single");
  const [stateSlug, setStateSlug] = useState(defaultState ?? "");
  const [frequency, setFrequency] = useState<PayFrequency>("biweekly");
  const [contribution401k, setContribution401k] = useState("0");

  const result = useMemo(() => {
    const gross = parseFloat(salary) || 0;
    const state = stateSlug ? getStateBySlug(stateSlug) ?? null : null;
    const k401 = parseFloat(contribution401k) || 0;
    return computePaycheck(gross, filing, state, frequency, k401);
  }, [salary, filing, stateSlug, frequency, contribution401k]);

  const frequencyLabel: Record<PayFrequency, string> = {
    weekly: "/week",
    biweekly: "/biweek",
    semimonthly: "/period",
    monthly: "/month",
  };

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Annual Salary"
          value={salary}
          onChange={setSalary}
          prefix="$"
          placeholder="75000"
        />
        <CalculatorSelect
          label="Filing Status"
          value={filing}
          onChange={(v) => setFiling(v as FilingStatus)}
          options={filingOptions}
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorSelect
          label="State"
          value={stateSlug}
          onChange={setStateSlug}
          options={stateOptions}
        />
        <CalculatorSelect
          label="Pay Frequency"
          value={frequency}
          onChange={(v) => setFrequency(v as PayFrequency)}
          options={frequencyOptions}
        />
      </div>

      <CalculatorInput
        label="401(k) Contribution"
        value={contribution401k}
        onChange={setContribution401k}
        suffix="%"
        placeholder="0"
        helper="Pre-tax contribution percentage (optional)"
      />

      <CalculatorOutput
        label="Take-Home Pay"
        value={fmt(result.netPerPeriod)}
        period={frequencyLabel[frequency]}
        breakdown={[
          { label: "Gross annual salary", value: fmt(result.grossAnnual) },
          { label: "Federal income tax", value: `−${fmt(result.federalTax)}` },
          ...(result.stateTax > 0
            ? [{ label: "State income tax", value: `−${fmt(result.stateTax)}` }]
            : []),
          { label: "Social Security (6.2%)", value: `−${fmt(result.socialSecurity)}` },
          { label: "Medicare (1.45%)", value: `−${fmt(result.medicare)}` },
          ...(result.preTaxDeductions > 0
            ? [{ label: "401(k) pre-tax", value: `−${fmt(result.preTaxDeductions)}` }]
            : []),
          { label: "Annual take-home", value: fmt(result.netAnnual), highlight: true },
          { label: "Effective tax rate", value: `${result.effectiveTaxRate.toFixed(1)}%` },
        ]}
      />
    </div>
  );
}
