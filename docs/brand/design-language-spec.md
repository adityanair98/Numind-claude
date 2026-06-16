# Design Language Spec — "Warm-Premium Money Tool" (Phase 13)

> The redesign brief. This is the source of truth for the visual language and
> supersedes `design-tokens.md` for color/type/shape. It is grounded in the
> June-2026 audience-aesthetic research (`docs/product/` research + the
> three adversarial design-fit checks run during ideation) and was calibrated
> against that research twice to catch over-correction.
>
> Read alongside: `brand-guidelines.md` (voice, positioning, language rule,
> honest-progress vocabulary — all still binding) and `motion-guidelines.md`.

---

## 0. North star

**The lane: a warm-premium money *tool* applied to a teaching/quiz loop.**
The competitive map has two crowded corners — *warm-but-toy* education
(Zogo, Bloom, Greenlight) and *premium-but-cold* tracking (Copilot, Monarch,
Origin) — and an empty middle. We own it. One-line identity:

> **"The only money-education app that respects your money."**

It must feel: warm, credible, alive, grown-up. Never: childish, toy, clinical
dashboard, academic/magazine. The brand is "friendly, lightly playful" — life
is *required*, but it comes from illustration, depth, motion, and earned
celebration, **not** from rainbow color, mascots, hearts, points, or per-answer
confetti.

### Three load-bearing rules (memorize these)

1. **Warm-neutral base DOMINATES; one confident accent LEADS per screen.**
   Exactly one saturated color block per screen (usually the primary CTA / the
   daily action). Everything else is warm-neutral with a *single accent detail*
   (a colored glyph, number, or rule — not a color fill).
2. **Bold sans is the default register. Editorial serif is a bounded teaching
   accent** — never on functional or live-state surfaces. (The Robinhood split:
   serif marketing/headlines, sans product UI.)
3. **Every correct/wrong verdict is carried by FOUR redundant channels** (color
   + distinct-shape icon + fixed position + copy) and must pass the grayscale
   test. Color is never the sole signal (WCAG 1.4.1).

---

## 1. Color tokens

All accents have ONE semantic job. Light + dark are both first-class; **dark is
warm charcoal, NOT the cool blue-black shipping today.**

### Neutrals (the base — must dominate every screen)

| Token | Light | Dark | Use |
|---|---|---|---|
| `page` | `#FAF8F3` warm off-white | `#1A1611` warm charcoal | Screen background |
| `card` | `#FFFFFF` | `#24201A` | Default card surface |
| `cardRaised` | `#FFFFFF` + shadow | `#2C2720` | Elevated / modal |
| `ink` (text) | `#1A2236` | `#F1EADD` cream | Primary text; the inverted CTA fill |
| `mutedText` | `#8A8578` warm gray | `#A89E8C` | Secondary text, labels |
| `hairline` | `rgba(26,34,54,0.10)` | `rgba(241,234,221,0.10)` | Dividers, card borders |

### The four accents (each = one job)

| Token | Light | Dark | The ONE job |
|---|---|---|---|
| `actionInk` | `#1A2236` (text inverts → pill) | CTA = `#F1EADD` cream pill, dark label | Primary CTA. Boldness from weight/contrast, never a 5th hue. |
| `teal` | `#15A18C` | `#34D2BE` | Correct · Ready · Verified · positive state |
| `gold` | `#FFD84D` | `#FFD84D` | Insight / the shortcut "aha" — **insight only** |
| `ember` | `#F0851B` | `#FF9A3D` | The streak flame — **streak only** |

Supporting state surfaces (tints, never full body fills):
`tealTint #E3F6F1 / #15302B`, `goldTint #FFF6D9 / #2E2814`,
`emberTint #FFF1DA / #2E2113`, `wrong #E0632E / #FF8E57` +
`wrongTint #FFEDE4 / #2E1B12`.

**Gold vs ember are split on purpose** — gold never marks a save/badge, ember
never marks insight. (The "save" badge moved off gold to teal.)

### Topic-accent palette (the demoted module rainbow)

The legacy 13-hue `ModuleColor` rainbow is **retired as a fill palette**. Topic
identity survives only as **small icon chips and slim header strips**, in a
bounded, *desaturated* set — never as a full card/tile field, never on Home.

| Topic | Light chip icon | Dark chip icon |
|---|---|---|
| Everyday money | `#15A18C` on `#E3F6F1` | `#34D2BE` on `#15302B` |
| Paycheck / income | `#5E63B6` on `#ECEDF8` | `#8A8FE0` on `#22244A` |
| Housing | `#B5577A` on `#F6E9EC` | `#E08BA8` on `#3A2028` |
| Protect / safety | `#C0573A` on `#F7EAE5` | `#E89070` on `#3A2419` |
| Taxes | `#4A7C8A` on `#E7F0F2` | `#7FB0BD` on `#1E2C30` |
| Investing | `#3B8A55` on `#E8F2E5` | `#6FC089` on `#1C2E1F` |

**Hard rule:** cap *co-visible saturated hues* per screen at the four named
accents. Topic hues appear only in icon chips (≤32pt tile) and ≤4pt header
accent strips. The label always carries topic meaning for VoiceOver — color is
decorative wayfinding only.

---

## 2. Type system

Three typefaces, three jobs, mapped to SwiftUI system fonts (no custom font
dependency at v1).

| Role | Face | SwiftUI | Used for |
|---|---|---|---|
| **Teaching voice** (serif) | New York | `.system(..., design: .serif)` | Lesson concept headline + the shortcut callout; pack/paywall headline; marketing. **Bounded accent only.** |
| **Interface** (sans) | SF Pro | `.system(...)` default | Everything interactive: Home, Explore, quiz, CTAs, labels, all body, all state, all small/fast-read text |
| **Money** (mono) | SF Mono | `.system(..., design: .monospaced)` | Every figure: prices, scores, streak counts, take-home, % — always tabular |

### The register rule (binding)

> **Default register is bold sans. A surface may open in serif ONLY if it is on
> the editorial allow-list AND carries no primary action or live state.**

Editorial allow-list: `lesson concept intro`, `teach-card headline + shortcut
callout`, `pack header (headline only)`, `paywall headline (1–2 lines only)`,
marketing site. Everywhere else, including all of onboarding's functional
screens, the paywall *offer stack*, Home, Explore, Progress, Tools, and **all
feedback**, is bold sans.

- **Never** put serif on body copy, labels, numbers, or state. (Small-serif
  legibility + ADHD cognitive load.)
- **Never** italic serif (worst legibility form for this audience). Upright only.
- Weights: **two only** — regular (400) and medium (500). No 600/700.
- Sentence case everywhere. Tracked-caps eyebrow labels (10–11pt) are sans.

---

## 3. Shape, depth, spacing

Carried forward from `design-tokens.md`, plus the depth rule that gives "life."

- Radii: card `20` (continuous/squircle), inner card `14`, button/pill `999`,
  icon tile `9–12`. All `.continuous`.
- Spacing: screen H-padding `16–20`, card padding `14–18`, section `28`,
  button height `54`.
- **Depth (the life-giver the flat sketches couldn't show):** soft elevation on
  cards — light mode `shadow black 6% r12 y4`; dark mode `0.5pt warm hairline`
  (no shadow). Layering and the tilted money-artifact illustration read as
  tactile, not flat chrome. Hero/marketing surfaces may use a *real* gradient
  (gradients are for heroes only, never functional cards).

---

## 4. Illustration system

Illustration is **research-positive and required** — it's the single unclaimed
territory in the category and the real answer to "too plain." Style: **flat
geometric money-artifact collage** (the app's existing hero idiom), warm.

- **The money-artifact motif:** tilted receipt card with real line items, gold
  `%` coin, white `$` coin, teal cart, beads. Used on: onboarding hero, empty
  states, celebration moments, section heroes.
- **Topic headers:** lesson/pack open with a *slim* topic-accent header strip
  carrying one spot illustration (umbrella, key, shield). Strip, not full-bleed
  band. (Calibration fix — see §9.)
- **Spot art:** small, single-object, line-or-flat, in the topic accent.
- Beads-on-rails remains the brand mark motif (logo), and beads may be a playful
  micro-element. No literal abacus, no brain imagery.

---

## 5. Color-block usage (the calibration rule)

This is where "alive" stays disciplined. From the adversarial reconcile:

- **One saturated color block per screen**, and it's the lead action (the teal
  daily-workout card on Home; the teal "continue" hero on Explore). Everything
  else is `card`-neutral with a single accent detail.
- **Color marks payoffs, not chrome.** A solid teal panel is allowed for the
  *result* of a worked example / a correct verdict — the arrival moment — not as
  general card styling. Prefer tinted-panel + accent bar over full fills where
  it would add a competing saturated mass.
- **Never** a patchwork of 3–4 saturated blocks co-visible (the Home over-
  correction). If two color blocks want to be on one screen, demote one to
  neutral-with-accent-detail.

---

## 6. The streak (warm flame)

The streak is the one place playfulness is on-brand — it's the reward for
showing up. It is a **warm flame**, done right.

- **Color:** ember (`#F0851B` / dark `#FF9A3D`) — fire is warm, *never* teal.
  Ember is held distinct from the wrong-state terracotta (`#E0632E`); they never
  share a context.
- **Daily chip:** flame glyph + count on a *neutral* card (color in the glyph,
  not a fill — calibration). Warm one-liner allowed ("2 from your best").
- **Motion:** a subtle flicker daily; a bead/flame *leap + grow* at milestones.
- **Forgiving voice:** rest-day mechanic keeps an encouraging line ("a rest day
  is yours — the flame holds"). Never anxiety-loop framing.

---

## 7. Celebration vocabulary (milestones only)

A *vocabulary* of earned wins, never per-answer. Playfulness peaks here.

| Event | Treatment |
|---|---|
| Per answer correct | Calm: result zone settle + `.success` haptic. **No confetti.** |
| Skill mastered | Gold star badge on a warm-dark/teal field + light confetti + warm copy |
| Streak milestone (7/30/100) | Flame leaps + grows, confetti, `.success` haptic |
| Pack Ready / refresh-save | Brief milestone sheet ("Back to sharp") |

Confetti = restrained, brief, physics-light, gold/teal/ember particles. Never
heavy/casino. **Per-answer confetti is forbidden** (see §9 — it ships today and
must be removed).

---

## 8. Feedback: the four-channel rule

Every correct/wrong verdict carries FOUR channels that all agree; the screen
must remain legible in grayscale and for color-vision deficiency.

1. **Color** — colorblind-safe blue-yellow axis: `teal` correct / warm `amber`
   wrong. (Not green/red.)
2. **Icon** — topologically distinct *filled* glyphs: check-in-circle vs
   cross-in-circle. Never the same dot recolored.
3. **Position** — one fixed result zone the eye pre-learns; its appearance
   alone pre-signals "verdict."
4. **Copy** — one calm factual line. Correct: "Nice — that's right." Wrong:
   "Not quite." + the correct answer + next step (KCRF), coaching never blaming.

Rules: **wrong-state TEXT is dark ink, never orange** (orange is mid-luminance,
fails AA on white — orange only on fills/glyphs/strokes). Wrong = warm amber,
not alarm-red; the daily ring still advances. Motion: correct = quick badge
settle; wrong = one fast-damped horizontal nudge (<300ms) + Reduce-Motion static
fallback. Haptics `.success` / `.error`.

---

## 9. Two code fixes the audit surfaced (do these in the rebuild)

1. **Per-answer confetti is a live toy-signal violation.** `QuizSessionView`
   ships `ConfettiView` on the per-answer verdict today. Re-gate confetti to
   milestones only (§7).
2. **The 13-hue rainbow is still wired in tokens.** `ModuleColor` /
   `ModuleColorTheme` define 13 fully-saturated hues; any screen "decorates over
   an un-demoted palette." Formally demote: replace with the bounded topic-accent
   set (§1), enforced so the rainbow *can't* spread to a card fill.

---

## 10. Per-surface register assignment

| Surface | Register | Lead accent block | Notes |
|---|---|---|---|
| Onboarding hero | sans + **illustration** | navy/charcoal hero | money-artifact collage |
| Onboarding functional screens | **sans** | per screen | serif never on inputs/state |
| Paywall | serif *headline only* | bold offer stack | prices/cards/CTA loud sans |
| Home | **sans** | teal daily-workout card | rest neutral + accent detail |
| Explore | **sans** | teal/charcoal "continue" hero | topic color = icon chips only |
| Lesson concept intro | **serif** (teaching) | slim topic header strip | shortcut callout = serif |
| Worked example | sans | teal payoff panel | money in mono |
| Quiz question | **sans** | — | strong option-card affordance |
| Quiz feedback | **sans** | result zone (teal/amber) | four-channel rule |
| Pack | serif *headline only* | slim topic header strip | bold checklist |
| Progress | **sans** | — | practice chart + skills ledger |
| Tools / calculators | **sans** | ink result block | 3-layer disclaimer kept |
| Session summary | **sans** | the ring | mono score, skill moves |
| Milestone sheets | **sans** | celebration field | §7 vocabulary |
| Profile | **sans** | — | — |

---

## 11. Do-not-touch (inherited, still binding)

- **Honest-progress vocabulary** (`brand-guidelines.md`): capability words only
  — skills mastered / to refresh, packs Ready. **No points, levels, grades, XP**
  anywhere user-facing. Readiness claims scoped to evidence ("on track to
  Ready", never "Ready by").
- **Language rule:** math is the method, never the promise — one disarm use per
  surface.
- **Mascots** confined to celebration sheets; everyday iconography is SF Symbols
  in the topic/state accent.
- Centralized tokens (no scattered hex). Small modular files. VoiceOver labels
  on all interactive elements (bake in, don't retrofit).

---

## 12. Verify on device before final lock

- Serif body at 14pt on a small phone (New York legibility on lesson/pack).
- Module-accent icon chips at small size on dark `#24201A` (contrast).
- The warm cream base against the "friendly, not academic" mandate — if it tips
  literary, shift a half-step toward the shipped warm-neutral.
- Dark mode across every surface (designed, not inverted).
