import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { loanShortcut } from "@/lib/content/shortcuts";
import { loanFAQs } from "@/lib/content/faqs";
import { LoanCalculatorWidget } from "./LoanCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Loan Calculator — Total Interest & Payoff Timeline",
  description:
    "Calculate monthly payments, total interest, and payoff timeline for any loan. See the true cost of borrowing. Free, no sign-up.",
  path: "/tools/loan-calculator",
});

export default function LoanCalculatorPage() {
  return (
    <CalculatorShell
      slug="loan-calculator"
      name="Loan Calculator"
      tagline="See the true cost of any loan — monthly payment, total interest, and payoff timeline"
      calculator={<LoanCalculatorWidget />}
      shortcut={loanShortcut}
      faqs={loanFAQs}
      relatedSlugs={["credit-card-payoff-calculator", "balance-transfer-calculator", "house-affordability-calculator"]}
    />
  );
}
