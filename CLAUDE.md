# Numind Claude Instructions

You are building Numind, an iOS-first SwiftUI **financial education** app that teaches money decisions through mental math.

## Product Summary
Numind is a **financial education app that heavily uses math as its teaching method**. Where competitors teach financial *concepts* ("what is compound interest?"), Numind teaches the *math skill* behind each concept ("how to estimate compound interest in your head") so users can actually use the knowledge in real situations — at the restaurant, the dealership, on a job-offer call, during open enrollment.

The lesson structure reinforces this: every lesson is a financial literacy unit (credit-card APR, FICA, IDR, OOP max, etc.) delivered as a concept + a mental-math shortcut + practice quizzes. Concept lessons (text MCQ, no formula) cover financial knowledge that isn't reducible to arithmetic (credit-score factors, FLSA classification, IDR policy state, asset allocation rules of thumb). Numerical lessons (formula-driven, parametric quizzes) cover everything that has a real number to estimate.

The iOS app is the product. Calculators live on the marketing website as an acquisition channel — they answer the user's immediate query, then surface the mental-math shortcut and route to the app for the deeper financial education.

## Business Model
**Numind is a PAID app. There is no free version.** The app uses a free trial with a hard paywall.
- First-time users get a free trial period to experience the product.
- After the trial, a subscription is required to continue using the app.
- The onboarding flow is a conversion funnel optimized for trial-to-paid conversion. It uses personalization, product demos (mini-quiz), and psychological commitment (sunk cost) to maximize conversions.
- All premium features (streak protection, full content access, etc.) are available during the trial so users experience the full value before the paywall.
- Never assume a "free tier" or "freemium" model. Every feature decision should be evaluated through the lens of: does this drive trial sign-ups, does this retain paying subscribers, does this justify the subscription price.

## Brand
Numind should feel:
- friendly
- clean
- modern
- useful
- App Store-first
- not childish
- not academic-heavy
- not finance-dashboard-like

Brand motifs:
- brain + abacus
- beads and rails
- financial literacy via mental math
- daily reps
- blue / teal / yellow palette

## Build Strategy
The core product loop is built:
Home → Module → Lesson → Quiz → Feedback → Progress.

Current phase: retention mechanics (streak freezes built, notifications pending), onboarding conversion funnel, and paywall integration. The core app has 10 modules, 102 lessons, 509 quiz templates (391 numerical + 118 concept) with completion-based progression and adaptive difficulty. Phase 1 + Phase 2 of the regulated-content audit shipped (Parent PLUS rate, IDR reframed as concept, realistic min-payment math, OOP max carve-outs, HoH standard deduction, overtime fixes, +5 new topic-gap lessons, Roth + APR/APY splits, Filing Status merge, 15-lesson citation pass, content-audit-cadence ops doc, full web SEO surface stack including 5 new calculators + 121 programmatic pages + 3 E-E-A-T authority pages, Numind Score baseline diagnostic — no recalibration needed). What remains is the "ship it" layer (legal, accessibility, analytics) and the monetization layer (onboarding funnel, RevenueCat paywall).

## Stack
- SwiftUI
- Swift 5.9+
- Deployment target: iOS 17.0
- MVVM
- UserDefaults for local persistence (migrating to Supabase for sync)
- Supabase (auth + backend)
- RevenueCat (subscriptions + paywall)
- PostHog (analytics)
- Sentry (crash reporting)

## Launch Roadmap (Priority Order)

1. **Onboarding funnel** — conversion-optimized sales funnel (user to share design)
2. **Auth** — Supabase Auth + Sign in with Apple. Runs anonymously through onboarding, account creation at/before paywall.
3. **Paywall** — RevenueCat. Hard paywall after free trial. Placed at end of onboarding funnel after maximum sunk cost.
4. **Streak protection** — Freeze + restore as subscription perks. Available during trial, locked after expiry.
5. **Notifications** — Streak-aware reminders, streak warning/lost, comeback, celebrations.
6. **Privacy & legal** — PrivacyInfo.xcprivacy, privacy policy URL, terms of service.
7. **Accessibility** — VoiceOver labels on all interactive elements.
8. **Analytics** — PostHog (funnel/retention) + Sentry (crashes).
9. **Content balance** — Complete. All 10 modules have 7+ lessons (96 total: 77 numerical + 19 concept). Module restructure done: removed Travel/Estimation, merged Tips+Discounts into Smart Shopping, added Insurance, Car, Student Loans. Regulated-content accuracy audit Phase 1 shipped.

## Rules
- Do not add AI-generated content.
- Do not hardcode quiz questions inside SwiftUI views.
- Use template-driven quiz content.
- Centralize design tokens.
- Keep files small and modular.
- Prefer clear simple architecture over abstraction.
- Do not introduce dependencies without explaining why.

## Auth & Subscription Flow
- Onboarding runs fully anonymous — no account required to experience the funnel.
- Account creation happens at or just before the paywall (maximum sunk cost achieved).
- Sign in with Apple (required by App Store) + email/password via Supabase Auth.
- RevenueCat ties subscriptions to Supabase user IDs.
- "Restore purchases" available in Profile for users reinstalling or switching devices.
- After trial expiry without subscription: hard paywall blocks access to lessons/quizzes. Home screen visible with locked state.

## Required Docs To Read
Before implementation, read:
- docs/product/product-brief.md
- docs/product/v1-scope.md
- docs/product/user-flows.md
- docs/product/quiz-engine.md
- docs/product/content-model.md
- docs/brand/brand-guidelines.md
- docs/brand/design-tokens.md
- docs/architecture/tech-stack.md
- docs/claude/implementation-rules.md
- docs/product/prd-summary.md

## Source Documents

Long-form DOCX files live in `docs/_source/`.

Important:
The compressed PRD context is in docs/product/prd-summary.md. Use that as active PRD guidance.

Long-form DOCX source files may exist in docs/_source/. Do not read them by default. Only inspect docs/_source/ if the markdown docs are missing, contradictory, or if I explicitly ask you to reference the full PRD.

Do not read these by default during normal implementation. Use the markdown docs in `docs/product`, `docs/brand`, and `docs/architecture` as the source of truth.

Only inspect `docs/_source/` if:
- there is a contradiction in the markdown docs
- product strategy needs clarification
- brand guidance is missing
- architecture decisions are unclear