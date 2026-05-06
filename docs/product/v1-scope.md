# V1 Scope

> **Last updated:** May 2026 (after M60 — Game Modes expansion, Practice drills, Celebration effects).

## Tabs
- Home
- Learn
- Progress
- Profile

## Screens (implemented)
- **Home** — greeting, streak chip, daily workout card, resume card, module cards, horizontally scrollable game modes row (6 modes: Speed Drill, Blitz, Streak, True/False, Estimation, Comparison) via ModeCard component
- **Learn (zigzag path)** - alternating left/right lesson nodes with connector lines, module banners, checkpoint review nodes, pulsing ring on current node
- **Lesson** - concept card, shortcut, worked example, then quiz
- **Quiz** - 8 questions per session, MCQ or free entry, per-question timer, bead progress rail
- **Quiz Feedback** - per-question correct/wrong with explanation
- **Session Summary** - score, XP, mastery banner (pass/fail at 75%), personal best, new badges, retry or continue
- **Checkpoint Review** - review quiz covering 3 lessons, same flow as lesson quiz but no lesson content phase
- **Level-Up** - full-screen celebration when module skill level increases
- **Practice** — module tab strip, module spotlight, hero quiz card, 7 game-mode drill cards (Speed Drill, Blitz, Recall, Streak, True/False, Estimate, Compare), decorative-orb personal best display
- **Streak** — consecutive correct answers, one miss ends game, MCQ pool from mastered templates
- **True/False (Snap)** — 20 rapid-fire true/false statements generated from quiz templates
- **Estimation** — slider-based estimation with 10-second countdown, anti-center answer positioning, medium-hard difficulty filter
- **Comparison** — side-by-side comparison pairs (15 questions, 8s timer), tap the bigger answer
- **High Score Celebration** — confetti burst + "New Personal Best!" badge on all game mode summary screens
- **Progress** - streak, accuracy, sessions stats; weekly goal calendar; weekly XP leaderboard (4-week chart); skill mastery per module; badge collection
- **Profile** - goals, daily target, reset progress

## Content
- **8 modules**: Tips, Discounts, Money Math, Salary, Investing, Estimation, Debt, Travel
- **37 lessons** across all modules
- **187 quiz templates** (5 per lesson)
- **27 badges** across 7 categories

## Quiz System
- 8 questions per session
- Template-driven with randomized variables
- Multiple choice (4 options) or free entry
- 75% mastery threshold (6/8 correct)
- Retry with fresh random values each attempt
- Checkpoint reviews every 3 lessons

## Game Modes
7 game modes accessible from Practice tab (drill cards) and Home tab (scrollable ModeCard row). All modes are gated until at least one lesson is mastered.

- **Speed Drill** — 8 MCQ questions, 15s per question countdown, standard quiz view with timer ring
- **Blitz** — 60-second sprint, auto-advance on tap, no feedback phase, dedicated BlitzViewModel + BlitzView
- **Recall** — Review previously missed questions, built from stored QuestionResults
- **Streak** — Answer correctly in a row, one miss ends the game, large MCQ pool (~40 questions)
- **True/False (Snap)** — 20 statements (half correct, half distractor), rapid-fire true/false judgment
- **Estimation** — 10 slider-based questions, 10s countdown per question, graded by proximity (5%/15%/30% thresholds → 3/2/1/0 stars), anti-center answer positioning, medium-hard difficulty filter
- **Comparison** — 15 side-by-side pairs, 8s per question, tap the one with the larger answer

Personal bests are tracked for all modes and displayed in drill card decorative orbs.

## Learning Path
- Zigzag node layout alternating left/right
- 5 node states: mastered, attempted, current, available, locked
- Mastery gating: must pass at 75%+ to unlock next node
- Review nodes gate subsequent lessons
- Pulsing ring animation on the recommended next node
- Module banners group lessons visually

## Progress & Gamification
- XP: 10 per correct answer + speed bonus
- Streaks: consecutive calendar days with a session
- Skill levels: per-module, based on session count
- Badges: 27 earnable achievements
- Personal bests: per lesson/review
- Personal bests: tracked per game mode (speedDrill, blitz, recall, streak, trueFalse, estimation, comparison)
- Numind Score: composite score per module and overall, with tier system (displayed via NumindScoreRing in summary views)
- High score celebration: confetti particle burst + "New Personal Best!" badge on all summary screens when a new best is achieved
- Weekly XP leaderboard: 4-week bar chart

## Streak Definition
A streak is the number of consecutive calendar days on which the user completed at least one quiz session. Missing a day resets the streak to 0.

## Local Persistence
- UserDefaults via `ProgressStore` (ObservableObject, @EnvironmentObject)
- `ProgressData` struct: sessions array with computed helpers
- `SessionRecord` per quiz completion
- `ProgressData` fields for all 7 mode best scores: `blitzBestScore`, `streakModeBestScore`, `speedDrillBestScore`, `recallBestScore`, `trueFalseBestScore`, `estimationBestScore`, `comparisonBestScore`
- No backend required for V1

## Not Built Yet
- Onboarding/paywall flow
- Calculator tools (tip, bill split, discount)
- Backend (Supabase)
- Payments (RevenueCat)
- Analytics (PostHog)
- Crash reporting (Sentry)
- Push notifications
- Social features
