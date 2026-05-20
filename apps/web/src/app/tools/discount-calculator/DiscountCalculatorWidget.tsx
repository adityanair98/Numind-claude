"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeDiscount, computeStackedDiscount } from "@/lib/calculators/discount";

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function DiscountCalculatorWidget() {
  const [price, setPrice] = useState("80");
  const [discount1, setDiscount1] = useState("25");
  const [discount2, setDiscount2] = useState("");

  const result = useMemo(() => {
    const p = parseFloat(price) || 0;
    const d1 = parseFloat(discount1) || 0;
    const d2 = parseFloat(discount2) || 0;

    if (d2 > 0) {
      return { stacked: true as const, ...computeStackedDiscount(p, d1, d2) };
    }
    return { stacked: false as const, ...computeDiscount(p, d1) };
  }, [price, discount1, discount2]);

  return (
    <div className="space-y-6">
      <CalculatorInput label="Original Price" value={price} onChange={setPrice} prefix="$" placeholder="80" />
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Discount" value={discount1} onChange={setDiscount1} suffix="% off" placeholder="25" />
        <CalculatorInput
          label="Second Discount (stacked)"
          value={discount2}
          onChange={setDiscount2}
          suffix="% off"
          placeholder="0"
          helper="Optional — for coupon + sale combos"
        />
      </div>

      <CalculatorOutput
        label="You Pay"
        value={fmt(result.salePrice)}
        breakdown={[
          { label: "Original price", value: fmt(result.originalPrice) },
          { label: "You save", value: fmt(result.discountAmount), highlight: true },
          ...(result.stacked
            ? [
                {
                  label: `Combined discount`,
                  value: `${result.actualDiscountPercent.toFixed(1)}% (not ${result.naiveDiscountPercent}%)`,
                },
              ]
            : []),
        ]}
      />

      {result.stacked && (
        <p className="text-sm text-brand-muted leading-relaxed">
          Stacked discounts don&apos;t add up! {parseFloat(discount1)}% + {parseFloat(discount2)}% off
          is actually <strong className="text-brand-navy">{result.actualDiscountPercent.toFixed(1)}% off</strong>,
          not {result.naiveDiscountPercent}%. The second discount applies to the already-reduced price.
        </p>
      )}
    </div>
  );
}
