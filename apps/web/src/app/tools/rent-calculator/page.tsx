import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { rentShortcut } from "@/lib/content/shortcuts";
import { rentFAQs } from "@/lib/content/faqs";
import { RentCalculatorWidget } from "./RentCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Rent Affordability Calculator — How Much Rent Can I Afford?",
  description:
    "Find out how much rent you can afford based on your salary using the 28% rule. Free calculator with debt-to-income ratio check. No sign-up required.",
  path: "/tools/rent-calculator",
});

export default function RentCalculatorPage() {
  return (
    <CalculatorShell
      name="Rent Affordability Calculator"
      tagline="Find out how much rent you can comfortably afford on your income"
      calculator={<RentCalculatorWidget />}
      shortcut={rentShortcut}
      faqs={rentFAQs}
      relatedSlugs={["salary-calculator", "paycheck-calculator", "loan-calculator"]}
    />
  );
}
