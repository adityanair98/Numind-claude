import type { MetadataRoute } from "next";
import { calculatorRegistry } from "@/lib/content/calculators";
import { states } from "@/data/states";
import { salaryAmounts } from "@/data/salary-amounts";
import { ccBalances } from "@/data/cc-balances";
import { hysaBalances } from "@/data/hysa-balances";

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
      url: `${BASE_URL}/about-numind`,
      lastModified: now,
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${BASE_URL}/methodology`,
      lastModified: now,
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${BASE_URL}/editorial-standards`,
      lastModified: now,
      changeFrequency: "monthly",
      priority: 0.5,
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

  // Calculator pages (base routes from the registry)
  const calculatorPages: MetadataRoute.Sitemap = calculatorRegistry.map((calc) => ({
    url: `${BASE_URL}/tools/${calc.slug}`,
    lastModified: now,
    changeFrequency: "monthly" as const,
    priority: 0.8,
  }));

  // State-specific paycheck pages (51 pages)
  const paycheckStatePages: MetadataRoute.Sitemap = states.map((state) => ({
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

  // State-specific house-affordability pages (51 pages)
  const houseAffordabilityStatePages: MetadataRoute.Sitemap = states.map((state) => ({
    url: `${BASE_URL}/tools/house-affordability-calculator/${state.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  // State-specific 401(k) impact pages (51 pages)
  const k401StatePages: MetadataRoute.Sitemap = states.map((state) => ({
    url: `${BASE_URL}/tools/401k-impact-calculator/${state.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  // CC payoff balance pages (~9 pages)
  const ccBalancePages: MetadataRoute.Sitemap = ccBalances.map((b) => ({
    url: `${BASE_URL}/tools/credit-card-payoff-calculator/${b.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  // HYSA balance pages (~10 pages)
  const hysaBalancePages: MetadataRoute.Sitemap = hysaBalances.map((b) => ({
    url: `${BASE_URL}/tools/hysa-calculator/${b.slug}`,
    lastModified: now,
    changeFrequency: "yearly" as const,
    priority: 0.7,
  }));

  return [
    ...staticPages,
    ...calculatorPages,
    ...paycheckStatePages,
    ...salaryPages,
    ...houseAffordabilityStatePages,
    ...k401StatePages,
    ...ccBalancePages,
    ...hysaBalancePages,
  ];
}
