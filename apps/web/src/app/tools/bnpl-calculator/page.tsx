import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { bnplShortcut } from "@/lib/content/shortcuts";
import { bnplFAQs } from "@/lib/content/faqs";
import { BNPLCalculatorWidget } from "./BNPLCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "BNPL Calculator — Real Cost of Buy Now Pay Later",
  description:
    "See the true cost of BNPL plans: late fee impact, surcharge percentage, and stacked plan debt burden. Free, no sign-up.",
  path: "/tools/bnpl-calculator",
});

export default function BNPLCalculatorPage() {
  return (
    <CalculatorShell
      name="BNPL Calculator"
      tagline="The hidden cost of 'just 4 easy payments' — late fees, surcharges, and stacked-plan debt"
      calculator={<BNPLCalculatorWidget />}
      shortcut={bnplShortcut}
      faqs={bnplFAQs}
      relatedSlugs={["loan-calculator", "discount-calculator", "membership-calculator"]}
    />
  );
}
