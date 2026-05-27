import type { Metadata } from "next";
import Link from "next/link";
import { buildMetadata } from "@/lib/seo/metadata";
import { packRegistry } from "@/lib/content/packs";
import { ScrollReveal } from "@/components/landing/ScrollReveal";

export const metadata: Metadata = buildMetadata({
  title: "Life-Event Paths — Money decisions you're actually making | Numind",
  description:
    "Curated lesson sequences for the canonical money decisions: first paycheck, first apartment, credit card cleanup, open enrollment, buying a home, student loans, investing starter, car buying.",
  path: "/paths",
});

export default function PathsIndexPage() {
  return (
    <div className="mx-auto max-w-4xl px-screen py-12">
      <ScrollReveal>
        <div className="text-center mb-10">
          <h1 className="font-display text-3xl font-bold text-brand-navy sm:text-4xl">
            Life-Event Paths
          </h1>
          <p className="mt-3 text-brand-muted max-w-2xl mx-auto leading-relaxed">
            Most money decisions don&apos;t come from a finance textbook — they come from a
            moment. The first paycheck. The first apartment. Open enrollment week. The car
            purchase. Each path bundles the lessons that map to one of those moments, in the
            order you&apos;d actually walk through them.
          </p>
        </div>
      </ScrollReveal>

      <ScrollReveal stagger={100} className="grid gap-5 sm:grid-cols-2">
        {packRegistry.map((pack) => (
          <Link
            key={pack.id}
            href={`/paths/${pack.id}`}
            className="group flex h-full flex-col cursor-pointer rounded-card border border-brand-navy/8 bg-brand-card p-6 shadow-sm hover:border-brand-teal/40 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200"
          >
            <div className="mb-3 flex items-center justify-between text-xs text-brand-muted">
              <span className="font-medium uppercase tracking-wide">
                {pack.lessonIds.length} lessons
              </span>
              <span>~{pack.estimatedMinutes} min</span>
            </div>
            <h2 className="font-display text-xl font-bold text-brand-navy group-hover:text-brand-teal transition-colors duration-200">
              {pack.title}
            </h2>
            <p className="mt-1.5 text-sm font-medium text-brand-navy/80">
              {pack.tagline}
            </p>
            <p className="mt-3 text-sm text-brand-muted leading-relaxed">
              {pack.hook}
            </p>
            <span className="mt-4 inline-flex items-center text-sm font-medium text-brand-teal group-hover:underline">
              See the path →
            </span>
          </Link>
        ))}
      </ScrollReveal>

      <ScrollReveal>
        <div className="mt-12 rounded-card border border-brand-navy/8 bg-brand-bg p-6 text-center">
          <p className="text-sm text-brand-muted leading-relaxed">
            All {packRegistry.length} paths are curated sequences of lessons from the Numind iOS
            app. Each lesson is a 2-3 minute micro-lesson covering one decision, with the mental
            math shortcut you can actually use in the moment.
          </p>
          <a
            href="https://apps.apple.com/app/numind"
            target="_blank"
            rel="noopener noreferrer"
            className="mt-3 inline-block cursor-pointer rounded-button bg-brand-navy px-5 py-2.5 text-sm font-medium text-white hover:bg-brand-navy/90 transition-colors duration-200"
          >
            Download Numind for iOS
          </a>
        </div>
      </ScrollReveal>
    </div>
  );
}
