"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeLoanPayment } from "@/lib/calculators/loan";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtDetailed(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function LoanCalculatorWidget() {
  const [principal, setPrincipal] = useState("25000");
  const [rate, setRate] = useState("6.5");
  const [years, setYears] = useState("5");

  const result = useMemo(() => {
    return computeLoanPayment(
      parseFloat(principal) || 0,
      parseFloat(rate) || 0,
      parseFloat(years) || 0
    );
  }, [principal, rate, years]);

  return (
    <div className="space-y-6">
      <CalculatorInput label="Loan Amount" value={principal} onChange={setPrincipal} prefix="$" placeholder="25000" />
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Interest Rate (APR)" value={rate} onChange={setRate} suffix="%" placeholder="6.5" />
        <CalculatorInput label="Loan Term" value={years} onChange={setYears} suffix="years" placeholder="5" />
      </div>

      <CalculatorOutput
        label="Monthly Payment"
        value={fmtDetailed(result.monthlyPayment)}
        period="/month"
        breakdown={[
          { label: "Loan amount", value: fmt(parseFloat(principal) || 0) },
          { label: "Total of payments", value: fmt(result.totalPayment) },
          { label: "Total interest paid", value: fmt(result.totalInterest), highlight: true },
          { label: "Payoff in", value: `${result.months} months (${(result.months / 12).toFixed(1)} years)` },
        ]}
      />

      {parseFloat(principal) > 0 && isFinite(result.totalInterest) && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {fmt(parseFloat(principal))} loan at {rate}% APR for {years} years costs{" "}
          <strong className="text-brand-navy">{fmt(result.totalInterest)} in interest</strong>.
          Your total repayment is {fmt(result.totalPayment)} — that&apos;s{" "}
          {((result.totalInterest / (parseFloat(principal) || 1)) * 100).toFixed(0)}% more
          than the original loan.
        </p>
      )}
    </div>
  );
}
