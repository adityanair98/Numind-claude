import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { hysaShortcut } from "@/lib/content/shortcuts";
import { hysaFAQs } from "@/lib/content/faqs";
import { HysaCalculatorWidget } from "./HysaCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "High-Yield Savings (HYSA) Calculator | Numind",
  description:
    "See how much annual interest your savings earn at a high-yield APY — and how much you're leaving on the table at a big-bank rate. Free, no sign-up.",
  path: "/tools/hysa-calculator",
});

export default function HysaCalculatorPage() {
  return (
    <CalculatorShell
      slug="hysa-calculator"
      name="HYSA Calculator"
      tagline="Annual interest from a high-yield savings account vs the 0.01% your big bank pays"
      calculator={<HysaCalculatorWidget />}
      shortcut={hysaShortcut}
      faqs={hysaFAQs}
      relatedSlugs={["investment-calculator", "salary-calculator", "loan-calculator"]}
    />
  );
}
