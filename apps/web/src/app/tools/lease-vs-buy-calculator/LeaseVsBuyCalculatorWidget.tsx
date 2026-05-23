"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeLeaseVsBuy } from "@/lib/calculators/leaseVsBuy";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function LeaseVsBuyCalculatorWidget() {
  const [leasePayment, setLeasePayment] = useState("350");
  const [leaseMonths, setLeaseMonths] = useState("36");
  const [buyPayment, setBuyPayment] = useState("500");
  const [buyMonths, setBuyMonths] = useState("36");
  const [residualValue, setResidualValue] = useState("18000");

  const result = useMemo(() => {
    return computeLeaseVsBuy(
      parseFloat(leasePayment) || 0,
      parseInt(leaseMonths) || 0,
      parseFloat(buyPayment) || 0,
      parseInt(buyMonths) || 0,
      parseFloat(residualValue) || 0
    );
  }, [leasePayment, leaseMonths, buyPayment, buyMonths, residualValue]);

  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <p className="text-sm font-semibold text-brand-navy">Lease Option</p>
        <div className="grid gap-4 sm:grid-cols-2">
          <CalculatorInput label="Monthly Lease" value={leasePayment} onChange={setLeasePayment} prefix="$" placeholder="350" />
          <CalculatorInput label="Lease Term" value={leaseMonths} onChange={setLeaseMonths} suffix="months" placeholder="36" />
        </div>
      </div>

      <div className="space-y-2">
        <p className="text-sm font-semibold text-brand-navy">Buy Option</p>
        <div className="grid gap-4 sm:grid-cols-2">
          <CalculatorInput label="Monthly Payment" value={buyPayment} onChange={setBuyPayment} prefix="$" placeholder="500" />
          <CalculatorInput label="Compare Over" value={buyMonths} onChange={setBuyMonths} suffix="months" placeholder="36" />
        </div>
        <CalculatorInput
          label="Car Value at End of Period"
          value={residualValue}
          onChange={setResidualValue}
          prefix="$"
          placeholder="18000"
        />
      </div>

      <CalculatorOutput
        label="Winner"
        value={result.winner === "buy" ? "Buying" : result.winner === "lease" ? "Leasing" : "Roughly tied"}
        period={result.winner !== "tie" ? `saves ${fmt(result.difference)}` : ""}
        breakdown={[
          { label: "Lease total cost", value: fmt(result.leaseTotalCost) },
          { label: "Buy total payments", value: fmt(result.buyTotalPayments) },
          { label: "Buy net cost (after car value)", value: fmt(result.buyNetCost), highlight: true },
          { label: "Difference", value: fmt(result.difference) },
        ]}
      />

      {result.leaseTotalCost > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          Leasing for {leaseMonths} months costs <strong className="text-brand-navy">{fmt(result.leaseTotalCost)}</strong>{" "}
          and leaves you with nothing. Buying costs {fmt(result.buyTotalPayments)} in payments, but the car&apos;s{" "}
          {fmt(parseFloat(residualValue))} resale value brings your net cost to{" "}
          <strong className="text-brand-navy">{fmt(result.buyNetCost)}</strong>.{" "}
          {result.winner === "buy"
            ? `Buying wins by ${fmt(result.difference)}.`
            : result.winner === "lease"
              ? `Leasing wins by ${fmt(result.difference)} — but you'll need to lease again.`
              : "Either option costs about the same — pick based on lifestyle preference."}
        </p>
      )}
    </div>
  );
}
