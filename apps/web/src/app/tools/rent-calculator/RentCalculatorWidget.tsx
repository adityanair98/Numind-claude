"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeRentAffordability } from "@/lib/calculators/rent";

function fmt(n: number): string {
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

function pct(n: number): string {
  return `${n.toFixed(1)}%`;
}

export function RentCalculatorWidget() {
  const [salary, setSalary] = useState("60000");
  const [debt, setDebt] = useState("");
  const [customRent, setCustomRent] = useState("");

  const result = useMemo(() => {
    const annualSalary = parseFloat(salary) || 0;
    const monthlyDebt = parseFloat(debt) || 0;
    const rent = customRent ? parseFloat(customRent) : undefined;
    return computeRentAffordability(annualSalary, monthlyDebt, rent);
  }, [salary, debt, customRent]);

  const rentToCheck = parseFloat(customRent) || 0;
  const isOverBudget = result.rentToIncomePercent !== undefined && result.rentToIncomePercent > 28;

  return (
    <div className="space-y-6">
      <CalculatorInput
        label="Annual Salary (Gross)"
        value={salary}
        onChange={setSalary}
        prefix="$"
        placeholder="60000"
        helper="Your total salary before taxes"
      />

      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Monthly Debt Payments"
          value={debt}
          onChange={setDebt}
          prefix="$"
          placeholder="0"
          helper="Car loan, student loans, credit cards, etc."
        />
        <CalculatorInput
          label="Check a Specific Rent"
          value={customRent}
          onChange={setCustomRent}
          prefix="$"
          placeholder="1400"
          helper="Optional — see if a rent amount fits your budget"
        />
      </div>

      <CalculatorOutput
        label="Maximum Affordable Rent (28% Rule)"
        value={fmt(result.maxRent)}
        period="/month"
        breakdown={[
          { label: "Monthly gross income", value: fmt(result.monthlyGross) },
          { label: "28% of gross (max rent)", value: fmt(result.maxRent), highlight: true },
          ...(result.rentToIncomePercent !== undefined
            ? [
                {
                  label: `${fmt(rentToCheck)} rent = ${pct(result.rentToIncomePercent)} of income`,
                  value: isOverBudget ? "Over budget" : "Within budget",
                  highlight: true,
                },
              ]
            : []),
          ...(result.dtiPercent !== undefined
            ? [
                {
                  label: "Debt-to-income ratio",
                  value: `${pct(result.dtiPercent)} ${result.dtiPercent > 36 ? "(high)" : "(healthy)"}`,
                  highlight: result.dtiPercent > 36,
                },
              ]
            : []),
        ]}
      />

      {/* Answer-first paragraph for AIO */}
      {parseFloat(salary) > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          On a {fmt(parseFloat(salary))} annual salary, you can afford up to{" "}
          <strong className="text-brand-navy">{fmt(result.maxRent)}/month</strong> in rent
          using the 28% rule. Your monthly gross income is {fmt(result.monthlyGross)}.
          {result.rentToIncomePercent !== undefined && (
            <> A rent of {fmt(rentToCheck)} would be {pct(result.rentToIncomePercent)} of your gross income — {isOverBudget ? "above the recommended 28% threshold" : "within the 28% guideline"}.</>
          )}
        </p>
      )}
    </div>
  );
}
