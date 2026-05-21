"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { comparePlans } from "@/lib/calculators/insurance";

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function InsuranceCalculatorWidget() {
  const [premiumA, setPremiumA] = useState("350");
  const [deductibleA, setDeductibleA] = useState("1000");
  const [oopMaxA, setOopMaxA] = useState("5000");

  const [premiumB, setPremiumB] = useState("200");
  const [deductibleB, setDeductibleB] = useState("3000");
  const [oopMaxB, setOopMaxB] = useState("7000");

  const result = useMemo(() => {
    return comparePlans(
      parseFloat(premiumA) || 0,
      parseFloat(deductibleA) || 0,
      parseFloat(oopMaxA) || 0,
      parseFloat(premiumB) || 0,
      parseFloat(deductibleB) || 0,
      parseFloat(oopMaxB) || 0
    );
  }, [premiumA, deductibleA, oopMaxA, premiumB, deductibleB, oopMaxB]);

  const cheaperWorst = result.worstCaseDifference > 0 ? "Plan B" : "Plan A";
  const cheaperMax = result.absoluteMaxDifference > 0 ? "Plan B" : "Plan A";

  return (
    <div className="space-y-6">
      <p className="text-sm font-semibold text-brand-navy">Plan A (higher premium, lower deductible)</p>
      <div className="grid gap-4 sm:grid-cols-3">
        <CalculatorInput label="Monthly Premium" value={premiumA} onChange={setPremiumA} prefix="$" placeholder="350" />
        <CalculatorInput label="Deductible" value={deductibleA} onChange={setDeductibleA} prefix="$" placeholder="1000" />
        <CalculatorInput label="OOP Max" value={oopMaxA} onChange={setOopMaxA} prefix="$" placeholder="5000" />
      </div>

      <p className="text-sm font-semibold text-brand-navy">Plan B (lower premium, higher deductible)</p>
      <div className="grid gap-4 sm:grid-cols-3">
        <CalculatorInput label="Monthly Premium" value={premiumB} onChange={setPremiumB} prefix="$" placeholder="200" />
        <CalculatorInput label="Deductible" value={deductibleB} onChange={setDeductibleB} prefix="$" placeholder="3000" />
        <CalculatorInput label="OOP Max" value={oopMaxB} onChange={setOopMaxB} prefix="$" placeholder="7000" />
      </div>

      <CalculatorOutput
        label={`Worst-case year: ${cheaperWorst} is cheaper`}
        value={fmt(Math.abs(result.worstCaseDifference))}
        period=" savings"
        breakdown={[
          { label: "Plan A annual premium", value: fmt(result.planA.annualPremium) },
          { label: "Plan A worst case (premium + deductible)", value: fmt(result.planA.worstCaseCost), highlight: true },
          { label: "Plan A absolute max (premium + OOP max)", value: fmt(result.planA.absoluteMax) },
          { label: "Plan B annual premium", value: fmt(result.planB.annualPremium) },
          { label: "Plan B worst case (premium + deductible)", value: fmt(result.planB.worstCaseCost), highlight: true },
          { label: "Plan B absolute max (premium + OOP max)", value: fmt(result.planB.absoluteMax) },
        ]}
      />

      {(parseFloat(premiumA) > 0 || parseFloat(premiumB) > 0) && (
        <p className="text-sm text-brand-muted leading-relaxed">
          If you hit your deductible, <strong className="text-brand-navy">{cheaperWorst}</strong> saves you{" "}
          {fmt(Math.abs(result.worstCaseDifference))} per year. In a catastrophic year (OOP max),{" "}
          <strong className="text-brand-navy">{cheaperMax}</strong> saves {fmt(Math.abs(result.absoluteMaxDifference))}.
          The right plan depends on how much medical care you expect to use.
        </p>
      )}
    </div>
  );
}
