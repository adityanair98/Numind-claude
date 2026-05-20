# Web Architecture

> **Last updated:** May 2026 (initial build — 6 calculators, programmatic SEO, animations, inline shortcut teaser).

## Purpose
The website exists solely for acquisition: drive App Store downloads through SEO-optimized calculator tools. People search "paycheck calculator" or "how much is $25 an hour" -> land on our tool -> get the answer + see the mental math shortcut -> download the app.

## Stack
- **Next.js 16** (App Router, SSG) — all pages statically generated at build time
- **Tailwind CSS v4** — brand tokens mapped via `@theme inline` in globals.css (no tailwind.config.ts)
- **TypeScript** — strict mode
- **Lucide React** — SVG icon library (replaces all emoji icons)
- **Vercel** — deployment, edge caching, image optimization
- **No runtime dependencies** beyond Next.js + Tailwind + Lucide

## Page Count
106 statically generated pages:
- 1 landing page (`/`)
- 1 tools directory (`/tools`)
- 6 calculator pages (`/tools/{slug}`)
- 51 state paycheck pages (`/tools/paycheck-calculator/{state}`)
- 40 salary amount pages (`/tools/salary-calculator/{slug}`)
- 2 legal pages (`/privacy`, `/terms`)
- `robots.txt` + `sitemap.xml`

## Project Structure

```
apps/web/
  src/
    app/
      layout.tsx                    — Root layout (nav, footer, fonts, metadata)
      page.tsx                      — Landing page (3D hero, modules, CTA)
      globals.css                   — Tailwind v4 @theme, keyframes, animations
      robots.ts                     — robots.txt generation
      sitemap.ts                    — Dynamic sitemap (all static + programmatic pages)
      tools/
        page.tsx                    — Calculator directory (card grid)
        layout.tsx                  — Tools sub-layout (breadcrumbs)
        paycheck-calculator/
          page.tsx                  — Main paycheck calculator
          PaycheckCalculatorWidget.tsx
          [state]/page.tsx          — 51 state pages (generateStaticParams)
        salary-calculator/
          page.tsx                  — Salary converter
          SalaryCalculatorWidget.tsx
          [slug]/page.tsx           — 40 amount pages (generateStaticParams)
        rent-calculator/page.tsx
        investment-calculator/page.tsx
        discount-calculator/page.tsx
        loan-calculator/page.tsx
      privacy/page.tsx
      terms/page.tsx
    components/
      layout/
        Navbar.tsx                  — Sticky nav: logo, "Free Tools" link, "Get the App" pill
        Footer.tsx                  — Logo, tool links, legal links, App Store badge
        MobileMenu.tsx              — Hamburger menu for mobile
      ui/
        NumindCard.tsx              — Card primitive (white bg, 20px radius)
        PillButton.tsx              — CTA button (primary/secondary, sm/md)
        CalculatorIcon.tsx          — Maps icon names to Lucide components
        SliderInput.tsx             — Range slider for calculator inputs
      calculator/
        CalculatorShell.tsx         — Page template: header -> calculator -> teaser -> shortcut -> FAQ -> CTA -> related
        ShortcutTeaser.tsx          — Inline one-line tip + app CTA (below calculator, highest visibility)
        CalculatorInput.tsx         — Labeled numeric input with $ / % formatting
        CalculatorOutput.tsx        — Result display (animated numbers + breakdown)
        CalculatorSelect.tsx        — Styled select dropdown
        AnimatedValue.tsx           — Smooth number transitions on calculator value changes
        AnimatedAnswer.tsx          — Hero count-up animation for SEO amount pages
        MentalMathCard.tsx          — Full mental math shortcut card (yellow tint, steps, example)
        AppCTA.tsx                  — "Do this math in your head" App Store banner
        FAQSection.tsx              — Accordion + schema.org/FAQPage JSON-LD
        RelatedTools.tsx            — Internal linking grid
      seo/
        StructuredData.tsx          — JSON-LD injector
      landing/
        ScrollReveal.tsx            — IntersectionObserver scroll-triggered animations
        AnimatedCounter.tsx         — Count-up number animation (hero stats)
        AnimatedProgressBar.tsx     — Progress bar fill animation
    lib/
      calculators/
        paycheck.ts                 — Federal brackets + state tax + FICA -> net pay
        salary.ts                   — Hourly/annual/monthly/biweekly conversions
        rent.ts                     — 28% rule, DTI calculation
        investment.ts               — Compound interest, Rule of 72
        discount.ts                 — Percent off, stacked discounts
        loan.ts                     — Total repayment, total interest, monthly payment
      seo/
        metadata.ts                 — generateMetadata() helpers
      content/
        shortcuts.ts                — Mental math tricks per calculator (teaser + full steps)
        faqs.ts                     — FAQ content per calculator
        calculators.ts              — Calculator registry (name, slug, description, icon)
    data/
      states.ts                     — 51 entries: name, abbreviation, slug, tax rates
      salary-amounts.ts             — 40 slugs: "25-per-hour", "50000-annual", etc.
      tax-brackets.ts               — 2025 federal progressive brackets
```

## Calculator Page Architecture (CalculatorShell)

Every calculator page uses the same layout via `CalculatorShell`:

```
[Compact header: title + tagline]
[Calculator widget — instant, no animation]
[ShortcutTeaser — inline tip + app CTA, highest-visibility spot]
[MentalMathCard — full shortcut with steps + example (scroll reveal)]
[Children — page-specific content like salary breakdown tables]
[FAQSection — accordion + JSON-LD (scroll reveal)]
[AppCTA — full-width app download banner (scroll reveal)]
[RelatedTools — internal linking grid (scroll reveal)]
```

The ShortcutTeaser is the key conversion element — it sits right below the calculator output where user attention peaks after getting their answer. One-line mental math trick + "Practice until you don't need this calculator" CTA link.

## Programmatic SEO

### State paycheck pages (`/tools/paycheck-calculator/[state]`)
- `generateStaticParams()` returns 51 state slugs from `data/states.ts`
- Each page pre-fills the state, shows state-specific tax info
- Targets: "{State} paycheck calculator 2025"

### Salary amount pages (`/tools/salary-calculator/[slug]`)
- `generateStaticParams()` returns 40 slugs from `data/salary-amounts.ts`
- Two types: hourly ("25-per-hour") and annual ("50000-annual")
- Answer-first format: hero card with animated count-up + full breakdown table
- Targets: "what is $25 an hour annually", "$50,000 a year is how much an hour"

## Animation System

All animations use native browser APIs (IntersectionObserver + requestAnimationFrame). No animation libraries.

- **ScrollReveal** — fade/slide/scale on viewport entry, configurable stagger for grids
- **AnimatedValue** — smooth number transitions in calculator outputs (400ms ease-out)
- **AnimatedAnswer** — count-up from $0 to target on viewport entry (1s cubic ease-out)
- **AnimatedCounter** — count-up for landing page stats
- **AnimatedProgressBar** — fill animation for landing page demo
- **CSS keyframes** — float, shimmer, glow-pulse, orb-drift (landing page only)

All animations respect `prefers-reduced-motion`:
- CSS: `@media (prefers-reduced-motion: reduce)` resets all durations to 0.01ms
- JS: every animation component checks `window.matchMedia("(prefers-reduced-motion: reduce)")` and skips to final state

## SEO Infrastructure

- `robots.ts` — allows all crawlers, points to sitemap
- `sitemap.ts` — dynamically lists all static + programmatic pages
- `metadata.ts` — shared `generateMetadata()` with title template "%s | Numind"
- schema.org/FAQPage JSON-LD on every calculator page
- Canonical URLs on all pages
- OpenGraph + Twitter card metadata

## Design Tokens

Brand tokens are defined in `globals.css` via Tailwind v4 `@theme inline`:

| Token | Value | Tailwind Key |
|-------|-------|-------------|
| Primary Blue | #2F6BFF | `brand-blue` |
| Deep Navy | #10224A | `brand-navy` |
| Mind Teal | #2DC6B6 | `brand-teal` |
| Insight Yellow | #FFD84D | `brand-yellow` |
| Soft Background | #F6F9FF | `brand-bg` |
| Card Background | #FFFFFF | `brand-card` |
| Muted Text | #6B7280 | `brand-muted` |
| Error Soft Red | #EF6B6B | `brand-red` |

Fonts: Inter (body), DM Sans (display/titles).
