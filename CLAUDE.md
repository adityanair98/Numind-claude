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

Current phase: retention mechanics (streak freezes built, notifications pending), onboarding conversion funnel, and paywall integration. The core app has **11 modules, 127 lessons, 749 quiz templates** (445 numerical + 304 concept/decision; 124 fact-based decision/application items across 114 of 127 lessons), **12 Life-Event Packs** (curated lesson sequences), and a **decision-first progress model** (daily goal ring + per-pack Readiness, with restorable Freshness; XP/Level survive only as invisible fuel) plus adaptive difficulty. Phase 1–4 of the regulated-content audit shipped (Parent PLUS rate, IDR reframed as concept, realistic min-payment math, OOP max carve-outs, HoH standard deduction, overtime fixes, +5 Phase 2 + 5 Phase 3 + 11 Phase 4 lessons, Roth + APR/APY splits, Filing Status merge, taxes_brackets rebuild with real 2025 IRS brackets, citation pass, regulatory-constants registry, web SEO surface — 5 new calculators + 121 programmatic pages + 3 E-E-A-T authority pages). **Phase 5 shipped the architecture redesign:** 7 competency axes replace 10 module axes in the Numind Score (Everyday Money Math, Cash Flow & Budgeting, Income & Paycheck, Debt & Credit, Big Purchases, Protection & Benefits, Investing & Future), a new question-multiplier model (difficulty × review × speed) plus per-axis weighting profiles, evidence levels (relabeled Not started/Warming up/Building/Reliable in Phase 6a), coverage-cap composite formula, 2 new packs (Everyday Spending, Taxes Without Panic), iOS pack surfaces (PackPickerSheet, PackDetailView, focus-pack on Home, "Paths in progress" in Progress), Worlds tab rebuilt as a Brilliant-style fullscreen page-swipe carousel of themed world hero pages (each world has a tinted gradient background, module-color illustration composed from existing Module fields, Continue card pinned at the bottom; tapping Continue opens the world's quest map fullscreen with a down-chevron to dismiss), soft locks in Worlds quest map (every lesson tappable; reviews still gated), 7-axis radar wired into DailyInsightView + score-detail sheet, completion celebration queue (sequential sheets for pack + world), and Daily Workout (pack-aware question composition + streak rule change). **Phase 6a (shipped)** realigned the behavioral loop: recency-weighted score decay (0.95^days_since), an exploration bonus that replaced the old horizontal-imbalance penalty, pinnable axes (60/40 reweight), mastery decay (recent 3 attempts < 60% revokes), a rest-day streak mechanic (1 free skip / 14 days, first freeze at day 3, cap 5), and an extended 30/60-day SRS interval ladder. **Phase 6b (shipped)** refreshed every year-bound regulatory number to 2026 (IRS Rev Proc 2025-32, Notice 2025-67, Rev Proc 2025-19; SSA wage base $184,500; HHS poverty line) and absorbed OBBBA 2025 (DCFSA cap $7,500, SALT cap $40,400 with phaseout, TCJA bracket permanence, the RAP plan replacing SAVE/legacy IDR, the March-2025 PSLF employer narrowing) plus SECURE 2.0 super catch-up; the 1099 QBI multiplier moved 0.65→0.70; the emergency-fund lesson moved from Investing to Budgets & Spending and Investing was reordered so "what are stocks" is lesson 2 (counts unchanged: 118 lessons / 590 templates / 10 modules / 10 packs). **Phase 6c (shipped)** reworked the identity from "math app" to "financial-decisions product": a `realWorldHint` + `relatedCalculatorSlug` on every lesson, a decluttered Home (Daily Workout + streak + Continue-your-path + quick-access), a per-axis Progress breakdown with a Numind-Score-over-time chart, "money sense" copy, and warm-orange (not error-red) wrong-answer treatment. **Phase 7a–7b (shipped)** replaced the Practice tab with a **Tools tab** of **12 in-app calculators** (tip+split, discount+tax, paycheck, CC payoff, rent, HYSA, salary, loan, 401k impact, mortgage, lease-vs-buy, student loan) on a shared `CalculatorShell` with a three-layer disclaimer system, wired lesson→calculator deep-links, and **retired the timed game modes** (Speed Drill, Blitz, Streak, Estimation, Comparison) along with their views/engines — Recall ("review your weak spots") survives on Home (counts unchanged: 118 lessons / 590 templates / 10 modules / 10 packs / **12 calculators**). **Phase 9 (shipped) — score redesign:** retired the global 0–100 Numind Score (composite + coverage-cap + subtitle + `ScoreTier` + score-history all deleted) in favor of a two-currency, decision-first model — **XP + Level** (difficulty-weighted effort: easy 10 / med 15 / hard 25, monotonic, depth-gated above L8 so easy-only volume can't reach the top), **per-pack Readiness** (Not started → Learning → Almost ready → Ready → Sharp — the honest, decision-scoped competence signal, gated on coverage + depth + retention), and restorable **Freshness** (a Home "N skills to refresh" chip; the only currency that decays). New `MomentumEngine`/`ReadinessEngine`/`FreshnessEngine` (pure over the session log); the 7 axes survive only as a private coverage diagnostic; every score surface reworked (Home headline/sheet, Progress tab, Today's Insight, Session Summary, PackDetail) to Level + coverage map + Readiness board; refresh-first Daily Workout; +31 regression tests (Momentum/Readiness/Freshness/Mastery). **Phase 9E (shipped)** added an `isApplication` flag + the Readiness *application* gate, **102 verified "what would you do" decision items** covering **102 of 118 lessons** (the other 16 are pure mental-math, near-duplicates, or volatile policy where a *fact-based* question doesn't exist — deliberately excluded), every Life-Event Pack with a live 4th gate, and a `ContentInvariantTests` guard that enumerates all 433 numerical templates × all variable combos to block ≤0 "savings/cost" answers (the subscription-negative class bug). **A full 3-lens content audit (June 2026, `docs/ops/full-content-audit-2026-06.md`)** independently verified every 2026 regulatory figure against primary sources (all correct — incl. the Parent PLUS 9.07% rate published 2026-06-04), closed the final 6 application-coverage gaps (+6 decision items → 102), and corrected the one confirmed factual error (student-loan interest no longer auto-capitalizes at the end of grace, per the 2023 Direct Loan rule). **Phase 10 — Block 1 "make the product true" (shipped June 2026):** *(B) curriculum wave 1* — new 11th module **Protect Your Money** (`money_safety`: imposter-scam patterns, irreversible payment rails, credit-report rights) + 6 more search-validated lessons (salary negotiation, job-change 401(k), job-change health coverage, payday/overdraft true cost, car negative equity, shrinkflation unit price), tipflation decision items, BNPL bureau-reporting refresh, and the June-audit P1 fixes → **127 lessons / 749 templates (445 numerical + 304 concept) / 124 application items across 114 lessons**; *(C) pack re-weave* — **12 packs** (new: Protect Your Money, The Job Offer), stakes-sized cores of 3–6 lessons each with a live application gate, 105/127 lessons placed in ≥1 pack, 22 deliberate library-only; *(A) loop + de-gamification* — `DailyRingEngine` (the ring closes from ANY practice reaching the daily target and is the single streak write path), 3-segment Daily Workout via `DailyWorkoutEngine` (warm-up → focus with one-screen teach cards for never-attempted core lessons → one "what would you do" decision item), GoalRing replaced LevelRing and **XP/Level disappeared from every surface** (`MomentumEngine` stays as hidden fuel), Session Summary shows skill moves (mastered/refreshed/progressed) + the ring, Progress tab shows a skills ledger + practice-over-time chart, capability milestones (first skill mastered / first pack Ready / 3 packs Ready / first refresh save) replaced volume+level celebrations, **Worlds → Explore** (topic library: WORLD-N/crown/BOSS/pulsing-ring quest framing stripped; "Topic complete"), and **one consolidated Refresh** (`RefreshSessionBuilder`: stale mastered skills + unfixed mistakes; the Recall mode and its personal best retired); *(D) analytics seam* — `AnalyticsService` wrapping PostHog + Sentry (SPM; no-op without Info.plist keys; event taxonomy v1 instrumented at ProgressStore/Home seams). Test suite at 112. What remains overall is the "ship it" layer (legal, accessibility) and the monetization layer (onboarding funnel, RevenueCat paywall).

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
9. **Content balance** — Complete. 11 modules, 127 lessons (Phase 10 added the Protect Your Money module + 9 lessons). Module restructure history: removed Travel/Estimation, merged Tips+Discounts into Smart Shopping, added Insurance, Car, Student Loans, Protect Your Money. Regulated-content audit Phases 1–4 + June-2026 full audit shipped.
10. **Score architecture** — Redesigned in **Phase 9** (supersedes the Phase 5 7-axis composite). The global 0–100 Numind Score is retired. Progress is a two-currency, decision-first model: **XP/Level** (difficulty-weighted effort, depth-gated above L8), **per-pack Readiness** (coverage → depth → retention gates), and restorable **Freshness**. The 7 axes remain only as a private coverage diagnostic. Spec: `docs/product/scoring-system-research.md`.
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