import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { discountShortcut } from "@/lib/content/shortcuts";
import { discountFAQs } from "@/lib/content/faqs";
import { DiscountCalculatorWidget } from "./DiscountCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Discount Calculator — Percent Off, Sale Price, Stacked Discounts",
  description:
    "Calculate savings and final price for any discount. Handles stacked discounts too. Free shopping calculator with mental math tips.",
  path: "/tools/discount-calculator",
});

export default function DiscountCalculatorPage() {
  return (
    <CalculatorShell
      slug="discount-calculator"
      name="Discount Calculator"
      tagline="Find out how much you save and what you actually pay"
      calculator={<DiscountCalculatorWidget />}
      shortcut={discountShortcut}
      faqs={discountFAQs}
      relatedSlugs={["salary-calculator", "rent-calculator"]}
    />
  );
}
