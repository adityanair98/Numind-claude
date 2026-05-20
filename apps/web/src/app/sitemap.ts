import type { MetadataRoute } from "next";
import { calculatorRegistry } from "@/lib/content/calculators";
import { states } from "@/data/states";
import { salaryAmounts } from "@/data/salary-amounts";

const BASE_URL = "https://numind.app";

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date().toISOString();

  // Static pages
  const staticPages: MetadataRoute.Sitemap = [
    {
      url: BASE_URL,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 1.0,
    },
    {
      url: `${BASE_URL}/tools`,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 0.9,
    },
    {
      url: `${BASE_URL}/privacy`,
      lastModified: now,
      changeFrequency: "yearly",
      priority: 0.2,
    },
    {
      url: `${BASE_URL}/terms`,
      lastModified: now,
      changeFrequency: "yearly",
      priority: 0.2,
    },
  ];

  // Calculator pages
  const calculatorPages: MetadataRoute.Sitemap = calculatorRegistry.map((calc) => ({
    url: `${BASE_URL}/tools/${calc.slug}`,
    lastModified: now,
    changeFrequency: "monthly" as const,
    priority: 0.8,
  }));

  // State-specific paycheck pages (51 pages)
  const statePages: MetadataRoute.Sitemap = states.map((state) => ({
    url: `${BASE_URL}/tools/paycheck-calculator/${state.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  // Salary amount pages (~40 pages)
  const salaryPages: MetadataRoute.Sitemap = salaryAmounts.map((amount) => ({
    url: `${BASE_URL}/tools/salary-calculator/${amount.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  return [...staticPages, ...calculatorPages, ...statePages, ...salaryPages];
}
