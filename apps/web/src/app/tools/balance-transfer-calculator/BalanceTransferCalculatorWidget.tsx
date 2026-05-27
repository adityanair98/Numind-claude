"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeBalanceTransfer } from "@/lib/calculators/balanceTransfer";

function money(n: number): string {
  if (!isFinite(n) || n <= 0) return "$0";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

export function BalanceTransferCalculatorWidget() {
  const [balance, setBalance] = useState("8000");
  const [oldApr, setOldApr] = useState("22");
  const [promoMonths, setPromoMonths] = useState("18");
  const [feePct, setFeePct] = useState("3");

  const result = useMemo(
    () =>
      computeBalanceTransfer({
        balance: parseFloat(balance) || 0,
        oldApr: parseFloat(oldApr) || 0,
        promoMonths: parseFloat(promoMonths) || 0,
        feePct: parseFloat(feePct) || 0,
      }),
    [balance, oldApr, promoMonths, feePct]
  );

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Balance to Transfer"
          value={balance}
          onChange={setBalance}
          prefix="$"
          placeholder="8000"
        />
        <CalculatorInput
          label="Current Card APR"
          value={oldApr}
          onChange={setOldApr}
          suffix="%"
          placeholder="22"
        />
        <CalculatorInput
          label="0% Promo Length"
          value={promoMonths}
          onChange={setPromoMonths}
          suffix="months"
          placeholder="18"
        />
        <CalculatorInput
          label="Transfer Fee"
          value={feePct}
          onChange={setFeePct}
          suffix="%"
          placeholder="3"
        />
      </div>

      <CalculatorOutput
        label={result.worthIt ? "Net Benefit" : "Net Loss"}
        value={money(Math.abs(result.netBenefit))}
        period={result.worthIt ? "saved by transferring" : "lost to the fee"}
        breakdown={[
          { label: "Transfer fee", value: money(result.fee) },
          { label: "Interest avoided during promo", value: money(result.interestSaved), highlight: true },
          { label: "Required monthly to clear before promo ends", value: money(result.requiredMonthly) },
          {
            label: "Breakeven APR (transfer worth it above this)",
            value: `${result.breakevenApr.toFixed(2)}%`,
          },
        ]}
      />

      {result.fee > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          Transferring {money(parseFloat(balance))} from a {oldApr}% APR card to a{" "}
          {promoMonths}-month 0% promo with a {feePct}% fee{" "}
          {result.worthIt ? (
            <>
              <strong className="text-brand-navy">
                saves about {money(result.netBenefit)}
              </strong>{" "}
              vs leaving the balance on the old card — provided you pay roughly{" "}
              {money(result.requiredMonthly)}/month to clear it before the promo ends.
            </>
          ) : (
            <>
              would cost about {money(Math.abs(result.netBenefit))} more than just
              keeping the balance in place — the fee outweighs the interest you&apos;d
              avoid. The breakeven APR is {result.breakevenApr.toFixed(2)}%.
            </>
          )}
        </p>
      )}
    </div>
  );
}
