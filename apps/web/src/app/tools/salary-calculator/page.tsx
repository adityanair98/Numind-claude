import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { salaryShortcut } from "@/lib/content/shortcuts";
import { salaryFAQs } from "@/lib/content/faqs";
import { SalaryCalculatorWidget } from "./SalaryCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Salary Converter — Hourly to Annual, Monthly, Biweekly",
  description:
    "Convert between hourly, weekly, biweekly, monthly, and annual salary. Uses the 2,080-hour standard. Free, instant, no sign-up required.",
  path: "/tools/salary-calculator",
});

export default function SalaryCalculatorPage() {
  return (
    <CalculatorShell
      slug="salary-calculator"
      name="Salary Converter"
      tagline="Convert between hourly, weekly, biweekly, monthly, and annual pay instantly"
      calculator={<SalaryCalculatorWidget />}
      shortcut={salaryShortcut}
      faqs={salaryFAQs}
      relatedSlugs={["paycheck-calculator", "401k-impact-calculator", "rent-calculator"]}
    />
  );
}
