import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { carShortcut } from "@/lib/content/shortcuts";
import { carFAQs } from "@/lib/content/faqs";
import { CarCalculatorWidget } from "./CarCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Car Calculator — Affordability & True Cost",
  description:
    "Check if you can afford a car using the 20/4/10 rule. See total cost with interest, down payment impact, and first-year depreciation. Free, no sign-up.",
  path: "/tools/car-calculator",
});

export default function CarCalculatorPage() {
  return (
    <CalculatorShell
      slug="car-calculator"
      name="Car Affordability Calculator"
      tagline="See the true cost of buying a car — and whether you can afford it"
      calculator={<CarCalculatorWidget />}
      shortcut={carShortcut}
      faqs={carFAQs}
      relatedSlugs={["loan-calculator", "paycheck-calculator", "rent-calculator"]}
    />
  );
}
