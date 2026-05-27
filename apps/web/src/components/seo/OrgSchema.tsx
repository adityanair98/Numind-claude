import { StructuredData } from "./StructuredData";

/**
 * Site-wide schema.org/Organization JSON-LD identifying Numind as the publisher.
 * Mounted in the root layout so every page emits it. Strengthens E-E-A-T for
 * YMYL finance content per Google's Quality Rater Guidelines.
 */
export function OrgSchema() {
  return (
    <StructuredData
      data={{
        "@context": "https://schema.org",
        "@type": "Organization",
        name: "Numind",
        url: "https://numind.app",
        logo: "https://numind.app/numind-logo.png",
        description:
          "Numind is a financial education app that teaches the mental math behind every real money decision — paycheck, rent, mortgage, credit cards, taxes, investing, and more.",
        sameAs: [
          // Add social profiles here as they're created
          // e.g. "https://twitter.com/numind",
          // e.g. "https://www.linkedin.com/company/numind"
        ],
      }}
    />
  );
}
