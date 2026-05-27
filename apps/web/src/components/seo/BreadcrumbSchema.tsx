import { StructuredData } from "./StructuredData";

interface BreadcrumbItem {
  /** Display name (e.g. "Home", "Tools", "BNPL Calculator") */
  name: string;
  /** Absolute URL */
  url: string;
}

interface BreadcrumbSchemaProps {
  /** Ordered breadcrumb trail from root → current page (root first) */
  items: BreadcrumbItem[];
}

/**
 * Emits schema.org/BreadcrumbList JSON-LD so Google can render breadcrumb-style
 * rich snippets in search results (replaces the URL with the trail).
 *
 * For Numind tool pages the trail is typically:
 *   Home → Tools → {Calculator Name}
 */
export function BreadcrumbSchema({ items }: BreadcrumbSchemaProps) {
  return (
    <StructuredData
      data={{
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        itemListElement: items.map((item, idx) => ({
          "@type": "ListItem",
          position: idx + 1,
          name: item.name,
          item: item.url,
        })),
      }}
    />
  );
}
