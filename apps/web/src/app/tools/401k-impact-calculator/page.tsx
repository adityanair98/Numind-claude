import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { k401ImpactShortcut } from "@/lib/content/shortcuts";
import { k401ImpactFAQs } from "@/lib/content/faqs";
import { K401ImpactCalculatorWidget } from "./K401ImpactCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "401(k) Take-Home Impact Calculator | Numind",
  description:
    "See what a pre-tax 401(k) contribution actually costs your paycheck after the tax break — plus the employer match it captures. Free, no sign-up.",
  path: "/tools/401k-impact-calculator",
});

export default function K401ImpactCalculatorPage() {
  return (
    <CalculatorShell
      slug="401k-impact-calculator"
      name="401(k) Impact Calculator"
      tagline="What a 6% 401(k) contribution actually costs you in take-home pay — after the tax break"
      calculator={<K401ImpactCalculatorWidget />}
      shortcut={k401ImpactShortcut}
      faqs={k401ImpactFAQs}
      relatedSlugs={["paycheck-calculator", "investment-calculator", "salary-calculator"]}
    />
  );
}
