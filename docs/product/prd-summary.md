# Numind PRD Summary

> **Last updated:** May 2026 (after M56).

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

## V1 Modules (8 total)
1. **Tips** (tips) - tip calculation, pre/post-tax, bill splitting (5 lessons)
2. **Discounts** (discounts) - percentage off, BOGO, stacked discounts, unit pricing (5 lessons)
3. **Money Math** (money_math) - budgeting, subscriptions, cost per use, sales tax, cart estimation (5 lessons)
4. **Salary** (salary) - net pay, raises, overtime, pay period conversion (4 lessons)
5. **Investing** (investing) - simple interest, Rule of 72, ROI (3 lessons)
6. **Estimation** (estimation) - rounding, hourly rate, percent change, doubling/halving, multiply by 5 (6 lessons)
7. **Debt** (debt) - credit card interest, minimum payments, loans, DTI, extra payments (5 lessons)
8. **Travel** (travel) - currency conversion, exchange fees, travel budgets, accommodation, insurance (5 lessons)

**Total: 37 lessons, 187 quiz templates**

## Core User Loop
Home / Today
-> pick a lesson from the learning path
-> read short lesson (concept + shortcut + example)
-> quiz: 8 template-generated questions
-> instant feedback per question (correct/wrong + explanation)
-> session summary with XP, personal best, mastery status
-> progress update (streak, badges, level-up)

## Learning Path
The Learn tab presents lessons as a **zigzag path** (Duolingo-style), alternating nodes left and right. Lessons are grouped by module with banner headers. Every 3 lessons within a module, a **checkpoint review** node appears that tests across all 3 preceding lessons.

### Mastery Gating
- Each quiz requires **75% accuracy** (6/8 correct) to be considered "mastered"
- The next lesson/review node only unlocks when the previous one is mastered
- Failed quizzes can be retried from both the summary screen and the path node
- Each retry generates fresh random values and answer choices (same templates, different numbers)

### Checkpoint Reviews
- Review nodes appear after every 3 lessons within a module
- They pull templates from all covered lessons via round-robin sampling
- Reviews are recorded with stable IDs (`review_{moduleId}_{groupIndex}`)
- Reviews gate subsequent lessons just like regular lesson quizzes

## Quiz System
- **8 questions per session** (both lessons and reviews)
- Questions generated from **templates** with randomized variables
- **Multiple choice** (4 options) or **free entry** (numeric keypad) depending on template
- Timer per question for speed bonus XP
- Distractor strategies: roundedNeighbor, offByDecimal, commonMistake
- Each template defines: id, moduleId, difficulty, promptTemplate, variableRules, answerFormula, answerFormat, distractorStrategy, explanationTemplate
- Templates are interleaved and shuffled for variety

## Progress & Gamification

### XP System
- Base XP per correct answer: 10
- Speed bonus: extra XP for fast answers (< 5 seconds)
- XP displayed in session summary and on progress tab

### Streaks
A streak is the number of consecutive calendar days on which the user completed at least one quiz session.

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
Session summaries flag new personal bests per lesson (higher correct count or XP).

## Session Types
- **Lesson quiz:** 8 questions from that lesson's 5 templates
- **Checkpoint review:** 8 questions round-robined across 3 lessons' templates

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
The website is not the product. It supports acquisition through:
- landing page
- SEO calculators
- privacy/terms/support
- App Store conversion

## V1 Build Priority
Currently implemented:
- SwiftUI app shell with 4-tab navigation
- Design tokens and theme system
- Local content model with JSON-based lessons and templates
- Template-driven quiz engine with 40+ answer formulas
- All 8 modules with 37 lessons
- 187 quiz templates (5 per lesson)
- Mastery gating at 75%
- Checkpoint review quizzes
- Zigzag learning path
- XP, streaks, badges, levels
- Personal bests and weekly leaderboard
- Session summary with retry flow
- Level-up ceremony

Not built yet:
- backend (Supabase)
- payments (RevenueCat)
- analytics (PostHog)
- crash reporting (Sentry)
- onboarding/paywall flow
- calculator tools
- push notifications
- social features
