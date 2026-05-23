"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeFSA } from "@/lib/calculators/fsa";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function FSACalculatorWidget() {
  const [election, setElection] = useState("2850");
  const [taxRate, setTaxRate] = useState("25");
  const [projectedSpend, setProjectedSpend] = useState("2000");

  const result = useMemo(() => {
    return computeFSA(
      parseFloat(election) || 0,
      parseFloat(taxRate) || 0,
      parseFloat(projectedSpend) || 0
    );
  }, [election, taxRate, projectedSpend]);

  return (
    <div className="space-y-6">
      <CalculatorInput label="FSA Election Amount" value={election} onChange={setElection} prefix="$" placeholder="2850" />
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Your Tax Rate" value={taxRate} onChange={setTaxRate} suffix="%" placeholder="25" />
        <CalculatorInput label="Expected Spending" value={projectedSpend} onChange={setProjectedSpend} prefix="$" placeholder="2000" />
      </div>

      <CalculatorOutput
        label="Net Result"
        value={fmt(result.netResult)}
        period={result.isWorthIt ? "you come out ahead" : "you lose money"}
        breakdown={[
          { label: "Tax savings on full election", value: fmt(result.taxSaving) },
          { label: "Break-even spend (minimum)", value: fmt(result.breakevenSpend), highlight: true },
          { label: "Forfeited (unspent)", value: fmt(result.forfeitedAmount) },
          { label: "Verdict", value: result.isWorthIt ? "Worth electing ✓" : "Lower your election ✗" },
        ]}
      />

      {result.taxSaving > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {fmt(parseFloat(election))} election saves you {fmt(result.taxSaving)} in taxes. But to avoid losing money to
          forfeiture, you must spend at least <strong className="text-brand-navy">{fmt(result.breakevenSpend)}</strong>{" "}
          on qualified medical expenses.{" "}
          {result.isWorthIt
            ? `At ${fmt(parseFloat(projectedSpend))} expected spend, you net ${fmt(result.netResult)} ahead.`
            : `At ${fmt(parseFloat(projectedSpend))} expected spend, you'd lose ${fmt(Math.abs(result.netResult))} after forfeiture. Lower your election to match.`}
        </p>
      )}
    </div>
  );
}
