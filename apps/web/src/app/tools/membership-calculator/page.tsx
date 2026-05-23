import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { membershipShortcut } from "@/lib/content/shortcuts";
import { membershipFAQs } from "@/lib/content/faqs";
import { MembershipCalculatorWidget } from "./MembershipCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Membership Break-even Calculator — Is It Worth It?",
  description:
    "Calculate when Costco, DashPass, Uber One, Amazon Prime, and other memberships actually pay for themselves. Free.",
  path: "/tools/membership-calculator",
});

export default function MembershipCalculatorPage() {
  return (
    <CalculatorShell
      name="Membership Break-even Calculator"
      tagline="Find your break-even uses — when DashPass, Costco, Uber One actually start saving you money"
      calculator={<MembershipCalculatorWidget />}
      shortcut={membershipShortcut}
      faqs={membershipFAQs}
      relatedSlugs={["discount-calculator", "bnpl-calculator", "investment-calculator"]}
    />
  );
}
