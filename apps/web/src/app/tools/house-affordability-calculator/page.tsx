import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { houseAffordabilityShortcut } from "@/lib/content/shortcuts";
import { houseAffordabilityFAQs } from "@/lib/content/faqs";
import { HouseAffordabilityCalculatorWidget } from "./HouseAffordabilityCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "How Much House Can I Afford? Free Calculator | Numind",
  description:
    "Estimate your max home purchase price using the Fannie Mae 28% rule plus rate, down payment, taxes, and insurance. Free, no sign-up.",
  path: "/tools/house-affordability-calculator",
});

export default function HouseAffordabilityCalculatorPage() {
  return (
    <CalculatorShell
      name="House Affordability Calculator"
      tagline="Max purchase price from income, mortgage rate, down payment, taxes, and insurance"
      calculator={<HouseAffordabilityCalculatorWidget />}
      shortcut={houseAffordabilityShortcut}
      faqs={houseAffordabilityFAQs}
      relatedSlugs={["rent-calculator", "loan-calculator", "paycheck-calculator"]}
    />
  );
}
