# Numind — Screen Specs (V1 wireframes)

> **Design target (updated April 2026):** "Route 2 — Friendly Skill Trainer" is now the authoritative design reference. It supersedes this document where they conflict. Key Route 2 principles: warm greeting on Home, streak + weekly calendar strip as a card, module cards carry tinted backgrounds (not white), quiz feedback uses a large coloured answer-reveal, Progress shows per-module skill mastery levels and a streak ring. All colours still derive from the 8 design tokens — no new hexes.

> **Status:** Mid-fidelity wireframes, April 2026.
> **Source of truth:** Route 2 wireframe image + this document together.
> **Tokens referenced** are the Swift constants in `apps/ios/Numind/Core/DesignSystem/Tokens/`. Do not introduce new tokens here — if a value is missing, propose it as a token first.

This document defines the per-screen layout, copy, and empty / error / loading states for the V1 screens. Every screen sits inside `Theme.Colors.softBackground` and uses the standard `Theme.Spacing.screenHorizontal = 20` gutter unless noted.

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

Tints are derived as `Color.opacity(0.12–0.22)` overlays of the source token — never new hexes.

The four root tabs use the **iOS large-title** style (32–34pt rounded, navy). Pushed and modal screens use a **44pt inline header** with leading chevron-back or X.

---

## 01 · Home (`Today`)

**Tab:** Home (active). **Header style:** large title, "Today". **Top-right accessory:** `Streak chip` (icon `flame`, "12 day streak").

**Layout (top → bottom):**

1. **Eyebrow** "Today's workout" (12pt uppercase muted, kerning 0.8).
2. **DailyWorkoutCard** — `NumindCard` containing:
   - Top row: large `IconTile` (blue, 56pt, `bolt`) · headline "5-minute warm-up" · caption "Tip math · 5 quick questions".
   - Middle: `BeadRail.chunky` (5 segments, 0 filled) · right-aligned XP pill "+15 XP".
   - **Primary CTA** `PillButton.primary` "Start workout" → opens lesson or quiz.
   - Tertiary inline link "Change session type" (blue, 12pt).
3. **Eyebrow** "Continue learning".
4. **ResumeCard** — module color tint (teal here) · `IconTile` · module eyebrow ("TIPS, TAX & BILL SPLIT") · headline ("Lesson 3 · Tip in your head") · `Progress` bar at 60% · "3 of 5 steps · Resume" · trailing chevron. Card is tappable; deep-links to the lesson.
5. **Eyebrow** "Up next".
6. **Flush card** with 2 `ModuleRow.compact` rows (sm icon tile, body title, small subtitle, chevron). Each row = a suggested next lesson or daily exercise.

**Copy guidance:** Encouraging, second-person ("you"), present tense. Never gamified beyond the streak.

**Empty state (no streak, fresh install):** Replace streak chip with `PillButton.secondary` "Set daily goal" (links to Profile → Goals). Keep DailyWorkoutCard but swap subtitle to "Pick something quick to get started." Hide "Continue learning" + "Up next" sections; show single full-width `EmptyHint` card: tile (yellow, `star`) + "Your first workout will appear here once you finish it."

**Error state:** If today's session fails to load, replace DailyWorkoutCard body with inline `Alert` (red tint card, `xCircle` icon, "Couldn't load today's workout. Pull to refresh."). Other sections render normally if cached.

**Loading:** 3 skeleton cards (rounded, 100×80 / 80 / 60) using `mutedTint`. No spinners.

> **Rationale.** Home is the daily entry point — the user must see exactly one obvious next action. We elevate "today's workout" as the only filled-color element above the fold and keep "Continue learning" as a softer secondary card so the choice is clear. The streak chip lives in the nav accessory rather than as a hero card to keep the page calm and avoid finance-dashboard density.

---

## 02 · Learn (module list)

**Tab:** Learn (active). **Header style:** large title, "Learn".

**Layout:**

1. **Eyebrow** "Modules".
2. Vertical stack of 4 `ModuleRow` cards, 12pt gap. Each card:
   - `IconTile` (module color) · headline title · caption subtitle · trailing chevron.
   - Below the row, a 6pt-tall `Progress` bar in module color tint.
   - Caption row: "5 lessons" (left) · "40%" or "Not started" (right).
3. Centered footer caption "More modules arrive after V1" — sets expectation without an empty placeholder.

**Module roster (V1):**
- Tips, Tax & Bill Split — blue, `percent`
- Discounts & Shopping — teal, `tag`
- Everyday Money Math — yellow, `dollar`
- Estimation & Number Sense — muted, `eye`

**Empty state:** Not applicable — module list is hard-coded V1 content.

**Error state:** If progress data fails, render rows without the progress bar / percent and show a single muted footer "Couldn't load progress — tap to retry."

**Loading:** 4 row skeletons, no progress bar.

> **Rationale.** The placeholder already lays out modules as iconified cards; we add per-module progress + lesson counts so the list earns the user's scroll. One module color per row is the only place we use color as taxonomy — this propagates through Module Detail, Lesson, and Progress so the user starts forming a color → topic association.

---

## 03 · Module Detail

**Header style:** inline, leading chevron-back, title = module name.

**Layout:**

1. **ModuleHero** — full-bleed colored card (filled with module color, e.g. blue), white type. Contains:
   - White-tinted `IconTile` (rgba(255,255,255,0.18)) · "Module 1 of 4" + subtitle.
   - Progress meta line: "2 of 5 lessons · 40%".
   - Progress bar on rgba(255,255,255,0.22), filled with `yellow` for warmth.
2. **Eyebrow** "Lessons".
3. **Lesson list** (flush card) — one `LessonRow` per lesson:
   - **Done:** small tile (teal tint + `check`) · title · "Completed".
   - **Current:** small tile (blue tint + lesson number) · title · "In progress · N steps" · 140pt mini progress bar.
   - **Locked / not-started:** small tile (muted tint + lesson number) · title · "N steps".
   - All rows have trailing chevron and 1pt hairline separator.
4. Centered footer caption "Lessons unlock as you progress".

**Empty state:** N/A — modules always have lessons.

**Error state:** If lesson progress fails, render all lessons as "not started" and show inline retry footer.

**Loading:** Hero card loads first (static metadata); lesson list shows 5 row skeletons.

> **Rationale.** The colored hero card is the only place inside the V1 visual system where we fill a card with a brand color — it's reserved for "you are inside this module." The list below stays soft and additive so the user reads top-down: where I am → what's left.

---

## 04 · Lesson

**Header style:** inline, leading X (closes session with confirm), no title (lesson title is in the body), trailing empty.

**Layout:**

1. **Lesson progress strip** — 6pt thin `Progress` bar (blue) + "2 / 5" small caption. Sits flush below the inline header.
2. **Lesson eyebrow** — module name + lesson number (blue, uppercase).
3. **Title** — `Theme.Typography.title` ("The 10% trick").
4. **ConceptCard** — body copy with the rule, then a **decimal-shift block** (soft-bg, mono font) showing 2 worked examples (`$48.00 → $4.80`).
5. **WhyCard** — yellow-tinted insight card. Tile (yellow, `hint`) + "Why this works" headline + caption explanation. Reused for all "aha" moments across the app.
6. **Optional illustration slot** — placeholder dashed box (height 120pt) reserved for bead-rail diagrams or simple line illustrations to be added when assets ship.
7. **Footer** — sticky bottom `PillButton.primary` "Continue".

**Empty / error / loading:**
- **Loading:** title + concept card skeleton; sticky button disabled.
- **Error:** if lesson body fails to fetch, show full-width `ErrorCard` (red tint, `xCircle`, "Couldn't load this lesson. Try again."); footer shows "Back to module" instead of Continue.
- **Empty state:** N/A.

**Copy guidance:** Each lesson is one shortcut, one paragraph. Concept first, worked example second, "why" last. Never more than ~120 words of body copy on a single lesson screen — split into multiple steps.

> **Rationale.** Lessons are the heart of Numind's "practical number sense" claim. The page is intentionally short and reads like a flash card: one rule, one example, one reason. The yellow `WhyCard` is the recurring visual primitive that ties learning moments together; it appears verbatim on Quiz Feedback so the explanation feels native, not bolted-on.

---

## 05 · Quiz Question

**Header style:** inline. Leading X (with confirm), title = lesson short name, trailing = "3 / 5" small bold counter.

**Layout:**

1. **Beads progress** — `BeadRail.chunky` centered (5 beads, current = blue, completed = on/yellow, upcoming = muted). Acts as both progress and orientation device.
2. **QuestionCard** —
   - Eyebrow ("Question 3", blue uppercase).
   - Title body ("Your dinner bill is **$48**. About how much is a **20% tip?**") — `Theme.Typography.title`, line-height 1.25.
   - Caption hint ("Use the 10% trick — round to the nearest dollar.").
3. **Option list** — vertical stack of `OptionCard`s, 10pt gap. 4 options (A–D). One can be `selected` (blue ring + tint). Numpad-key letter on the left, value on the right.
4. **Hint** — ghost button "Hint" (icon + label), centered. On tap → modal with the matching `WhyCard`-style hint; reveals cost the user XP.
5. **Footer** — sticky `PillButton.primary` "Check answer". Disabled state = muted tint + muted text until something is selected.

**States:**
- **No selection:** Continue button disabled.
- **Selected:** option border + tint = blue.
- **Hint used:** ghost button changes to "Hint used" with reduced opacity.
- **Loading:** the question card shimmers but options + chrome are visible.
- **Error:** "Question couldn't load — Skip / Retry" inline alert in place of the option list.

> **Rationale.** MCQ-only is a V1 constraint, so the question card and option cards must do all the work. We keep the question text generous (24pt) and never let it scroll away — it's anchored above the options, the most-tapped surface. Letter keys (A–D) on options are deliberate: they double as accessibility anchors and let us refer back to specific options in feedback ("B was right").

---

## 06 · Quiz Feedback

**Header style:** identical to Quiz Question (X · lesson name · "3 / 5") so the user feels they are still in the same flow, not a new screen.

**Layout:**

1. **Beads progress** — same as Quiz Question, but the current bead is now `on` (yellow) since it's been answered.
2. **ResultHero** — full-width tinted card (teal tint for correct, red tint for wrong). Contains a 64pt circular badge (teal/red filled) with `check` or `xCircle`, headline ("Nice — that's right." / "Not quite."), and reward sub-line ("+10 XP · streak +1" or "Take a moment — no penalty.").
3. **Option recap** — same option list, but:
   - The correct option is fully visible with a `correct` style (teal ring + tint + trailing check icon, label bold).
   - All other options are dimmed to 50% opacity. If the user picked wrong, their pick gets the `wrong` style and stays at full opacity.
4. **WhyCard** — eyebrow "Why" (blue uppercase) + body explaining the math + caption with the "shortcut" framing. Same component as the Lesson WhyCard so it builds visual continuity between lesson and quiz.
5. **Footer** — sticky `PillButton.primary` "Continue".

**States:**
- **Correct:** teal hero, "+XP" copy.
- **Incorrect:** red hero, neutral copy ("no penalty"), explanation framed as a hint.
- **Out of attempts (rare):** show "Try again later" state — disable continue, replace footer with "Back to lesson".

> **Rationale.** Feedback is the single highest-leverage moment for retention. We commit to a single emotional beat (the hero card), one piece of evidence (the option recap), and one teaching moment (the WhyCard). No confetti, no extended animations — Numind is App-Store-friendly, not Duolingo-loud. Color is emotion: teal for "you got it," red only as a soft tint for "not quite."

---

## 07 · Session Summary

**Header style:** inline, **trailing X only** (no back). The session is "done" — the only forward action is Continue or Done.

**Layout:**

1. **CompletionHero** — centered.
   - 88pt yellow-tinted circle with `trophy` glyph (yellow stroke + fill).
   - `Theme.Typography.display` "Workout complete!".
   - Caption "Tip math · 5 questions · 4 min".
2. **StatsCard** — 3 `Stat` cells separated by `vrule`s.
   - **Correct** — value in teal ("4/5").
   - **XP earned** — neutral navy ("+45").
   - **Streak** — value in yellow with flame ("13🔥").
3. **Eyebrow** "Recap".
4. **Recap card** (flush) — 5 rows:
   - sm tile (teal/red tint + `check`/`x`).
   - body label = the question stem in past tense ("10% of $80 is…").
   - if wrong, trailing "Review" link (blue, small) → opens that question's feedback view.
5. **Footer (sticky)** — stack of two buttons:
   - `PillButton.primary` "Continue learning" → next lesson or recommended workout.
   - `PillButton.ghost` "Done for today" → Home.

**States:**
- **Perfect score:** swap stats card highlight color to teal across the row; no other change.
- **First-ever session:** add a single `WhyCard`-style "habit prompt" between hero and stats: "Want a daily reminder?" with inline link to Profile → Reminders.
- **Loading:** stats card shimmers; recap rows are skeletons.

> **Rationale.** Summary is a celebration screen, not a debrief. We use the warmest color (yellow) only here — the trophy glow signals "you finished," not "you mastered." The recap is unflashy on purpose: it lets the user verify what they got wrong and re-enter feedback for those questions, which protects retention without nagging.

---

## 08 · Tools list

**Header style:** inline, leading chevron-back, title "Tools". Reachable from a Home overflow menu and from "Practice this skill" links inside lessons.

**Layout:**

1. Top caption (no eyebrow): "Quick calculators that use the same shortcuts you learn in lessons."
2. Vertical stack of 3 `ToolCard`s:
   - **Tip calculator** — blue tile, `percent`, "Round any bill, in your head or on screen."
   - **Bill split** — teal tile, `receipt`, "Split fairly across people, with or without tip."
   - **Discount** — yellow tile, `tag`, "Sale price, markdowns, percent off."
3. **Cross-link card** (blue tint background) — tile (blue, `hint`) + "Practice what you learn" + caption explaining each tool links back to its lesson.

**Empty state:** N/A.

**Error state:** N/A — calculators are local.

> **Rationale.** Tools is the V1 utility surface — a place to use Numind in the wild, not just inside lessons. The cross-link card at the bottom is the only persuasion attempt; everything else is direct.

---

## 09 · Tip calculator

**Header style:** inline, leading chevron-back, title "Tip calculator", trailing `hint` icon button (opens contextual explanation as a sheet).

**Layout:**

1. **Bill input** (`InputCard`) — uppercase muted "BILL" label · 22pt rounded value "$48.00". Tap opens the system numpad.
2. **Eyebrow** "Tip".
3. **PercentChips** — 4 pill chips (15 / 18 / 20 / 25) full-width row. Selected chip is filled blue.
4. Caption "Slide for custom %" — links to a system slider sheet for non-preset values.
5. **CalcResult** "Tip" — big colored card (blue), white display value "$9.60".
6. **CalcResult** "Total" — teal card, white display value "$57.60".
7. **MentalMathCard** — yellow-tinted, `hint` tile + caption "**In your head:** 10% of $48 = $4.80. Double for 20% → $9.60." (Same shortcut surface as lesson WhyCard.)

**States:**
- **Empty bill:** result cards show "—" in place of the value, `MentalMathCard` is hidden, primary action becomes the bill input itself (no sticky footer).
- **Custom percent:** chips show "—%" and a small inline "Custom" pill to indicate non-preset.

> **Rationale.** The tip calculator must look more like a learning artifact than a finance app — that's why the result cards are flat colored cards (not data tables) and the mental-math card is always the last visible element. The user should walk away knowing the trick, not just the answer.

---

## 10 · Bill split calculator

**Header style:** inline, leading chevron-back, title "Bill split".

**Layout:**

1. **Two side-by-side `InputCard`s:** "Bill" (left, $86.40) + "People" (right, 4). Equal flex.
2. **Eyebrow** "Include tip?" + 4 `PercentChips` (0 / 15 / 18 / 20).
3. **People row** — N small blue tiles (`person` icon), centered, 6pt gap. Visual confirmation of the splitter count.
4. **CalcResult** "Each person pays" — blue card, large display.
5. **BreakdownCard** — Subtotal · Tip (N%) · hairline · **Total**. Right-aligned values, body labels left.

**States:**
- **People = 1:** the People-row collapses to a single tile and the result label switches to "You pay".
- **Bill empty:** all amounts show "—".
- **Tip = 0:** breakdown card omits the Tip row; "Include tip?" chip "0" is filled.

> **Rationale.** Bill split is the highest-utility tool of the three — most likely to be opened mid-restaurant. The two side-by-side inputs at the top mean the user can edit either with a single thumb without scrolling. The people-row tiles are the only "playful" element here; they're cheaper than illustrations and reinforce the split count.

---

## 11 · Discount calculator

**Header style:** inline, leading chevron-back, title "Discount".

**Layout:**

1. **Original price** `InputCard` ($120.00).
2. **Eyebrow** "Discount" + `PercentChips` (10 / 25 / 40 / 50).
3. **CalcResult** "You save" — yellow card (warm, the win), display "$30.00".
4. **CalcResult** "Sale price" — teal card, display "$90.00".
5. **MentalMathCard** — eyebrow ("HOW TO DO IT IN YOUR HEAD"), body "25% off = ¼ off. $120 ÷ 4 = $30. Subtract → $90."

**States:**
- **0% discount:** "You save" card hides; sale price = original price; mental-math card swaps copy to the trivial case.

> **Rationale.** Discount calc is a teaching moment as much as a calculator — the *fraction equivalents* of common discounts (¼, ½, ⅓) are the actual mental-math shortcut. We surface the savings card before the sale price card to mirror the user's question ("how much do I save?") rather than the receipt order.

---

## 12 · Progress

**Tab:** Progress (active). **Header style:** large title, "Progress".

**Layout:**

1. **Eyebrow** "This week".
2. **OverviewCard** — 3 `Stat` cells separated by `vrule`s (Streak / Lessons / Accuracy). Mirrors the placeholder structure but with real values.
3. **Eyebrow** "Weekly goal".
4. **WeeklyGoalCard** —
   - Top row: headline ("4 of 5 workouts") + caption ("One more to hit your goal") · trailing yellow `IconTile` + `trophy`.
   - Day-row (7 columns, M T W T F S S): each day is a 28pt circle — filled blue with white check if completed, muted-tint otherwise. Day letter caption below.
5. **Eyebrow** "By module".
6. **ByModuleCard** — 4 rows (one per module), separated by 1pt hairlines. Each row: module title · right-aligned percent · 6pt progress bar in module tint color.

**Empty state (no activity):** Replace OverviewCard values with "—". Hide WeeklyGoalCard. Replace ByModuleCard with single muted card "Finish your first lesson to start tracking progress."

**Loading:** all three cards as skeletons (top stat row, day row, 4 module rows).

> **Rationale.** Progress is the screen most at risk of becoming a "finance dashboard." We resist that by limiting it to three cards, no charts, and using module color only inside the per-module bars. The weekly goal day-row is the one piece of habit visualization — a single, calm, clear pattern.

---

## 13 · Profile

**Tab:** Profile (active). **Header style:** large title, "Profile".

**Layout:**

1. **AccountCard** — large blue tile (`person`) · headline ("Alex") · caption ("Joined April 2026 · 12-day streak") · trailing chevron. Tap → account detail (post-V1).
2. **Eyebrow** "Goals".
3. **GoalsCard** (flush, hairlines between rows):
   - **Daily target** — sm blue tile (`bolt`) · "5 minutes" detail · chevron.
   - **Weekly goal** — sm yellow tile (`trophy`) · "5 workouts" detail · chevron.
   - **Reminders** — sm teal tile (`light`) · "Daily, 6:30 PM" detail · chevron.
4. **Eyebrow** "App".
5. **AppCard** (flush):
   - **Share Numind** — sm muted tile (`share`) · chevron.
   - **Reset progress** — sm red tile (`reset`) · red title · caption "Clears local lesson and quiz history." Tap → destructive confirm sheet.

**Empty / error states:**
- **No name set:** "Alex" placeholder swaps to "Set your name" in muted color, links to onboarding.
- **Reset confirm sheet:** native iOS action sheet with red "Reset everything" + "Cancel". Reset clears UserDefaults keys behind the persistence layer.

**Loading:** AccountCard renders immediately from local data; goals/app sections are static.

> **Rationale.** Profile is intentionally short. We surface goals as the second card because they're the only thing the user can change that affects the rest of the app. The "Reset progress" row uses the red tint primitive sparingly — it's the only destructive action in V1, and it lives at the bottom of Profile where it's hard to hit by accident.

---

## Cross-screen notes

- **Tab bar.** Floating glass pill with rounded 28pt radius, sitting 14pt off the safe-area bottom. Active tab has a `primaryBlue.opacity(0.12)` pill behind the icon and a blue label. Renders identically across all four tab screens.
- **Inline navigation header.** 44pt high, leading + trailing icon slots are 32pt tap targets, title is 17pt semibold navy. Title can be empty (Lesson) when the body owns the heading.
- **Sticky footers.** Whenever a screen has a sticky CTA, the scroll content pads 100pt at the bottom and the footer floats with a 12pt vertical pad and a softBg-to-transparent gradient mask so content doesn't slam into it.
- **Modals (Lesson, Quiz, Tools details).** Use the inline header pattern with X close (or chevron-back if pushed from a list). Sticky footers on Lesson, Quiz Question, Quiz Feedback. Session Summary closes via the trailing X.
- **No new colors.** Every color used across all screens is one of the 8 design tokens or a tint (≤22% opacity overlay) of one. No gradients other than the implicit softBg→transparent gradient under sticky footers.
