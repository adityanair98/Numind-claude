# Numind PRD Summary

> **Last updated:** May 2026 (after V1 refinement, V3 concept lessons, and Phase 1 audit fixes — module restructure, scoring reweight, adaptive difficulty, streak freezes, concept template support, regulated-content accuracy review, lastVerified field).

## Product Thesis
Numind is an iOS **financial education app that heavily uses math as its teaching method**.

The market is full of financial-literacy products that explain concepts. They tell you what compound interest is. What an IDR plan is. What the 20/4/10 rule is. They stop there. Numind keeps going: it teaches you the *mental math* behind each concept so you can actually use it the next time the situation comes up — at the restaurant, at the dealership, on a job-offer call, during open enrollment, while comparing two health plans, while signing a lease.

Each lesson is a financial literacy unit (credit-card APR, FICA, IDR, OOP max, mortgage estimate, etc.) delivered as:
1. **Concept** — what the rule is, plus the nuance most apps skip.
2. **Shortcut** — the mental-math move that makes the concept usable in real time.
3. **Quiz** — parametric practice with fresh numbers every retry; concept-only lessons use text MCQ where math doesn't apply.

The product should feel like a short useful workout, not a textbook, calculator utility, or generic brain-training app.

Coverage spans the 10 modules below — chosen to map to real US adult money decisions (search-volume + Reddit-frequency weighted), not to a math-curriculum hierarchy:

- smart shopping (tips, bill splitting, discounts, membership break-even)
- budgeting, subscriptions, and sales tax
- salary, raises, and pay periods
- investing basics (Rule of 72, ROI, 401k match, compound growth, allocation)
- debt math (credit cards, loans, DTI, BNPL, credit scores)
- housing and rent (affordability, leases, mortgage vs rent)
- taxes and paycheck (brackets, deductions, take-home pay, filing status)
- insurance and healthcare (deductibles, OOP max, HDHP vs PPO, HSA, FSA)
- car and big purchases (20/4/10, depreciation, TCO, lease vs buy)
- student loans (IDR, PSLF, refinance, employer benefits)

## Core Promise
Become financially fluent in 5 minutes a day — by learning the math behind every real money decision.

## Positioning
Do position as:
- a financial education app that teaches the math behind every-day money decisions
- usable financial literacy for adults (knowledge you can apply in real time)
- short practical training, not a textbook or a calculator
- confidence and speed for the moment the decision actually happens

Do not position as:
- a pure mental-math drill app (math is the method, not the product)
- a financial-concepts-only app (we go further than concept explanation)
- a kids math app
- a calculator replacement
- a medical brain-health product
- a broad microlearning app

## Target User
Adults and young adults, roughly 22-40, who want to be financially competent and confident — without enrolling in a course, reading a personal-finance book, or sitting through a YouTube finance bro.

They may feel slow or rusty when:
- splitting a check, calculating tips, judging discounts
- reading a paycheck stub or understanding their take-home pay
- deciding their 401(k) contribution, picking Roth vs Traditional
- comparing two job offers (especially across pay periods or total comp)
- choosing a health plan during open enrollment
- deciding whether to refinance student loans
- sanity-checking a car-loan or mortgage offer in real time

## V1 Modules (10 total)
1. **Smart Shopping** (smart_shopping) - tipping shortcuts, bill splitting, stacked discounts, BOGO math, coupon vs cashback, discount + tax, membership break-even, retailer manipulation (9 lessons)
2. **Budgets & Spending** (money_math) - subscription audits, cost per use, tax + budget, 50/30/20 rule, latte factor, weekly-to-monthly conversion, needs vs wants, sinking funds, emergency fund sizing (9 lessons)
3. **Salary & Income** (salary) - net pay, raises (with after-tax), overtime totals, pay-period comparison, inflation-adjusted raises, hourly-to-salary, total comp, side hustles, exempt vs non-exempt (9 lessons)
4. **Investing Basics** (investing) - Rule of 72, what stocks/bonds/funds are (lesson 2), ROI, 401(k) match, Roth vs Traditional, compound growth, DCA, APY/HYSA, fund fees, EF location, rental yield, "am I on track", asset allocation, panic-sell behavior (18 lessons)
5. **Debt & Loans** (debt) - credit card interest, minimum payment trap, true loan cost, DTI, extra payments, avalanche vs snowball, APR vs APY, BNPL, credit scores, good vs bad debt (10 lessons)
6. **Housing & Rent** (housing) - rent affordability, rent increase + renewal-vs-move, move-in costs, roommate math, true cost of renting, mortgage (rate-factor method), lease break math, buy vs rent, lease clauses (9 lessons)
7. **Taxes & Paycheck** (taxes) - marginal brackets, paycheck deductions, tax refund (behavioral), self-employment, standard vs itemized, capital gains, W-4 adjustment, paycheck stub, filing status (9 lessons)
8. **Insurance & Healthcare** (insurance) - deductible vs premium, copay vs coinsurance, OOP max, HDHP vs PPO, HSA, FSA, life insurance, brand vs generic Rx, policies you need, disability insurance (10 lessons)
9. **Car & Big Purchases** (car) - monthly vs total cost, loan term delta, down payment savings, 20/4/10 rule, depreciation, TCO, lease vs buy, trade-in vs private sale, dealer tactics, warranties (10 lessons)
10. **Student Loans & Education** (student_loans) - monthly payment (rule of thumb), total cost, refinance vs PSLF, IDR, PSLF, employer benefit, grace period, Parent PLUS, subsidized vs unsubsidized, federal protections (10 lessons)

**Total: 118 lessons, 686 quiz templates** (433 numerical + 253 concept/decision; +96 Phase-9E fact-based decision items covering all decision-relevant lessons), **10 Life-Event Packs**, a two-currency progress model (XP/Level + per-pack Readiness + Freshness — see "Progress model"). Phase 2 audit added 5 topic-gap lessons. Phase 3 added 5 more (RSUs, ESPP, CC statement cycle, open enrollment, three-accounts), rebuilt taxes_brackets with explicit taxable-income concept + real 2025 IRS brackets, and shipped the per-number `regulatory-constants.md` registry. Phase 4 added 11 search-intent lessons (W-2 vs 1099 offer, 401(k) vesting, cash-to-close, COL relocation, EF location, first-month true cost, medical bill EOB, CC rewards vs interest, sinking funds, compound reverse goal, bonus after tax). **Phase 5** added 2 more packs (Everyday Spending, Taxes Without Panic) for 10 total; mapped all 118 lessons to one of 7 SkillAxis values (primarySkill + 0–2 secondarySkills); shipped iOS pack-aware Home + Learn segmented control + Progress "Paths in progress" section; replaced the 10-module Numind Score with 7-axis competency scoring (per-question multipliers, weighting profiles, evidence levels, coverage-cap composite — see `docs/ops/numind-score-baseline-2026-05.md`). Roth/APR-APY splits + Filing Status merge from Phase 2 retained. Every lesson carries a `lastVerified` field per `docs/ops/content-audit-cadence.md`. **Phase 6a** realigned the behavioral loop (recency-weighted score decay, exploration bonus replacing the old imbalance penalty, pinnable axes, mastery decay, rest-day streak mechanic, extended SRS ladder to 30/60-day intervals, evidence-label renames Not started/Warming up/Building/Reliable). **Phase 6b** refreshed every year-bound regulatory number to 2026 (IRS Rev Proc 2025-32, Notice 2025-67, Rev Proc 2025-19; SSA wage base $184,500; HHS poverty line) and absorbed OBBBA 2025 (DCFSA cap $7,500, SALT cap $40,400 with phaseout, TCJA bracket permanence, the RAP repayment plan replacing SAVE/legacy IDR, the March-2025 PSLF qualifying-employer narrowing) plus SECURE 2.0 super catch-up; the 1099 QBI multiplier moved 0.65→0.70; the emergency-fund lesson moved from Investing to Budgets & Spending and Investing was reordered so "what are stocks" is lesson 2. Counts unchanged (118 lessons / 590 templates / 10 modules / 10 packs). **Phase 9** retired the global 0–100 Numind Score for a two-currency model — XP/Level + per-pack Readiness + restorable Freshness (see "Progress model" below); the 7 axes survive as a private coverage diagnostic; new MomentumEngine/ReadinessEngine/FreshnessEngine + 31 regression tests. The content rebalance (Phase 9E — scenario/decision templates) is the remaining piece.

## Core User Loop
Home / Today
-> pick a lesson from the learning path
-> read short lesson (concept + shortcut + example)
-> quiz: 5 questions (first attempt) or 8 questions (subsequent)
-> instant feedback per question (correct/wrong + explanation)
-> session summary with XP, personal best, mastery status
-> progress update (streak, badges, level-up)

## Learning Path
The Learn tab has two top-level sub-tabs (segmented picker): **Worlds** and **Paths**.

- **Worlds** (default) presents the 10 modules as a Brilliant-style fullscreen page-swipe carousel. Each world fills the screen as a themed hero: module-color gradient background, "WORLD N" eyebrow, module title, themed illustration (composed from the module's SF Symbol + emoji mascot + math-glyph watermark — no bespoke artwork needed), and a Continue card with the user's next undone lesson. Page dots at the bottom indicate position; horizontal swipe switches worlds. Tapping Continue opens the world's quest map — a zigzag of lesson and review nodes with curved connectors — as a fullscreen view with a floating down-chevron to return to the carousel. Inside the quest map, lessons are grouped chronologically and a **checkpoint review** node appears every 3 lessons that tests across all 3 preceding lessons. With Phase 5 soft locks, every lesson is tappable (dimmed if not-yet-suggested); review nodes remain gated on their covered lessons.
- **Paths** presents the 10 Life-Event Packs (curated lesson sequences across modules) — see `apps/web/src/lib/content/packs.ts` for the canonical list. Tapping a pack opens its detail sheet with the ordered lesson list + an anchor lesson + a "Make this my focus" CTA.

### Progression & Mastery
- **Completion-based progression:** any attempt at a lesson unlocks the next node (no score gate)
- **Mastery is aspirational:** 75% accuracy (6/8 or 4/5) earns a gold star on the learning path
- Failed quizzes can be retried from both the summary screen and the path node
- Each retry generates fresh random values and answer choices (same templates, different numbers)

### Checkpoint Reviews
- Review nodes appear after every 3 lessons within a module
- They pull templates from all covered lessons via round-robin sampling
- Reviews are recorded with stable IDs (`review_{moduleId}_{groupIndex}`)
- Reviews gate subsequent lessons just like regular lesson quizzes

## Quiz System
- **5 questions on first attempt, 8 on subsequent** (diagnostic calibration may adjust further)
- Questions generated from **templates** with randomized variables
- **Multiple choice** (4 options) or **free entry** (numeric keypad) depending on template
- Timer per question for speed bonus XP
- Distractor strategies: roundedNeighbor, offByDecimal, commonMistake — all use proportional step sizing (~5-8% of answer, rounded to natural numbers)
- Each template defines: id, moduleId, difficulty, promptTemplate, variableRules, answerFormula, answerFormat, distractorStrategy, explanationTemplate
- Templates are interleaved and shuffled for variety
- Adaptive difficulty: onboarding diagnostic calibrates starting difficulty per module

## Progress & Gamification

### XP System
- Base XP per correct answer: 10
- Speed bonus: extra XP for fast answers (< 5 seconds)
- XP displayed in session summary and on progress tab

### Streaks
A streak is the number of consecutive calendar days on which the user completed at least one quiz session. Users earn one streak freeze per 7-day milestone (max 5 banked; first at day 3, per Phase 6a). Freezes are auto-applied on missed days before showing a streak loss.

### Progress model (Phase 9 — replaced the 0–100 Numind Score)
The global composite score is retired. Progress is two currencies + a freshness signal:
- **XP / Level** — effort. XP = `10 × difficulty` per correct answer (easy 10 / med 15 / hard 25) + milestones (lesson mastered +50, pack Ready +150). Monotonic; never decays. Level is a front-loaded ladder, **depth-gated above L8** (each level past 8 also needs one "deep mastery" — a lesson mastered with a correct hard question, or a pack at Ready) so easy-only volume can't grind to the top.
- **Readiness (per pack)** — the honest, decision-scoped competence signal: *Not started → Learning → Almost ready (names the one missing gate) → Ready → Sharp*, gated on coverage (all core lessons attempted) + depth (each core mastered-with-hard) + retention (correct across ≥2 distinct days). Claims are scoped to the evidence, never a "ready for real life" verdict.
- **Freshness** — the only thing that decays. Derived from the SRS overdue signal; surfaced as a Home "N skills to refresh" chip. Reviewing restores it; it never touches XP/Level/mastery.
- The 7 competency axes survive only as a **private coverage diagnostic** (radar + per-axis mastered/total), not a graded composite. Full spec: `docs/product/scoring-system-research.md`.

### Badges
27 earnable badges across categories:
- **Starter:** first session, first perfect, first speed bonus
- **Streak:** 3-day, 7-day, 14-day streaks
- **Accuracy:** 80%+ and 90%+ (after 20+ questions)
- **Volume:** 100/500 questions, 10/25 sessions
- **XP:** 100, 500, 1000 XP milestones
- **Breadth:** 5 unique lessons, 3+ modules
- **Speed:** triple perfect, 5 speed sessions, fast five (5 correct < 5s in one session)

### Skill Levels
Module-level skill levels based on sessions completed within each module.

### Level-Up Ceremony
When a module level increases, a full-screen animated celebration appears before the session summary.

### Weekly XP Leaderboard
Progress tab shows a 4-week XP bar chart with "Best week!" indicator.

### Personal Bests
Personal-best fields remain in `ProgressData` for snapshot back-compat, but the game modes that wrote them (Speed Drill, Blitz, Streak, Estimation, Comparison) and the Practice tab were retired in Phase 7a. Recall ("review your weak spots") survives on Home and still shows a "New personal best!" badge with a confetti burst when its best is beaten.

### High Score Celebration
When a user achieves a new Recall personal best, the summary screen shows:
- ConfettiBurst particle animation (Canvas + TimelineView, 60 particles, 3-second duration)
- NewBestBadge trophy capsule with spring bounce-in animation
- Previous best comparison text (when applicable)

## Session Types
- **Lesson quiz:** 5 questions (first attempt) or 8 (subsequent) from that lesson's 5 templates
- **Checkpoint review:** 8 questions round-robined across 3 lessons' templates
- **Daily Workout:** 10 mixed questions, pack-aware composition; the streak anchor
- **Recall:** Review mode targeting previously missed questions (Home "review your weak spots")
- *Retired in Phase 7a: the timed game modes — Speed Drill, Blitz, Streak, Estimation, Comparison — along with the Practice tab. The Tools tab (12 calculators) replaced them.*

## Lessons
Each lesson is a micro-primer, not long content.

Each lesson includes:
- one concept
- one shortcut
- one real-world example
- immediate practice (quiz)

## Feedback
Feedback is immediate, per-question.

Correct:
- teal result card with checkmark
- reinforce shortcut
- show XP earned

Incorrect:
- red result card
- show correct answer
- explain the simplest shortcut

## Session Summary
After all 8 questions:
- Score display (correct/total)
- XP earned breakdown (base + speed bonus)
- **Mastery banner:** green if >= 75% ("Lesson mastered!"), orange if < 75% ("Need 75% to master")
- Personal best indicator
- New badge celebration
- **Actions:**
  - If mastered: "Review mistakes" + "Continue learning"
  - If not mastered: "Retry quiz" (primary, orange) + "Skip for now"

## Future Onboarding / Paywall
Later flow:
Welcome
-> motivation selection
-> self-rating
-> diagnostic
-> results
-> personalized plan
-> hard paywall with 7-day free trial

Do not build this before the core app loop exists.

## Website Layer
The website (`apps/web/`) is not the product. It supports acquisition through SEO-optimized calculator tools that drive App Store downloads.

**Built and deployed:**
- Landing page with 3D hero, animated counters, module showcase, and app CTA
- 19 calculator tools: Paycheck, Salary Converter, Rent Affordability, Investment, Discount, Loan, Insurance, Car, Student Loan, BNPL, Membership Break-even, Lease vs Buy, FSA, Life Insurance, House Affordability, Credit Card Payoff, 401(k) Impact, HYSA, Balance Transfer (Phase 2 added the last 5)
- 51 state-specific paycheck pages (programmatic SEO)
- 40 salary amount pages (programmatic SEO, e.g. "$25/hr is $52,000/year")
- Tools directory with staggered card grid
- Shared CalculatorShell: calculator widget → inline shortcut teaser → mental math card → FAQ → app CTA → related tools
- Privacy and terms pages

**Conversion strategy:** Each calculator page gives the user their answer instantly (SEO hook), then shows an inline mental math teaser right below the result ("Double the hourly rate, add three zeros") with a link to the app. The mental math shortcut is Numind's differentiator — no other calculator site teaches the trick.

## V1 Build Priority
Currently implemented:
- SwiftUI app shell with 4-tab navigation
- Design tokens and theme system
- Local content model with JSON-based lessons and templates
- Template-driven quiz engine with 300+ answer formulas
- All 10 modules with 118 lessons (post-Phase-4 audit)
- 590 quiz templates (~5 per lesson) with proportional distractor generation
- Concept template support added (text-MCQ, no formula evaluation) for lessons covering critical financial literacy topics that aren't reducible to mental math
- Completion-based progression (mastery = gold star, not gate)
- Checkpoint review quizzes
- Zigzag learning path
- XP, streaks, badges, levels
- Streak freezes (earned every 7-day milestone, max 3 banked, auto-applied)
- Personal bests and weekly leaderboard
- Session summary with retry flow
- Level-up ceremony
- Tools tab with 12 in-app calculators on `CalculatorShell` (replaced the Practice tab in Phase 7a)
- Recall ("review your weak spots") quick-access entry on Home
- High score celebration (confetti + badge) on a new Recall personal best
- Numind Score with reweighted scoring (accuracy 60, difficulty 25, speed 15)
- Estimation slider with anti-center positioning and proximity grading
- Adaptive difficulty engine with onboarding diagnostic calibration
- Dynamic question count (5 first attempt, 8 subsequent, diagnostic-adjusted)
- previousBest/isNewBest celebration pattern on Recall personal bests
- `lastVerified` date stamp on `Lesson` (optional) so future audits surface stale regulated content systematically
- Phase 1 audit fixes shipped: Overtime arithmetic, Parent PLUS rate update (9.08% → 8.94% for 2025-26), Overtime exempt/non-exempt caveat, realistic minimum-payment formula replacing the "2% of balance" simplification, OOP max framing carve-outs, IDR reframed as a concept lesson post-SAVE litigation, Standard deduction expanded to include Head of Household

Not built yet:
- backend (Supabase)
- payments (RevenueCat)
- analytics (PostHog)
- crash reporting (Sentry)
- onboarding/paywall flow
- push notifications
- social features
