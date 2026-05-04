# User Flows

> **Last updated:** May 2026 (after M57 — Game Modes: Speed Drill, Blitz, Enhanced Daily Challenge).

## Overview

All V1 flows are local-only. No auth, no backend, no paywall.

---

## Flow 1: First Launch

```
App opens
→ RootTabView (4 tabs: Home, Learn, Progress, Profile)
→ Home tab active by default
→ ProgressStore initialized with empty ProgressData
→ Home shows greeting + daily challenge + workout card (first lesson)
→ Learn tab shows full zigzag path (first node = current, rest = locked)
→ Progress tab shows empty state ("No sessions yet")
```

No onboarding in V1. User lands directly on the Home tab.

---

## Flow 2: Lesson Quiz (primary loop)

```
Home "Start workout" OR Learn tab node tap
→ LessonView presented as .fullScreenCover
→ Phase 1: Lesson content
   → LessonHero (progress bar + title + quiz count)
   → RuleCard (concept)
   → WorkedExampleCard (monospaced breakdown)
   → WhyCard (shortcut explanation)
   → "Start quiz" footer button
→ Phase 2: Quiz (QuizSessionView)
   → 8 questions, each:
      → QuizGraphicBanner + PromptCard
      → MCQ: 4 OptionCards OR Free entry: NumpadView
      → Optional: "Show shortcut" hint
      → "Check answer" → feedback phase
      → ResultHero (correct/wrong) + AnswerRevealPill + WhyCard
      → "Continue" → next question
   → After question 8: session complete
→ SessionRecord created and saved to ProgressStore
→ Personal best check (compare before recording)
→ Level-up check (compare skill level before/after recording)
→ IF level-up: LevelUpView (.fullScreenCover) → dismiss
→ Phase 3: SessionSummaryView
   → ResultHeader:
      → PASS (≥75%): trophy icon + "Session complete!" + animated XP + personal best chip (if applicable)
      → FAIL (<75%): retry icon + "Almost there!" + static XP + score gap message ("You got X/N — need Y to master")
   → StatsCard (correct, accuracy, streak)
   → MasteryBanner (pass only): "Lesson mastered! / Next lesson unlocked"
   → New badges (if any)
   → Recap (per-question results)
   → Footer actions (see below)
→ Dismiss → back to Learn tab (path recomputed)
```

### Summary Footer Actions

**Mastered (≥75%):**
- "Review N mistake(s)" → ReviewMistakesEngine quiz (.fullScreenCover)
- "Continue learning" / "Skip & continue" → dismiss
- "Done for today" → dismiss to Home

**Not mastered (<75%):**
- "Retry quiz" (orange, primary) → new QuizSessionViewModel with fresh seeds → Phase 2
- "Skip for now" (secondary button — light background, blue text, visually subordinate to "Retry quiz") → dismiss
- "Done for today" → dismiss to Home

---

## Flow 3: Checkpoint Review

```
Learn tab: review node tap
→ CheckpointView presented as .fullScreenCover
→ No lesson content phase — jumps straight to quiz
→ CheckpointQuizEngine.build(lessonIds:) generates 8 questions
   (round-robin across 3 covered lessons' templates)
→ Quiz flow identical to Flow 2 Phase 2
→ Session recorded with review ID (review_{moduleId}_{groupIndex})
→ Level-up check → optional LevelUpView
→ SessionSummaryView with retry support
→ Dismiss → back to Learn tab
```

---

## Flow 4: Daily Challenge

```
Home tab: "Start challenge" button
→ DailyChallengeEngine.dailyQuestions(from:progressData:) generates 10 questions
   → Template pool: mastered-lesson templates only (falls back to all if none mastered)
   → Questions seeded with today's date (YYYYMMDD) — same for all users each day
→ QuizSessionView presented as .fullScreenCover (standard quiz UI)
→ Quiz flow (10 questions, same question/feedback cycle)
→ On completion:
   → SessionRecord saved (lessonId: "daily_challenge", moduleId: "mixed")
   → progressStore.markDailyChallengeCompleted()
→ Dismiss → Home updates to show "✓ Come back tomorrow"
```

Daily challenge resets each calendar day. Questions are drawn from mastered lessons only — users see content they've already learned, applied with fresh numbers each day.

---

## Flow 5: Review Mistakes

```
SessionSummaryView: "Review N mistake(s)" button
→ ReviewMistakesEngine.build(from:results) creates a quiz
   targeting only the templates the user got wrong
→ QuizSessionView presented as .fullScreenCover from within summary
→ On completion: dismiss back to summary
```

Review-mistakes sessions are not recorded to ProgressStore — they are practice-only.

---

## Flow 6: Retry Quiz

```
SessionSummaryView: "Retry quiz" button (shown when <75%)
→ New QuizSessionViewModel created with same lesson but fresh random seeds
→ All state reset (isNewPersonalBest, newBadgeIds, pendingLevelUp)
→ Phase resets to .quiz
→ Entirely new question values, answer choices, and order
→ Flows back through Phase 2 → completion → summary
```

---

## Flow 7: Learning Path Progression

```
User masters a lesson (≥75% on any attempt)
→ ProgressStore updated with new SessionRecord
→ LearnViewModel.refresh(using:) recomputes all path nodes
→ Next node transitions: locked → available (or current)
→ Review nodes unlock when all 3 covered lessons are mastered
→ Review nodes gate subsequent lessons until the review itself is mastered
```

### Path Node State Machine

```
locked → available (previous node mastered)
available → current (first unlocked-unattempted node)
current → attempted (quiz taken but <75%)
current → mastered (quiz taken and ≥75%)
attempted → mastered (retry achieves ≥75%)
```

---

## Flow 8: Badge Earning

```
Any SessionRecord saved to ProgressStore
→ BadgeEvaluator.evaluate(progressData) runs
→ Compares earned badges vs. previously earned
→ New badge IDs stored in progressStore.newlyEarnedBadgeIds
→ SessionSummaryView displays new badges with celebration row
→ Haptic feedback (.success) on appear
→ Badge grid in Progress tab updates
```

---

## Flow 9: Level-Up

> **Mastery gate:** The level-up ceremony only triggers when the completed session meets the mastery threshold (≥75% score). Failed quiz attempts record to ProgressStore but do not trigger the ceremony.

```
SessionRecord saved → skill level recalculated for module
→ If newLevel > prevLevel:
   → LevelUpInfo created (moduleName, icon, color, newLevel)
   → LevelUpView presented as .fullScreenCover
   → Confetti + spring animation + haptic
   → "Keep going" → dismiss → summary phase begins
```

Skill levels: Beginner (1), Developing (2), Skilled (3), Advanced (4), Expert (5).

---

## Flow 10: Profile & Settings

```
Profile tab (or gear icon from Progress tab)
→ ProfileView
→ Available actions:
   → View stats (sessions, XP, accuracy, best streak)
   → Toggle daily reminder → notification permission flow
   → Set reminder time (DatePicker)
   → Switch appearance (Auto / Light / Dark)
   → Reset progress → destructive confirmation alert → ProgressStore.reset()
```

---

## Flow 12: Speed Drill

```
Home tab: "Speed Drill" mode card (locked until ≥1 lesson mastered)
→ MasteredTemplatePool.mcqTemplates(from:progressData) builds question pool
→ 8 MCQ questions generated (cycles through pool if needed), shuffled
→ QuizSessionViewModel created with questionTimeLimit: 15.0
→ QuizSessionView presented as .fullScreenCover
   → Toolbar: circular countdown ring (replaces elapsed timer)
     → Ring color: blue (>5s) → orange (≤5s) → red (≤3s)
   → 15s per question; timer starts on viewModel.startSession() → .onAppear
   → Timer expiry: handleTimeout() → .feedback(UUID()) = automatic wrong answer
   → Quiz flow otherwise identical to standard lesson quiz
   → User can still answer before timer expires (cancelQuestionTimer on checkAnswer)
→ On completion:
   → SessionRecord saved (lessonId: "speed_drill", moduleId: "mixed")
→ SessionSummaryView (standard pass/fail summary)
→ Dismiss → Home tab
```

Speed Drill uses the standard QuizSessionView + QuizSessionViewModel. Only the `questionTimeLimit` parameter and the countdown ring overlay differ from a normal quiz.

---

## Flow 13: Blitz Mode

```
Home tab: "Blitz" mode card (locked until ≥1 lesson mastered)
→ BlitzEngine.generateQuestionQueue(from:progressData) pre-generates ~45 MCQ questions
   (cycles through mastered templates until queueSize reached)
→ BlitzViewModel created (previousBest: progressStore.blitzBest)
→ BlitzView presented as .fullScreenCover

Playing phase:
→ viewModel.start() begins 60s countdown
→ Top bar: close button | circular countdown timer (72pt) | score counter
→ Question area: prompt card (large text, no scenario card)
→ Options: 2×2 grid of large MCQ buttons (tap = immediate submit, no "Check answer")
→ On tap: viewModel.select(choiceId)
   → Score updated (if correct)
   → State → .flashing(Bool) for 0.5s (green flash = correct, red = wrong)
   → Auto-advance to next question after flash
→ Countdown runs concurrently; reaching 0 → endGame() → state = .complete

Summary phase (on state == .complete):
→ BlitzSummaryView shown inline (no new fullScreenCover)
→ Shows: score, personal best badge (if isNewBest), stats card, footer buttons
→ "Play again" → BlitzEngine re-generates queue → viewModel.reset() → back to playing
→ "Done" → recordSession() + updateBlitzBest() → dismiss full screen cover

Session recording (on Done):
→ SessionRecord saved (lessonId: "blitz_session", moduleId: "mixed",
                        correctCount: score, totalCount: totalAnswered)
→ progressStore.updateBlitzBest(score:) updates persistent personal best
```

Blitz uses its own `BlitzViewModel` and `BlitzView` — the lifecycle (auto-advance, global timer, no feedback phase) differs too much from the standard quiz to share `QuizSessionViewModel`.

---

## Flow 11: Practice Tab

```
Practice tab
→ Module tab strip shows all 8 modules
→ Tap module tab → module header card and lesson list update (animated .easeInOut)
→ "Surprise Me" dice button (header card, top-right)
   → random lesson selected from current module
   → LessonView presented as .fullScreenCover
→ Lesson row tap → LessonView presented as .fullScreenCover
→ Lesson completion → dismiss LessonView → back to Practice tab
   → lesson row updates status (index circle, subtitle, status icon)
```

**No mastery gating.** All lessons in the Practice tab are accessible regardless of Learn tab progression. Tapping any row launches the lesson directly — there is no path node state check.

**Practice vs. Learn.** The Learn tab enforces a gated quest-journey path. The Practice tab is a free-browse companion — users can revisit any lesson, drill specific modules, or explore ahead without unlocking.

---

## Navigation Map

```
RootTabView
├── Home (NavigationStack)
│   ├── → LessonView (.fullScreenCover)
│   │   ├── Lesson phase
│   │   ├── QuizSessionView (quiz phase)
│   │   ├── LevelUpView (.fullScreenCover, optional)
│   │   └── SessionSummaryView (summary phase)
│   │       └── → QuizSessionView (.fullScreenCover, review mistakes)
│   ├── → QuizSessionView (.fullScreenCover, daily challenge — 10q, mastered pool)
│   ├── → QuizSessionView (.fullScreenCover, Speed Drill — 8q, 15s timer, mastered MCQ pool)
│   └── → BlitzView (.fullScreenCover)
│       └── BlitzSummaryView (inline phase within BlitzView)
├── Learn (NavigationStack)
│   ├── → LessonView (.fullScreenCover)
│   │   └── (same as above)
│   └── → CheckpointView (.fullScreenCover)
│       ├── QuizSessionView (quiz phase)
│       ├── LevelUpView (.fullScreenCover, optional)
│       └── SessionSummaryView (summary phase)
├── Practice (NavigationStack)
│   └── → LessonView (.fullScreenCover)  [any lesson, no gating]
│       └── (same as Learn → LessonView above)
├── Progress (NavigationStack)
│   ├── → SkillDetailView (NavigationLink)
│   └── → ProfileView (.sheet)
└── Profile (NavigationStack)
    └── ProfileView
```
