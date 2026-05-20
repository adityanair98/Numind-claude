"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorSelect } from "@/components/calculator/CalculatorSelect";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { convertSalary, estimateAfterTax, type PayPeriod } from "@/lib/calculators/salary";

const periodOptions = [
  { label: "Hourly", value: "hourly" },
  { label: "Weekly", value: "weekly" },
  { label: "Biweekly (every 2 weeks)", value: "biweekly" },
  { label: "Monthly", value: "monthly" },
  { label: "Annual", value: "annual" },
];

function fmt(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtHourly(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function SalaryCalculatorWidget() {
  const [amount, setAmount] = useState("50000");
  const [period, setPeriod] = useState<PayPeriod>("annual");
  const [hours, setHours] = useState("40");

  const result = useMemo(() => {
    const num = parseFloat(amount) || 0;
    const hrs = parseFloat(hours) || 40;
    return convertSalary(num, period, hrs);
  }, [amount, period, hours]);

  const afterTax = estimateAfterTax(result.annual);

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput
          label="Pay Amount"
          value={amount}
          onChange={setAmount}
          prefix="$"
          placeholder="50000"
        />
        <CalculatorSelect
          label="Pay Period"
          value={period}
          onChange={(v) => setPeriod(v as PayPeriod)}
          options={periodOptions}
        />
      </div>

      {period === "hourly" && (
        <CalculatorInput
          label="Hours per Week"
          value={hours}
          onChange={setHours}
          placeholder="40"
          helper="Standard full-time is 40 hours"
        />
      )}

      <CalculatorOutput
        label="Annual Salary"
        value={fmt(result.annual)}
        breakdown={[
          { label: "Hourly", value: fmtHourly(result.hourly) },
          { label: "Weekly", value: fmt(result.weekly) },
          { label: "Biweekly", value: fmt(result.biweekly) },
          { label: "Monthly", value: fmt(result.monthly) },
          { label: "Annual", value: fmt(result.annual), highlight: true },
          { label: "After tax (est. ~25%)", value: fmt(afterTax) },
        ]}
      />
    </div>
  );
}
