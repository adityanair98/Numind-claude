import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { studentLoanShortcut } from "@/lib/content/shortcuts";
import { studentLoanFAQs } from "@/lib/content/faqs";
import { StudentLoanCalculatorWidget } from "./StudentLoanCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Student Loan Calculator — Repayment, Refinancing & PSLF",
  description:
    "Calculate student loan payments, total interest, refinancing savings, and PSLF forgiveness amounts. Compare repayment plans. Free, no sign-up.",
  path: "/tools/student-loan-calculator",
});

export default function StudentLoanCalculatorPage() {
  return (
    <CalculatorShell
      slug="student-loan-calculator"
      name="Student Loan Calculator"
      tagline="Compare repayment plans and see how much you can save with refinancing or PSLF"
      calculator={<StudentLoanCalculatorWidget />}
      shortcut={studentLoanShortcut}
      faqs={studentLoanFAQs}
      relatedSlugs={["loan-calculator", "salary-calculator", "paycheck-calculator"]}
    />
  );
}
