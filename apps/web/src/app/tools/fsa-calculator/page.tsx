import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { fsaShortcut } from "@/lib/content/shortcuts";
import { fsaFAQs } from "@/lib/content/faqs";
import { FSACalculatorWidget } from "./FSACalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "FSA Calculator — How Much to Elect Without Losing Money",
  description:
    "Find your FSA break-even election. Avoid losing money to use-it-or-lose-it. Free, no sign-up required.",
  path: "/tools/fsa-calculator",
});

export default function FSACalculatorPage() {
  return (
    <CalculatorShell
      slug="fsa-calculator"
      name="FSA Calculator"
      tagline="Calculate your safe FSA election — tax savings, break-even spend, and net result"
      calculator={<FSACalculatorWidget />}
      shortcut={fsaShortcut}
      faqs={fsaFAQs}
      relatedSlugs={["insurance-calculator", "paycheck-calculator", "life-insurance-calculator"]}
    />
  );
}
