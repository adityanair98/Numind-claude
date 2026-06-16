# Numind — Component Specs (V1)

> **Last updated:** May 2026 (after M56).
> **Status:** Implemented components reflecting the current SwiftUI codebase.
> **M1 primitives** already in code: `NumindCard`, `IconTile`, `PillButton`, `BeadRail`. This doc covers all primitives and composed components used across the app.
> **Tokens-only:** every dimension and color references a `Theme.*` token. No raw values. No new colors. Tints are predefined tokens (`primaryBlueTint`, `mindTealTint`, etc.) or `Color.opacity(0.12–0.22)` overlays.

---

## Token quick-reference

| Alias | Swift token |
|---|---|
| **navy / blue / teal / yellow / red / muted** | `Theme.Colors.deepNavy / .primaryBlue / .mindTeal / .insightYellow / .errorSoftRed / .mutedText` |
| **softBg / cardBg** | `Theme.Colors.softBackground / .cardBackground` |
| **tints** | `.primaryBlueTint / .mindTealTint / .errorSoftRedTint / .insightYellowTint / .mutedTint` |
| **insightText** | `Theme.Colors.insightText` (legible dark yellow for text on yellow backgrounds) |
| **hairline** | `Theme.Colors.hairline` |
| **r-card / r-pill / r-tile** | `Theme.Radius.card (20) / .pill (999) / .iconTile (24)` |
| **gutter / card-pad / section / button-h** | `Theme.Spacing.screenHorizontal (20) / .cardPadding (18) / .sectionSpacing (28) / .buttonHeight (54)` |
| **display / title / headline / body / caption / small** | `Theme.Typography.*` |

Sizes below are SwiftUI `CGFloat` points.

---

## A. Design System Primitives

All primitives live in `Core/DesignSystem/Primitives/`.

### A1. `NumindCard`

**File:** `NumindCard.swift`

Base card container used throughout the app.

- **Background:** `cardBg` by default; accepts custom background color via init parameter.
- **Padding:** `card-pad` (18pt).
- **Corner radius:** `r-card` (20pt), continuous style.
- **Shadow:** `black.opacity(0.06)`, radius 8, y: 2.
- **Usage:** wraps any card content via `@ViewBuilder` closure.

### A2. `IconTile`

**File:** `IconTile.swift`

Tinted icon circle used everywhere for module and feature icons.

- **Init:** `IconTile(systemName:tint:size:)`.
- **Default size:** 48pt. Common sizes used: 36pt (small), 48pt (medium), 52pt (large).
- **Icon size:** `size * 0.42` (proportional scaling).
- **Background:** `tintColor.opacity(0.12)`.
- **Corner radius:** `r-tile` (24pt), continuous style.
- **Icon weight:** `.semibold`.

### A3. `PillButton`

**File:** `PillButton.swift`

Full-width capsule CTA button.

- **Variants:** `.primary` (blue fill, white text) and `.secondary` (softBg fill, blue text).
- **Height:** `button-h` (54pt).
- **Font:** `Theme.Typography.headline`.
- **Shape:** `Capsule()`.
- **Ghost variant:** not formalized in the primitive — ghost-style buttons (transparent background, blue text) are built inline where needed (e.g., "Done for today", "Skip for now").

### A4. `BeadRail`

**File:** `BeadRail.swift`

Dot/bar progress indicator. Two variants via `Variant` enum:

- **`.dot` (default):** 10pt circles, 8pt gap. Done = `insightYellow`. Current = `primaryBlue` at 1.3x scale. Upcoming = `mutedTint`.
- **`.chunky`:** 28pt × 6pt capsules, 6pt gap. Done = `primaryBlue`. Upcoming = `mutedTint`.

Parameters: `progress` (Int, beads filled), `total` (Int), `variant` (default `.dot`).

### A5. `NumpadView`

**File:** `NumpadView.swift`

Custom numeric keypad for free-entry quiz questions.

- **Layout:** 4×3 grid of keys. Rows: [7,8,9], [4,5,6], [1,2,3], [.,0,⌫].
- **Key size:** full flex width, 58pt height.
- **Key style:** cardBg background, 14pt corner radius, continuous style.
- **Digit font:** 24pt semibold rounded, navy.
- **Delete font:** 22pt semibold rounded, muted.
- **Spacing:** 10pt between keys (both horizontal and vertical).
- **Callbacks:** `onDigit(String)`, `onDecimal()`, `onDelete()`.

### A6. `QuestionTheme`

**File:** `QuestionTheme.swift`

Enum mapping quiz template IDs to visual themes. 10 themes: `dining`, `shopping`, `everydaySpend`, `budget`, `paycheck`, `investing`, `quickMath`, `estimation`, `debt`, `travel`.

Each theme provides:
- `symbolName` — primary SF Symbol.
- `accentSymbolName` — secondary decorative symbol.
- `sceneLabel` — short label ("At the restaurant", "Shopping", etc.).
- `moduleColor` — `ModuleColor` pair for tinting.

Static `theme(for templateId:)` method resolves a template ID to its theme based on module prefix.

### A7. `QuizGraphicBanner`

**File:** `QuizGraphicBanner.swift`

Decorative themed header banner shown above quiz question cards.

- **Background:** theme's `tintBackground` color.
- **Decorative elements:** two ghost circles (large and small) bleeding off the bottom-right corner, plus a large ghost accent symbol on the right.
- **Content:** left-aligned icon circle (theme symbol) + scene label.
- **Height:** ~80pt.
- **Corner radius:** `r-card`, continuous style.
- **Placed 8pt above the prompt `NumindCard`** so they read as a visual unit.

---

## B. Quiz Components

### B1. `OptionCard`

**File:** `Features/Quiz/OptionCard.swift`

MCQ option button with 4 visual states. The most state-rich card in the system.

- **Layout:** HStack: 28pt key bubble (circle, letter A–D) + 17pt answer text + optional trailing checkmark (correct state only).
- **Padding:** 16pt horizontal, 14pt vertical. Min height 60pt.
- **Border:** 1.5pt `RoundedRectangle`, `r-card` corner radius.
- **Spacing in stack:** 10pt vertical gap between options.

**States** — border / background / key bubble:

| State | Border | Background | Key fill | Key text |
|---|---|---|---|---|
| `normal` | `hairline` | `cardBg` | `mutedTint` | navy |
| `selected` | `primaryBlue` | `primaryBlueTint` | `primaryBlue` | white |
| `correct` | `mindTeal` | `mindTealTint` | `mindTeal` | white |
| `wrong` | `errorSoftRed` | `errorSoftRedTint` | `errorSoftRed` | white |

Post-feedback, non-selected/non-correct options are dimmed to 0.45 opacity by the parent view.

### B2. `ConfettiView`

**File:** `Features/Quiz/ConfettiView.swift`

Particle burst animation for correct answers and level-up celebrations.

- **Pieces:** 36 confetti particles.
- **Shape:** mix of rounded rectangles and circles (isRound = index % 3 == 0).
- **Colors:** cycles through blue, teal, yellow, pink, orange.
- **Motion:** upper-semicircle burst (angles 0°–175°), each piece moves outward + rotates + fades. Staggered delays (0.03s per group).
- **Size range:** 6pt–12pt.
- **Hit testing:** disabled (`allowsHitTesting(false)`).
- **Used on:** quiz correct answer feedback, level-up ceremony.

### B3. `PulsingRing`

**File:** `Features/Learn/LearnView.swift` (private struct)

Animated ring behind the current node on the quest-journey learning path.

- **Shape:** `Circle().stroke()`.
- **Animation:** `easeOut(1.1s)`, repeats forever. Scales from 1.0 → 1.45 while opacity fades from 0.35 → 0. Line width shrinks from 10pt → 2pt.
- **Color:** module accent color.
- **Size:** matches `nodeColWidth` (68pt).
- **Purpose:** draws attention to the recommended next node (the `current` state quest node).
- **Quest-journey context:** the `current` node is a 64pt full-color circle. The `PulsingRing` sits behind it. Additionally, the `current` node shows a bouncing "START" badge. Mastered nodes display a golden star badge and sparkle decorations. Curved S-curve bezier connectors (SwiftUI `Path`) link consecutive nodes; world banners (colored tint card with 32pt progress ring) head each module group.

---

## C. Composed Card Components

These are built inline within feature views, not extracted as separate files. Documented here for design consistency.

### C1. `StreakWeekCard` (Home)

Streak count + weekly calendar strip.

- **Container:** `NumindCard`.
- **Top row:** flame icon (22pt, yellow) + streak count (30pt bold rounded, navy) + "day streak" label + encouragement copy.
- **Day row:** 7 columns (M–S), each: 28pt circle (blue fill + white checkmark if completed, mutedTint otherwise) + day letter label (10pt medium, muted).

### C2. `DailyChallengeCard` (Home)

Daily mixed-module challenge.

- **Container:** `NumindCard` with `primaryBlueTint` background.
- **Header:** 44pt circle (blue/teal) with bolt/checkmark icon + headline + status caption.
- **Progress:** `BeadRail.chunky` (5 segments) + XP pill.
- **CTA:** `PillButton.primary` "Start challenge" or completion text.

### C3. `WorkoutCard` (Home)

Today's recommended lesson.

- **Container:** `NumindCard`.
- **Header:** 52pt `IconTile` + module eyebrow (capsule) + lesson title + concept preview (2 lines) + duration pill ("5–7 min", muted capsule).
- **Progress:** `BeadRail.chunky` + XP pill (insightYellowTint).
- **CTA:** `PillButton.primary` "Start workout".

### C4. `ResumeCard` (Home)

Continue-learning card.

- **Container:** `NumindCard`.
- **Layout:** `IconTile` + module eyebrow (small, accent, uppercase) + lesson title (headline) + trailing chevron. Below: 6pt progress bar (module color fill, mutedTint track). Footer: "N of M lessons · Resume" (small, muted).

### C5. `ResultHeroCard` (Quiz Feedback)

Top card of quiz feedback phase.

- **Container:** `NumindCard` with tinted background (tealTint for correct, redTint for wrong).
- **Center:** 64pt circle (teal/red filled, white check/xmark icon).
- **Title:** `Theme.Typography.title` in matching color.
- **Caption:** correct → "+10 XP · streak +1" + optional speed bonus pill. Wrong → "No penalty — keep going."

### C6. `AnswerRevealPill` (Quiz Feedback)

Full-width capsule showing the correct answer.

- **Background:** teal (correct) or red (wrong).
- **Text:** 30pt bold rounded, white.
- **Padding:** 32pt horizontal, 14pt vertical.

### C7. `WhyCard` (Lesson + Quiz Feedback)

Recurring insight card — appears in lesson body and quiz feedback.

- **Container:** `NumindCard` with `insightYellowTint` background.
- **Header:** lightbulb icon (15pt, `insightText`) + label (small, semibold, `insightText`, uppercase).
- **Lesson variant:** label "Why this works" + shortcut body text.
- **Feedback variant:** label "WHY" + explanation text + divider + "Shortcut:" label + shortcut text.

### C8. `MasteryBanner` (Session Summary)

Conditional card showing mastery status after a quiz session. Only the pass variant exists.

- **Mastered (≥75%):** accent tint background + `checkmark.seal.fill` (22pt, accent) + "Lesson mastered!" headline + "Next lesson unlocked" caption.
- The fail variant ("Not mastered yet") has been removed from this component. On a failed session, the score gap message ("You got X/N — need Y to master") is embedded directly in the `SessionSummaryView` fail `ResultHeader` as a `warmOrangeTint` pill. `MasteryBanner` is not rendered at all when the session score is below 75%.

### C9. `StatsCard` (Session Summary + Progress)

Horizontal stat row with vertical dividers.

- **Container:** `NumindCard`.
- **Layout:** HStack of 3 stat cells separated by 1pt × 32pt dividers (`hairline` color).
- **StatCell:** VStack: value (22pt bold rounded) + label (small, uppercase, muted, kerning 0.6). Value color varies by context (accent, navy, yellow).

### C10. `StreakRing` (Progress)

Circular progress ring showing streak against weekly goal.

- **Size:** 84pt × 84pt.
- **Track:** 8pt stroke, `mutedTint`.
- **Fill:** 8pt stroke, `insightYellow`, round line cap, rotated -90°. Animated sweep-in on appear.
- **Center:** flame icon (13pt, yellow) + streak count (18pt bold rounded, navy) + "days" label (9pt medium, muted).

### C11. `WeeklyGoalCard` (Progress)

- **Container:** `NumindCard`.
- **Top row:** "N of M workouts" headline + goal caption + trailing yellow `IconTile` trophy.
- **Day row:** 7 columns (M–S), each: 28pt circle (blue + white check if completed, mutedTint otherwise) + day letter (small, muted).

### C12. `WeeklyXPLeaderboard` (Progress)

4-week XP bar chart.

- **Container:** `NumindCard`.
- **Header:** rank text + XP count + optional "Best week!" star pill (insightYellowTint).
- **Chart:** HStack of 4 equal-flex columns. Each: XP label (10pt bold rounded) + bar (5pt rounded rect, max 72pt height) + week label. Current week = blue, others = mutedTint. 0-XP weeks show 3pt baseline bar.

### C13. `SkillMasteryRow` (Progress)

Per-module skill display row.

- **Layout:** 36pt `IconTile` + module title (body, semibold) + level capsule ("Lvl N", module color text, module tint background) + 5pt progress bar + "Level N of 5" caption.
- **Not started:** level shows "—", mutedTint capsule, "Not started" caption.

### C14. `BadgeCell` (Progress)

Individual badge in the grid.

- **Size:** flexible grid column (3 columns).
- **Circle:** 48pt. Earned = tier color tint background + badge icon. Locked = mutedTint + lock icon (0.5 opacity).
- **Label:** badge name (10pt, semibold, 2-line max).
- **Tier colors:** bronze = `Color(red: 0.78, green: 0.50, blue: 0.20)`, silver = teal, gold = yellow.

### C15. `StatTile` (Profile)

Stats grid tile for the Profile screen.

- **Container:** `NumindCard`.
- **Layout:** 36pt `IconTile` + value (26pt bold rounded, navy) + label (small, muted).
- **Grid:** 2×2 `LazyVGrid`, 12pt spacing.

---

## D. Atoms

### D1. `Eyebrow` / `SectionLabel`

Uppercase section header label used throughout the app.

- **Font:** `Theme.Typography.small` (12pt, .medium).
- **Color:** `muted`.
- **Kerning:** 0.8.
- **Transform:** `.uppercased()`.
- **Implementation:** inline helper function `sectionLabel(_:)` in each view.

### D2. `DifficultyPips`

3-dot difficulty indicator on quiz question cards.

- **Layout:** HStack, 3pt spacing, 3 circles.
- **Size:** 6pt per dot.
- **Filled:** dots up to `difficulty` level use module accent color.
- **Empty:** remaining dots use `mutedTint`.
- **Accessibility:** labeled "Easy" / "Medium" / "Hard".

### D3. `TimerPill`

Elapsed time display in quiz toolbar.

- **Font:** 12pt semibold monospaced.
- **Color:** muted text.
- **Background:** mutedTint capsule.
- **Padding:** 10pt horizontal, 4pt vertical.
- **Update:** `TimelineView(.periodic(from: .now, by: 1))`.

### D4. `FreeEntryDisplay`

Typed answer display for free-entry questions.

- **Font:** 38pt bold rounded.
- **Empty state:** "$—" (currency), "—" (other), muted color.
- **Filled state:** "$N" / "N%" / "N" depending on `answerFormat`, navy color.
- **Background:** mutedTint, `r-card` corners.
- **Height:** 80pt, full width.

### D5. `XPPill`

Small XP reward chip used on workout cards and daily challenge.

- **Font:** 12pt bold.
- **Color:** `insightText`.
- **Background:** `insightYellowTint` capsule.
- **Padding:** 8pt horizontal, 3pt vertical.

### D6. `SpeedBonusPill`

Speed bonus indicator in quiz feedback and session summary.

- **Layout:** bolt icon (10pt bold) + text (11-12pt bold).
- **Color:** `insightText`.
- **Background:** `insightYellowTint` capsule.
- **Padding:** 10pt horizontal, 4pt vertical.

### D7. `PersonalBestChip`

"New personal best!" indicator in session summary.

- **Layout:** trophy emoji + "New personal best!" text (13pt bold, accent color).
- **Background:** accent tint capsule.
- **Animation:** spring scale-in (0.75 → 1.0) with 1.0s delay.
- **Visibility condition:** only displayed when `isPersonalBest && didMaster` — failed quiz attempts (score <75%) never show this chip, even if the score is technically the user's highest attempt on that lesson.

---

## E. Component → Screen Matrix

| Component | Used on |
|---|---|
| `NumindCard` | Every screen (base card wrapper) |
| `IconTile` | Every screen |
| `PillButton` | Home, Lesson, Quiz, Summary, Level-Up |
| `BeadRail` (dot) | Ornamental progress displays |
| `BeadRail` (chunky) | Home workout card, Daily challenge, Quiz |
| `NumpadView` | Quiz (free entry mode) |
| `QuizGraphicBanner` | Quiz question |
| `QuestionTheme` | Quiz question (theme resolution) |
| `OptionCard` | Quiz question, Quiz feedback |
| `ConfettiView` | Quiz feedback (correct), Level-Up |
| `PulsingRing` | Learn (current node) |
| `WhyCard` | Lesson, Quiz feedback |
| `MasteryBanner` | Session Summary |
| `ResultHeroCard` | Quiz feedback |
| `AnswerRevealPill` | Quiz feedback |
| `StatsCard` | Session Summary, Progress |
| `StreakRing` | Progress |
| `WeeklyGoalCard` | Progress |
| `WeeklyXPLeaderboard` | Progress |
| `SkillMasteryRow` | Progress |
| `BadgeCell` | Progress |
| `StatTile` | Profile |
| `Eyebrow` | Every tab screen |

---

## F. Practice Tab Patterns *(retired in Phase 7a)*

> The Practice tab and `Features/Practice/PracticeView.swift` were removed in Phase 7a (replaced by the Tools tab). This section is retained as history only — these patterns are no longer in the codebase.

Components and patterns formerly in `Features/Practice/PracticeView.swift`.

### F1. Module Tab Strip

**Used in:** `PracticeView`

Horizontal `ScrollView(.horizontal, showsIndicators: false)` containing one 60×60 rounded-square button per module (8 total).

- **Tile size:** 60×60pt, `r-card` (20pt) corner radius, continuous style.
- **Icon:** module SF Symbol at 24pt.
- **Label:** module short-name, 10pt, below the icon.
- **Selected state:** `module.color.tintBackground` fill, 2pt `module.color.accentColor` border, accent-colored icon, bold label, glow shadow (accent, radius 6, opacity 0.25). Uses `ModuleColor.tintColor` and `ModuleColor.tintBackground` from the `ModuleColor` enum.
- **Unselected state:** `cardBackground` fill, `hairline` border, `mutedText` icon, regular label weight.
- **Interaction:** tapping a tile sets the selected module; header card and lesson list update with `.animation(.easeInOut)`.
- **No extraction:** implemented inline in `PracticeView`; not a standalone primitive file.

### F2. FlowRow (removed)

The custom `Layout` struct `FlowRow` has been removed from `PracticeView.swift`. It was used for the pill-grid lesson layout in the previous Practice tab design. It is no longer used anywhere in the codebase.

If re-needed in the future, implement it as a standalone file in `Core/DesignSystem/Primitives/FlowRow.swift`.

### F3. Lesson Row (Practice tab)

**Used in:** `PracticeView` lesson list section.

A tappable `HStack` inside a divider-separated `NumindCard`. Three visual states based on mastery.

- **Layout:** 32pt index circle + title/subtitle `VStack` + trailing status icon(s) + `chevron.right`.
- **Index circle (32pt):**
  - Mastered: accent fill, white `checkmark` icon.
  - Attempted-not-mastered: `warmOrangeTint` fill, `warmOrange` lesson number (body, semibold).
  - Not attempted: `mutedTint` fill, `mutedText` lesson number (body, semibold).
- **Title:** body semibold, `deepNavy`.
- **Subtitle:**
  - Mastered: "Best: NN%" in accent color.
  - Attempted: "Best: NN%" in `warmOrange`.
  - Not attempted: "Not attempted yet" in `mutedText`.
- **Status icon (trailing, before chevron):**
  - Mastered: `checkmark.seal.fill` in accent color.
  - Attempted: `arrow.counterclockwise` in `warmOrange`.
  - Not attempted: omitted (chevron only).
- **All rows are tappable** — no mastery gating in the Practice tab.

---

## G. Design Principles

- **One `WhyCard` for every insight moment.** The same yellow-tinted card appears in Lesson body and Quiz Feedback — consistency teaches users that yellow = insight.
- **One option primitive with four states.** `OptionCard` handles the full `normal → selected → correct/wrong` lifecycle so the answer→feedback transition feels like one continuous flow.
- **Color is taxonomy, never decoration.** Each module owns one color pair. That color appears on its path nodes, lesson hero, quiz banner, and progress bars — nowhere else.
- **The bead/rail motif lives in one primitive.** `BeadRail` with two variants (`.dot`, `.chunky`) covers both ornamental progress and quiz orientation.
- **No new colors. No gradients.** The only gradient is the softBg→transparent mask under sticky footers — necessary for legibility, not for visual flourish. All tints are predefined tokens.
