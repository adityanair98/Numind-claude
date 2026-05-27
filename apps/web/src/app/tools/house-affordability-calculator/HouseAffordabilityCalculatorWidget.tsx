"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeHouseAffordability } from "@/lib/calculators/houseAffordability";

function fmt(n: number): string {
  if (!isFinite(n) || n <= 0) return "$0";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

interface HouseAffordabilityCalculatorWidgetProps {
  /** Pre-fill property-tax-aware default for "Taxes + Insurance (annual)" (used by state pages) */
  defaultTaxInsAnnualPct?: string;
}

export function HouseAffordabilityCalculatorWidget({
  defaultTaxInsAnnualPct,
}: HouseAffordabilityCalculatorWidgetProps = {}) {
  const [monthlyGross, setMonthlyGross] = useState("7000");
  const [ratePercent, setRatePercent] = useState("6.5");
  const [downPercent, setDownPercent] = useState("10");
  const [taxInsAnnualPct, setTaxInsAnnualPct] = useState(
    defaultTaxInsAnnualPct ?? "1.5"
  );

  const result = useMemo(
    () =>
      computeHouseAffordability({
        monthlyGross: parseFloat(monthlyGross) || 0,
        ratePercent: parseFloat(ratePercent) || 0,
        downPercent: parseFloat(downPercent) || 0,
        taxInsAnnualPct: parseFloat(taxInsAnnualPct) || 0,
      }),
    [monthlyGross, ratePercent, downPercent, taxInsAnnualPct]
  );

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Monthly Gross Income"
          value={monthlyGross}
          onChange={setMonthlyGross}
          prefix="$"
          placeholder="7000"
        />
        <CalculatorInput
          label="Mortgage Rate"
          value={ratePercent}
          onChange={setRatePercent}
          suffix="%"
          placeholder="6.5"
        />
        <CalculatorInput
          label="Down Payment"
          value={downPercent}
          onChange={setDownPercent}
          suffix="%"
          placeholder="10"
        />
        <CalculatorInput
          label="Taxes + Insurance (annual)"
          value={taxInsAnnualPct}
          onChange={setTaxInsAnnualPct}
          suffix="%"
          placeholder="1.5"
        />
      </div>

      <CalculatorOutput
        label="Max Purchase Price"
        value={fmt(result.maxPurchasePrice)}
        period="using the 28% rule"
        breakdown={[
          { label: "Max monthly PITI (28% of gross)", value: fmt(result.maxPiti) },
          { label: "Loan amount", value: fmt(result.maxLoan) },
          { label: "Down payment", value: fmt(result.downPayment), highlight: true },
          { label: "Est. monthly P&I", value: fmt(result.monthlyPI) },
          { label: "Est. monthly tax + insurance", value: fmt(result.monthlyTaxIns) },
        ]}
      />

      {result.maxPurchasePrice > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          On {fmt(parseFloat(monthlyGross))}/month gross income at a {ratePercent}% mortgage
          rate, you can support a home around{" "}
          <strong className="text-brand-navy">{fmt(result.maxPurchasePrice)}</strong>{" "}
          with {downPercent}% down. Total monthly housing cost would be ~
          {fmt(result.monthlyPI + result.monthlyTaxIns)}, matching the Fannie Mae 28% rule.
          {parseFloat(downPercent) < 20 &&
            " Note: with under 20% down, expect to also pay PMI (typically 0.3-1.5% of the loan annually) until you reach 20% equity."}
        </p>
      )}
    </div>
  );
}
