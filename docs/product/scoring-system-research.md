# Numind — Scoring System Redesign Brief (for implementation)

> **IMPLEMENTATION STATUS — as shipped (June 2026). This section is authoritative where it
> differs from the brief below**, which is preserved as the original Phase 9 research/design
> input (the rationale in §2/§6/§7 still stands). Key deltas:
>
> - **Two currencies shipped, then the headline moved.** The brief's "MP" shipped as **XP**
>   via `MomentumEngine` (formula + ladder + depth-gate exactly as §3.2–§3.4). In **Phase 10**
>   XP/Level became **hidden fuel** — retired from every surface. The user-facing headline is
>   now the **daily goal ring + per-pack Readiness + restorable Freshness**. The brief's
>   "Sharpness" is the shipped **Freshness** (`FreshnessEngine`).
> - **Counts (current):** 11 modules · 134 lessons · 791 templates · 12 packs · 12 calculators.
> - **Mastery star** (`ProgressData.hasMasteredLesson`, **focused lesson sessions only**): one
>   session ≥85% **or** two ≥75% on non-consecutive days, with ≥1 correct medium/hard.
>   `masteredWithHard` (deep mastery) additionally needs a correct **hard** answer.
> - **Readiness gates — Option C (June 2026 audit), supersedes §3.7.** Four gates over a pack's
>   *core* lessons:
>     - **coverage** — each core lesson practiced ≥once — *any practice surface*
>     - **retention** — each core lesson correct on **≥2 distinct calendar days** — *any surface*
>     - **application** — ≥1 correct `isApplication` decision item among core lessons — *any
>       surface* (gate present only when such items exist; else the §3.7 fallback)
>     - **depth** — each core lesson **mastered-with-hard** — *focused lesson sessions only*;
>       **carve-out:** a hard-incapable concept-only core lesson (no hard question is generable)
>       satisfies depth via plain top-tier mastery, else its pack could never reach Ready.
>   "Any surface" = a focused lesson, the Daily Workout, a Refresh, or a Bonus round (these
>   record under a synthetic `lessonId` but carry the real `templateId`). Net: daily/refresh
>   practice advances coverage/retention/application + Freshness, while the **mastery star and
>   depth stay earned by focused lessons** — so a daily-only user's packs progress while their
>   "Mastered" count stays 0 by design. States: Not started → Learning → Almost ready (names the
>   one missing gate) → Ready → **Sharp** (Ready + every core lesson currently fresh).
> - **Streak** (`DailyRingEngine.markActiveDay` + `computeStreak`): a day counts when the user
>   does **any** real practice that day (not only when the ring's 5–8 question target is hit), or
>   a freeze / rest day covers it. The ring is the daily *goal*; the streak is "you showed up."
> - **Freezes:** first at **day 3**, then every 7 days, **cap 5** (the §3.9 drift fix; the old
>   "max 3" was wrong). Accepting a streak loss resets the milestone counter **and** the banked
>   balance, so a new streak earns from scratch (no double-award).
> - **Free-entry grading:** magnitude-aware tolerance — currency `max(4%, $0.25)`, integer ±0.5,
>   percent ±0.5pp (replaced the flat ±0.05 that rejected correct estimates).
> - **Review:** the brief's "Recall" is retired; one consolidated **Refresh**
>   (`RefreshSessionBuilder`) = stale mastered skills + unfixed mistakes.
>
> Engines: `MomentumEngine` · `ReadinessEngine` · `FreshnessEngine` · `DailyRingEngine` ·
> `MilestoneEngine`. June-2026 audit fixes: commits b5fc5d0 (4 defects), 170c9d3 (Option C),
> 5cc212f (tolerance + cleanups).

## 0. CONTEXT
Numind is a PAID iOS SwiftUI financial-learning app (hard paywall), US adults ~22–40.
10 modules, 118 lessons, 590 quiz templates, 10 life-event packs, 12 calculators.
Progress stored locally (UserDefaults). Loop: Home → Lesson → Quiz → Feedback → Progress,
with a Daily Workout (streak anchor) and a Recall weak-spots mode.
It pivoted from a mental-math app (where one 0–100 competence score made sense) to a
financial-DECISIONS product. The current multi-score system is a leftover from the old shape
and is being redesigned. Constraint that overrides everything: do NOT demotivate paying users.

## 1. CORE DESIGN DECISION
The single global 0–100 "competence" score is the wrong SHAPE for a decisions product and is
the root of every known bug. Replace it with TWO separated layers:

  (A) MOMENTUM — the motivation engine. Honest about being EFFORT/consistency, never claims to
      measure competence. (Almost) only goes up. Owns daily-habit retention.
  (B) READINESS — the honest competence signal, made PER-DECISION (per life-event pack), not
      global. Framed positively as things UNLOCKED, never as deficits.

Four principles, all research-backed (see §2):
  1. Effort and competence are different currencies — don't collapse them into one number.
  2. The headline mostly only goes up; staleness lives in a separate, RESTORABLE meter, never
     subtracted from the headline.
  3. Generous on-ramp, EARNED ceiling: easy early wins are good; only the TOP of the range
     requires demonstrated depth (hard questions + applied/scenario items).
  4. Every number is framed as INFORMATION about growing competence, never as a controlling
     carrot ("do X to earn Y"). Same mechanic, opposite phrasing, opposite motivational effect.

## 2. RESEARCH RATIONALE (why, compressed)

UI/UX (Duolingo, Elevate, Peak):
- Apps in this space sell the FEELING OF PROGRESS, not content; first positive signal should hit
  in the first seconds (Duolingo awards XP before the lesson screen closes). Award MP before the
  first lesson finishes.
- "Something must always be advancing, even on a bad day." Layer multiple progress surfaces.
- Make failure feel SAFE: gentle feedback, no red error screens. Khan renamed its harsh
  "Struggling" state to neutral "Attempted." Use no-deficit language everywhere.
- ADULT self-improvement audience: paid apps like Elevate deliberately AVOID leaderboards and
  users praise the lack of social pressure. Favor PRIVATE self-progress over Duolingo-style
  competitive leagues for this 22–40 finance audience.
- Streaks: long streaks (90+ days) carry the HIGHEST abandonment risk when broken; "slack"
  (freeze/rest days) increases persistence. Keep the streak forgiving and SECONDARY — not the
  central anxiety lever.

Product:
- The dominant financial-literacy app (Zogo) runs on EXTRINSIC rewards (points → gift cards).
  Numind is paid and cannot/should not pay users to learn; motivation must be intrinsic.
- Paid adult self-improvement apps (Elevate EPQ, Peak PBS) prove a composite self-progress
  number is viable IF framed as personal progress, never a verdict.
- Discipline: pick ONE connective currency (MP) that every mechanic feeds; tie scoring to the
  north-star (post-paywall retention).

Financial educator (CFPB, Jump$tart, financial-capability literature):
- The field's goal is FINANCIAL WELL-BEING and CALIBRATED CONFIDENCE, not a knowledge test score.
  Literacy = knowledge + skills (application) + confidence.
- OVERCONFIDENCE is specifically harmful in finance (underestimating risk, overtrading,
  under-insuring). So an inflated score is not just non-credible — it can nudge real financial
  mistakes. Depth-gating the ceiling is therefore a SAFETY requirement, not just credibility.
- Generic financial education has a weak, decaying link to behavior; JUST-IN-TIME learning tied
  to an imminent decision transfers far better. → Per-decision readiness is also the better
  pedagogy. Map packs to a recognized standard (e.g., Jump$tart National Standards).

Learning behavior (Self-Determination Theory, mastery-learning research):
- Intrinsic motivation needs competence, autonomy, relatedness.
- Overjustification effect: rewards perceived as CONTROLLING reduce intrinsic motivation; rewards
  perceived as competence-INFORMATION can increase it. → drives principle #4 above.
- Meta-analysis: gamification lifts autonomy/relatedness but barely moves perceived competence;
  the competence feeling comes from succeeding at HARDER material, not from accumulating points.
- Autonomy: offer multiple paths and meaningful choices → let users pick which pack to pursue.
- Khan Academy mastery model (borrow directly): 4-level ladder, mastery "not easily earned";
  research shows depth (proportion taken to proficient/mastered) beats breadth. Two currencies
  (Energy Points = effort reward, Mastery Points = competence). Practice is consequence-free
  (wrong answers in practice never cost points); only graded checks move standing; protected floor.

## 3. SPEC (what to build)

### 3.1 Two currencies
- Mastery Points (MP): the competence STOCK / headline. Drives Level. Never decays.
- Sharpness: separate freshness FLOW. Decays on SRS schedule, fully restorable. Never touches MP.

### 3.2 Mastery Points (MP) formula
- Earned only on CORRECT answers. Wrong = 0 (never negative).
- Per correct question: base 10 × difficulty multiplier → easy 10, medium 15, hard 25.
  (Widen the hard premium vs the legacy 1.0/1.2/1.5 so depth pays meaningfully.)
- One-time milestone bonuses: master a lesson +50; unlock a pack +150.
- NO speed/review/recency multipliers on MP — keep it legible ("+15" must be explainable).
- MP is monotonic: it never goes down, ever.

### 3.3 Level ladder (front-loaded, then widening)
L1:0  L2:80  L3:180  L4:320  L5:500  L6:750  L7:1100  L8:1550
L9:2150  L10:2950  L11:4000  L12:5400  L13:7200  L14:9600  L15:12800
- Target Level 2 mid-first-session (paywall validation). First MP before first lesson closes.
- Show "X XP to next level" and attribute every gain to a concrete event
  ("+15 — mastered Compound Interest"). No mysterious movements.

### 3.4 Depth gate (the earned ceiling)
- Levels 1–8: by total MP only (generous on-ramp).
- Levels 9+: each level ALSO requires +1 "deep mastery" = a lesson mastered with ≥1 correct HARD
  question, OR a pack unlocked. Effective level = min(level-by-MP, level-allowed-by-depth).
- Result: cannot grind easy-only volume to the top; nothing is ever taken away from the user.

### 3.5 Sharpness (freshness)
- Per mastered skill: freshness decays using existing SRS overdue logic (priorityScore).
- Aggregate Sharpness = avg freshness across mastered skills.
- Surface as opportunities: "3 skills ready for a refresh." Reviewing RAISES freshness.
- NEVER subtract from MP or Level. Worst case after a long absence: Level unchanged, Sharpness
  dips, positive refresh nudge.

### 3.6 Mastery star (per lesson)
- Require ≥1 non-easy (medium/hard) correct success before awarding the star (fixes mastery-on-
  easy). Reuse existing hasMasteredLessonNow logic + add the non-easy condition.

### 3.7 Per-decision readiness (the competence headline)
- Each life-event pack maps to a set of core lessons/templates.
- States (positive framing only; never "not ready"):
  Not started → Learning → Almost ready (name the ONE missing gate) → Ready → Sharp.
- Ready gates: coverage (core lessons seen) + depth (medium/hard correct in core lessons)
  + retention (held across ≥1 SRS interval) + application (≥1 scenario item correct).
- Until scenario content exists, fall back to: all core lessons mastered (drop application gate).
- "Almost ready" must always name the single next action ("try the harder questions" /
  "one more spaced review").
- Let the user CHOOSE which pack to pursue (autonomy). Map packs to Jump$tart standards.

### 3.8 Copy framing rules (apply globally)
- Frame every increment as competence information: "You've mastered compound interest," NOT
  "Do 3 lessons to earn 50 points."
- No verdict labels. Replace Rookie/Analyst/Sharp/Pro tier copy with the level ladder.
- All locked/incomplete states phrased as opportunity, never deficit.

### 3.9 Streak
- Keep, but secondary. Preserve freeze + free-rest-day forgiveness. Fix the freeze-cap doc/code
  drift (comment says max 3; actual cap is 5). Don't make the streak the central pressure lever.

## 4. BUGS TO FIX / REMOVE (from current system)
- DELETE the composite() pipeline, coverageCaps, and the +20 exploration bonus (these cause
  "breadth beats depth": touching 7 axes shallowly lifts the ceiling from 60→100).
- STOP counting "Warming up" (5 questions) as a covered axis anywhere.
- REMOVE recency decay from the headline (it moves into Sharpness only).
- REMOVE ScoreTier verdict bands and subtitle band copy.
- FIX mastery-on-one-easy-session (require non-easy success — see 3.6).
- Mastery "never decays if you stop" is now handled by Sharpness (headline doesn't decay by design).
- CAP secondary-axis attribution: one question currently credits up to 3 axes (primary + 2
  secondary), compounding breadth inflation. Only credit secondaries once primary has real
  evidence, or cap their contribution.
- Resolve doc/code drift: freeze cap 3 vs 5; label "Developing" vs "Building"; stale SRS comment.

## 5. CODE: KEEP / REUSE / REPLACE
- KEEP (independent of the score, survive the change): SpacedRepetitionEngine, AdaptiveDifficulty
  Engine, mastery logic, streak/freezes.
- REUSE as substrate: DifficultyScorer (difficulty multiplier for MP), SpacedRepetitionEngine.
  priorityScore (drives Sharpness), per-question axis attribution in NumindScoreEngine.axisResults
  (re-pointed to feed MP + readiness instead of the composite).
- REPLACE: NumindScoreEngine.composite() → MP aggregation + Level lookup; radar-as-headline →
  private positively-framed diagnostic feeding "Focus next" + pack readiness.
- This is mostly a re-aggregation over existing attempt history, not new instrumentation.
- UI unwind touches Home, Progress, and Session Summary (the score/radar/tier/subtitle/history
  chart are wired into all three). Plan for that; the engines underneath are reusable.

## 6. DEPENDENCY / RISK
- Scenario/application content is thin (~9% structured; ZERO in insurance, car, student loans).
  The readiness "application" gate and the depth gate are hollow until this content is built.
  Treat scenario content as the highest-priority parallel investment; until then use the
  fallbacks noted in 3.7 / 3.4.

## 7. SOURCES (paraphrased; for traceability)
- Duolingo gamification/retention: trophy.so, trypropel.ai, blakecrosley.com, strivecloud.io
- Zogo (financial-literacy comparator, extrinsic-reward model): zogo.com
- Khan Academy mastery system + depth>breadth research: support.khanacademy.org, blog.khanacademy.org
- Elevate/Peak (paid adult self-improvement, self-progress scores, no leaderboards): apple app store, nibble-app.com
- Self-Determination Theory / overjustification: selfdeterminationtheory.org, yukaichou.com,
  link.springer.com (s11423-023-10337-7), en.wikipedia.org/wiki/Overjustification_effect
- Streak psychology / loss-aversion downside: trophy.so, smashingmagazine.com, marketingmonsters.io
- Financial well-being / overconfidence harm (CFPB, capability literature): cambridge.org,
  sciencedirect.com, springer (s10834-020-09678-9), pmc.ncbi.nlm.nih.gov (Fernandes et al.)
