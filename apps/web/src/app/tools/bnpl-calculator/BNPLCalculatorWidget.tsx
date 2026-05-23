"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeBNPL } from "@/lib/calculators/bnpl";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtDetailed(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function BNPLCalculatorWidget() {
  const [price, setPrice] = useState("300");
  const [numPayments, setNumPayments] = useState("4");
  const [lateFee, setLateFee] = useState("35");

  const result = useMemo(() => {
    return computeBNPL(
      parseFloat(price) || 0,
      parseInt(numPayments) || 4,
      parseFloat(lateFee) || 0
    );
  }, [price, numPayments, lateFee]);

  return (
    <div className="space-y-6">
      <CalculatorInput label="Purchase Price" value={price} onChange={setPrice} prefix="$" placeholder="300" />
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Number of Payments" value={numPayments} onChange={setNumPayments} placeholder="4" />
        <CalculatorInput label="Late Fee (if missed)" value={lateFee} onChange={setLateFee} prefix="$" placeholder="35" />
      </div>

      <CalculatorOutput
        label="Per Payment"
        value={fmtDetailed(result.paymentAmount)}
        period={`× ${numPayments} payments`}
        breakdown={[
          { label: "Total cost (paid on time)", value: fmt(result.totalCost) },
          { label: "Cost with one late fee", value: fmt(result.costWithLateFee), highlight: true },
          { label: "Surcharge if one missed", value: `${result.surchargePercent.toFixed(1)}%` },
        ]}
      />

      {result.totalCost > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {fmt(result.totalCost)} BNPL plan looks like {fmt(result.paymentAmount)} per payment.{" "}
          But miss one payment and the {fmt(parseFloat(lateFee))} late fee adds a{" "}
          <strong className="text-brand-navy">{result.surchargePercent.toFixed(1)}% surcharge</strong>{" "}
          to the original price. Stack 3 plans at this level and you&apos;re carrying{" "}
          {fmt(result.paymentAmount * 3)} per month of invisible debt.
        </p>
      )}
    </div>
  );
}
