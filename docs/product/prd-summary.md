# Numind PRD Summary

> **Last updated:** May 2026 (after V1 refinement — new modules, scoring reweight, adaptive difficulty, streak freezes, distractor fix).

## Product Thesis
Numind is an iOS-first daily training app for practical number fluency.

It helps users get faster and more confident with real-world money math:
- tips and bill splitting
- discounts and shopping
- budgeting, subscriptions, and sales tax
- salary, raises, and pay periods
- investing basics (simple interest, Rule of 72, ROI)
- debt math (credit cards, loans, DTI)
- travel money (currency conversion, fees, budgeting)
- housing and rent (affordability, leases, mortgage vs rent)
- taxes and paycheck (brackets, deductions, take-home pay)
- estimation and mental math shortcuts

The product should feel like a short useful workout, not a textbook, calculator utility, or generic brain-training app.

## Core Promise
Get faster at everyday money math in 5 minutes a day.

## Positioning
Do position as:
- daily real-world number fluency
- everyday money math for adults
- short practical training workouts
- confidence and speed in daily life

Do not position as:
- a broad microlearning app
- a kids math app
- a calculator replacement
- a medical brain-health product

## Target User
Adults and young adults, roughly 22-40, who want to feel sharper, faster, and more confident with everyday math.

They may feel slow or rusty with:
- splitting bills
- calculating tips
- judging discounts
- estimating totals
- interpreting percentages
- understanding loan costs
- comparing salary offers

## V1 Modules (10 total)
1. **Smart Shopping** (smart_shopping) - tipping shortcuts, bill splitting, stacked discounts, BOGO math, coupon vs cashback, discount + tax, membership break-even (8 lessons)
2. **Budgets & Spending** (money_math) - subscription audits, cost per use, tax + budget, 50/30/20 rule, latte factor, weekly-to-monthly conversion (6 lessons)
3. **Salary & Income** (salary) - net pay, raises (with after-tax), overtime totals, pay-period comparison, inflation-adjusted raises, hourly-to-salary, total comp, side hustles (8 lessons)
4. **Investing Basics** (investing) - Rule of 72, ROI, 401k match, Roth vs Traditional, compound growth, DCA, fund fees, emergency fund, rental yield, "am I on track" (10 lessons)
5. **Debt & Loans** (debt) - credit card interest, minimum payment trap, true loan cost, DTI, extra payments, avalanche vs snowball, APR vs APY, BNPL (8 lessons)
6. **Housing & Rent** (housing) - rent affordability, rent increase + renewal-vs-move, move-in costs, roommate math, true cost of renting, mortgage (rate-factor method), lease break math (7 lessons)
7. **Taxes & Paycheck** (taxes) - marginal brackets, paycheck deductions, tax refund (behavioral), self-employment, standard vs itemized, capital gains, W-4 adjustment (7 lessons)
8. **Insurance & Healthcare** (insurance) - deductible vs premium, copay vs coinsurance, OOP max, HDHP vs PPO, HSA, FSA, life insurance, brand vs generic Rx (8 lessons)
9. **Car & Big Purchases** (car) - monthly vs total cost, loan term delta, down payment savings, 20/4/10 rule, depreciation, TCO, lease vs buy, trade-in vs private sale (8 lessons)
10. **Student Loans & Education** (student_loans) - monthly payment (rule of thumb), total cost, refinance vs PSLF, IDR, PSLF, employer benefit, grace period, Parent PLUS (8 lessons)

**Total: 96 lessons, 479 quiz templates** (78 numerical + 18 concept lessons; ~389 numerical templates + ~90 concept templates)

## Core User Loop
Home / Today
-> pick a lesson from the learning path
-> read short lesson (concept + shortcut + example)
-> quiz: 5 questions (first attempt) or 8 questions (subsequent)
-> instant feedback per question (correct/wrong + explanation)
-> session summary with XP, personal best, mastery status
-> progress update (streak, badges, level-up)

## Learning Path
The Learn tab presents lessons as a **zigzag path** (Duolingo-style), alternating nodes left and right. Lessons are grouped by module with banner headers. Every 3 lessons within a module, a **checkpoint review** node appears that tests across all 3 preceding lessons.

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
A streak is the number of consecutive calendar days on which the user completed at least one quiz session. Users earn one streak freeze per 7-day milestone (max 3 banked). Freezes are auto-applied on missed days before showing a streak loss.

### Numind Score (0–100)
Composite per-module score reflecting competence:
- Accuracy: 0–60 pts (primary driver)
- Difficulty: 0–25 pts (weighted by adaptive difficulty tier)
- Speed: 0–15 pts (bonus only — deliberately down-weighted so accurate-but-slow users still see a fair score)

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
Personal bests tracked per game mode: Speed Drill, Blitz, Recall, Streak, Estimation, Comparison. Displayed as decorative orb overlays on Practice tab drill cards. Summary screens show "New personal best!" badge with confetti burst animation when a new best is achieved.

### High Score Celebration
When a user achieves a new personal best in any game mode, the summary screen shows:
- ConfettiBurst particle animation (Canvas + TimelineView, 60 particles, 3-second duration)
- NewBestBadge trophy capsule with spring bounce-in animation
- Previous best comparison text (when applicable)

## Session Types
- **Lesson quiz:** 5 questions (first attempt) or 8 (subsequent) from that lesson's 5 templates
- **Checkpoint review:** 8 questions round-robined across 3 lessons' templates
- **Speed Drill:** 8 MCQ questions, 15s per question countdown timer
- **Blitz:** 60-second sprint, auto-advance on tap, no feedback phase
- **Recall:** Review mode targeting previously missed questions
- **Streak:** Consecutive correct answers, one miss ends the game
- **Estimation:** 10 slider-based proximity questions, 10s timer per question, 3-star grading
- **Comparison:** 15 side-by-side pairs, 8s per question, tap the larger answer

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
- 14 calculator tools: Paycheck, Salary Converter, Rent Affordability, Investment, Discount, Loan, Insurance, Car, Student Loan, BNPL, Membership Break-even, Lease vs Buy, FSA, Life Insurance
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
- Template-driven quiz engine with 120+ answer formulas
- All 10 modules with 96 lessons (78 numerical + 18 concept)
- 479 quiz templates (~5 per lesson) with proportional distractor generation
- Concept template support added (text-MCQ, no formula evaluation) for lessons covering critical financial literacy topics that aren't reducible to mental math
- Completion-based progression (mastery = gold star, not gate)
- Checkpoint review quizzes
- Zigzag learning path
- XP, streaks, badges, levels
- Streak freezes (earned every 7-day milestone, max 3 banked, auto-applied)
- Personal bests and weekly leaderboard
- Session summary with retry flow
- Level-up ceremony
- 6 game modes (Speed Drill, Blitz, Recall, Streak, Estimation, Comparison)
- Practice tab with module spotlight, hero quiz card, and 6 drill cards
- Home tab with horizontally scrollable mode cards
- Personal best tracking for all game modes with decorative orb display
- High score celebration (confetti + badge) across all modes
- Numind Score with reweighted scoring (accuracy 60, difficulty 25, speed 15)
- Estimation slider with anti-center positioning and proximity grading
- Adaptive difficulty engine with onboarding diagnostic calibration
- Dynamic question count (5 first attempt, 8 subsequent, diagnostic-adjusted)
- previousBest/isNewBest pattern on all game mode ViewModels

Not built yet:
- backend (Supabase)
- payments (RevenueCat)
- analytics (PostHog)
- crash reporting (Sentry)
- onboarding/paywall flow
- push notifications
- social features
