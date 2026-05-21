"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeAffordability, computeCarCost } from "@/lib/calculators/car";

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function CarCalculatorWidget() {
  const [income, setIncome] = useState("5000");
  const [carPrice, setCarPrice] = useState("30000");
  const [downPercent, setDownPercent] = useState("20");
  const [payment, setPayment] = useState("500");
  const [termMonths, setTermMonths] = useState("60");
  const [depPercent, setDepPercent] = useState("20");

  const afford = useMemo(() => {
    return computeAffordability(parseFloat(income) || 0);
  }, [income]);

  const cost = useMemo(() => {
    return computeCarCost(
      parseFloat(carPrice) || 0,
      parseFloat(downPercent) || 0,
      parseFloat(payment) || 0,
      parseFloat(termMonths) || 0,
      parseFloat(depPercent) || 0
    );
  }, [carPrice, downPercent, payment, termMonths, depPercent]);

  const monthlyIncome = parseFloat(income) || 0;
  const passes10Pct = monthlyIncome > 0 && (parseFloat(payment) || 0) <= monthlyIncome * 0.1;

  return (
    <div className="space-y-6">
      <CalculatorInput
        label="Monthly Gross Income"
        value={income}
        onChange={setIncome}
        prefix="$"
        placeholder="5000"
        helper="For the 20/4/10 affordability check"
      />

      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Car Price" value={carPrice} onChange={setCarPrice} prefix="$" placeholder="30000" />
        <CalculatorInput label="Down Payment" value={downPercent} onChange={setDownPercent} suffix="%" placeholder="20" />
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <CalculatorInput label="Monthly Payment" value={payment} onChange={setPayment} prefix="$" placeholder="500" />
        <CalculatorInput label="Loan Term" value={termMonths} onChange={setTermMonths} suffix="months" placeholder="60" />
        <CalculatorInput label="Year 1 Depreciation" value={depPercent} onChange={setDepPercent} suffix="%" placeholder="20" />
      </div>

      <CalculatorOutput
        label="Total Cost of Ownership"
        value={fmt(cost.totalCost)}
        breakdown={[
          { label: "Down payment", value: fmt(cost.downPayment) },
          { label: "Loan amount", value: fmt(cost.loanAmount) },
          { label: "Total loan payments", value: fmt(cost.totalPayments) },
          { label: "Total interest paid", value: fmt(cost.totalInterest), highlight: true },
          { label: "Value after year 1", value: fmt(cost.valueAfterYear1) },
          { label: "Year 1 depreciation loss", value: fmt(cost.depreciationYear1), highlight: true },
          { label: "20/4/10 max car price", value: fmt(afford.maxCarPrice) },
          {
            label: "10% rule check",
            value: passes10Pct ? "Passes" : "Over budget",
            highlight: !passes10Pct,
          },
        ]}
      />

      {parseFloat(carPrice) > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {fmt(parseFloat(carPrice))} car with {downPercent}% down costs{" "}
          <strong className="text-brand-navy">{fmt(cost.totalCost)} total</strong>, including{" "}
          {fmt(cost.totalInterest)} in interest. It loses {fmt(cost.depreciationYear1)} in value
          the first year alone. Based on your income, the 20/4/10 rule says you can afford up to{" "}
          {fmt(afford.maxCarPrice)}.
        </p>
      )}
    </div>
  );
}
