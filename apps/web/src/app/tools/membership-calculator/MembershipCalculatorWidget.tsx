"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeMembership } from "@/lib/calculators/membership";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function MembershipCalculatorWidget() {
  const [fee, setFee] = useState("9.99");
  const [saving, setSaving] = useState("3");
  const [uses, setUses] = useState("8");

  const result = useMemo(() => {
    return computeMembership(
      parseFloat(fee) || 0,
      parseFloat(saving) || 0,
      parseFloat(uses) || 0,
      true
    );
  }, [fee, saving, uses]);

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Monthly Fee" value={fee} onChange={setFee} prefix="$" placeholder="9.99" />
        <CalculatorInput label="Saving Per Use" value={saving} onChange={setSaving} prefix="$" placeholder="3" />
      </div>
      <CalculatorInput label="Expected Uses Per Month" value={uses} onChange={setUses} placeholder="8" />

      <CalculatorOutput
        label="Break-even Uses"
        value={`${result.breakevenUses} per month`}
        breakdown={[
          { label: "Your expected uses", value: `${uses} per month` },
          { label: "Monthly net saving", value: fmt(result.netSaving), highlight: result.netSaving > 0 },
          { label: "Annual fee equivalent", value: fmt(result.annualFeeEquivalent) },
          { label: "Verdict", value: result.isWorthIt ? "Worth it ✓" : "Not worth it ✗" },
        ]}
      />

      {result.breakevenUses > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          You need <strong className="text-brand-navy">{result.breakevenUses} uses per month</strong> just to
          break even on the {fmt(parseFloat(fee))} fee. At {uses} expected uses, you&apos;ll{" "}
          {result.netSaving > 0 ? (
            <>save <strong className="text-brand-navy">{fmt(result.netSaving)}/month</strong> (after the fee).</>
          ) : (
            <>lose <strong className="text-brand-navy">{fmt(Math.abs(result.netSaving))}/month</strong> on this membership.</>
          )}
        </p>
      )}
    </div>
  );
}
