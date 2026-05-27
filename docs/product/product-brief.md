# Product Brief

> **Last updated:** May 2026 (after V1 refinement, V3 concept lessons, and the Phase 1 audit-fix pass — module restructure, concept template support, regulated-content accuracy review).

## Product
Numind is an iOS **financial education app that heavily uses math as its teaching method**. Every other financial-literacy app teaches concepts ("what is compound interest?"). Numind teaches the underlying mental math ("how do you estimate compound interest in your head?") so the financial knowledge is *usable* — at the table, the dealership, in HR open enrollment — not just memorizable.

Calculators are deferred to the future marketing website (where they drive App Store acquisition) and are not part of the iOS app.

## Core Promise
Become financially fluent in 5 minutes a day — by learning the math behind every real money decision.

## Target User
Adults and young adults (roughly 22-40) who want to be sharper, faster, and more confident handling money — without sitting through a textbook or a YouTube finance bro.

They may feel slow or rusty with: splitting a check, judging a discount, reading a paycheck stub, picking a 401(k) contribution rate, comparing two job offers, weighing rent vs buy, choosing a health plan during open enrollment, deciding whether to refinance student loans, or sanity-checking a car-loan offer. The pain isn't "I don't know what compound interest is" — it's "I can't quickly tell if this deal is good *right now*."

## What "financial education through math" means in practice
- **Numerical lessons (77 of 96):** concept + mental-math shortcut + 5 parametric quiz templates. The shortcut is the user-facing teaching artifact (e.g. "20% per $100 in bill, multiply by bill ÷ 100").
- **Concept lessons (19 of 96):** text-MCQ quizzes for financial literacy that isn't arithmetic — credit-score factor weights, FLSA exempt classification, IDR plan landscape (in flux post-SAVE), asset allocation, dealer tactics, insurance policy priority.
- Together, they form a single financial-education curriculum: math where math helps, concept where it doesn't.

## V1 Wedge
Financial education across 10 topic areas, every lesson grounded in real US money decisions:
- **Smart Shopping** - tipping shortcuts, bill splitting, stacked discounts, BOGO math, coupon vs cashback, discount + tax, membership break-even
- **Budgets & Spending** - subscription audits, cost per use, tax + budget, 50/30/20 rule, latte factor, weekly-to-monthly conversion
- **Salary & Income** - net pay, raises (with after-tax), overtime totals, pay-period comparison, inflation-adjusted raises, hourly-to-salary, total comp, side hustles
- **Investing Basics** - Rule of 72, ROI, 401(k) match, Roth vs Traditional, compound growth, DCA, fund fees, emergency fund, rental yield, "am I on track"
- **Debt & Loans** - credit card interest, minimum payment trap, true loan cost, DTI, extra payments, avalanche vs snowball, APR vs APY, BNPL
- **Housing & Rent** - rent affordability (28% rule), rent increase + renewal-vs-move, move-in costs, roommate math, true cost of renting, mortgage (rate-factor method), lease break math
- **Taxes & Paycheck** - marginal brackets, paycheck deductions, tax refund (behavioral), self-employment, standard vs itemized, capital gains, W-4 adjustment
- **Insurance & Healthcare** - deductible vs premium, copay vs coinsurance, OOP max, HDHP vs PPO, HSA, FSA, life insurance, brand vs generic Rx
- **Car & Big Purchases** - monthly vs total cost, loan term delta, down payment savings, 20/4/10 rule, depreciation, TCO, lease vs buy, trade-in vs private sale
- **Student Loans & Education** - monthly payment (rule of thumb), total cost, refinance vs PSLF, IDR, PSLF, employer benefit, grace period, Parent PLUS

**Total: 10 modules, 107 lessons, 535 quiz templates (400 numerical + 135 concept)** (post-Phase-3 audit: Phase 2 added +5 topic-gap lessons + Roth/APR-APY splits + Filing Status merge; Phase 3 added +5 high-demand lessons (RSUs, ESPP, CC statement cycle, open enrollment, three-accounts clarification), rebuilt 7.1 taxes_brackets with taxable-income prelude and real 2025 IRS brackets, tightened 5 decision-frame lessons, and created the per-number `regulatory-constants.md` registry — see `docs/ops/` and the Phase 3 commits for detail).

## Core Loop
Home -> pick a lesson from the zigzag learning path -> read short lesson (concept + shortcut + example) -> quiz (5 questions first time, 8 on subsequent attempts) -> instant feedback per question -> session summary with XP, mastery star, personal best, badges -> progress update (streak, levels)

## Long-Term Monetization
Long onboarding -> diagnostic test -> preliminary evaluation -> personalized plan -> hard paywall with 7-day free trial.

## Immediate Build Priority
Core product loop first:
Home -> Learn (zigzag path) -> Lesson -> Quiz -> Feedback -> Summary -> Progress.

## Non-Goals For First Build
- no real payments
- no real backend
- no AI generation
- no social features
- no content CMS
- no Android
- no calculator tools (deferred to website)
- no push notifications (local reminders only)
