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

Current phase: retention mechanics (streak freezes built, notifications pending), onboarding conversion funnel, and paywall integration. The core app has **11 modules, 134 lessons, 791 quiz templates** (445 numerical + 346 concept/decision; 138 fact-based decision/application items across 121 of 134 lessons), **12 Life-Event Packs** (curated lesson sequences), and a **decision-first progress model** (daily goal ring + per-pack Readiness, with restorable Freshness; XP/Level survive only as invisible fuel) plus adaptive difficulty. Phase 1–4 of the regulated-content audit shipped (Parent PLUS rate, IDR reframed as concept, realistic min-payment math, OOP max carve-outs, HoH standard deduction, overtime fixes, +5 Phase 2 + 5 Phase 3 + 11 Phase 4 lessons, Roth + APR/APY splits, Filing Status merge, taxes_brackets rebuild with real 2025 IRS brackets, citation pass, regulatory-constants registry, web SEO surface — 5 new calculators + 121 programmatic pages + 3 E-E-A-T authority pages). **Phase 5 shipped the architecture redesign:** 7 competency axes replace 10 module axes in the Numind Score (Everyday Money Math, Cash Flow & Budgeting, Income & Paycheck, Debt & Credit, Big Purchases, Protection & Benefits, Investing & Future), a new question-multiplier model (difficulty × review × speed) plus per-axis weighting profiles, evidence levels (relabeled Not started/Warming up/Building/Reliable in Phase 6a), coverage-cap composite formula, 2 new packs (Everyday Spending, Taxes Without Panic), iOS pack surfaces (PackPickerSheet, PackDetailView, focus-pack on Home, "Paths in progress" in Progress), Worlds tab rebuilt as a Brilliant-style fullscreen page-swipe carousel of themed world hero pages (each world has a tinted gradient background, module-color illustration composed from existing Module fields, Continue card pinned at the bottom; tapping Continue opens the world's quest map fullscreen with a down-chevron to dismiss), soft locks in Worlds quest map (every lesson tappable; reviews still gated), 7-axis radar wired into DailyInsightView + score-detail sheet, completion celebration queue (sequential sheets for pack + world), and Daily Workout (pack-aware question composition + streak rule change). **Phase 6a (shipped)** realigned the behavioral loop: recency-weighted score decay (0.95^days_since), an exploration bonus that replaced the old horizontal-imbalance penalty, pinnable axes (60/40 reweight), mastery decay (recent 3 attempts < 60% revokes), a rest-day streak mechanic (1 free skip / 14 days, first freeze at day 3, cap 5), and an extended 30/60-day SRS interval ladder. **Phase 6b (shipped)** refreshed every year-bound regulatory number to 2026 (IRS Rev Proc 2025-32, Notice 2025-67, Rev Proc 2025-19; SSA wage base $184,500; HHS poverty line) and absorbed OBBBA 2025 (DCFSA cap $7,500, SALT cap $40,400 with phaseout, TCJA bracket permanence, the RAP plan replacing SAVE/legacy IDR, the March-2025 PSLF employer narrowing) plus SECURE 2.0 super catch-up; the 1099 QBI multiplier moved 0.65→0.70; the emergency-fund lesson moved from Investing to Budgets & Spending and Investing was reordered so "what are stocks" is lesson 2 (counts unchanged: 118 lessons / 590 templates / 10 modules / 10 packs). **Phase 6c (shipped)** reworked the identity from "math app" to "financial-decisions product": a `realWorldHint` + `relatedCalculatorSlug` on every lesson, a decluttered Home (Daily Workout + streak + Continue-your-path + quick-access), a per-axis Progress breakdown with a Numind-Score-over-time chart, "money sense" copy, and warm-orange (not error-red) wrong-answer treatment. **Phase 7a–7b (shipped)** replaced the Practice tab with a **Tools tab** of **12 in-app calculators** (tip+split, discount+tax, paycheck, CC payoff, rent, HYSA, salary, loan, 401k impact, mortgage, lease-vs-buy, student loan) on a shared `CalculatorShell` with a three-layer disclaimer system, wired lesson→calculator deep-links, and **retired the timed game modes** (Speed Drill, Blitz, Streak, Estimation, Comparison) along with their views/engines — Recall ("review your weak spots") survives on Home (counts unchanged: 118 lessons / 590 templates / 10 modules / 10 packs / **12 calculators**). **Phase 9 (shipped) — score redesign:** retired the global 0–100 Numind Score (composite + coverage-cap + subtitle + `ScoreTier` + score-history all deleted) in favor of a two-currency, decision-first model — **XP + Level** (difficulty-weighted effort: easy 10 / med 15 / hard 25, monotonic, depth-gated above L8 so easy-only volume can't reach the top), **per-pack Readiness** (Not started → Learning → Almost ready → Ready → Sharp — the honest, decision-scoped competence signal, gated on coverage + depth + retention), and restorable **Freshness** (a Home "N skills to refresh" chip; the only currency that decays). New `MomentumEngine`/`ReadinessEngine`/`FreshnessEngine` (pure over the session log); the 7 axes survive only as a private coverage diagnostic; every score surface reworked (Home headline/sheet, Progress tab, Today's Insight, Session Summary, PackDetail) to Level + coverage map + Readiness board; refresh-first Daily Workout; +31 regression tests (Momentum/Readiness/Freshness/Mastery). **Phase 9E (shipped)** added an `isApplication` flag + the Readiness *application* gate, **102 verified "what would you do" decision items** covering **102 of 118 lessons** (the other 16 are pure mental-math, near-duplicates, or volatile policy where a *fact-based* question doesn't exist — deliberately excluded), every Life-Event Pack with a live 4th gate, and a `ContentInvariantTests` guard that enumerates all 433 numerical templates × all variable combos to block ≤0 "savings/cost" answers (the subscription-negative class bug). **A full 3-lens content audit (June 2026, `docs/ops/full-content-audit-2026-06.md`)** independently verified every 2026 regulatory figure against primary sources (all correct — incl. the Parent PLUS 9.07% rate published 2026-06-04), closed the final 6 application-coverage gaps (+6 decision items → 102), and corrected the one confirmed factual error (student-loan interest no longer auto-capitalizes at the end of grace, per the 2023 Direct Loan rule). **Phase 10 — Block 1 "make the product true" (shipped June 2026):** *(B) curriculum wave 1* — new 11th module **Protect Your Money** (`money_safety`: imposter-scam patterns, irreversible payment rails, credit-report rights) + 6 more search-validated lessons (salary negotiation, job-change 401(k), job-change health coverage, payday/overdraft true cost, car negative equity, shrinkflation unit price), tipflation decision items, BNPL bureau-reporting refresh, and the June-audit P1 fixes → **127 lessons / 749 templates (445 numerical + 304 concept) / 124 application items across 114 lessons**; *(C) pack re-weave* — **12 packs** (new: Protect Your Money, The Job Offer), stakes-sized cores of 3–6 lessons each with a live application gate, 105/127 lessons placed in ≥1 pack, 22 deliberate library-only; *(A) loop + de-gamification* — `DailyRingEngine` (the ring closes from ANY practice reaching the daily target and is the single streak write path), 3-segment Daily Workout via `DailyWorkoutEngine` (warm-up → focus with one-screen teach cards for never-attempted core lessons → one "what would you do" decision item), GoalRing replaced LevelRing and **XP/Level disappeared from every surface** (`MomentumEngine` stays as hidden fuel), Session Summary shows skill moves (mastered/refreshed/progressed) + the ring, Progress tab shows a skills ledger + practice-over-time chart, capability milestones (first skill mastered / first pack Ready / 3 packs Ready / first refresh save) replaced volume+level celebrations, **Worlds → Explore** (topic library: WORLD-N/crown/BOSS/pulsing-ring quest framing stripped; "Topic complete"), and **one consolidated Refresh** (`RefreshSessionBuilder`: stale mastered skills + unfixed mistakes; the Recall mode and its personal best retired); *(D) analytics seam* — `AnalyticsService` wrapping PostHog + Sentry (SPM; no-op without Info.plist keys; event taxonomy v1 instrumented at ProgressStore/Home seams). **Phase 11 (shipped June 2026) — onboarding funnel v2:** the 27-screen conversion funnel rebuilt around decision readiness — Insecurity Mirror (felt-moment costs), Life-Moment Picker (12 packs as moments; first = focus), Deadline screen (dated moments via MomentsRegistry), diagnostic-as-demo (shortcut reveal card after every answer; results never create SessionRecords), Money Map placement (no badges; "Ready is earned"), honest projection ("on track to Ready", never a promise). **Phase 12 (shipped June 2026) — felt sharpness:** *(L)* de-math language pass — math is the method, never the promise; one disarm line budget (DiagnosticIntroView); legacy OnboardingView deleted; brand-guidelines language rule. *(P)* `SharpnessEngine` — favorable-only speed deltas (prior median of last 5 correct, ≥8s baseline, current < 0.7×median) as a quiz-result pill; refresh-save toast ("Back to sharp"). *(M)* `MomentsRegistry` (open enrollment, FSA use-it, tax season, post-tax regret, IRS limits, lease renewal, payday — honest windows, "about N weeks", no fake countdowns; pack-scoped awareness, universal active) + `PaycheckSchedule` (4 cadences) + Home moment chip + PackDetail moment line. *(N)* payday + moment notifications (`NotificationScheduler`; ≤3 one-off payday triggers; never prompts). *(O)* onboarding payday-capture screen (11 of 27, skippable) + habit-buyer copy branch (fluency-ladder Kaizen/Projection when focus = everyday_spending or staySharp). *(S)* monthly sharpness check (28-day gate, diagnostic-shaped, results stored OUTSIDE the session log) + real-world saves ledger (weekly one-tap chips; Progress stat). *(C)* administrative-adulting content wave — 7 lessons / 42 concept templates / 14 decision items, all primary-source verified (filing mechanics, credit from zero, dispute a charge, banking fees, renters insurance, auto insurance shopping, beneficiary designations) → the counters above. *(W)* WidgetKit extension — accessoryCircular/accessoryRectangular/systemSmall ring + streak + next moment, fed by a `WidgetSnapshot` App Group write in ProgressStore.persist(). Test suite at 140. **Pricing (June 2026):** switched from monthly to a **weekly model — $3.99/week or $29.99/year (save 85%, $0.58/wk)**; paywall + priming screens updated (RevenueCat products will mirror these). **Phase 13 (specced, June 2026) — visual redesign "Warm-Premium Money Tool":** a full design-language spec at `docs/brand/design-language-spec.md`, grounded in June-2026 audience-aesthetic research (apps for the 22-40 TikTok-acquired, ADHD-leaning paid audience) and calibrated against it twice via adversarial design-fit reconciles (caught an editorial over-weight, then a saturation over-correction; both folded in). Direction: own the unclaimed middle between warm-but-toy education and premium-but-cold tracking — a warm-neutral base that DOMINATES with ONE confident accent block per screen; **bold sans as the default register, editorial serif as a bounded teaching accent only** (the Robinhood split); a **warm-charcoal dark mode** (not the cool blue-black shipping today); the 13-hue module rainbow **demoted** to small topic-accent icon chips; three typefaces / three jobs (New York serif = teaching voice, SF Pro = interface, SF Mono = every money figure); a flat money-artifact **illustration system**; a colorblind-safe **four-channel feedback rule** (teal/amber + distinct filled icon + fixed position + copy, grayscale-test-passing); a warm **flame streak**; and **milestone-only celebration**. Two code fixes flagged for the rebuild: re-gate the live per-answer `ConfettiView` to milestones, and formally demote `ModuleColor`'s 13 saturated hues in the token layer. **Phase 13 (shipped June 2026) — the visual rebuild landed.** The foundation repoints the existing `Theme.Colors`/`Theme.Typography` token *values* (not names, so all ~200 call sites still compile) to the warm-premium palette — adaptive light/dark with explicit dark hex on every token (warm-charcoal `#1A1611`, not the old cool blue-black), the 13-hue module rainbow collapsed into 6 topic accents (`ModuleColorTheme` maps the `ModuleColor` enum onto the repointed tokens), and three type registers (`serifDisplay`/`serifTitle` New York teaching voice, plain SF Pro interface, `moneyHero`/`mono` SF Mono for every figure). All 14 handoff screens were rebuilt natively: onboarding hero (warm illustration panel + sans ink headline + teal Sign-in), Home (white daily hero + teal ring + ember streak chip), Explore (clean searchable topic library; the worlds swipe-carousel + Explore/Paths segmented control retired), lesson story (serif concept headline + gold shortcut callout), worked example (mono ledger + teal result pop), quiz question (`disabledFill` Check until a choice) + **four-channel correct/wrong feedback** (teal/amber + filled icon + fixed result zone + copy, wrong-text dark-ink not orange), pack detail (serif headline + readiness), session summary (completed teal ring + ember streak row; the trophy/🏆/🔥/gold-star gamification removed), **Progress de-densified** to a 7-bar practice chart + two-card skills ledger (the clinical dashboard — navy streak hero, radar, badges, weekly-XP — deleted), Tools calmer (mono money figures across all 12 calculators + neutral `EstimateTag`), milestone (restrained top-zone gold/teal/ember confetti + gold-coin mascot — the **only** surface where confetti survives), and paywall (goldTint serif hero, mono prices, ink-selected/teal-savings plan cards; real $3.99-wk / $29.99-yr pricing kept). Per-answer `ConfettiView` retired from the quiz; several white-on-`deepNavy` CTAs moved to `ctaFill`/`ctaLabel` (dark-mode correctness, since `deepNavy` now inverts to cream); dead carousel/dashboard code removed (LearnView 925→778, ProgressTabView 1284→412). Test suite at 141. What remains overall is the "ship it" layer (legal, accessibility) and the monetization layer (RevenueCat paywall wiring, auth).

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
9. **Content balance** — Complete. 11 modules, 134 lessons (Phase 10 added the Protect Your Money module + 9 lessons; Phase 12 added the 7-lesson administrative-adulting wave). Module restructure history: removed Travel/Estimation, merged Tips+Discounts into Smart Shopping, added Insurance, Car, Student Loans, Protect Your Money. Regulated-content audit Phases 1–4 + June-2026 full audit shipped.
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
- docs/brand/design-language-spec.md  (Phase 13 visual redesign — source of truth for color/type/illustration/feedback; supersedes design-tokens.md for the visual language)
- docs/brand/design-tokens.md  (pre-redesign baseline; shape + spacing values still current)
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