import { StructuredData } from "./StructuredData";

interface CalculatorAppSchemaProps {
  /** Calculator name, e.g. "BNPL Calculator" */
  name: string;
  /** One-line description (use the page tagline) */
  description: string;
  /** Absolute URL of the calculator page */
  url: string;
}

/**
 * Emits schema.org/WebApplication JSON-LD describing each calculator as a free
 * web app under the "FinanceApplication" category. Eligible for Google's rich
 * card display on calculator-style searches.
 */
export function CalculatorAppSchema({
  name,
  description,
  url,
}: CalculatorAppSchemaProps) {
  return (
    <StructuredData
      data={{
        "@context": "https://schema.org",
        "@type": "WebApplication",
        name,
        description,
        url,
        applicationCategory: "FinanceApplication",
        operatingSystem: "Any (web)",
        browserRequirements: "Modern browser with JavaScript enabled",
        offers: {
          "@type": "Offer",
          price: "0",
          priceCurrency: "USD",
        },
        publisher: {
          "@type": "Organization",
          name: "Numind",
          url: "https://numind.app",
        },
      }}
    />
  );
}
