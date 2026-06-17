# Numind

Numind is an iOS-first **financial-education** app that teaches the real-life
money skills school never taught you — both the math (a tip, an APR, a paycheck,
a loan) and the decisions (a health plan, a lease, a scam, a job offer) — so when
the decision shows up, you're ready.

> Positioning: *Numind teaches the real-life money skills school never taught you
> — so when the decision shows up, you're ready.*

## What it is

A 5-minute daily lesson → quiz loop. Every lesson is a financial-literacy unit
(credit-card APR, FICA, OOP max, renters insurance, salary negotiation…) taught
as a concept + a mental-math shortcut + practice. It is **not** a budgeting app
or a bank — it's skill-building. Think "Brilliant or Duolingo, but for money
decisions, for adults."

- **11 modules · 134 lessons · 791 quiz templates** (445 numerical + 346
  concept/decision; 138 "what would you do" application items).
- **12 Life-Event Packs** — curated lesson sequences for real moments (First
  Paycheck, Open Enrollment, The Job Offer, Protect Your Money…).
- **12 in-app calculators** (Tools tab) with a three-layer disclaimer system.
- **Decision-first progress model:** a daily goal **ring**, per-pack
  **Readiness** (the honest competence signal), restorable **Freshness**, a warm
  **streak**, and capability milestones. No points, levels, or grades.
- Retention mechanics (streak freezes, payday/moment notifications), a 27-screen
  onboarding conversion funnel, and a WidgetKit home-screen widget.

## Business model

A **paid** app — free trial, then a hard paywall. **$3.99/week** or
**$29.99/year** (save 85%). No free tier.

## Audience

Adults 22–40, acquired largely via TikTok, ADHD-leaning. Tone: warm, credible,
alive, grown-up — never childish, toy, or a finance dashboard.

## Stack

- **iOS:** SwiftUI, iOS 17+, MVVM, UserDefaults (migrating to Supabase for sync)
- **Backend:** Supabase (auth + sync) — pending
- **Payments:** RevenueCat + Apple IAP — pending
- **Analytics:** PostHog (funnel/retention) + Sentry (crashes) — `AnalyticsService`
  seam shipped, no-op without keys
- **Web:** Next.js on Vercel — marketing + SEO calculators (acquisition channel)

## Repo layout

```
apps/ios/      SwiftUI app (Numind) + NumindWidget + NumindTests   — see apps/ios/README.md
apps/web/      Next.js marketing site + programmatic calculators
docs/          product, brand, architecture, ops — see CLAUDE.md "Required Docs"
```

## Status

The core loop (Home → Module/Pack → Lesson → Quiz → Feedback → Progress) is
built, with 141 passing tests. Shipped through **Phase 13** — the
**"Warm-Premium Money Tool" visual redesign** is implemented across the
foundation tokens and all 14 handoff screens (warm-neutral base + one accent
block per screen, serif-as-bounded-teaching-voice, every money figure in mono,
four-channel quiz feedback, milestone-only celebration). See
[`docs/brand/design-language-spec.md`](docs/brand/design-language-spec.md).
What remains overall is the **ship-it layer** (legal, accessibility) and the
**monetization layer** (RevenueCat paywall, Supabase auth).

## Working in this repo

Start with [`CLAUDE.md`](CLAUDE.md) (product summary, rules, and the required-docs
list). Build/test the iOS app per [`apps/ios/README.md`](apps/ios/README.md).
