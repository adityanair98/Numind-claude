import type { Metadata } from "next";
import Link from "next/link";
import { buildMetadata } from "@/lib/seo/metadata";
import { calculatorRegistry } from "@/lib/content/calculators";
import { CalculatorIcon } from "@/components/ui/CalculatorIcon";
import { ScrollReveal } from "@/components/landing/ScrollReveal";

export const metadata: Metadata = buildMetadata({
  title: "Free Financial Calculators",
  description:
    "Free paycheck, salary, rent, investment, discount, and loan calculators. Get instant answers plus the mental math shortcut behind each one.",
  path: "/tools",
});

export default function ToolsPage() {
  return (
    <div className="mx-auto max-w-4xl px-screen py-12">
      <ScrollReveal>
        <div className="text-center mb-10">
          <h1 className="font-display text-3xl font-bold text-brand-navy sm:text-4xl">
            Free Financial Calculators
          </h1>
          <p className="mt-3 text-brand-muted max-w-lg mx-auto">
            Get instant answers — plus the mental math shortcut behind each one, so you can
            eventually do it in your head.
          </p>
        </div>
      </ScrollReveal>

      <ScrollReveal stagger={100} className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {calculatorRegistry.map((calc) => (
          <Link
            key={calc.slug}
            href={`/tools/${calc.slug}`}
            className="group flex h-full flex-col cursor-pointer rounded-card border border-brand-navy/8 bg-brand-card p-5 shadow-sm hover:border-brand-blue/30 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200"
          >
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-brand-blue/8 mb-3 transition-transform duration-300 group-hover:scale-110">
              <CalculatorIcon name={calc.icon} size={20} className="text-brand-blue" />
            </div>
            <h2 className="font-display text-base font-bold text-brand-navy group-hover:text-brand-blue transition-colors duration-200">
              {calc.name}
            </h2>
            <p className="mt-1.5 text-sm text-brand-muted leading-relaxed">
              {calc.description}
            </p>
          </Link>
        ))}
      </ScrollReveal>
    </div>
  );
}
