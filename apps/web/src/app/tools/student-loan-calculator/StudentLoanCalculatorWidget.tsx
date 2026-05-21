"use client";

import { useState, useMemo } from "react";
import { CalculatorInput } from "@/components/calculator/CalculatorInput";
import { CalculatorOutput } from "@/components/calculator/CalculatorOutput";
import { computeStudentLoan, computeIDRPayment, computePSLF } from "@/lib/calculators/student-loan";

function fmt(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function fmtDetailed(n: number): string {
  if (!isFinite(n)) return "N/A";
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function StudentLoanCalculatorWidget() {
  const [balance, setBalance] = useState("35000");
  const [rate, setRate] = useState("5.5");
  const [years, setYears] = useState("10");
  const [annualIncome, setAnnualIncome] = useState("50000");

  const standard = useMemo(() => {
    return computeStudentLoan(
      parseFloat(balance) || 0,
      parseFloat(rate) || 0,
      parseFloat(years) || 0
    );
  }, [balance, rate, years]);

  const idrMonthly = useMemo(() => {
    return computeIDRPayment(parseFloat(annualIncome) || 0, 10);
  }, [annualIncome]);

  const pslf = useMemo(() => {
    return computePSLF(parseFloat(balance) || 0, idrMonthly);
  }, [balance, idrMonthly]);

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Loan Balance" value={balance} onChange={setBalance} prefix="$" placeholder="35000" />
        <CalculatorInput label="Interest Rate" value={rate} onChange={setRate} suffix="%" placeholder="5.5" />
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <CalculatorInput label="Repayment Term" value={years} onChange={setYears} suffix="years" placeholder="10" />
        <CalculatorInput
          label="Annual Income (for IDR)"
          value={annualIncome}
          onChange={setAnnualIncome}
          prefix="$"
          placeholder="50000"
          helper="Used for income-driven repayment estimate"
        />
      </div>

      <CalculatorOutput
        label="Standard Repayment"
        value={fmtDetailed(standard.monthlyPayment)}
        period="/month"
        breakdown={[
          { label: "Total paid over loan life", value: fmt(standard.totalPaid) },
          { label: "Total interest", value: fmt(standard.totalInterest), highlight: true },
          { label: "Repayment period", value: `${standard.months} months (${(standard.months / 12).toFixed(1)} years)` },
          { label: "IDR payment (10% plan)", value: fmtDetailed(idrMonthly) },
          { label: "PSLF: total you pay (120 payments)", value: fmt(pslf.totalPaid) },
          { label: "PSLF: amount forgiven", value: fmt(pslf.amountForgiven), highlight: pslf.amountForgiven > 0 },
        ]}
      />

      {parseFloat(balance) > 0 && (
        <p className="text-sm text-brand-muted leading-relaxed">
          A {fmt(parseFloat(balance))} loan at {rate}% for {years} years costs{" "}
          <strong className="text-brand-navy">{fmtDetailed(standard.monthlyPayment)}/month</strong> with{" "}
          {fmt(standard.totalInterest)} in total interest. On an IDR plan at your income, you would
          pay {fmtDetailed(idrMonthly)}/month. With PSLF after 10 years of public service,{" "}
          {fmt(pslf.amountForgiven)} would be forgiven tax-free.
        </p>
      )}
    </div>
  );
}
