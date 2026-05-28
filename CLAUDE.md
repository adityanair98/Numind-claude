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

Current phase: retention mechanics (streak freezes built, notifications pending), onboarding conversion funnel, and paywall integration. The core app has **10 modules, 118 lessons, 590 quiz templates** (433 numerical + 157 concept), **10 Life-Event Packs** (curated lesson sequences), and a **7-axis competency-based Numind Score** with adaptive difficulty. Phase 1–4 of the regulated-content audit shipped (Parent PLUS rate, IDR reframed as concept, realistic min-payment math, OOP max carve-outs, HoH standard deduction, overtime fixes, +5 Phase 2 + 5 Phase 3 + 11 Phase 4 lessons, Roth + APR/APY splits, Filing Status merge, taxes_brackets rebuild with real 2025 IRS brackets, citation pass, regulatory-constants registry, web SEO surface — 5 new calculators + 121 programmatic pages + 3 E-E-A-T authority pages). **Phase 5 shipped the architecture redesign:** 7 competency axes replace 10 module axes in the Numind Score (Everyday Money Math, Cash Flow & Budgeting, Income & Paycheck, Debt & Credit, Big Purchases, Protection & Benefits, Investing & Future), a new question-multiplier model (difficulty × review × speed) plus per-axis weighting profiles, evidence levels (relabeled Not started/Warming up/Building/Reliable in Phase 6a), coverage-cap composite formula, 2 new packs (Everyday Spending, Taxes Without Panic), iOS pack surfaces (PackPickerSheet, PackDetailView, focus-pack on Home, "Paths in progress" in Progress), Worlds tab rebuilt as a Brilliant-style fullscreen page-swipe carousel of themed world hero pages (each world has a tinted gradient background, module-color illustration composed from existing Module fields, Continue card pinned at the bottom; tapping Continue opens the world's quest map fullscreen with a down-chevron to dismiss), soft locks in Worlds quest map (every lesson tappable; reviews still gated), 7-axis radar wired into DailyInsightView + score-detail sheet, completion celebration queue (sequential sheets for pack + world), and Daily Workout (pack-aware question composition + streak rule change). **Phase 6a (shipped)** realigned the behavioral loop: recency-weighted score decay (0.95^days_since), an exploration bonus that replaced the old horizontal-imbalance penalty, pinnable axes (60/40 reweight), mastery decay (recent 3 attempts < 60% revokes), a rest-day streak mechanic (1 free skip / 14 days, first freeze at day 3, cap 5), and an extended 30/60-day SRS interval ladder. **Phase 6b (shipped)** refreshed every year-bound regulatory number to 2026 (IRS Rev Proc 2025-32, Notice 2025-67, Rev Proc 2025-19; SSA wage base $184,500; HHS poverty line) and absorbed OBBBA 2025 (DCFSA cap $7,500, SALT cap $40,400 with phaseout, TCJA bracket permanence, the RAP plan replacing SAVE/legacy IDR, the March-2025 PSLF employer narrowing) plus SECURE 2.0 super catch-up; the 1099 QBI multiplier moved 0.65→0.70; the emergency-fund lesson moved from Investing to Budgets & Spending and Investing was reordered so "what are stocks" is lesson 2 (counts unchanged: 118 lessons / 590 templates / 10 modules / 10 packs). **Phases 6c (Math→Finance UI identity rework) and 7 (in-app Tools tab + 12 calculators) are the next batches.** What remains is the "ship it" layer (legal, accessibility, analytics) and the monetization layer (onboarding funnel, RevenueCat paywall).

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
9. **Content balance** — Complete. All 10 modules have 7+ lessons (118 total: 92 numerical + 26 concept after Phase 4 + 5). Module restructure: removed Travel/Estimation, merged Tips+Discounts into Smart Shopping, added Insurance, Car, Student Loans. Regulated-content audit Phases 1–4 shipped.
10. **Score architecture v2** — Complete (Phase 5). 7 competency axes replace 10 module axes. Per-question multipliers (difficulty/review/speed). Evidence levels gate axis visibility. Coverage-cap composite formula.
11. **Life-Event Packs** — Complete (Phase 5). 10 curated lesson sequences (First Paycheck, First Apartment, Credit Card Cleanup, Open Enrollment, Buying a Home, Student Loan Repayment, Investing Starter, Car Buying, Everyday Spending, Taxes Without Panic). iOS surfaces: PackPickerSheet, PackDetailView, focus-pack on Home, "Paths in progress" in Progress. Web: /paths landing pages with OG images.
12. **Daily Workout** — Complete (Phase 5). Replaces Daily Challenge as streak anchor. Pack-aware question composition (3 pack-priority slots when focus pack is set). `dailyWorkoutDates: Set<Date>` drives the streak.

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