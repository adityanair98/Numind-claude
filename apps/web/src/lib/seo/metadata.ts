import type { Metadata } from "next";

interface MetadataInput {
  title: string;
  description: string;
  path: string;
  /** Override the OG image path (relative to /public) */
  ogImage?: string;
}

const BASE_URL = "https://numind.app";

export function buildMetadata({ title, description, path, ogImage }: MetadataInput): Metadata {
  const url = `${BASE_URL}${path}`;

  return {
    title,
    description,
    alternates: {
      canonical: url,
    },
    openGraph: {
      title,
      description,
      url,
      type: "website",
      ...(ogImage ? { images: [{ url: ogImage, width: 1200, height: 630 }] } : {}),
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}
