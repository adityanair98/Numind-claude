"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeLifeInsurance } from "@/lib/calculators/lifeInsurance";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtDetailed(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function LifeInsuranceCalculatorWidget() {
  const [salary, setSalary] = useState("75000");
  const [mortgage, setMortgage] = useState("250000");
  const [savings, setSavings] = useState("50000");
  const [education, setEducation] = useState("0");

  const result = useMemo(() => {
    return computeLifeInsurance(
      parseFloat(salary) || 0,
      parseFloat(mortgage) || 0,
      parseFloat(savings) || 0,
      parseFloat(education) || 0
    );
  }, [salary, mortgage, savings, education]);

  return (
    <div className="space-y-6">
      <CalculatorInput label="Annual Salary" value={salary} onChange={setSalary} prefix="$" placeholder="75000" />
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Mortgage Balance" value={mortgage} onChange={setMortgage} prefix="$" placeholder="250000" />
        <CalculatorInput label="Current Savings" value={savings} onChange={setSavings} prefix="$" placeholder="50000" />
      </div>
      <CalculatorInput
        label="Future Education Costs"
        value={education}
        onChange={setEducation}
        prefix="$"
        placeholder="0"
      />

      <CalculatorOutput
        label="Recommended Coverage"
        value={fmt(result.adjustedCoverage)}
        period="20-30 year term"
        breakdown={[
          { label: "Baseline (10× salary)", value: fmt(result.baseline10x) },
          { label: "Adjusted (DIME method)", value: fmt(result.adjustedCoverage), highlight: true },
          { label: "Estimated monthly premium", value: fmtDetailed(result.estimatedMonthlyPremium) },
          { label: "Estimated annual cost", value: fmt(result.estimatedAnnualPremium) },
        ]}
      />

      {result.adjustedCoverage > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          For a {fmt(parseFloat(salary))} salary with a {fmt(parseFloat(mortgage))} mortgage and{" "}
          {fmt(parseFloat(savings))} in savings, your family needs roughly{" "}
          <strong className="text-brand-navy">{fmt(result.adjustedCoverage)}</strong> in term life coverage.
          A healthy 35-year-old would pay around{" "}
          <strong className="text-brand-navy">{fmtDetailed(result.estimatedMonthlyPremium)}/month</strong> for a
          20-year policy. Premiums vary widely — shop at least 3 quotes.
        </p>
      )}
    </div>
  );
}
