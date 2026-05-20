import { type ReactNode } from "react";
import { NumindCard } from "@/components/ui/NumindCard";
import { ShortcutTeaser } from "@/components/calculator/ShortcutTeaser";
import { MentalMathCard } from "@/components/calculator/MentalMathCard";
import { FAQSection, type FAQ } from "@/components/calculator/FAQSection";
import { AppCTA } from "@/components/calculator/AppCTA";
import { RelatedTools } from "@/components/calculator/RelatedTools";
import { StructuredData } from "@/components/seo/StructuredData";
import { ScrollReveal } from "@/components/landing/ScrollReveal";

export interface ShortcutContent {
  title: string;
  /** One-line teaser shown inline below the calculator (high-visibility spot) */
  teaser: string;
  steps: string[];
  example: string;
}

interface CalculatorShellProps {
  /** Page title displayed in the hero */
  name: string;
  /** One-line value prop under the title */
  tagline: string;
  /** The interactive calculator widget */
  calculator: ReactNode;
  /** Mental math shortcut content */
  shortcut: ShortcutContent;
  /** FAQ entries (also rendered as schema.org/FAQPage) */
  faqs: FAQ[];
  /** Slugs of related calculator tools */
  relatedSlugs?: string[];
  /** Additional content sections between shortcut and FAQ */
  children?: ReactNode;
}

export function CalculatorShell({
  name,
  tagline,
  calculator,
  shortcut,
  faqs,
  relatedSlugs = [],
  children,
}: CalculatorShellProps) {
  return (
    <>
      {/* Schema.org FAQPage */}
      <StructuredData
        data={{
          "@context": "https://schema.org",
          "@type": "FAQPage",
          mainEntity: faqs.map((faq) => ({
            "@type": "Question",
            name: faq.question,
            acceptedAnswer: {
              "@type": "Answer",
              text: faq.answer,
            },
          })),
        }}
      />

      {/* Compact header — calculator-first, above the fold */}
      <div className="mx-auto max-w-3xl px-screen pt-8 pb-section">
        <div className="mb-6">
          <h1 className="font-display text-2xl font-bold text-brand-navy sm:text-3xl">
            {name}
          </h1>
          <p className="mt-1.5 text-brand-muted">{tagline}</p>
        </div>

        {/* Calculator widget — no animation, instant */}
        <NumindCard className="mb-4">{calculator}</NumindCard>

        {/* Inline teaser — highest visibility, right after calculator */}
        <ShortcutTeaser teaser={shortcut.teaser} className="mb-section" />

        {/* Mental math shortcut (full version) — scroll reveal */}
        <ScrollReveal>
          <MentalMathCard shortcut={shortcut} className="mb-section" />
        </ScrollReveal>

        {/* Additional content */}
        {children && <ScrollReveal>{children}</ScrollReveal>}

        {/* FAQ — scroll reveal */}
        <ScrollReveal>
          <FAQSection faqs={faqs} className="mb-section" />
        </ScrollReveal>

        {/* App CTA — scroll reveal with scale */}
        <ScrollReveal direction="scale">
          <AppCTA className="mb-section" />
        </ScrollReveal>

        {/* Related tools — scroll reveal */}
        {relatedSlugs.length > 0 && (
          <ScrollReveal>
            <RelatedTools slugs={relatedSlugs} />
          </ScrollReveal>
        )}
      </div>
    </>
  );
}
