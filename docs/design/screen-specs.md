# Numind — Screen Specs (V1)

> **Last updated:** May 2026 (after V1 refinement — completion-based progression, 10 modules, dynamic question count, streak freezes).
> **Status:** Implemented screens, reflecting the current SwiftUI codebase.
> **Tokens referenced** are the Swift constants in `apps/ios/Numind/Core/DesignSystem/Tokens/`. Do not introduce new tokens here — if a value is missing, propose it as a token first.

This document defines the per-screen layout, copy, and states for V1 screens. Every screen sits inside `Theme.Colors.softBackground` and uses the standard `Theme.Spacing.screenHorizontal = 20` gutter unless noted.

---

## Conventions

| Token alias | Swift |
|---|---|
| **softBg** | `Theme.Colors.softBackground` (#F6F9FF) |
| **cardBg** | `Theme.Colors.cardBackground` (#FFFFFF) |
| **navy** | `Theme.Colors.deepNavy` (#10224A) |
| **blue** | `Theme.Colors.primaryBlue` (#2F6BFF) |
| **teal** | `Theme.Colors.mindTeal` (#2DC6B6) |
| **yellow** | `Theme.Colors.insightYellow` (#FFD84D) |
| **muted** | `Theme.Colors.mutedText` (#6B7280) |
| **red** | `Theme.Colors.errorSoftRed` (#EF6B6B) |
| **gutter** | `Theme.Spacing.screenHorizontal = 20` |
| **section** | `Theme.Spacing.sectionSpacing = 28` |
| **card-pad** | `Theme.Spacing.cardPadding = 18` |
| **r-card** | `Theme.Radius.card = 20` |
| **r-pill** | `Theme.Radius.pill = 999` |

Tints are derived as `Color.opacity(0.12–0.22)` overlays of the source token — never new hexes. Additional tint tokens: `primaryBlueTint`, `mindTealTint`, `errorSoftRedTint`, `insightYellowTint`, `mutedTint`, `insightText`.

The four root tabs use the **iOS large-title** style (32–34pt rounded, navy). Pushed and modal screens use a **44pt inline header** with leading chevron-back or X.

---

## 00 · Launch Screen & Splash

**Files:** `Resources/Base.lproj/LaunchScreen.storyboard` (native) + `App/SplashView.swift` (SwiftUI overlay)

The launch experience has two seamless phases:

### Phase 1: Native Launch Screen (LaunchScreen.storyboard)

Displayed instantly by iOS before any SwiftUI code runs.

**Layout:**
- **Background:** `LaunchBackground` named color — brand blue `srgb(0.184, 0.420, 1.000)` in light mode, dark navy `srgb(0.059, 0.090, 0.149)` in dark mode.
- **Logo:** `LaunchLogo` image, 120×120pt, centered horizontally and vertically (Auto Layout centerX + centerY constraints). Background-removed symbol with transparent background, light and dark variants.
- **Wordmark:** `LaunchWordmark` image, height 24pt, centered horizontally, pinned 36pt above safe area bottom. White text variant used for both modes.

### Phase 2: SplashView (SwiftUI overlay)

Takes over from the storyboard with an identical layout, then fades out.

**Layout:** `ZStack` matching storyboard exactly:
- `Color("LaunchBackground")` full bleed.
- `LaunchLogo` at exact center (ZStack default), 120×120pt.
- `LaunchWordmark` at bottom via `VStack { Spacer(); Image(...).frame(height: 24).padding(.bottom, 36) }`.

**Animation:** After 1.2s hold, fades to 0 opacity with 1.06× scale-up over 0.35s. `allowsHitTesting(false)` prevents interaction during fade.

**Appearance:** `SceneDelegate` sets `UIWindow.overrideUserInterfaceStyle` before the storyboard dismisses, ensuring iOS caches the correct light/dark snapshot for next cold start.

---

## 01 · Home (`Today`)

**File:** `Features/Home/HomeView.swift` + `HomeViewModel.swift`
**Tab:** Home (active). **Header style:** large title, "Today".

**Layout (top → bottom):**

1. **GreetingHeader** — HStack: 44pt avatar circle (user initial, blue tint) · time-based greeting ("👋 Good morning, [name]!") + subtitle "Ready for your daily workout?".
2. **StreakWeekCard** — `NumindCard` containing:
   - Top row: flame icon (22pt, yellow) + streak count (30pt bold rounded) + "day streak" label + encouragement copy.
   - Day row: 7-column M–S calendar strip. Each day: 28pt circle (blue fill + white check if completed, muted tint otherwise) + day letter caption.
3. **DailyChallengeSection** — eyebrow "Daily challenge":
   - `NumindCard` with blue tint background. Contains: bolt icon circle (44pt, blue/teal depending on completion state) + "5 questions · All modules" headline + status caption.
   - `BeadRail.chunky` (5 segments) + XP pill "+50 XP max".
   - CTA: `PillButton.primary` "Start challenge" (or "✓ Come back tomorrow" if completed).
   - Daily challenge launches a mixed-module `QuizSessionView` via `DailyChallengeEngine`.
4. **WorkoutSection** — eyebrow "Today's workout":
   - `NumindCard` with: `IconTile` (52pt, module color) + module eyebrow + lesson title + concept preview (2 lines) + duration pill ("5–7 min").
   - `BeadRail.chunky` (progress 0 / question count) + XP pill.
   - `PillButton.primary` "Start workout".
   - **All-done state:** teal checkmark circle (44pt) + "All done for today!" + "Come back tomorrow" caption.
5. **ContinueSection** — eyebrow "Continue learning" (shown when there's a resumable lesson):
   - `NumindCard`: module icon tile + module eyebrow + lesson title + progress bar (module color) + "N of M lessons · Resume" + trailing chevron.
6. **UpNextSection** — eyebrow "Up next" (shown when multiple lessons available):
   - Flush `NumindCard` with rows: 36pt `IconTile` + lesson title + module subtitle + chevron. Rows separated by hairline dividers.

**Copy guidance:** Encouraging, second-person ("you"), present tense.

**Empty state (fresh install):** Keep DailyWorkoutCard but swap copy. Hide "Continue learning" + "Up next" sections.

---

## 02 · Learn (quest-journey path)

**File:** `Features/Learn/LearnView.swift` + `LearnViewModel.swift`
**Tab:** Learn (active). **Header style:** large title, "Learn".

**Layout (Phase 5):**

The Learn tab has two top-level sub-tabs (segmented picker at the top): **Worlds** and **Paths**.

**Worlds sub-tab** — a Brilliant-style fullscreen page-swipe carousel of 10 world hero pages (one per module), implemented with `TabView(selection:).tabViewStyle(.page)`. Each hero page renders:
1. **World eyebrow:** "WORLD N" in the module accent color.
2. **Title + subtitle:** module title in display font, module subtitle in caption.
3. **Themed illustration:** 240×240 ZStack composed from the existing `Module` fields — no bespoke artwork. Layers (back to front): outer tinted circle (module color, 0.14 fill / 0.28 border); the module's `glyph` ("%", "$", "÷", …) as a 180pt low-opacity background watermark; the module's SF Symbol at 88pt as the hero figure; the module's emoji `mascot` floating top-right at 44pt with a soft drop shadow.
4. **Continue card** pinned near the bottom: dynamic eyebrow label (PICK UP HERE / RESUME / UP NEXT / REVISIT / JUMP AHEAD based on the next node's state) + lesson title + done/total counter + a large module-color CTA ("Continue world" / "Start world"). Conquered worlds get a gold "WORLD CONQUERED" callout instead.
5. **Page indicator dots** at the bottom (`indexViewStyle(.page(backgroundDisplayMode: .always))`) show position 1-of-10 and which worlds have been visited.

Tapping Continue from a hero page opens the world's **quest map** as a fullscreen view that replaces the carousel within the Learn tab (the header + segmented control hide so the map gets full vertical real estate). A floating down-chevron at top-left returns to the carousel. The quest map itself is the existing zigzag rendering:

1. **World banner** at the top — full-width card with colored tint background: filled accent circle (module icon) + module title (headline) + "N/N completed" counter + 32pt progress ring.
2. **Quest nodes** — 64pt circles positioned along the path. Nodes alternate left and right using `.offset(x:)` with `pathOffset: 56pt` from center.
   - **Node button:** full-color fill for current/mastered nodes; white fill with accent border for available; dimmed (0.55 opacity, 0.92 scale) with the lesson number/icon for `notYetSuggested` — Phase 5e soft locks made these tappable instead of hard-gated. Optional `PulsingRing` animation behind `current` nodes.
   - **Node label:** lesson title (110pt width, 2-line max, centered) + state subtitle below the node ("JUMP AHEAD" for soft-locked lessons).

**Paths sub-tab** — a vertical scroll of pack cards (one per Life-Event Pack). Each card shows the pack title, tagline, status badge (FOCUS / ACTIVE x/y / COMPLETE ✓ / NEW), lesson count, and estimated time. Tapping opens the pack's detail sheet.
   - **Curved connectors:** SwiftUI `Path` with bezier curves (S-curve between consecutive nodes), not straight lines or arrows.

**5 Node States:**

| State | Circle fill | Icon / decoration | Label subtitle |
|---|---|---|---|
| `mastered` | full accent color | white checkmark + golden star badge + sparkle decorations | "Mastered ✓" |
| `attempted` | orange | orange retry icon | "Practice more" |
| `current` | full accent color | pulsing ring animation + bouncing "START" badge | "Available" |
| `available` | white, accent border | lesson number in accent color | "Available" |
| `locked` | muted fill, 45% opacity | lock icon | "Locked" |

**Node types:**
- **Lesson nodes** — tapping opens `LessonView` via `.fullScreenCover`.
- **Review nodes** — tapping opens `CheckpointView` via `.fullScreenCover`. Reviews appear after every 3 lessons within a module.

**Completion-based progression:** locked nodes have 0.45 opacity and ignore taps. A node unlocks when the preceding node is completed (any attempt). Mastery (≥75%) earns a gold star but is not required for progression.

**Reactivity:** Path rebuilds on every `progressStore` change via `.onChange(of: progressStore.totalSessions)`.

> **Rationale.** The quest-journey path replaces the earlier zigzag list design. Curved S-curve connectors and distinct node decorations (pulsing ring, bouncing START badge, star + sparkle for mastered) make progress feel game-like and spatial. The world banner gives each module a clear visual identity. The single pulsing "current" node provides a clear call to action without cluttering the path.

---

## 03 · Module Detail (legacy)

**File:** `Features/Learn/ModuleDetail/ModuleDetailView.swift`
**Status:** Still in codebase but not actively navigated to from the Learn tab. The zigzag path (02) replaced this screen as the primary learning navigation. May be removed in a future cleanup.

---

## 03b · Practice

**File:** `Features/Practice/PracticeView.swift`
**Tab:** Practice (active). **Header style:** large title, "Practice".

The Practice tab gives users free-access browsing of all lessons across all modules, independent of Learn tab progression. All lessons are accessible regardless of mastery gating.

**Layout (top → bottom):**

1. **Module Tab Strip** — `ScrollView(.horizontal, showsIndicators: false)` at the top of the screen. Contains one icon tile per module (10 total).

   **Each tile:** 60×60 rounded square (`r-card` corners), module SF Symbol icon (24pt), module short-name label below (10pt).

   **Selected state:** `tintBackground` fill (accent color at 0.15 opacity), 2pt accent-color border, accent-colored icon, bold label, subtle glow shadow (accent color, radius 6, opacity 0.25).

   **Unselected state:** `cardBackground` fill, `hairline` border, `mutedText` icon color, regular label weight.

   Tapping a tile updates the header card and lesson list with an `.animation(.easeInOut)` transition.

2. **Module Header Card** — `NumindCard` with `tintBackground` fill (module accent at 0.12 opacity).

   Contains:
   - Module title (20pt bold rounded, `deepNavy`)
   - Module subtitle (caption, `mutedText`)
   - **"Surprise Me" button** — 36pt circle, accent fill, dice SF Symbol icon (white), positioned top-right corner. Tapping picks a random lesson from the selected module and launches `LessonView` as `.fullScreenCover`.
   - **Watermark icon** — module SF Symbol at 64pt, accent color at 0.12 opacity, right-aligned behind the text content.
   - **Mastery progress bar** — 6pt capsule, accent fill over accent/0.2 track. Shows fraction of lessons mastered in this module.
   - **"N/M mastered" label** — 11pt semibold, accent color at 0.8 opacity, below the progress bar.

3. **Lesson List** — "LESSONS" eyebrow label (`sectionLabel`) + a single `NumindCard` with hairline-divider-separated rows. One row per lesson in the selected module.

   **Each row (HStack):**
   - **Index circle** (32pt):
     - Mastered: accent fill + white `checkmark` icon
     - Attempted-not-mastered: `warmOrangeTint` fill + `warmOrange` lesson number
     - Not attempted: `mutedTint` fill + `mutedText` lesson number
   - **Title + subtitle stack:**
     - Title: body weight, semibold, `deepNavy`
     - Subtitle: "Best: NN%" in accent color (mastered), "Best: NN%" in `warmOrange` (attempted), "Not attempted yet" in `mutedText` (not attempted)
   - **Status icon + chevron (trailing):**
     - Mastered: `checkmark.seal.fill` in accent color + `chevron.right` (muted)
     - Attempted: `arrow.counterclockwise` in `warmOrange` + `chevron.right` (muted)
     - Not attempted: `chevron.right` only (muted)

   Tapping any row launches `LessonView` as `.fullScreenCover`. No mastery gating — all rows are tappable.

**Removed from earlier designs:** FlowRow pill layout, expand/collapse module cards, global Surprise Me hero card at screen top.

---

## 04 · Lesson

**File:** `Features/Learn/Lesson/LessonView.swift` + `LessonViewModel.swift`
**Header style:** inline, leading X (dismisses with confirm), no title in header (lesson title is in the body).

**LessonView manages 3 phases** as an internal `Phase` enum: `.lesson` → `.quiz` → `.summary`. The quiz and summary phases embed `QuizSessionView` and `SessionSummaryView` respectively.

**Layout (lesson phase):**

1. **LessonHero** — progress bar (4pt, accent color) + step label ("Lesson 2 of 5") · category chip (accent color, capsule) · lesson title (26pt bold rounded) · quiz count badge ("8 questions to follow").
2. **RuleCard** — `NumindCard`: "THE RULE" eyebrow (accent) + concept body text.
3. **WorkedExampleCard** — "WORKED EXAMPLE" eyebrow (muted) + monospaced label/value rows. Each row: left label + right value, separated by hairlines. Final row has accent tint background and bold accent text.
4. **WhyCard** — `NumindCard` with `insightYellowTint` background: lightbulb icon + "Why this works" headline (insightText color) + shortcut body text.
5. **Footer** — sticky `PillButton.primary` "Start quiz". Gradient mask over scroll content.

**Phase transitions:**
- "Start quiz" → builds `QuizSessionViewModel` and transitions to `.quiz` phase.
- Quiz completion → records `SessionRecord`, checks personal best and level-up, transitions to `.summary` (or level-up ceremony first).
- Level-up detected → `LevelUpView` shown as `.fullScreenCover`; on dismiss → `.summary` phase.
- "Retry quiz" from summary → new `QuizSessionViewModel` with fresh random seeds, back to `.quiz`.

---

## 05 · Quiz Question

**File:** `Features/Quiz/QuizSessionView.swift` + `QuizSessionViewModel.swift`
**Header style:** inline. Leading X (dismisses), title = lesson/session name, trailing = timer pill.

The quiz supports two input modes: **multiple choice** (4 options) and **free entry** (numeric keypad).

**Layout:**

1. **BeadRail** — `BeadRail.chunky` centered (8 beads for standard sessions, progress updates as questions are answered).
2. **QuizGraphicBanner** — decorative themed header graphic based on template ID (via `QuestionTheme`).
3. **PromptCard** — `NumindCard` containing:
   - Top row: module chip (capsule, module color) + difficulty pips (3 dots, filled to difficulty level) + question counter ("3 / 8").
   - Optional scenario text (italic, muted).
   - Prompt text (`Theme.Typography.title`, navy).

4a. **Option list (MCQ mode)** — vertical stack of `OptionCard`s, 10pt gap. 4 options (A–D). Key letter on the left, value on the right.
4b. **Free entry (freeEntry mode)** — display strip (38pt bold rounded, shows typed value with format prefix/suffix) + `NumpadView` (custom numeric keypad with digit, decimal, delete buttons).

5. **Hint section** — initially a capsule button "Show shortcut" (insightYellowTint). On tap, expands to a full `NumindCard` (insightYellowTint) with lightbulb icon + "SHORTCUT" eyebrow + lesson shortcut text.

6. **Footer** — sticky "Check answer" button. Disabled state = muted tint + muted text until an option is selected (MCQ) or text is entered (free entry).

**Timer pill:** trailing toolbar item, monospaced elapsed time in a muted capsule. Updates every second via `TimelineView`.

**States:**
- **No selection / empty input:** Check answer button disabled.
- **Selected (MCQ):** option border + tint = blue.
- **Hint revealed:** button expands to full shortcut card.
- **Feedback transition:** confetti + haptic for correct; error haptic for wrong.

---

## 06 · Quiz Feedback

**File:** `Features/Quiz/QuizSessionView.swift` (feedback phase within same view)
**Header style:** identical to Quiz Question (the user stays in the same flow).

**Layout:**

1. **BeadRail** — same as Question, current bead now marked as answered.
2. **ResultHero** — `NumindCard` with tinted background (tealTint for correct, redTint for wrong):
   - 64pt circle (teal/red filled) with white checkmark/xmark.
   - Headline: "Nice — that's right." / "Not quite."
   - Correct: "🎉 +10 XP · streak +1" + optional speed bonus pill (insightYellowTint, bolt icon, "+N XP speed bonus!").
   - Wrong: "No penalty — keep going."
3. **AnswerRevealPill** — full-width capsule showing correct answer in 30pt bold rounded white text on teal/red background.
4. **OptionsRecap (MCQ only)** — same option list, but correct option gets `correct` state (teal), user's wrong pick gets `wrong` state (red), all others dimmed to 0.45 opacity.
5. **WhyCard** — `NumindCard` (insightYellowTint): lightbulb + "WHY" eyebrow + explanation text + divider + "Shortcut:" label + shortcut text.
6. **Footer** — sticky `PillButton.primary` "Continue" → advances to next question or completes session.

---

## 07 · Session Summary

**File:** `Features/Quiz/SessionSummaryView.swift`
**Header style:** inline, **trailing X only** (no back). The session is done.

**Layout:**

1. **ResultHeader** — centered, split by pass/fail:

   **Pass (≥75%):**
   - 96pt circle (accent tint) + trophy icon.
   - `Theme.Typography.display` "Session complete!".
   - Caption "N questions · MM:SS".
   - Animated "+XP" pill (insightYellowTint, 22pt bold rounded, insightText, springs in with 0.3s delay).
   - Speed bonus callout (if any): bolt icon + "+N XP speed bonus included" (insightText).
   - "New personal best!" chip (spring animation) — only on first mastered or higher score.

   **Below 75%:**
   - 96pt circle (warmOrangeTint) + encouraging icon.
   - `Theme.Typography.display` "Great effort!".
   - Caption "N questions · MM:SS".
   - Static "+XP" pill (insightYellowTint, body font, no animation delay).
   - "Practice more to earn the gold star" encouragement text.
   - No trophy, no personal best chip, no speed bonus callout.

2. **StatsCard** — `NumindCard` with 3 `StatCell`s separated by vertical dividers:
   - **Correct** — "N/N" in accent color.
   - **Accuracy** — "N%" in navy (overall accuracy from progressStore).
   - **Streak** — "N🔥" in yellow.

3. **MasteryBanner** — pass variant only:
   - **Mastered (≥75%):** accent tint background + checkmark.seal.fill + gold star + "Lesson mastered!".
   - Below 75%: no mastery banner. Encouraging "Practice more" framing in footer. Next lesson is already unlocked via completion-based progression.

4. **NewBadgesSection** (if badges earned) — "BADGES UNLOCKED" eyebrow + card with badge rows:
   - Each row: tier-colored circle (48pt, badge icon) + badge name (semibold) + description + teal checkmark.seal.fill.
   - Haptic feedback on appear.

5. **RecapSection** — "RECAP" eyebrow + flush card with per-question rows:
   - 36pt result tile (teal check / red xmark) + question prompt preview + retry icon for wrong answers.

6. **Footer (sticky)** — varies by mastery:
   - **Below 75%:** "Practice more" (primary) + "Continue" (`PillButton(.secondary)` — light background, blue text, next lesson already unlocked) + "Done for today" (text link).
   - **Mastered with mistakes:** "Review N mistake(s)" (red capsule) + "Skip & continue" (ghost) + "Done for today".
   - **Mastered, perfect:** "Continue learning" (primary) + "Done for today".

**Review mistakes:** launches a new `QuizSessionView` via `ReviewMistakesEngine.build()` as a `.fullScreenCover`.

> **Rationale.** The gold star is the key feedback element — it makes 75% an aspirational goal without blocking progression. Completion-based unlocking ensures anxious users aren't stuck, while the gold star still rewards high performance. The "Practice more" framing encourages persistence without punishment.

---

## 08 · Checkpoint Review

**File:** `Features/Learn/Checkpoint/CheckpointView.swift`
**Header style:** inline (via embedded `QuizSessionView`).

A module review quiz that covers the 3 most recent lessons. No lesson-content phase — jumps straight to questions.

**Phases:** `.quiz` → `.summary` (same as LessonView but without the lesson phase).

**Flow:**
1. `CheckpointQuizEngine.build(lessonIds:)` generates 8 questions round-robined across covered lessons.
2. Title: "Module Review". Shortcut: "Apply everything you've learned in [module]."
3. On completion: records session with stable review ID (`review_{moduleId}_{groupIndex}`), checks personal best and level-up.
4. Level-up → `LevelUpView` → summary. Otherwise → summary directly.
5. Summary has full retry support (rebuilds quiz with fresh questions).

---

## 09 · Level-Up Ceremony

**File:** `Features/Quiz/LevelUpView.swift`
**Presentation:** `.fullScreenCover` from within `LessonView` or `CheckpointView`, shown before session summary.

**Layout:**

1. **Background:** `softBg` with `ConfettiView` particle overlay.
2. **Module badge** — 128pt circle (accent tint) with module icon (36pt, accent) + level number ("Lv N"). Spring scale-in animation from 0.55 → 1.0.
3. **Headline** — `Theme.Typography.display` "Level up!" + module name (headline, muted) + level name capsule ("BEGINNER" / "DEVELOPING" / "SKILLED" / "ADVANCED" / "EXPERT", accent text on accent tint).
4. **Level pips** — 5 circles: filled pips for completed levels (accent), empty for remaining (mutedTint). Current level pip is 14pt (others 8pt).
5. **Footer** — `PillButton.primary` "Keep going" → dismisses to reveal session summary.

**Haptic:** `.success` notification feedback on appear.

---

## 10 · Progress

**File:** `Features/Progress/ProgressTabView.swift`
**Tab:** Progress (active). **Header style:** large title, "Progress". Trailing toolbar: gear icon → `ProfileView` sheet.

**Layout:**

1. **OverviewCard** — `NumindCard`:
   - Left: **StreakRing** (84pt, 8pt stroke, yellow fill, muted track, rotated -90°). Center: flame icon + streak count + "days" label.
   - Right: streak count (28pt bold) + "day streak" + "Best: N days" caption + mini stats (sessions count + accuracy %) separated by 1pt vertical rule.

2. **WeeklyGoalCard** — `NumindCard`:
   - Top row: "N of M workouts" headline + goal caption + trailing yellow `IconTile` trophy.
   - Day row: 7 columns (M-S), each: 28pt circle (blue + white check if completed, mutedTint otherwise) + day letter.

3. **WeeklyXPLeaderboard** — `NumindCard`:
   - Header: rank text ("Ranked #N of your last 4 weeks") + XP count + optional "Best week!" star pill (insightYellowTint).
   - Bar chart: 4 bars (HStack, equal flex), each with XP label above + colored bar + week label below. Current week = blue, others = mutedTint. Min bar height 3pt for 0-XP weeks. Max bar height 72pt.

4. **SkillMasteryCard** — `NumindCard` with header "SKILL MASTERY" + "See all" NavigationLink:
   - Per module row: 36pt `IconTile` + module title + level capsule ("Lvl N", module color) + 5pt progress bar + "Level N of 5" / "Not started" caption. Rows separated by hairline dividers.

5. **RecentActivityCard** (shown when sessions exist) — `NumindCard`:
   - Per session row: module icon tile (36pt) + lesson title + relative date + score (N/N) + accuracy %. High accuracy (≥80%) shown in teal.

6. **TotalXPCard** — `NumindCard` (insightYellowTint background):
   - "TOTAL XP" eyebrow + XP count (30pt bold rounded) + trailing trophy `IconTile` (48pt, yellow).

7. **BadgesGrid** — "N of 27 unlocked" caption + `NumindCard` with 3-column `LazyVGrid`:
   - Each badge: 48pt circle (tier color tint if earned, mutedTint if locked) + icon (badge icon if earned, lock if locked) + name (10pt, 2 lines).
   - Tier colors: bronze = warm brown, silver = teal, gold = yellow.

**Empty state (no sessions):** Blue circle (96pt) with chart icon + "No sessions yet" display text + "Complete your first lesson" body text.

---

## 11 · Profile

**File:** `Features/Profile/ProfileView.swift`
**Presentation:** Sheet from Progress tab gear icon, or standalone via Profile tab.
**Header style:** large title, "Profile".

**Layout:**

1. **ProfileCard** — `NumindCard`: 56pt avatar circle (user initial, blue tint) + name (headline) + "Member since [date]" caption + streak emoji + count (if active).

2. **StatsSection** — eyebrow "Your numbers" + 2×2 `LazyVGrid` of stat tiles:
   - **Sessions** (blue bolt icon) + **Total XP** (yellow star icon) + **Accuracy** (teal scope icon) + **Best streak** (red flame icon).
   - Each tile: `NumindCard` with `IconTile` (36pt) + value (26pt bold rounded) + label.

3. **RemindersSection** — eyebrow "Reminders" + `NumindCard`:
   - Toggle row: bell icon (teal, 36pt) + "Daily reminder" + toggle (teal tint).
   - Time picker row (shown when enabled): clock icon + "Remind me at" + `DatePicker` (hourAndMinute). Animated expand/collapse.

4. **AppearanceSection** — eyebrow "Appearance" + `NumindCard`:
   - Circle.lefthalf.filled icon (blue, 36pt) + "Theme" + 3-segment picker (Auto / Light / Dark).

5. **AppSection** — eyebrow "App" + `NumindCard`:
   - "Reset progress" row: red counterclockwise icon (36pt) + red title + "Clears all local lesson and quiz history" caption. Tap → destructive confirmation alert.

6. **BrandFooter** — centered: Numind wordmark image (20pt height, 0.55 opacity) + version string.

**States:**
- **Reset confirm:** native iOS alert with red "Reset" + "Cancel".
- **Notifications blocked:** alert directing to Settings to re-enable.

---

## 12 · Speed Drill (overlay on QuizSessionView)

**File:** `Features/Quiz/QuizSessionView.swift` (standard view with countdown ring)
**Presentation:** `.fullScreenCover` from Home tab "Speed Drill" mode card.
**Trigger:** `QuizSessionViewModel(questions:title:shortcut:moduleColor:questionTimeLimit: 15.0)`

Speed Drill is the standard `QuizSessionView` with a countdown ring replacing the elapsed-time pill. Everything else (bead rail, prompt card, option cards, feedback, explanation, continue button) is unchanged.

**Countdown ring (toolbar trailing, 40×40pt):**
- Outer stroke: `mutedTint`, 3pt, full circle.
- Inner arc: trim from 0 to `questionTimeRemaining / questionTimeLimit`. Stroke: 3pt, `.round` lineCap. Animated with `.linear(duration: 0.1)`.
- Center text: `Int(ceil(remaining))` — `13pt bold rounded`. No animation.
- Color: `primaryBlue` (>5s) → `warmOrange` (≤5s) → `errorSoftRed` (≤3s).
- Timer starts via `viewModel.startSession()` called from `.onAppear`.
- Timer expiry: `handleTimeout()` → auto-wrong → `.feedback(UUID())`. User sees error card + explanation + Continue, then advances normally.

**Session recording:** `lessonId: "speed_drill"`, `moduleId: "mixed"`. Standard SessionSummaryView shown on completion.

---

## 13 · Blitz Mode

**Files:** `Features/Blitz/BlitzView.swift`, `Features/Blitz/BlitzSummaryView.swift`
**Presentation:** `.fullScreenCover` from Home tab "Blitz" mode card.
**ViewModel:** `BlitzViewModel` (not `QuizSessionViewModel` — different lifecycle).

### Playing Phase

**Top bar (full-width, 16pt top padding):**
- Leading: 36pt circle close button (`xmark`, mutedTint fill, navy icon).
- Center: 72pt circular countdown timer. Outer ring: 5pt mutedTint. Inner arc: trim from 0 to `timeRemaining/60`, 5pt lineCap round, animated `.linear(0.1)`. Color: `mindTeal` (>20s) → `warmOrange` (≤20s) → `errorSoftRed` (≤10s). Center: time in seconds (24pt bold rounded) + "sec" (10pt semibold muted). Pulsing scale animation when ≤10s.
- Trailing: score capsule — `checkmark` icon (12pt bold) + count (18pt bold rounded). Fill: `mindTeal` if score > 0, else muted. Spring-animates on increment.

**Prompt card** (`NumindCard`): question prompt only (22pt semibold rounded, centered). No scenario card — too slow to read mid-blitz.

**Options grid:** `LazyVGrid` 2 columns, 12pt spacing. Each option: `NumindCard` background, 17pt semibold, centered, minHeight 72pt. Tap = immediate answer (no "Check answer" button). Disabled during `.flashing` state.

**Flash overlay** (0.5s, `allowsHitTesting: false`):
- Full-screen color tint (green 0.15 opacity if correct, red 0.15 opacity if wrong).
- 72pt circle (mindTeal/errorSoftRed) + large checkmark/xmark icon.

### Summary Phase

Shown when `viewModel.state == .complete` (inline within `BlitzView` — no new cover).

**Layout:**
1. **Hero:** 72pt warmOrangeTint circle with flame icon. "Blitz complete!" (28pt bold). Score number (72pt black rounded, warmOrange, spring-animated on appear). "questions correct" label (16pt muted).
2. **Personal best badge:** If `isNewBest` — "🏆 New personal best!" in insightYellowTint capsule with shadow.
3. **Stats card** (`NumindCard`): 4 divider-separated rows — Correct (count/total), Accuracy (%), XP earned (+N XP), Avg time/question (Xs).
4. **Footer:** "Play again" (`.primary` PillButton) → reset + new queue + back to playing. "Done" (`.secondary` PillButton) → recordSession + updateBlitzBest + dismiss.

**Haptic:** `.success` notification on game end.

---

## 14 · Home — Game Modes Section

**Section:** Sits between Daily Challenge and Today's Workout in HomeView scroll.

**Section label:** "GAME MODES" (standard eyebrow text — 10pt semibold muted, 0.8 tracking, uppercase).

**Layout:** HStack of two equal-width mode cards.

**Mode card structure** (`NumindCard`, each half-width):
- 44pt icon circle (tint background, icon fill in accent color). Lock icon in mutedText when locked.
- Title (15pt bold rounded, navy). Locked → muted.
- Subtitle (small, muted): "8 questions · 15s each" / "60 seconds · Go fast".
- Chip (10pt bold): best stat in accent color/tint, or "Master a lesson to unlock" (muted) when locked.

**Speed Drill:** `mindTeal` accent. Icon: `bolt.fill`.
**Blitz:** `warmOrange` accent. Icon: `flame.fill`.
**Locked state:** Both cards disabled, icon replaced with `lock.fill`, chip shows unlock prompt.

---

## 15 · Tools (future)

Calculator tools (tip calculator, bill split, discount calculator) are not part of V1. These are deferred to the future website, per the product brief.

---

## 16 · Mid-Session Motivator Checkpoint

**Files:** `Features/Quiz/MotivatorView.swift` (full-screen), `Features/Quiz/InlineEncouragementView.swift` (overlay)
**Presentation:** Inline phase within `QuizSessionView` or `EstimationView` (not a new cover). Uses `.motivator(MotivatorCheckpoint)` session state.

Duolingo-style checkpoint moments shown between quiz questions. Four full-screen types + one inline overlay.

**Eligible modes:** Lesson Quiz, Daily Challenge, Checkpoint Review, Speed Drill (max 1), Estimation.
**Excluded modes:** Blitz, Streak, Comparison (auto-advance, no pause point).

### Common Layout (all 4 full-screen types)

**Background:** `softBg`, full bleed. No navigation bar, no bead rail.

1. **Illustration** — 80pt circle (`illustrationTint` fill) + 36pt SF Symbol (`illustrationColor`). Spring scale-in from 0.6 → 1.0, 0.1s delay.
2. **Headline** — `display` font (32pt bold rounded), `deepNavy`, centered.
3. **Subtitle** — `headline` font (18pt semibold), accent color, centered.
4. **Body** — `body` font (16pt), `mutedText`, centered. Optional.
5. **Type-specific content** — varies (see below). Fade in with 0.25s delay.
6. **Footer** — sticky `PillButton` CTA + optional secondary text link (caption, muted). Same gradient mask as other sticky footers.

| Type | Icon | Tint | Accent |
|---|---|---|---|
| Momentum | `star.fill` | `insightYellowTint` | `mindTeal` |
| Coaching | `lightbulb.fill` | `insightYellowTint` | `mutedText` |
| Progress | `mountain.2.fill` | `primaryBlueTint` | `primaryBlue` |
| Near Finish | `trophy.fill` | `insightYellowTint` | `primaryBlue` |

### Type-specific content

**Momentum:**
- Streak visualization: HStack of 32pt circles — `mindTealTint` fill + white checkmark for each correct, `mutedTint` fill for remaining.
- Stats card: `NumindCard` with clock icon (40pt `primaryBlueTint` circle) + "Your pace is improving!" / "Avg. time: Ns" + "Last N questions".
- CTA: "Keep going". Secondary: "See progress".

**Coaching:**
- Tip card: `NumindCard(background: primaryBlueTint)` with brain icon + "TRY THIS TIP" eyebrow + lesson shortcut text (headline bold) + tip body.
- Example card: `NumindCard` with "EXAMPLE" eyebrow + monospaced example text from `Lesson.example`.
- Encouragement footer: brain icon circle (36pt) + "You've got this!" + "Every step counts." + chevron.
- CTA: "Keep going".

**Progress:**
- Completion text: "You've completed" (body) + "N of M questions" (title, `primaryBlue`).
- `BeadRail.dot` with `primaryBlue` fill.
- Stats card: chart icon + "You're staying sharp" + accuracy % + avg time.
- CTA: "Continue". Secondary: "View progress".

**Near Finish:**
- Stats card 1: star icon + "Great work!" + accuracy % (headline, `mindTeal`) + "Keep it up!".
- Stats card 2: flame icon + "Daily streak" + N days (headline, `warmOrange`). Only shown if streak > 0.
- CTA: "Finish strong". Secondary: "See today's progress".

### Inline Encouragement (overlay)

Non-blocking card overlaid on the feedback screen. Does NOT count toward the 2-motivator cap.

**Layout:** Centered card, max width 300pt.
- Dimmed background (`black.opacity(0.15)`).
- 72pt `insightYellowTint` circle + `star.fill` (32pt, `insightYellow`).
- Headline (headline font, navy) + subtitle (body, muted).
- "Continue" capsule button (`primaryBlueTint` bg, `primaryBlue` text).
- Entry: scale from 0.9 + opacity, spring animation.
- Auto-dismiss after 2.5s. Light impact haptic on appear.

**Trigger conditions (any of):** Fast answer (<5s), used hint and still correct, 3+ consecutive correct.

**Haptic:** Light impact on appear (full-screen + inline). No haptic on dismiss.

---

## Cross-screen notes

- **Tab bar.** Standard iOS tab bar with 4 tabs: Home, Learn, Progress, Profile. Active tab uses standard iOS tinting.
- **Inline navigation header.** 44pt high, leading + trailing icon slots are 32pt tap targets, title is 17pt semibold navy. Title can be empty (Lesson) when the body owns the heading.
- **Sticky footers.** Whenever a screen has a sticky CTA, the scroll content pads at the bottom and the footer floats with a gradient mask so content doesn't slam into it. The gradient is `softBg.opacity(0)` → `softBg`, 24pt high.
- **Full-screen covers.** Lessons and reviews open as `.fullScreenCover` from the Learn tab. Level-up is a nested `.fullScreenCover` from within the lesson/review view. Session summary is a phase within the lesson/review view, not a separate screen.
- **No new colors.** Every color used across all screens is one of the design tokens or a tint overlay. No gradients other than the implicit softBg→transparent mask under sticky footers.
- **Haptics.** Light impact on option selection and digit entry. Medium impact on correct answer. Error notification on wrong answer. Success notification on badge unlock and level-up.
