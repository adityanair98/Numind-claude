# V1 Scope

> **Last updated:** May 2026 (after V1 refinement — new modules, scoring reweight, distractor fix, streak freezes, True/False removal).

## Tabs
- Home
- Learn
- Progress
- Profile

## Screens (implemented)
- **Home** — greeting, streak chip (with freeze count), daily workout card, resume card, module cards, horizontally scrollable game modes row (5 modes: Speed Drill, Blitz, Streak, Estimation, Comparison) via ModeCard component
- **Learn (zigzag path)** - alternating left/right lesson nodes with connector lines, module banners, checkpoint review nodes, pulsing ring on current node
- **Lesson** - concept card, shortcut, worked example, then quiz
- **Quiz** - 5 questions on first attempt / 8 on subsequent attempts, MCQ or free entry, per-question timer, bead progress rail
- **Quiz Feedback** - per-question correct/wrong with explanation
- **Session Summary** - score, XP, mastery banner (gold star at 75%), personal best, new badges, continue or practice more
- **Checkpoint Review** - review quiz covering 3 lessons, same flow as lesson quiz but no lesson content phase
- **Level-Up** - full-screen celebration when module skill level increases
- **Practice** — module tab strip, module spotlight, hero quiz card, 6 game-mode drill cards (Speed Drill, Blitz, Recall, Streak, Estimate, Compare), decorative-orb personal best display
- **Streak** — consecutive correct answers, one miss ends game, MCQ pool from mastered templates
- **Estimation** — slider-based estimation with 10-second countdown, anti-center answer positioning, medium-hard difficulty filter
- **Comparison** — side-by-side comparison pairs (15 questions, 8s timer), tap the bigger answer
- **High Score Celebration** — confetti burst + "New Personal Best!" badge on all game mode summary screens
- **Progress** - streak, accuracy, sessions stats; weekly goal calendar; weekly XP leaderboard (4-week chart); skill mastery per module; badge collection
- **Profile** - goals, daily target, reset progress

## Content
- **10 modules**: Smart Shopping, Budgets & Spending, Salary, Investing, Debt, Housing & Rent, Taxes & Paycheck, Insurance & Healthcare, Car & Big Purchases, Student Loans & Education
- **96 lessons** across all modules (78 numerical + 18 concept lessons)
- **479 quiz templates** (~5 per lesson; ~90 are concept templates with text MCQ choices instead of computed numerical answers)
- **27 badges** across 7 categories

## Quiz System
- 5 questions on first attempt at any lesson, 8 on subsequent attempts (diagnostic calibration adjusts this further)
- Template-driven with randomized variables
- Multiple choice (4 options) or free entry
- 75% mastery threshold for gold star (aspirational, not required for progression)
- Completion-based progression: any attempt unlocks the next lesson
- Retry with fresh random values each attempt
- Checkpoint reviews every 3 lessons
- Proportional distractor generation: wrong answers are ~5-8% from correct, rounded to psychologically natural numbers
- Adaptive difficulty: onboarding diagnostic calibrates starting difficulty per module

## Numind Score (0–100)
Composite score per module and overall:
- Accuracy: 0–60 pts (primary driver)
- Difficulty: 0–25 pts (weighted by adaptive difficulty tier)
- Speed: 0–15 pts (bonus, not penalty — down-weighted to avoid punishing anxious users)

## Game Modes
6 game modes accessible from Practice tab (drill cards) and Home tab (scrollable ModeCard row). All modes are gated until at least one lesson is completed.

- **Speed Drill** — 8 MCQ questions, 15s per question countdown, standard quiz view with timer ring
- **Blitz** — 60-second sprint, auto-advance on tap, no feedback phase, dedicated BlitzViewModel + BlitzView
- **Recall** — Review previously missed questions, built from stored QuestionResults
- **Streak** — Answer correctly in a row, one miss ends the game, large MCQ pool (~40 questions)
- **Estimation** — 10 slider-based questions, 10s countdown per question, graded by proximity (5%/15%/30% thresholds → 3/2/1/0 stars), anti-center answer positioning, medium-hard difficulty filter
- **Comparison** — 15 side-by-side pairs, 8s per question, tap the one with the larger answer

Personal bests are tracked for all modes and displayed in drill card decorative orbs.

## Learning Path
- Zigzag node layout alternating left/right
- 5 node states: mastered, attempted, current, available, locked
- Completion-based progression: completing any lesson attempt unlocks the next node (mastery = gold star, not gate)
- Review nodes gate subsequent lessons until completed
- Pulsing ring animation on the recommended next node
- Module banners group lessons visually

## Progress & Gamification
- XP: 10 per correct answer + speed bonus
- Streaks: consecutive calendar days with a session
- Streak freezes: earned every 7-day milestone (max 3 banked), auto-applied on missed days
- Skill levels: per-module, based on session count
- Badges: 27 earnable achievements
- Personal bests: per lesson/review
- Personal bests: tracked per game mode (speedDrill, blitz, recall, streak, estimation, comparison)
- Numind Score: composite score per module and overall, with tier system (displayed via NumindScoreRing in summary views)
- High score celebration: confetti particle burst + "New Personal Best!" badge on all summary screens when a new best is achieved
- Weekly XP leaderboard: 4-week bar chart

## Streak Definition
A streak is the number of consecutive calendar days on which the user completed at least one quiz session. Missing a day costs a streak freeze (auto-applied if available) or resets the streak to 0. Users earn one freeze per 7-day streak milestone, up to 3 banked.

## Local Persistence
- UserDefaults via `ProgressStore` (ObservableObject, @EnvironmentObject)
- `ProgressData` struct: sessions array with computed helpers
- `SessionRecord` per quiz completion
- `ProgressData` fields for 6 mode best scores: `blitzBestScore`, `streakModeBestScore`, `speedDrillBestScore`, `recallBestScore`, `estimationBestScore`, `comparisonBestScore`
- `ProgressData` fields for streak freezes: `availableFreezes`, `freezeMilestonesAwarded`
- No backend required for V1

## Website (Built)
Marketing site at `apps/web/` for SEO acquisition → App Store downloads.

- **14 calculator tools**: Paycheck, Salary Converter, Rent Affordability, Investment, Discount, Loan, Insurance, Car, Student Loan, BNPL, Membership Break-even, Lease vs Buy, FSA, Life Insurance
- **51 state paycheck pages**: programmatic SEO (`/tools/paycheck-calculator/[state]`)
- **40 salary amount pages**: programmatic SEO (`/tools/salary-calculator/[slug]`)
- **Landing page**: 3D hero, animated counters, scroll-reveal sections, module showcase, app CTA
- **Tools directory**: card grid with staggered scroll animations
- **Shared calculator shell**: compact header → calculator widget → inline shortcut teaser → mental math card → FAQ → app CTA → related tools
- **Inline shortcut teaser**: one-line mental math tip + app CTA, placed directly below calculator output (highest-visibility conversion spot)
- **SEO infrastructure**: schema.org/FAQPage JSON-LD, dynamic sitemap, canonical URLs, OG metadata
- **Animations**: scroll-triggered reveals (ScrollReveal), animated calculator output numbers (AnimatedValue), hero count-up (AnimatedAnswer), animated counters, animated progress bars, floating orbs, shimmer text, glow pulse CTA
- **Accessibility**: all animations respect `prefers-reduced-motion` via CSS and JS

## Not Built Yet
- Onboarding/paywall flow
- Backend (Supabase)
- Payments (RevenueCat)
- Analytics (PostHog)
- Crash reporting (Sentry)
- Push notifications
- Social features
