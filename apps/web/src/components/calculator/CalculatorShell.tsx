import { type ReactNode } from "react";
import { NumindCard } from "@/components/ui/NumindCard";
import { ShortcutTeaser } from "@/components/calculator/ShortcutTeaser";
import { MentalMathCard } from "@/components/calculator/MentalMathCard";
import { FAQSection, type FAQ } from "@/components/calculator/FAQSection";
import { AppCTA } from "@/components/calculator/AppCTA";
import { RelatedTools } from "@/components/calculator/RelatedTools";
import { CalculatorAttribution } from "@/components/calculator/CalculatorAttribution";
import { StructuredData } from "@/components/seo/StructuredData";
import { BreadcrumbSchema } from "@/components/seo/BreadcrumbSchema";
import { CalculatorAppSchema } from "@/components/seo/CalculatorAppSchema";
import { MentalMathHowToSchema } from "@/components/seo/MentalMathHowToSchema";
import { ScrollReveal } from "@/components/landing/ScrollReveal";
import { calculatorRegistry } from "@/lib/content/calculators";

const SITE_BASE_URL = "https://numind.app";
const DEFAULT_REVIEW_DATE = "2026-05-26";

/**
 * Resolves the last-reviewed date for a given calculator slug from the
 * registry. Programmatic sub-pages (e.g. "paycheck-calculator/california")
 * fall through to the parent calc's date; unknown slugs use the site-wide
 * default (today's audit date).
 */
function resolveLastReviewed(slug: string): string {
  const parent = slug.split("/")[0];
  const entry = calculatorRegistry.find((c) => c.slug === parent);
  return entry?.lastReviewed ?? DEFAULT_REVIEW_DATE;
}

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
  /** Calculator slug used in the URL (e.g. "bnpl-calculator"). Used for canonical URL in JSON-LD. */
  slug: string;
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
  slug,
  calculator,
  shortcut,
  faqs,
  relatedSlugs = [],
  children,
}: CalculatorShellProps) {
  const pageUrl = `${SITE_BASE_URL}/tools/${slug}`;
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

      {/* Schema.org BreadcrumbList — Home > Tools > {Calculator} */}
      <BreadcrumbSchema
        items={[
          { name: "Home", url: SITE_BASE_URL },
          { name: "Tools", url: `${SITE_BASE_URL}/tools` },
          { name, url: pageUrl },
        ]}
      />

      {/* Schema.org WebApplication — calculator-as-app rich card */}
      <CalculatorAppSchema name={name} description={tagline} url={pageUrl} />

      {/* Schema.org HowTo — mental-math shortcut as a procedure */}
      <MentalMathHowToSchema name={name} shortcut={shortcut} url={pageUrl} />

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

        {/* Attribution / E-E-A-T footer: last-reviewed date + links to methodology & editorial standards */}
        <CalculatorAttribution lastReviewed={resolveLastReviewed(slug)} />
      </div>
    </>
  );
}
