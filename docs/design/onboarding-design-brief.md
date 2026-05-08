# Onboarding Design Brief — Claude Design Handoff

> **26-screen conversion funnel for Numind, an iOS mental math app.**
> Design all screens in this document as high-fidelity mobile mockups (iPhone 15 Pro frame, 393×852pt).

---

## What is Numind?

Numind is a **paid iOS app** (SwiftUI) that teaches practical mental math through short lessons, quizzes, and game modes. Think Duolingo for everyday number sense — tipping, discounts, salary math, investing calculations, splitting bills.

**Business model:** 5-day free trial → hard paywall → monthly/yearly subscription. No free version.

**The onboarding is a conversion funnel.** Every screen builds toward the paywall by accumulating sunk cost (time invested, personal data shared, personalized plan built). The user should feel increasingly invested and personally understood as they progress.

---

## Design System

### Colors

| Token | Hex (Light) | Hex (Dark) | Usage |
|-------|------------|------------|-------|
| Primary Blue | `#2F6BFF` | `#5B8FFF` | Primary CTAs, active states, progress |
| Deep Navy | `#10224A` | `#E8ECF4` | Headlines, primary text |
| Mind Teal | `#2DC6B6` | `#3DD9C8` | Success, correct, streaks |
| Insight Yellow | `#FFD84D` | `#FFD84D` | Highlights, XP, rewards, accent |
| Warm Orange | `#FF7A3D` | `#FF8E57` | Streaks, urgency |
| Error Soft Red | `#EF6B6B` | `#F08080` | Wrong answers, errors |
| Soft Background | `#F6F9FF` | `#0F1726` | Page backgrounds |
| Card Background | `#FFFFFF` | `#1A2332` | Cards, elevated surfaces |
| Muted Text | `#6B7280` | `#8B95A5` | Secondary text, captions |
| Insight Text | `#8A6500` | `#FFD84D` | Text on yellow tint backgrounds |

**Tints:** Each brand color has a tint variant at 12–22% opacity, used as card/badge backgrounds.

**Rule: No new colors.** All backgrounds derive from these tokens via opacity. No gradients except the softBg→transparent mask under sticky footer CTAs.

### Typography

| Style | Spec |
|-------|------|
| Display | SF Rounded, 32pt, Bold |
| Title | SF Rounded, 24pt, Semibold |
| Headline | SF Pro, 18pt, Semibold |
| Body | SF Pro, 16pt, Regular |
| Caption | SF Pro, 14pt, Regular |
| Small | SF Pro, 12pt, Medium |

Headlines and display text use **SF Rounded** for warmth. Body text uses **SF Pro** for legibility.

### Shape & Spacing

| Token | Value |
|-------|-------|
| Card radius | 20pt (continuous corners) |
| Button radius | Capsule (pill shape, 999pt) |
| Icon tile radius | 24pt |
| Screen horizontal padding | 20pt |
| Card internal padding | 18pt |
| Section spacing | 28pt |
| Button height | 54pt |

### Key Components

**PillButton** — Full-width capsule CTA. Primary variant: blue fill, white text. Secondary variant: soft background, blue text. Height 54pt. Used for all primary and secondary CTAs.

**NumindCard** — White card with 20pt continuous corner radius. Light mode: drop shadow (black 6%, blur 12, y:4). Dark mode: hairline border instead of shadow. 18pt internal padding.

**IconTile** — Tinted icon square. Icon at 42% of tile size, centered. Background is the icon's color at 12% opacity. 24pt corner radius. Default size 48pt.

**Footer pattern** — Sticky bottom CTA with a softBackground→transparent gradient mask above it (24pt tall), so content scrolls under smoothly. 44pt bottom padding below the button.

### Brand Feel

- Friendly, clean, modern, useful
- Lightly playful but not childish
- App Store quality — not academic, not finance-dashboard
- Motifs: beads, rails, brain-abacus, progress paths, yellow accent bead
- **Avoid:** school worksheet UI, finance dashboard styling, generic brain-training visuals, childish mascots, harsh red/green

---

## UX Patterns (applies to all screens)

### Progress Bar
- Thin capsule bar across the top of every screen (except Screen 1 and Screen 25/26)
- **Not numbered** — no "Step 3 of 26"
- Segmented by phase, fills gradually left to right
- 5 segments corresponding to phases: Problem Framing | Data Collection | Diagnostic | Plan + Priming | Paywall
- Height: ~4pt, horizontal padding matches screen padding (20pt)
- Fill color: Primary Blue. Unfilled: Muted Tint (mutedText at 12% opacity)

### Back Navigation
- Every screen (except Screen 1) has a back chevron in the top-left
- Simple `chevron.left` SF Symbol, Deep Navy, tappable area 44×44pt
- State is preserved on back — selections aren't cleared
- The diagnostic quiz (Screen 16) is non-reversible once started

### Transitions
- Forward: horizontal slide (trailing → leading)
- Back: reverse horizontal slide
- Phase transitions: slightly slower spring animation

### Screen Layout Pattern
Most data collection screens follow this template:
1. Progress bar (top)
2. Back chevron (top-left)
3. Headline (large, 28pt bold rounded, Deep Navy)
4. Subtitle/instruction (caption, Muted Text)
5. Content area (cards, selectors, inputs — scrollable)
6. Sticky footer CTA (PillButton with gradient mask)

---

## Screen-by-Screen Designs

### Phase 1: Problem Framing (Screens 1–4)

---

#### Screen 1 — Welcome / Hook

**Background:** Full-bleed gradient — Deep Navy (#10224A) top-left → rich blue (#1447B8) bottom-right.

**Layout:**
- Top half: Hero illustration (already built — abstract receipt card tilted -7°, floating % coin in Insight Yellow, cart badge in Mind Teal, dollar pill, decorative dots, soft glow blobs behind). All elements float with gentle ease-in-out animation.
- Bottom half: Left-aligned text block.

**Copy:**
- Headline: "Real math." (white, 38pt heavy rounded) / "Real life." (Insight Yellow, 38pt heavy rounded) — two lines
- Subtext: "Build everyday math skills that help you make smarter decisions — every day." (white 70% opacity, body)

**Value props** (3 rows, icon + text):
1. ⚡ (Primary Blue tint circle) "Short, focused workouts" / "5–10 minutes to build momentum"
2. 🛒 (Mind Teal tint circle) "Practical & relevant" / "Learn skills you can use today"
3. 📊 (Insight Yellow tint circle) "Track progress, build habits" / "Streaks, goals, and rewards"

**CTAs:**
- Primary: "Get started" — white fill, Deep Navy text, capsule, full-width
- Secondary: "I already have an account" — white 60% opacity text, no background

**No progress bar on this screen.**

**Reference:** This screen is already built. See the existing `WelcomePage` in `OnboardingView.swift`.

---

#### Screen 2 — Problem: Social Proof

**Background:** Deep Navy (#10224A) full bleed — dark, dramatic.

**Layout:** Centered content, lots of breathing room.

**Copy:**
- Large stat: "1 in 3" — Insight Yellow, ~72pt black rounded, center-aligned
- Below stat: "adults feel anxious about everyday math" — white, 20pt semibold
- Spacer
- "You're not alone — and it's fixable." — white 70% opacity, body
- Small citation footnote at bottom: "KPMG Foundation, 2023" — white 40% opacity, 11pt

**CTA:** "Continue" — white fill, Deep Navy text (same style as Screen 1)

**Mood:** The dark background + big yellow number creates gravitas. This is the "problem" screen — it should feel weighty but not depressing.

---

#### Screen 3 — Solution: Daily Micro-Learning

**Background:** Soft Background (#F6F9FF) — shift to light, optimistic.

**Layout:** Centered, airy.

**Copy:**
- Headline: "What if 5 minutes a day could change that?" — Deep Navy, 28pt bold rounded
- Subtext: "Short, focused sessions make learning 17% more efficient than traditional methods" — Muted Text, caption
- Small citation: "Journal of Applied Psychology" — Muted Text, 11pt

**Visual:** Consider a simple illustration or icon composition — a clock showing 5 minutes, or a brain icon with a small progress spark. Keep it abstract and brand-aligned (beads/rails motif).

**CTA:** "Let's find out" — PillButton primary

---

#### Screen 4 — Mind-Blowing Fact: Screen Time

**Background:** Soft Background

**This screen has two states:**

**State 1 — Question:**
- Headline: "How much time do you spend on social media daily?" — Deep Navy, 28pt bold rounded
- 4 selection cards (single-select, vertical stack):
  1. "30 minutes"
  2. "1 hour"
  3. "2 hours"
  4. "3+ hours"
- Card style: NumindCard with radio indicator (circle + inner dot when selected, border color = Primary Blue when selected)

**State 2 — Reveal (appears after selection, cards collapse or fade, reveal slides in):**
- "That's **[X] hours a year**" — Deep Navy, large (e.g., 730 hrs for 2hr selection)
- "Just 10 minutes on Numind = **61 hours/year**" — Mind Teal accent
- "— enough to build a real skill"
- Subtext: "Structured practice — even in short daily sessions — produces measurable skill improvement" — Muted Text, caption
- Citation: "Ericsson et al., 1993" — 11pt

**CTA (state 2):** "That's eye-opening" — PillButton primary

---

### Phase 2: Data Collection (Screens 5–14)

---

#### Screen 5 — Confidence Self-Rating

**Standard light layout with progress bar.**

**Copy:**
- Headline: "How would you rate your everyday mental math?" — 28pt bold rounded
- No subtitle needed

**4 selection cards** (single-select, vertical stack):
1. "I struggle" / "Everyday math feels hard" — icon: 😰 or a relevant SF Symbol
2. "I get by" / "I manage, but it's slow"
3. "I'm decent" / "Pretty comfortable"
4. "I'm quick" / "Confident and fast"

Card style: same as Screen 4 — NumindCard, radio indicator, blue highlight on selected.

**CTA:** "Continue" — PillButton primary

---

#### Screen 6 — Motivation

**Standard light layout.**

**Copy:**
- Headline: "What brings you to Numind?" — 28pt bold rounded
- Subtitle: "Pick up to 3" — Muted Text, caption

**7 option chips/cards** (multi-select, max 3):
1. 💰 "Better financial decisions" — tips, budgets, investments
2. 💪 "Build confidence" — stop second-guessing everyday math
3. 📈 "Career growth" — salary negotiations, business math
4. 🧠 "Stay mentally sharp" — keep my mind active
5. 📚 "Support my education" — school, exams, coursework
6. ✨ "Appear sharper socially" — impress friends, split bills fast
7. 🎯 "Boost focus & analytical thinking" — train my brain

**Multi-select style:** Tappable cards with checkmark indicator. Selected state: Primary Blue border + subtle blue tint fill + checkmark. Unselected: hairline border, no fill.

**CTA:** "Continue" — PillButton primary (enabled once 1+ selected)

---

#### Screen 7 — Aspiration

**Standard light layout.**

**Copy:**
- Headline: "Where do you want to be in 30 days?" — 28pt bold rounded

**4 selection cards** (single-select):
1. "Tip in my head instantly"
2. "Feel confident with money decisions"
3. "Know if a deal is actually good"
4. "Do mental math faster than my phone"

Same card style as Screen 5 (single-select with radio).

**CTA:** "Continue" — PillButton primary

---

#### Screen 8 — Mirroring / Reinforcement

**Background:** Could use a subtle Primary Blue tint background or stay on Soft Background with a prominent card.

**Copy:**
- Small label: "BASED ON YOUR GOALS" — Muted Text, 11pt, uppercase, tracked
- Headline: Dynamic — reflects their motivation + aspiration. Example layouts:

If "Career growth" + "Feel confident with money":
> "Numind users report feeling more confident in salary discussions within 2 weeks"

If "Build confidence":
> "Daily practice builds automatic recall — the same way athletes train muscle memory"

- Show 2–3 bullet points inside a NumindCard, each with a small teal checkmark icon
- Below card: "We built Numind for exactly this." — Deep Navy, semibold

**CTA:** "That's what I need" — PillButton primary

**Mood:** Warm, personal, "we get you." This is the NLP mirroring moment — the user should feel understood.

---

#### Screen 9 — Topic Interest

**Standard light layout.**

**Copy:**
- Headline: "Which of these would help you most?" — 28pt bold rounded
- Subtitle: "Pick at least 2" — Muted Text

**6 option cards** (multi-select, **minimum 2**, max 4):
1. "Tipping & percentages" — icon: receipt or % symbol — Mind Teal accent
2. "Shopping & discounts" — icon: shopping bag — Primary Blue accent
3. "Salary & income" — icon: briefcase — Warm Orange accent
4. "Returns & investing" — icon: chart.line.uptrend — Invest Indigo (#5B5BD6) accent
5. "Splitting bills & estimation" — icon: person.2 — Growth Green accent
6. "Debt & interest rates" — icon: creditcard — Debt Coral (#EF5A3A) accent

**Card design:** 2-column grid (3 rows × 2 cols). Each card is square-ish with icon on top, label below. Selected state: colored border + tint fill + checkmark badge in corner.

**CTA:** "Continue" — PillButton primary. **Disabled (muted) until 2+ selected.**

---

#### Screen 10 — Time Commitment

**Standard light layout.**

**Copy:**
- Headline: "How much time can you dedicate daily?" — 28pt bold rounded

**4 selection cards** (single-select):
1. "5 minutes" — "Quick daily boost"
2. "10 minutes" — "Solid daily practice"
3. "15 minutes" — "Serious skill building"
4. "20+ minutes" — "Maximum growth"

Card style: single-select with radio, same as Screen 5.

**Small note at bottom:** "You can always do more with practice modes beyond your daily goal" — Muted Text, 12pt

**CTA:** "Continue" — PillButton primary

---

#### Screen 11 — Kaizen / Compounding

**Background:** Could use Deep Navy for impact (like Screen 2) or stay light with a prominent visual.

**Copy:**
- Dynamic based on Screen 10 selection. Example for "10 minutes":
  - "10 minutes a day =" — white/Deep Navy, body
  - "**61 hours this year**" — Insight Yellow (or Mind Teal), large display
  - Spacer
  - "The kaizen principle:" — label
  - "Getting 1% better every day compounds to **37.8× improvement** in a year" — emphasis on the multiplier
  - "Numind makes this fun — short games, daily challenges, and streaks keep you sharp without it feeling like work" — body

**Visual:** An upward-curving exponential growth line or stacking blocks animation. Keep it simple and clean — this is a "wow" moment, not a data visualization.

**CTA:** "I'm in" — PillButton (white fill if dark bg, primary blue if light bg)

---

#### Screen 12 — ADHD Screen

**Standard light layout.**

**Copy:**
- Headline: "Do you have ADD or ADHD?" — 28pt bold rounded

**5 options** (single-select, simple list or card style):
1. "Yes"
2. "No"
3. "I think so"
4. "Prefer not to say"
5. "Unsure"

**Conditional reveal (if Yes / I think so / Unsure selected):**
- Supportive card appears below with Mind Teal accent:
  - Stat: "An FDA-cleared game-based tool showed significant attention improvement in adults with ADHD — 72.5% reported quality-of-life gains"
  - "Numind's short, game-based sessions are designed to work with your attention — not against it"
  - Citation: "EndeavorOTC / STARS-ADHD-Adult, Akili Interactive, 2023" — 11pt

**If "No" or "Prefer not to say":** No reveal, just advance on CTA tap.

**CTA:** "Continue" — PillButton primary

**Tone:** Supportive, not clinical. No diagnosis language.

---

#### Screen 13 — Name Collection

**Standard light layout.**

**Copy:**
- Headline: "What should we call you?" — 28pt bold rounded
- Subtitle: "Used for your greeting and profile" — Muted Text

**Input:** Single text field, large (22pt semibold rounded input text). NumindCard-style container with blue border highlight on focus. Auto-focused on appear (keyboard slides up).

**CTA:** "Continue" — PillButton primary (works even if empty — defaults to "You")

**Reference:** Already built as `NamePage` in current onboarding. Same style.

---

#### Screen 14 — Age Range

**Standard light layout.**

**Copy:**
- Headline: "What's your age range?" — 28pt bold rounded
- Subtle note below options: "This helps us personalize your experience" — Muted Text, 12pt

**6 options** (single-select, horizontal pills or vertical cards):
1. "13–24"
2. "25–34"
3. "35–44"
4. "45–54"
5. "55–64"
6. "65+"

**Style option:** These could be horizontal pill chips (2 rows × 3 cols) instead of full-width cards — it's a simple categorical choice that doesn't need the weight of full cards.

**CTA:** "Continue" — PillButton primary

---

### Phase 3: Diagnostic (Screens 15–17)

---

#### Screen 15 — Diagnostic Intro

**Background:** Soft Background or subtle gradient.

**Copy:**
- Headline: "Let's see where you're starting" — 28pt bold rounded
- Subtext: "8 quick questions — no pressure, just calibration" — body
- "[Name], this helps us build your personal plan." — uses their name from Screen 13
- Small print: "This won't affect your score" — Muted Text, small

**Visual:** A simple icon composition — brain/lightbulb with a measuring element (ruler, gauge). Keep it encouraging, not test-like.

**CTA:** "Let's go" — PillButton primary

---

#### Screen 16 — Diagnostic Quiz

**This is 8 sequential question screens, NOT one screen.**

**Layout per question:**
- Progress: "1/8", "2/8" etc. — small counter in top bar
- Optional thin progress bar filling across questions
- Question card (NumindCard): scenario text (caption) + prompt (20pt bold rounded)
- 4 answer choices in a 2×2 grid below the card

**After each answer:** Brief flash overlay (green/correct or red/incorrect — same as True/False mode) then auto-advance to next question. No explanation, no hints, no motivators.

**Style reference:** Very similar to the existing True/False Snap mode — fast, clean, minimal chrome. See `TrueFalseView.swift` for the flash overlay pattern.

**No back navigation during the quiz.** Progress bar continues to show the onboarding phase position.

---

#### Screen 17 — Preparing Results (Loading)

**Background:** Deep Navy or Soft Background.

**Layout:** Centered, animated.

**Animation sequence (2–3 seconds total):**
1. "Analyzing your strengths..." — appears with fade-in + subtle slide up
2. "Setting your starting level..." — appears below
3. "Building your plan..." — appears below

Each step gets a small checkmark or completion indicator as it "finishes."

**Visual:** Brand particle/glow animation — could be abstract dots/beads converging, or a subtle pulsing ring. Think premium loading, not spinner.

**Auto-advances to Screen 18 when animation completes.** No CTA button.

---

### Phase 4: Results (Screen 18)

---

#### Screen 18 — Diagnostic Results

**Standard light layout.**

**Copy:**
- Headline: "Here's where you stand" — 28pt bold rounded
- Positive framing regardless of score

**Visual:** Per-topic performance breakdown. NOT the real Numind Score radar chart. Simple, friendly visualization:
- Each selected topic from Screen 9 gets a row
- Status indicator: ✅ "Strong" (green) / 🔄 "Needs work" (orange) / 🌱 "Starting fresh" (blue)
- Keep it visual, not data-heavy

**Positive framing examples:**
- Good score: "Nice! Strong foundations in [topic]. Let's build on that."
- Low score: "Great starting point in [topic]. You'll improve fast with practice."

**CTA:** "See my plan" — PillButton primary

---

### Phase 5: Personalized Plan + Priming (Screens 19–24)

---

#### Screen 19 — Personalized Plan

**Background:** Soft Background. This is a premium "reveal" moment.

**Copy:**
- Headline: "Your Numind Plan, [Name]" — 28pt bold rounded
- "You said you want to [aspiration] — here's how we'll get there" — body, Muted Text

**Content (scrollable, card-based):**
1. **Starting level card** — "Based on your diagnostic" + level indicator
2. **Focus areas** — their selected topics with simple progress indicators (empty bars ready to fill)
3. **Daily goal** — "[X] questions/day, [Y] minutes" with clock icon
4. **Timeline** — "In [Z] days, you'll [aspiration answer]" — uses aspiration + commitment level

Each section could be its own NumindCard, stacked vertically. Or one large card with dividers.

**CTA:** "Start my plan" — PillButton primary

---

#### Screen 20 — Notification Permission

**Standard light layout.**

**Copy:**
- Headline: "Stay on track with smart reminders" — 28pt bold rounded
- Subtext: "We'll remind you at the right time — and celebrate your streaks"

**Visual:** 2 example notification previews (mock iOS notification banners):
1. "🔥 Keep your streak alive! 5 minutes to level up." (streak reminder)
2. "🎉 New milestone! You've mastered Tipping." (celebration)

**Style:** The mock notifications should look like real iOS notification banners with the Numind app icon, slightly elevated with shadow.

**CTAs:**
- Primary: "Enable reminders" — PillButton primary
- Secondary: "Maybe later" — text button, Muted Text

---

#### Screen 21 — Paywall Priming

**Background:** Light, playful. This screen should feel casual, not salesy.

**Copy options (pick the best tone):**
- "Numind costs less than a coffee a month ☕"
- ROI framing: "The average overtipping mistake costs $200+/year. Numind pays for itself."
- Or a comparison card: left side shows a coffee cup with "$5", right side shows Numind logo with the monthly price

**Mood:** Light, almost humorous. The point is to pre-anchor the price so the paywall doesn't feel like sticker shock. Think "huh, that's actually reasonable" not "BUY NOW."

**CTA:** "Sounds fair" — PillButton primary

---

#### Screen 22 — Streak Goal

**Standard light layout.**

**Copy:**
- Headline: "Set your first streak goal" — 28pt bold rounded

**3 selection cards** (single-select):
1. **3 days** — "Build your first habit loop" — icon: 🔥 or flame.fill
2. **7 days** — "Complete your first module" — icon: 🏆 or trophy.fill — *recommended badge*
3. **14 days** — "Measurable improvement in mental math speed" — icon: ⚡ or bolt.fill

**Design note:** The 7-day option should have a subtle "Recommended" badge (Primary Blue pill label) since it extends past the 5-day trial — this is an intentional conversion lever.

**CTA:** "I'm going for [X] days" — PillButton primary (text updates based on selection)

---

#### Screen 23 — Improvement Projection

**Background:** Could use Deep Navy for dramatic reveal, or stay light.

**Copy:**
- Headline: "In just [streak goal] days, here's what you'll unlock:" — 28pt bold rounded

**Dynamic value props** (based on streak goal + time commitment):
- "✅ [N] lessons completed"
- "✅ [M] questions practiced"
- "🏅 Your first [topic interest] mastery badge"
- "⏱ [X] hours of focused practice"

Each line reveals with a staggered animation (fade-in + slide, 0.2s delay between each).

**Bottom text:** "Start with a free trial and see the improvement for yourself" — Muted Text

**CTA:** "Let me try" — PillButton primary

---

#### Screen 24 — Trial End Notification

**Standard light layout.**

**Copy:**
- Headline: "When should we remind you before your trial ends?" — 28pt bold rounded
- Subtext: "We'll never surprise you with a charge" — Muted Text

**3 options** (single-select):
1. "1 day before" — (day 4 of trial)
2. "2 days before" — (day 3 of trial)
3. "Don't remind me"

**CTA:** "Continue" — PillButton primary

**Tone:** Trust-building. This screen says "we're transparent about the trial."

---

### Phase 6: Paywall + Welcome (Screens 25–26)

---

#### Screen 25 — Paywall

**Background:** Soft Background or slight gradient. Premium feel.

**Layout:**
- Top: Numind logo/wordmark
- Plan toggle: Monthly / Yearly — pill segment control. **Yearly is default and highlighted** with "Best value" or "Save X%" badge
- Price cards or a single card showing:
  - Plan name
  - Price per period
  - Price per day/week breakdown
  - "Cancel anytime"
- Prominent: **"No payment due now"** — this must be highly visible, not buried
- Feature list: checkmarks showing what's included in trial
- "Restore purchases" link — small, bottom

**CTA:** "Start my free trial" — PillButton primary, large

**Secondary:** "Not now" or skip option — very subtle, small text. We want them to convert but we can't trap them.

**No progress bar.** This is a modal/destination screen.

---

#### Screen 26 — Welcome + First Session

**Background:** Soft Background. Celebration moment.

**Copy:**
- Headline: "Welcome to Numind, [Name]!" — 28pt bold rounded
- Brief celebration: confetti burst or brand particle animation (ConfettiBurst component exists)
- Streak priming: "Complete your first lesson to start your streak!" — with flame icon

**CTAs:**
- Primary: "Start my first lesson" — PillButton primary
- Secondary: "Explore first" — PillButton secondary

**No progress bar.** This is the end of onboarding.

---

## Interaction Summary Table

| Screen | Background | Selection Type | CTA Text |
|--------|-----------|---------------|----------|
| 1 — Welcome | Navy gradient | None | "Get started" |
| 2 — Social Proof | Deep Navy | None | "Continue" |
| 3 — Micro-Learning | Soft Background | None | "Let's find out" |
| 4 — Screen Time | Soft Background | Single-select (4 options) → reveal | "That's eye-opening" |
| 5 — Confidence | Soft Background | Single-select (4 cards) | "Continue" |
| 6 — Motivation | Soft Background | Multi-select (max 3, 7 options) | "Continue" |
| 7 — Aspiration | Soft Background | Single-select (4 cards) | "Continue" |
| 8 — Mirroring | Soft Background | None (dynamic content) | "That's what I need" |
| 9 — Topics | Soft Background | Multi-select (min 2, max 4, 6 options) | "Continue" |
| 10 — Time | Soft Background | Single-select (4 options) | "Continue" |
| 11 — Kaizen | Deep Navy or Soft | None (dynamic calc) | "I'm in" |
| 12 — ADHD | Soft Background | Single-select (5 options) + conditional reveal | "Continue" |
| 13 — Name | Soft Background | Text input | "Continue" |
| 14 — Age | Soft Background | Single-select (6 options) | "Continue" |
| 15 — Diagnostic Intro | Soft Background | None | "Let's go" |
| 16 — Diagnostic Quiz | Soft Background | 8 MCQ questions, auto-advance | (auto-advance) |
| 17 — Loading | Deep Navy or Soft | None (animation) | (auto-advance) |
| 18 — Results | Soft Background | None | "See my plan" |
| 19 — Plan | Soft Background | None (personalized content) | "Start my plan" |
| 20 — Notifications | Soft Background | None | "Enable reminders" / "Maybe later" |
| 21 — Paywall Priming | Soft Background | None | "Sounds fair" |
| 22 — Streak Goal | Soft Background | Single-select (3 options) | "I'm going for [X] days" |
| 23 — Projection | Deep Navy or Soft | None (staggered reveal) | "Let me try" |
| 24 — Trial Reminder | Soft Background | Single-select (3 options) | "Continue" |
| 25 — Paywall | Soft Background | Plan toggle (monthly/yearly) | "Start my free trial" |
| 26 — Welcome | Soft Background | None | "Start my first lesson" |

---

## Dark Background Screens

These screens use Deep Navy (#10224A) background for dramatic emphasis:
- **Screen 1** — Welcome (navy gradient, already built)
- **Screen 2** — Social Proof (big yellow stat on dark = gravitas)
- **Screen 11** — Kaizen (optional — the compounding reveal should feel like a "wow" moment)
- **Screen 17** — Loading (optional — premium loading feel)

All other screens use Soft Background (#F6F9FF) for consistency with the rest of the app.

When a screen uses Dark Background:
- Headline text → white
- Body text → white 70% opacity
- CTA → white fill with Deep Navy text (inverted from normal)
- Accent stats → Insight Yellow

---

## Selection State Patterns

**Single-select cards:**
- Unselected: Card Background, hairline border, no indicator fill
- Selected: Card Background, Primary Blue border (1.5pt), small filled radio circle (Primary Blue)
- Subtle blue shadow on selected card

**Multi-select cards:**
- Unselected: Card Background, hairline border
- Selected: Card Background, Primary Blue border (1.5pt), blue tint fill (Primary Blue 8%), checkmark badge (top-right corner, Primary Blue circle with white checkmark)

**Disabled CTA:**
- PillButton at 40% opacity, non-interactive
- Enabled when selection requirement is met (e.g., min 2 topics on Screen 9)

---

## Notes for Designer

1. **Pacing:** The first 4 screens are fast — minimal input, build emotional investment. Screens 5–14 collect data but should never feel like a form. Each screen asks ONE question.

2. **Emotional arc:** Problem (dark, weighty) → Solution (bright, hopeful) → Personal investment (clean, professional) → Diagnostic (game-like) → Results (celebratory) → Plan (premium, personalized) → Paywall (transparent, fair).

3. **The mirroring screen (8) is critical.** It's the "we understand you" moment. Should feel different from the data collection screens — warmer, more personal, less transactional.

4. **Screen 17 (loading) is fake but important.** The "analyzing your results" animation creates perceived value. It should feel like the app is doing real work, not just a progress bar.

5. **The paywall (25) should not feel like a trap.** Prominent "no payment now," clear pricing, visible skip option. Trust > pressure.

6. **Screen 4 and 11 are the "wow" screens.** Screen 4: "That's a lot of wasted time." Screen 11: "1% daily = 37.8× in a year." These need visual punch — big numbers, dramatic reveals.

7. **Consistency with existing app:** The rest of Numind uses Soft Background pages, NumindCard cards, PillButton CTAs. Onboarding should feel like the same app, just with more storytelling.
