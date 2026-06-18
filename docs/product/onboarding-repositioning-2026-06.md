# Onboarding Repositioning — Audience & Insecurity Strategy (June 2026)

> Re-evaluation of *what the onboarding sells and to whom*, grounded in
> segment-level insecurity/peak-pain analysis + an evidence lens (8 segment
> deep-dives + market research, synthesized adversarially). Supersedes the
> goal-based pitch in `onboarding-strategy.md` / `onboarding-funnel-v2.md` for
> positioning; the 27-screen flow + signals machinery stay, re-aimed.
>
> Status: **shipped (June 2026).** Founder forks resolved — positioning line
> = **"Walk in ready"**; default cold-open = the universal school-gap/composure
> frame (organic + founder-led + ASO/SEO acquisition, year-round, not seasonal);
> dated-event = the templated intent/monetization lane; full-restructure scope.
> Code landed: Confidence↔Mirror reorder, lane-aware skip (Deadline/Payday by
> lane), the relief-framed `fillTheGapSchoolLeft` motivation, the micro/macro
> mirroring rhythm, and the readiness-over-speed copy pass (every onboarding
> "20-second"/"math person" promise removed). 7 regression tests; suite at 148.

## 1. The core sell (what we're actually selling)

**Composure under the decision** — *"Walk into the money moment already knowing
your number, so you don't get quietly taken, outplayed, or caught not-knowing
when it counts."*

Every one of the 8 segments is buying the same felt state: the death of the
11pm-before-the-deadline stomach-drop and the drive-home replay — being the
calmest, un-bluffable person at the table. That's the emotional job. **Readiness**
is the in-app receipt for it; the **school gap** is the no-blame on-ramp; the
**20-second mental-math shortcut** is delight *inside* the product, never the pitch.

**Why this beats the current goal-based pitch** ("stop leaving money on the table,"
"make my money grow," etc.):
- Those `Motivation` labels are **rational outcomes**, not felt states — a dollar
  result the user can't picture. "I won't get got" / "I'll know what I'm looking
  at" is a body sensation every segment narrates verbatim.
- "Stop leaving money on the table" is **acquisition-narrow** — it fits the
  optimizer and the job-offer slice and actively *repels* the two largest, best-
  evidenced segments (the avoider and the competent-but-faking-it adult hear it as
  "one more way I'm already failing").
- Composure is the only frame that **survives the hard paywall** across segments: a
  dollar promise invites "I'll just Google it"; the promise of not-flinching-when-
  it-lands is exactly what they *can't* get from FinTok (which gives conflicting
  takes and more anxiety). Evidence: stress ≠ apathy — 72% already took an action;
  people are shopping for **agency**, not gain.

## 2. Positioning line candidates

| Line | Best for | Risk |
|---|---|---|
| **"Know your number before they say theirs."** | Widest net (operator, job-offer, got-burned, competent-but-faking); concrete, mono-figure-friendly, screenshot-able; pairs with the diagnostic demo. | Faintly transactional/negotiation-coded; tilts toward operator, away from the pure avoider (who wants calm before a number). |
| **"Walk in ready."** ("You don't get a redo. Walk into the offer, the form, the dealership already knowing what you're looking at.") | The dated-event core (best WTP); maps 1:1 onto the moments machinery + "on track to Ready by [date]." | Episodic/deadline-leaning; weaker for the always-on everyday-spending/staySharp retention buyer. |
| **"Stop guessing on the stuff nobody taught you."** | The avoider + competent-but-faking + school-cheated majority; externalizes shame, lowest-threat, no-judgment. | Slightly passive/deficit-flavored; under-sells the operator/maintainer who don't think they guess. |

## 3. Segment taxonomy (verdicts)

- **"Nobody taught me" / school-cheated adult → KEEP as the UNIVERSAL FRAME, not a
  routable persona.** Best-evidenced resonance in the deck (82% wish PF were
  required; 88% Gen Z feel unprepared) and the sentence the brand was built on. But
  it's "so broad it's nearly everyone" — use it as the no-blame on-ramp (screens
  2–4) for *all* segments; route on the moment/motivation underneath.
- **Money-Avoider → KEEP (co-primary acquisition; the volume top-of-funnel).**
  Largest reachable segment (~26–33% avoid finances under stress; 49% have looked
  away from a balance; skews female, concentrated in 22–40). This is the
  Insecurity-Mirror audience. **Conversion-fragile** (signs up on resolve, ghosts
  Thursday) and lowest tolerance for judgment-coded UI/account-linking — so the
  warm/no-grades/no-red treatment is a conversion **gate**, not polish.
- **Dated-Event / Life-Transition → KEEP (the primary PAYING engine).** Strongest
  monetization fit; the segment funnel-v2 + MomentsRegistry were built for. The
  moment supplies urgency, Readiness supplies the receipt. Limit: one-decision LTV
  — retention depends on landing a secondary pack or converting to a habit buyer.
- **First-real-paycheck (22–27) → KEEP as a bounded acquisition wedge; validate WTP
  separately.** High urgency, clean mapping to `understandPaycheck` + First Paycheck
  pack + payday trigger. But most cash-strapped and most FinTok-habituated — highest
  need, lowest disposable income. A younger instance of the dated-event buyer.
- **Got-burned / "never again" → MERGE into Dated-Event (keep as a copy LANE +
  reactivation/ad hook).** Potent and already first-class (`stopGettingTaken`,
  protect_your_money + car_buying packs, `almostScammed`), and FTC/scam data is
  real — but it's a moment-triggered *mood*, not a standing identity. Honesty
  mechanics are the lever; funnel pressure backfires here specifically.
- **Competent-everywhere-but-money (skews female) → MERGE into the Avoider** as a
  higher-functioning sub-tier + the **female-skewing TONE lever.** Same underlying
  job (composure without exposure). The gender data is a tone/imagery lever
  (judgment-free, low-numeracy-threat, the single "math" disarm line) — **NOT** a
  competence-deficit claim.
- **Level-up optimizer (skews male) → MERGE into Dated-Event for acquisition; keep a
  narrow `stopLeavingMoney`/`growMoney` copy lane.** Real, high-ARPU, high-intent —
  but smallest of the "real" set for a *paid education* app and most served by free
  FinTok. Genuine demand, weak WTP-for-education. Capture where he self-selects
  (job-offer/investing) + the diagnostic-as-ego-mirror; don't over-index the funnel
  on optimize/grow.
- **Finance-literate maintainer / staySharp → CUT as acquisition; KEEP strictly as a
  RETENTION mode.** Near-zero cold demand for a paid app to "stay sharp" before any
  felt pain. Real *post-onboarding* behavior (Freshness, habit-buyer branch). Never
  spend acquisition $ or lead the funnel on maintenance.

## 4. The onboarding spine (re-aimed, existing infra only)

**Arc:** no-blame origin (school gap) → felt exposure named (the mirror) → "you'll
see it coming" agency flip → a usable taste of composure (diagnostic-as-demo
shortcut reveal) → an honest, dated map to Ready → paywall as "buy the rest of the
composure you just felt." Math appears ONLY inside the demo.

**Branch points (no net-new infra):**
1. **Primary router = Life-Moment Picker (screen 7) → `focusPackId`.** Already drives
   MirroringCopy, the Deadline screen, and diagnostic weighting. Dated packs → dated
   arc; `everyday_spending` → habit-buyer/fluency-ladder branch.
2. **Tone router = `confidenceLevel` × `feltMoments` (screens 4–5).** struggle/getBy +
   guessedHealthPlan/carriedCardBalance = **avoider** → lead with relief + no-blame,
   suppress dollar-loss bullets. decent/quick + almostScammed/acceptedWithoutNegotiating
   = **operator/got-burned** → lead with edge/agency. noneYet + quick + staySharp =
   **maintainer** → "good — let's keep it sharp," route to retention branch.
3. **Motivation (screen 6) = copy-lane selector, not a new screen.** **Enum gap:** add
   one relief-framed case `fillTheGapSchoolLeft` ("Finally learn what school
   skipped") so the school-cheated majority sees their own sentence; optionally
   soften `decideWithConfidence` → "Stop dreading money decisions" (the avoider's
   true entry mood). Do **not** add a maintenance-acquisition case.
4. **Age (screen 14) = secondary router only.** 22–27 → first-time packs; 28–40 →
   dated life-moment packs. Gender-aware lever is **tone**, never separate content.

## 5. Screen-by-screen fix list (current 27-screen funnel)

- **S2 Social Proof** — "nobody showed them the 20-second version of the math" over-
  claims + double-spends the math budget + leads with doom. → Cut "of the math" →
  "nobody ever showed them how." Keep the APA stat (verify exact wording/year before
  screenshots) and immediately pair with agency ("stress isn't the same as stuck —
  72% already tried").
- **S5 Confidence → move BEFORE S4 Mirror.** The funnel's highest-leverage screen
  currently fires blind to the one signal (struggle vs quick) that decides
  relief-vs-edge. Swap 4↔5.
- **S4 Insecurity Mirror** — cost-reveal can confirm shame for the fragile majority.
  → Frame every cost stat as system-caused + universal (attributed to the gap, never
  the person); suppress dollar-loss for struggle/getBy, lead with relief.
- **S6 Motivations** — all 7 cards sell a destination; none mirrors the no-blame
  origin. → Add `fillTheGapSchoolLeft`; soften `decideWithConfidence`; keep
  `stopLeavingMoney` for the operator lane but never as the universal headline.
- **S8 Mirroring** — `bullets()` ranks motivation copy first and only shows a felt-
  moment bullet "if matched < 3," so avoiders may never see their own moment; only
  the two operator/got-burned moments have feltMoment bullets. → For struggle/getBy,
  show the felt-moment mirror FIRST; add relief-led bullets for
  guessedHealthPlan/carriedCardBalance.
- **S9 Deadline** — manufactures urgency for undated moments (forbidden). → Skip
  entirely for undated focus packs; keep countdowns only for genuine MomentsRegistry
  windows.
- **S11 Kaizen** — optimization/compounding frame leans operator + reads "childish"
  to the operator/maintainer it targets; v2 already flags it for the 27→24 cut. →
  For avoiders, replace with one relief line ("five minutes, no homework, no
  grades"); keep the habit-buyer fluency-ladder variant; candidate to cut if
  drop-off clusters here.
- **S16 Diagnostic-as-demo** — too-early "test" can fire school trauma for avoiders;
  too-easy run validates "I already know this" for the operator. → Branch reveal
  *emphasis* (not questions): avoiders get "oh, that's all it was?" + zero
  red/grade; operators get at least one favorable-but-revealing gap (speed delta or a
  d3 miss).
- **S22 Paywall Priming** — "Quick Math" label spends the math budget on a conversion
  surface + leads avoider/got-burned with loss/fear. → Rename "Quick Math" → "What
  this costs you"; for avoider/maintainer lanes, lead with the composure feeling
  before any dollar figure.
- **S24 Projection** — for short-fuse dated buyers (deadline < ~1 week), "on track to
  Ready by [date]" can over-promise. → Soften to "sharper for [moment] by [date]"
  inside the gate horizon; keep the honesty mechanic.

## 6. Open decisions (founder)

1. **Acquisition center of gravity** — the default unbranched path / cold-open
   headline / App Store screenshots must pick ONE: **(a) avoider/no-judgment volume**
   [largest, fragile, lower ARPU] or **(b) dated-event/life-transition intent** [smaller
   flow, best WTP, seasonal]. Evidence points to **dated-event as the monetization
   anchor, avoider as the volume top-of-funnel** — but the *default* path owns one.
2. **Positioning line** — "Know your number" vs "Walk in ready" vs "Stop guessing"
   (§2). Cascades into ad creative + the screen-1 hook.
3. **Enum change** — approve adding `fillTheGapSchoolLeft` (+ maybe renaming
   `decideWithConfidence`). Touches OnboardingSignals, MirroringCopy, Motivations
   screen, analytics keys.
4. **Screen-count cut** — recommendation: cut the undated-path Deadline screen now
   (principled); gate the rest (Kaizen/Framing) on PostHog drop-off data.
5. **Confidence-before-Mirror reorder** — small build, large conversion implication.
6. **Maintainer = retention-only** — confirm no acquisition spend (or a small
   referral-led experiment given the "friend everyone texts" word-of-mouth).
7. **Got-burned & operator = copy lanes + reactivation/seasonal ad creative**, not
   dedicated funnel personas — confirm.

## 7. Evidence highlights

- **Gender:** a real, replicated *confidence/money-talk* gap (not a competence gap):
  38% of young women feel confident talking about money vs 56% of men (Principal
  Foundation, n=3,000, Aug 2025); women report ~3× the low-numeracy-confidence of men
  (National Numeracy/KPMG UK, 2025). → Women are an under-served, high-intent segment;
  the lever is **tone** (judgment-free, low-numeracy-threat) — never a competence-
  deficit claim, and a strong reason to keep "math" to the one disarm line.
- **Age:** within 22–40, Gen Z (≈22–27) and younger Millennials (≈28–40) diverge —
  treat as distinct. Gen Z: higher anxiety, more avoidance (49% looked away from a
  balance), more FinTok-shaped (~70%), more first-time decisions. Late-20s/30s: more
  concrete life-moment decisions, higher baseline confidence but ~1 in 3 still anxious
  (the "confidence paradox").
- **Behavior:** stress ≠ apathy — 72% already took a money action; the funnel should
  sell **agency**, not gain.

_Source workflow: `onboarding-audience-reposition` (8 segment profiles + evidence +
adversarial synthesis), June 2026._
