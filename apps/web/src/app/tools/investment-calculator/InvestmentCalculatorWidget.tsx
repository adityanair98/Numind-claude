"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeInvestment } from "@/lib/calculators/investment";

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export function InvestmentCalculatorWidget() {
  const [principal, setPrincipal] = useState("10000");
  const [monthly, setMonthly] = useState("500");
  const [rate, setRate] = useState("7");
  const [years, setYears] = useState("20");

  const result = useMemo(() => {
    return computeInvestment(
      parseFloat(principal) || 0,
      parseFloat(monthly) || 0,
      parseFloat(rate) || 0,
      parseFloat(years) || 0
    );
  }, [principal, monthly, rate, years]);

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Initial Investment" value={principal} onChange={setPrincipal} prefix="$" placeholder="10000" />
        <CalculatorInput label="Monthly Contribution" value={monthly} onChange={setMonthly} prefix="$" placeholder="500" />
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Annual Return Rate" value={rate} onChange={setRate} suffix="%" placeholder="7" helper="S&P 500 historical average: ~7% after inflation" />
        <CalculatorInput label="Time Period" value={years} onChange={setYears} suffix="years" placeholder="20" />
      </div>

      <CalculatorOutput
        label="Final Balance"
        value={fmt(result.finalBalance)}
        breakdown={[
          { label: "Total contributed", value: fmt(result.totalContributed) },
          { label: "Interest earned", value: fmt(result.totalInterest), highlight: true },
          { label: "Rule of 72: doubles in", value: result.yearsToDouble === Infinity ? "N/A" : `~${result.yearsToDouble.toFixed(1)} years` },
        ]}
      />
    </div>
  );
}
