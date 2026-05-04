# V1 Scope

> **Last updated:** May 2026 (after M56).

## Tabs
- Home
- Learn
- Progress
- Profile

## Screens (implemented)
- **Home** - greeting, streak chip, daily workout card, resume card, module cards
- **Learn (zigzag path)** - alternating left/right lesson nodes with connector lines, module banners, checkpoint review nodes, pulsing ring on current node
- **Lesson** - concept card, shortcut, worked example, then quiz
- **Quiz** - 8 questions per session, MCQ or free entry, per-question timer, bead progress rail
- **Quiz Feedback** - per-question correct/wrong with explanation
- **Session Summary** - score, XP, mastery banner (pass/fail at 75%), personal best, new badges, retry or continue
- **Checkpoint Review** - review quiz covering 3 lessons, same flow as lesson quiz but no lesson content phase
- **Level-Up** - full-screen celebration when module skill level increases
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
- Weekly XP leaderboard: 4-week bar chart

## Streak Definition
A streak is the number of consecutive calendar days on which the user completed at least one quiz session. Missing a day resets the streak to 0.

## Local Persistence
- UserDefaults via `ProgressStore` (ObservableObject, @EnvironmentObject)
- `ProgressData` struct: sessions array with computed helpers
- `SessionRecord` per quiz completion
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
- Daily workout session type
- Speed round session type
