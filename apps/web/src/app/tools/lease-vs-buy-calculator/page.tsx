import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";
import { CalculatorShell } from "@/components/calculator/CalculatorShell";
import { leaseVsBuyShortcut } from "@/lib/content/shortcuts";
import { leaseVsBuyFAQs } from "@/lib/content/faqs";
import { LeaseVsBuyCalculatorWidget } from "./LeaseVsBuyCalculatorWidget";

export const metadata: Metadata = buildMetadata({
  title: "Lease vs Buy Calculator — Compare 3-Year Car Cost",
  description:
    "Compare the true cost of leasing vs buying a car over the same period, including residual value. Free, no sign-up.",
  path: "/tools/lease-vs-buy-calculator",
});

export default function LeaseVsBuyCalculatorPage() {
  return (
    <CalculatorShell
      name="Lease vs Buy Calculator"
      tagline="See which actually costs more — leasing or buying — over the same period"
      calculator={<LeaseVsBuyCalculatorWidget />}
      shortcut={leaseVsBuyShortcut}
      faqs={leaseVsBuyFAQs}
      relatedSlugs={["car-calculator", "loan-calculator", "membership-calculator"]}
    />
  );
}
