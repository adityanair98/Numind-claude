import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { packRegistry, getPackBySlug, lessonTitles } from "@/lib/content/packs";
import { StructuredData } from "@/components/seo/StructuredData";
import { BreadcrumbSchema } from "@/components/seo/BreadcrumbSchema";
import { ScrollReveal } from "@/components/landing/ScrollReveal";

const SITE_BASE_URL = "https://numind.app";

export async function generateStaticParams() {
  return packRegistry.map((p) => ({ slug: p.id }));
}

type Props = {
  params: Promise<{ slug: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const pack = getPackBySlug(slug);
  if (!pack) return {};

  const title = `${pack.title} — ${pack.tagline} | Numind`;
  const description = `${pack.hook} ${pack.lessonIds.length} lessons, ~${pack.estimatedMinutes} minutes.`;

  return {
    title,
    description,
    alternates: {
      canonical: `${SITE_BASE_URL}/paths/${pack.id}`,
    },
    openGraph: {
      title,
      description,
      url: `${SITE_BASE_URL}/paths/${pack.id}`,
      type: "website",
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

export default async function PackLandingPage({ params }: Props) {
  const { slug } = await params;
  const pack = getPackBySlug(slug);
  if (!pack) notFound();

  const pageUrl = `${SITE_BASE_URL}/paths/${pack.id}`;
  const anchorTitle =
    lessonTitles[pack.anchorLessonId] ?? pack.anchorLessonId;

  // ItemList schema — exposes the lesson sequence to search engines as a
  // structured list (helps with rich-result eligibility for curated content).
  const itemListSchema = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: pack.title,
    description: pack.description,
    numberOfItems: pack.lessonIds.length,
    itemListOrder: "https://schema.org/ItemListOrderAscending",
    itemListElement: pack.lessonIds.map((lessonId, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: lessonTitles[lessonId] ?? lessonId,
    })),
  };

  return (
    <>
      <BreadcrumbSchema
        items={[
          { name: "Home", url: SITE_BASE_URL },
          { name: "Paths", url: `${SITE_BASE_URL}/paths` },
          { name: pack.title, url: pageUrl },
        ]}
      />
      <StructuredData data={itemListSchema} />

      <div className="mx-auto max-w-3xl px-screen py-12">
        {/* Hero */}
        <ScrollReveal>
          <div className="mb-8">
            <Link
              href="/paths"
              className="text-sm text-brand-muted hover:text-brand-navy transition-colors"
            >
              ← All paths
            </Link>
            <h1 className="mt-4 font-display text-3xl font-bold text-brand-navy sm:text-4xl">
              {pack.title}
            </h1>
            <p className="mt-2 text-lg font-medium text-brand-navy/80">
              {pack.tagline}
            </p>
            <div className="mt-3 flex items-center gap-4 text-sm text-brand-muted">
              <span>{pack.lessonIds.length} lessons</span>
              <span aria-hidden="true">·</span>
              <span>~{pack.estimatedMinutes} minutes</span>
            </div>
          </div>
        </ScrollReveal>

        {/* Hook + description */}
        <ScrollReveal>
          <div className="mb-8 rounded-card bg-brand-bg p-card">
            <p className="text-base text-brand-navy font-medium leading-relaxed">
              {pack.hook}
            </p>
            <p className="mt-3 text-sm text-brand-muted leading-relaxed">
              {pack.description}
            </p>
          </div>
        </ScrollReveal>

        {/* Anchor lesson — "Start here" */}
        <ScrollReveal>
          <div className="mb-8 rounded-card border-2 border-brand-teal/40 bg-brand-card p-card">
            <span className="inline-block rounded-full bg-brand-teal/10 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-brand-teal">
              Start here
            </span>
            <h2 className="mt-3 font-display text-lg font-bold text-brand-navy">
              {anchorTitle}
            </h2>
            <p className="mt-1.5 text-sm text-brand-muted">
              The lesson that frames the whole path. Open the Numind app to take it
              first, then continue with the sequence below.
            </p>
          </div>
        </ScrollReveal>

        {/* Lesson sequence */}
        <ScrollReveal>
          <h2 className="mb-4 font-display text-xl font-bold text-brand-navy">
            The path, in order
          </h2>
          <ol className="space-y-3">
            {pack.lessonIds.map((lessonId, index) => {
              const isAnchor = lessonId === pack.anchorLessonId;
              return (
                <li
                  key={lessonId}
                  className={`flex items-start gap-4 rounded-card border p-4 ${
                    isAnchor
                      ? "border-brand-teal/40 bg-brand-teal/5"
                      : "border-brand-navy/8 bg-brand-card"
                  }`}
                >
                  <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-brand-navy/8 text-sm font-semibold text-brand-navy tabular-nums">
                    {index + 1}
                  </span>
                  <div className="flex-1">
                    <h3 className="text-base font-semibold text-brand-navy">
                      {lessonTitles[lessonId] ?? lessonId}
                    </h3>
                    {isAnchor && (
                      <span className="mt-1 inline-block text-xs font-medium uppercase tracking-wide text-brand-teal">
                        Anchor lesson
                      </span>
                    )}
                  </div>
                </li>
              );
            })}
          </ol>
        </ScrollReveal>

        {/* CTA */}
        <ScrollReveal direction="scale">
          <div className="mt-10 rounded-card bg-brand-navy p-card text-center">
            <h2 className="font-display text-xl font-bold text-white">
              Take the {pack.title} path in the app
            </h2>
            <p className="mt-2 text-sm text-white/70 max-w-md mx-auto">
              All {pack.lessonIds.length} lessons are in Numind for iOS. Each is a
              2-3 minute micro-lesson with a mental-math shortcut you can use the
              next time the decision comes up in real life.
            </p>
            <a
              href="https://apps.apple.com/app/numind"
              target="_blank"
              rel="noopener noreferrer"
              className="mt-4 inline-block cursor-pointer rounded-button bg-white px-6 py-2.5 text-sm font-semibold text-brand-navy hover:bg-white/90 transition-colors duration-200"
            >
              Download Numind for iOS
            </a>
          </div>
        </ScrollReveal>

        {/* Other paths */}
        <ScrollReveal>
          <div className="mt-10">
            <h2 className="mb-4 font-display text-base font-bold text-brand-navy">
              Other paths
            </h2>
            <div className="grid gap-3 sm:grid-cols-2">
              {packRegistry
                .filter((p) => p.id !== pack.id)
                .slice(0, 4)
                .map((other) => (
                  <Link
                    key={other.id}
                    href={`/paths/${other.id}`}
                    className="group rounded-card border border-brand-navy/8 bg-brand-card p-4 hover:border-brand-teal/40 hover:shadow-sm transition-all"
                  >
                    <h3 className="font-display text-sm font-semibold text-brand-navy group-hover:text-brand-teal">
                      {other.title}
                    </h3>
                    <p className="mt-1 text-xs text-brand-muted leading-relaxed">
                      {other.tagline}
                    </p>
                  </Link>
                ))}
            </div>
          </div>
        </ScrollReveal>
      </div>
    </>
  );
}
