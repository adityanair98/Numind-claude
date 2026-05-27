import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { ccPayoffShortcut } from "@/lib/content/shortcuts";
import { ccPayoffFAQs } from "@/lib/content/faqs";
import { CreditCardPayoffCalculatorWidget } from "./CreditCardPayoffCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Credit Card Payoff Calculator — Time to Debt-Free | Numind",
  description:
    "See exactly how many months until you're debt-free at a fixed monthly payment — plus how much extra payment shaves off the timeline. Free, no sign-up.",
  path: "/tools/credit-card-payoff-calculator",
});

export default function CreditCardPayoffCalculatorPage() {
  return (
    <CalculatorShell
      name="Credit Card Payoff Calculator"
      tagline="How many months until the balance is gone — and how much you pay in interest along the way"
      calculator={<CreditCardPayoffCalculatorWidget />}
      shortcut={ccPayoffShortcut}
      faqs={ccPayoffFAQs}
      relatedSlugs={["loan-calculator", "bnpl-calculator", "balance-transfer-calculator"]}
    />
  );
}
