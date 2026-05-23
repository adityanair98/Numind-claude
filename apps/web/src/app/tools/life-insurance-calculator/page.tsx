import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { lifeInsuranceShortcut } from "@/lib/content/shortcuts";
import { lifeInsuranceFAQs } from "@/lib/content/faqs";
import { LifeInsuranceCalculatorWidget } from "./LifeInsuranceCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Life Insurance Calculator — How Much Do You Need?",
  description:
    "Calculate term life insurance need with the 10× rule and DIME method. Free, no sign-up, no email required.",
  path: "/tools/life-insurance-calculator",
});

export default function LifeInsuranceCalculatorPage() {
  return (
    <CalculatorShell
      name="Life Insurance Calculator"
      tagline="Estimate your term life coverage need with the 10× rule and DIME method"
      calculator={<LifeInsuranceCalculatorWidget />}
      shortcut={lifeInsuranceShortcut}
      faqs={lifeInsuranceFAQs}
      relatedSlugs={["insurance-calculator", "fsa-calculator", "investment-calculator"]}
    />
  );
}
