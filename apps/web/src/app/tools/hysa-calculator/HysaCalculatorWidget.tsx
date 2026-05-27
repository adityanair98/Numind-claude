"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeHysa } from "@/lib/calculators/hysa";

function money(n: number): string {
  if (!isFinite(n) || n <= 0) return "$0";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  });
}

function moneyDetailed(n: number): string {
  if (!isFinite(n)) return "$0.00";
  return n.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

interface HysaCalculatorWidgetProps {
  /** Pre-fill the starting balance (used by /[balance] programmatic pages) */
  defaultBalance?: string;
}

export function HysaCalculatorWidget({
  defaultBalance,
}: HysaCalculatorWidgetProps = {}) {
  const [balance, setBalance] = useState(defaultBalance ?? "10000");
  const [apy, setApy] = useState("4.5");
  const [bigBankApy, setBigBankApy] = useState("0.01");

  const result = useMemo(
    () =>
      computeHysa({
        balance: parseFloat(balance) || 0,
        apy: parseFloat(apy) || 0,
        bigBankApy: parseFloat(bigBankApy) || 0,
      }),
    [balance, apy, bigBankApy]
  );

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-3">
        <CalculatorInput
          label="Balance"
          value={balance}
          onChange={setBalance}
          prefix="$"
          placeholder="10000"
        />
        <CalculatorInput
          label="HYSA APY"
          value={apy}
          onChange={setApy}
          suffix="%"
          placeholder="4.5"
        />
        <CalculatorInput
          label="Big-bank APY"
          value={bigBankApy}
          onChange={setBigBankApy}
          suffix="%"
          placeholder="0.01"
        />
      </div>

      <CalculatorOutput
        label="Annual Interest Earned"
        value={money(result.annualInterest)}
        period={`at ${apy}% APY`}
        breakdown={[
          { label: "Monthly interest", value: moneyDetailed(result.monthlyInterest) },
          { label: "Big-bank annual interest", value: moneyDetailed(result.bigBankAnnualInterest) },
          { label: "Annual gap (free money for switching)", value: money(result.annualGap), highlight: true },
          { label: "Rule of 72 — years to double", value: `${result.yearsToDouble.toFixed(1)} years` },
        ]}
      />

      {result.annualInterest > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {money(parseFloat(balance))} balance at {apy}% APY earns{" "}
          <strong className="text-brand-navy">{money(result.annualInterest)}/year</strong>{" "}
          — vs {moneyDetailed(result.bigBankAnnualInterest)} at the typical big-bank rate of{" "}
          {bigBankApy}% APY. That gap is essentially free money for the act of moving your
          savings account.
        </p>
      )}
    </div>
  );
}
