import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { insuranceShortcut } from "@/lib/content/shortcuts";
import { insuranceFAQs } from "@/lib/content/faqs";
import { InsuranceCalculatorWidget } from "./InsuranceCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Insurance Calculator — Compare Health Plan Costs",
  description:
    "Compare health insurance plans by total annual cost. See premiums, deductibles, and out-of-pocket maximums side by side. Free, no sign-up.",
  path: "/tools/insurance-calculator",
});

export default function InsuranceCalculatorPage() {
  return (
    <CalculatorShell
      slug="insurance-calculator"
      name="Insurance Calculator"
      tagline="Compare health plans by their true annual cost — not just the monthly premium"
      calculator={<InsuranceCalculatorWidget />}
      shortcut={insuranceShortcut}
      faqs={insuranceFAQs}
      relatedSlugs={["paycheck-calculator", "salary-calculator", "loan-calculator"]}
    />
  );
}
