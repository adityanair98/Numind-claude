import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { paycheckShortcut } from "@/lib/content/shortcuts";
import { paycheckFAQs } from "@/lib/content/faqs";
import { PaycheckCalculatorWidget } from "./PaycheckCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Paycheck Calculator 2025 — Take-Home Pay After Taxes",
  description:
    "Estimate your take-home pay after federal income tax, state tax, Social Security, and Medicare. Free paycheck calculator for all 50 states. No sign-up required.",
  path: "/tools/paycheck-calculator",
});

export default function PaycheckCalculatorPage() {
  return (
    <CalculatorShell
      slug="paycheck-calculator"
      name="Paycheck Calculator"
      tagline="See your take-home pay after federal, state, and FICA taxes"
      calculator={<PaycheckCalculatorWidget />}
      shortcut={paycheckShortcut}
      faqs={paycheckFAQs}
      relatedSlugs={["salary-calculator", "401k-impact-calculator", "house-affordability-calculator"]}
    />
  );
}
