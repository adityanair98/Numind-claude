import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { investmentShortcut } from "@/lib/content/shortcuts";
import { investmentFAQs } from "@/lib/content/faqs";
import { InvestmentCalculatorWidget } from "./InvestmentCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Investment Calculator — Compound Interest & Rule of 72",
  description:
    "See how your money grows with compound interest over time. Enter your initial investment, monthly contributions, and expected return to project your balance.",
  path: "/tools/investment-calculator",
});

export default function InvestmentCalculatorPage() {
  return (
    <CalculatorShell
      slug="investment-calculator"
      name="Investment Calculator"
      tagline="See how compound interest grows your money over time"
      calculator={<InvestmentCalculatorWidget />}
      shortcut={investmentShortcut}
      faqs={investmentFAQs}
      relatedSlugs={["hysa-calculator", "401k-impact-calculator", "salary-calculator"]}
    />
  );
}
