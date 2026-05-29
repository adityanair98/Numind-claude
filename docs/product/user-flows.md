# User Flows

> **Last updated:** May 2026 (after V1 refinement — completion-based progression, True/False removal, streak freezes, dynamic question count).

## Overview

All V1 flows are local-only. No auth, no backend, no paywall.

> **Retired in Phase 7a:** the **Practice tab** and the timed **game modes** (Speed Drill, Blitz, Streak, Estimation, Comparison) were removed and replaced by the **Tools tab** (12 in-app calculators). The "Practice Tab," "Speed Drill," "Blitz," "Streak," "Estimation," and "Comparison" flow sections below are retained as history only — they no longer reflect a live surface. **Recall** ("review your weak spots") survives as a Home entry point.

---

## Flow 1: First Launch

```
App opens
→ SceneDelegate.scene(_:willConnectTo:) fires
   → Reads "numind.appearance" from UserDefaults (default: "system")
   → Sets UIWindow.overrideUserInterfaceStyle on all windows
   → iOS displays correct light/dark LaunchScreen.storyboard instantly
     (LaunchLogo centered + LaunchWordmark at bottom on LaunchBackground)
→ SwiftUI loads RootView
→ SplashView overlays with identical layout (ZStack: logo center, wordmark bottom)
   → Seamless handoff from storyboard — user sees no transition
   → After 1.2s hold, fades out (0.35s, slight scale-up) to reveal app
→ RootTabView (4 tabs: Home, Learn, Progress, Profile)
→ Home tab active by default
→ ProgressStore initialized with empty ProgressData
→ Home shows greeting + daily challenge + workout card (first lesson)
→ Learn tab shows full zigzag path (first node = current, rest = locked)
→ Progress tab shows empty state ("No sessions yet")
```

No onboarding in V1. User lands directly on the Home tab.

### Subsequent Cold Starts

iOS caches the launch screen snapshot using the window's trait collection at app backgrounding time. Because `SceneDelegate` sets `overrideUserInterfaceStyle` early, the cached snapshot always matches the user's chosen appearance (light, dark, or system).

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
   → 5 questions (first attempt) or 8 (subsequent), each:
      → QuizGraphicBanner + PromptCard
      → MCQ: 4 OptionCards OR Free entry: NumpadView
      → Optional: "Show shortcut" hint
      → "Check answer" → feedback phase
      → ResultHero (correct/wrong) + AnswerRevealPill + WhyCard
      → Optional: InlineEncouragementView overlay (fast/hint/streak correct)
      → "Continue" → MotivatorEngine.evaluate()
         → If motivator fires: MotivatorView (full-screen checkpoint) → CTA → next question
         → If no motivator: next question directly
   → After question 8: session complete (NEVER a motivator after last question)
→ SessionRecord created and saved to ProgressStore
→ Personal best check (compare before recording)
→ Level-up check (compare skill level before/after recording)
→ IF level-up: LevelUpView (.fullScreenCover) → dismiss
→ Phase 3: SessionSummaryView
   → ResultHeader:
      → PASS (≥75%): trophy icon + "Session complete!" + animated XP + personal best chip (if applicable) + gold star
      → BELOW 75%: encouraging icon + "Great effort!" + static XP + "Practice more" framing
   → StatsCard (correct, accuracy, streak)
   → MasteryBanner (pass only): gold star + "Lesson mastered!"
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

**Below 75%:**
- "Practice more" (primary) → new QuizSessionViewModel with fresh seeds → Phase 2
- "Continue" (secondary) → dismiss (next lesson is already unlocked)
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
User completes a lesson (any attempt, any score)
→ ProgressStore updated with new SessionRecord
→ LearnViewModel.refresh(using:) recomputes all path nodes
→ Next node transitions: locked → available (or current)
→ Gold star earned if score ≥75% (aspirational, not required)
→ Review nodes unlock when all 3 covered lessons are completed
→ Review nodes gate subsequent lessons until the review itself is completed
```

### Path Node State Machine

```
locked → available (previous node completed)
available → current (first unlocked-unattempted node)
current → attempted (quiz taken but <75% — no gold star yet)
current → mastered (quiz taken and ≥75% — gold star earned)
attempted → mastered (retry achieves ≥75%)
```

Note: Progression only requires completion. Mastery (≥75%) is shown as a gold star but does not gate the next lesson.

---

## Flow 7b: Mid-Session Motivator

```
During quiz question progression (after feedback, before next question):
→ MotivatorEngine.evaluate() checks session state
→ Hard constraint: NEVER fires after the last question
→ Priority evaluation (first match wins):
   1. COACHING: 2+ wrong in last 3 → show lesson shortcut + tip + example
   2. MOMENTUM: 3+ correct streak → show streak count + pace stats
   3. PROGRESS: at halfway point → show completion count + accuracy + bead rail
   4. NEAR FINISH: 2 remaining + accuracy ≥ 60% → show accuracy + daily streak
→ If motivator fires:
   → sessionState = .motivator(checkpoint)
   → MotivatorView shown full-screen (illustration + headlines + stats cards + CTA)
   → Light haptic on appear
   → User taps CTA ("Keep going" / "Continue" / "Finish strong")
   → advance() resumes → next question loads
→ Maximum 2 full-screen motivators per session
→ Minimum 2-question cooldown between motivators
```

**Eligible modes:** Lesson Quiz (8q), Daily Workout (10q), Checkpoint Review (8q), Recall.

**Inline encouragement (separate):**
```
During feedback screen for correct answers:
→ MotivatorEngine.evaluateInline() checks:
   → Fast answer (< 5s) OR used hint + still correct OR 3+ streak
→ If triggered:
   → InlineEncouragementView overlaid on feedback screen
   → Non-blocking: auto-dismisses after 2.5s or on "Continue" tap
   → 3-question cooldown between inline displays
   → Does NOT count toward 2-motivator cap
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

## Flow 14: Streak Mode

```
Home tab or Practice tab: "Streak" mode card (locked until ≥1 lesson mastered)
→ MasteredTemplatePool.mcqTemplates(from:progressData) builds question pool
→ ~40 MCQ questions generated (large pool since game can go long)
→ StreakViewModel created (previousBest: progressStore.streakModeBest)
→ StreakView presented as .fullScreenCover

Playing phase:
→ Question displayed with MCQ options
→ Correct answer: streak counter increments, next question loads
→ Wrong answer: game over → state = .gameOver → summary phase
→ No timer per question — speed is not the constraint, accuracy is

Summary phase (on state == .gameOver):
→ Summary shown inline (no new fullScreenCover)
→ Shows: streak count (large number), personal best badge (if isNewBest), confetti burst (if isNewBest), stats card (streak count, XP earned), Numind Score delta
→ "Try again" → generates new question pool → viewModel.reset() → back to playing
→ "Done" → recordSession() + updateStreakBest() → dismiss

Session recording:
→ SessionRecord saved (lessonId: "streak_mode", moduleId: "mixed", correctCount: streakCount, totalCount: results.count)
→ progressStore.updateStreakBest(score:) updates persistent personal best
```

---

## Flow 15: Estimation

```
Home tab or Practice tab: "Estimate" mode card (locked until ≥1 lesson completed)
→ EstimationViewModel.generateItems(from:templates, count: 10)
   → Filters to difficulty ≥ 2 first, falls back to all if not enough
   → SliderRange.compute() generates adaptive slider bounds with anti-center positioning
     (correct answer placed in 18–38% OR 62–82% of slider range, never near center)
→ EstimationViewModel created (items: items, previousBest: progressStore.estimationBest)
→ EstimationView presented as .fullScreenCover

Playing phase:
→ 10-second countdown timer per question (draining bar, color: teal > orange > red)
→ Prompt card with optional scenario context
→ EstimationSlider: custom slider with step snapping, floating callout, endpoint labels
→ "Drag to estimate" hint until first drag
→ "Lock it in" button (disabled until slider dragged)
→ On submit or timer expiry:
   → Grade by proximity: ≤5% = perfect (3★), ≤15% = good (2★), ≤30% = okay (1★), >30% = miss (0★)
   → Feedback banner shows grade, stars, correct answer, error band on slider
   → "Next" button → advance to next question
→ After 10 questions → state = .complete

Summary phase:
→ Shows: total stars (N/30), XP earned (5 XP per star)
→ Personal best badge + confetti if isNewBest
→ Numind Score delta card
→ "Done" → dismiss

Session recording:
→ SessionRecord saved (lessonId: "estimation", moduleId: "mixed", correctCount: questions with ≥2 stars)
→ progressStore.updateEstimationBest(score:) updates persistent personal best
```

---

## Flow 16: Comparison

```
Home tab or Practice tab: "Compare" mode card (locked until ≥1 lesson completed)
→ ComparisonViewModel.generatePairs(from:templates, count: 15)
   → Each pair uses two different templates, generating two questions with different values
→ ComparisonViewModel created (pairs: pairs, previousBest: progressStore.comparisonBest)
→ ComparisonView presented as .fullScreenCover

Playing phase:
→ 8-second countdown timer per question
→ Two prompt cards side by side (A and B)
→ Player taps the side with the larger answer
→ On tap or timeout:
   → .flashing(Bool) for brief feedback → auto-advance
→ After 15 pairs → state = .complete

Summary phase:
→ Shows: score (N/15 correct), XP earned
→ Personal best badge + confetti if isNewBest
→ Numind Score delta card
→ "Done" → dismiss

Session recording:
→ SessionRecord saved (lessonId: "comparison", moduleId: "mixed")
→ progressStore.updateComparisonBest(score:) updates persistent personal best
```

---

## Flow 17: High Score Celebration

```
Any game mode summary screen
→ ViewModel.isNewBest computed (score > previousBest && score > 0)
→ If isNewBest:
   → ConfettiBurst overlay fires (60 particles, Canvas + TimelineView, 3s duration)
   → NewBestBadge appears with spring bounce-in animation (trophy icon + "New personal best!")
   → Haptic feedback (.success)
→ If not isNewBest but previousBest > 0:
   → "Personal best: N" text shown in muted style
→ Celebration is purely visual — does not block interaction or navigation

The previousBest value is captured at ViewModel creation time (before the session is recorded), ensuring accurate comparison.
```

---

## Flow 11: Practice Tab

```
Practice tab
→ PracticeView
```

**Layout (top -> bottom):**
1. Practice header with Numind wordmark + mastery pill (N/37 mastered)
2. Module tab strip (horizontally scrollable, 64pt rounded-square tiles with module mascots)
3. Module spotlight card (shown when specific module selected -- module stats, accuracy, sessions)
4. Hero quiz card (mixed-mode or module-specific quick quiz, "Start Mixed Round" / "Start Quick Quiz")
5. Drills section -- 6 game-mode drill cards in a 3-column grid:
   - Row 1: Speed Drill, Blitz Mode, Recall
   - Row 2: Streak, Estimate, Compare

**Drill cards:**
- Gradient-filled cards with icon tile, title, subtitle
- Decorative orb (70pt circle, bottom-right) shows personal best score when > 0
- Small decorative orb (24pt, top area) is always purely decorative
- Locked state: muted gradient, lock icon, hit testing disabled
- All modes gated by MasteredTemplatePool.hasUnlockedModes()

**Module selection:**
- "All" tab (default): pulls from all mastered templates
- Specific module tab: scopes quiz and drills to that module's templates
- Module spotlight card appears with module-specific stats (score, accuracy, sessions)

**Quick quiz (hero card):**
- 10 questions from mastered templates (module-scoped or all)
- Uses standard QuizSessionViewModel + PracticeQuizContainer
- No personal best tracking for quick quiz

**Drill launches:**
- Each drill card launches its respective mode as .fullScreenCover
- PracticeQuizContainer wraps Speed Drill and Recall with score tracking
- Other modes use their dedicated Views (StreakView, EstimationView, ComparisonView)

---

## Navigation Map

```
RootTabView
├── Home (NavigationStack)
│   ├── → LessonView (.fullScreenCover)
│   │   ├── Lesson phase
│   │   ├── QuizSessionView (quiz phase)
│   │   │   ├── MotivatorView (inline phase, max 2 per session)
│   │   │   └── InlineEncouragementView (overlay on feedback)
│   │   ├── LevelUpView (.fullScreenCover, optional)
│   │   └── SessionSummaryView (summary phase)
│   │       └── → QuizSessionView (.fullScreenCover, review mistakes)
│   ├── → QuizSessionView (.fullScreenCover, daily challenge — 7q, mastered pool)
│   ├── → QuizSessionView (.fullScreenCover, Speed Drill — 8q, 15s timer, max 1 motivator)
│   ├── → BlitzView (.fullScreenCover)
│   │   └── BlitzSummaryView (inline phase) + ConfettiBurst (if isNewBest)
│   ├── → StreakView (.fullScreenCover)
│   │   └── Summary (inline phase) + ConfettiBurst (if isNewBest)
│   ├── → EstimationView (.fullScreenCover)
│   │   └── Summary (inline phase) + ConfettiBurst (if isNewBest)
│   └── → ComparisonView (.fullScreenCover)
│       └── Summary (inline phase) + ConfettiBurst (if isNewBest)
├── Learn (NavigationStack)
│   ├── → LessonView (.fullScreenCover)
│   │   └── (same as above)
│   └── → CheckpointView (.fullScreenCover)
│       ├── QuizSessionView (quiz phase)
│       ├── LevelUpView (.fullScreenCover, optional)
│       └── SessionSummaryView (summary phase)
├── Tools (NavigationStack)
│   └── → CalculatorShell (NavigationLink push — one of 12 calculators via CalculatorRegistry)
├── Progress (NavigationStack)
│   ├── → SkillDetailView (NavigationLink)
│   └── → ProfileView (.sheet)
└── Profile (NavigationStack)
    └── ProfileView
```
