import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { balanceTransferShortcut } from "@/lib/content/shortcuts";
import { balanceTransferFAQs } from "@/lib/content/faqs";
import { BalanceTransferCalculatorWidget } from "./BalanceTransferCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Balance Transfer Calculator — Fee vs Interest Saved | Numind",
  description:
    "See if a balance transfer's 0% promo APR is worth the 3-5% fee — and the monthly payment needed to clear the debt before the promo ends.",
  path: "/tools/balance-transfer-calculator",
});

export default function BalanceTransferCalculatorPage() {
  return (
    <CalculatorShell
      name="Balance Transfer Calculator"
      tagline="Is the 0% APR worth the transfer fee? Net benefit, breakeven, and a payoff plan in one shot"
      calculator={<BalanceTransferCalculatorWidget />}
      shortcut={balanceTransferShortcut}
      faqs={balanceTransferFAQs}
      relatedSlugs={["credit-card-payoff-calculator", "loan-calculator", "bnpl-calculator"]}
    />
  );
}
