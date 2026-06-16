# Numind Product Strategy Audit — June 2026

**Lenses:** Senior consumer-fintech PM · Financial-education expert · Learning-behavior specialist
**Scope:** Product loop, curriculum gaps, learning design, gamification/scoring/progression, market analysis, roadmap.
**Basis:** Current implementation (post-Phase 9: 118 lessons / 692 templates / 102 decision items / 10 packs / 12 calculators / two-currency progress model), the June 2026 content audit (`docs/ops/full-content-audit-2026-06.md`), repo data pulls (pack graph, template variety, milestone inventory), and verified market research.
**Constraint honored:** Streaks stay. Everything else critiqued on merits.
**Audience assumption:** US adults 22–40; serious financial micro-learning product, paid (trial → hard paywall). Not a toy math game.

---

## 1. Executive summary

Numind has a **genuinely strong engine wrapped in a presentation layer that undersells it and a structure layer that hides it.**

What's strong is rare: a verified-accurate, template-driven curriculum (the June audit confirmed every 2026 regulatory figure against primary sources); an honest competence model (per-pack Readiness gated on coverage → depth → retention → application) that no competitor has; retrieval-based practice with real spaced repetition; and 102 fact-based "what would you do" decision items. This is the hard part, and it's done.

Three things hold it back:

1. **The most prominent number in the app is the least meaningful.** The Home headline is Level/XP — a currency that tells a 30-year-old nothing about their money and codes the product as a game. Meanwhile Readiness — the genuinely differentiated, decision-scoped signal — is buried in PackDetail. The fix is presentational, not architectural: retire visible XP/Level, promote Readiness and capability counts, keep the XP engine as hidden fuel.

2. **The pack spine is structurally underpowered.** Data: every pack's core is exactly 3 lessons (so "Ready" — the app's central claim — rests on 3 lessons even for *Buying a Home*); only 4 of 118 lessons appear in more than one pack (the cross-pack compounding loop is unused); and **53 of 118 lessons belong to no pack at all** — 45% of the catalog is invisible to the spine the product is betting on.

3. **The category's economics punish "learn finance" and reward "be ready for a decision."** The consumer fin-ed graveyard is real: Long Game shut down (Dec 2023, post-Truist acquisition), Zogo survived only by pivoting B2B to credit unions, Mint died Jan 2024. Standalone willingness-to-pay for financial *education* is weak. Numind's wedge — decision-readiness at life moments, verified accuracy, in-app tools — is the right one, but every surface and metric must keep pulling toward "ready for X," never drift back to "learn stuff, earn points."

**The single biggest untapped advantage:** finance has *real deadlines* — open enrollment (Nov), tax season (Jan–Apr), lease renewals, job offers. No language app has these. Seasonal "moments" should replace any temptation toward leagues/artificial competition: real deadlines beat fake ones, and they're inherently adult.

Overall: the product is ~2 presentation sprints + 1 structural sprint away from being coherent, and the launch-critical path (analytics → onboarding/diagnostic → paywall) is correctly identified. Grade as a serious financial micro-learning product today: **B (engine A−, surface C+)**.

---

## 2. Lens 1 — Product Manager audit

### 2.1 Does the app solve a clear, frequent, painful problem?

**The pain is real but episodic; the app is built daily.** The actual jobs-to-be-done arrive as *moments*: a job offer (every 2–4 years), open enrollment (annual), a lease renewal (annual), a car purchase (every ~6 years), a restaurant bill (daily, but low stakes). The daily-habit framing (workout + streak) is a retention mechanism, not the need itself. That's fine — Duolingo manufactured a daily habit for an episodic goal too — but it means the product must *also* own the moments, or the daily habit feels like homework with no exam date. Today the moment layer exists only as the Tools tab (12 calculators, buried as a tab) and pack names. No calendar awareness, no widgets, no moment-triggered notifications.

**Category evidence demands the decision framing.** Consumer fin-ed apps that sold "learn finance" died or fled to B2B (Long Game: acquired by Truist 2022, discontinued Dec 2023; Zogo: pivoted to selling through banks/credit unions; Mint: shut down Jan 2024). The products that survive sell an *outcome attached to money in motion* (YNAB: control; Robinhood: access; Monarch: clarity). Numind's survivable claim is **"you'll be ready for the decision"** — which is exactly what Readiness measures. The promise and the metric are aligned; the surfaces aren't yet.

### 2.2 Is the core loop compelling enough for repeat usage?

**Micro-loop (one session): strong.** Lesson → quiz → feedback, with wrong answers re-teaching the shortcut (Phase 9C), difficulty-adaptive selection, and misconception-mapped distractors. Production-style free entry on 433 numerical items (not just recognition MCQ) is the right call for skill.

**Meta-loop (why return): designed correctly, paced wrong.** The return motivators are streak (works), Freshness ("N skills to refresh" — works), and Readiness goalposts. But Readiness state changes are rare events (a pack flips state every several days at best) and visible mainly in PackDetail. Between flips, the user sees no movement on the thing that matters. Missing: **intermediate ticks** — per-skill mastery states changing ("Net pay: Mastered ✓"), capability counts ("4 of 6 First Paycheck skills"), gate progress ("1 retention check away"). The ledger exists in the engines; it isn't surfaced as motion.

**Cold start: currently broken by design (acknowledged).** No onboarding → no focus pack → Home's "one next action" has no *why*. The planned diagnostic-as-demo onboarding (goals → adaptive diagnostic → Money Map reveal → paywall) is the fix and is the top launch priority; this audit's job is to make sure what it lands into is coherent.

### 2.3 Are modules/lessons/quizzes/scoring/progression aligned with the promise?

| Layer | Aligned? | Evidence |
|---|---|---|
| Lesson format (concept + shortcut + practice) | ✅ | The decision-first rework (realWorldHint, decision items) landed |
| Quiz engine | ✅ mostly | Adaptive, SRS, honest mastery; one tension: an *estimation* brand graded by exact entry — audit tolerance bands on estimation-framed items |
| Decision items | ✅ | 102 fact-based items, all verified; ceiling: exactly 1 per lesson (see Lens 3) |
| Packs | ⚠️ structurally thin | core=3 everywhere; 4 shared lessons; 53 orphan lessons |
| Scoring | ⚠️ split personality | Engine honest (Readiness gates); headline childish (Level/XP) |
| Worlds tab | ❌ | A quest-map carousel of the *module* taxonomy — the last surviving toy-math surface, and a third competing content map |
| Tools | ✅ underleveraged | Right feature, wrong prominence: it's the moment-of-need surface with no moment triggers |

### 2.4 Where does it feel confusing, shallow, gimmicky, underdeveloped?

- **Confusing:** three content maps (Worlds, Packs, Modules-inside-Learn) for one catalog; three doors to the same review behavior (Recall on Home, Freshness chip, refresh-first Workout); five Readiness states where two ("Ready" vs "Sharp") are user-indistinguishable.
- **Shallow:** practice variety inside lessons — `tipAmount` is the formula behind 7 templates, `costPerUse` behind 5, `creditCardMonthlyInterest` behind 5, `paycheckNet` behind 5. Same computation, reworded prompt = massed repetition that feels like padding (June audit's #1 quality finding).
- **Gimmicky:** XP popcorn per answer; level-up celebrations at L3/L5/L8...; mascot emoji on world pages; quest-map metaphor. None of it survives contact with a 35-year-old comparing you to Oura.
- **Underdeveloped:** the moment/calendar layer (nothing); capability messaging ("you can now read a job offer" appears nowhere); pack completion payoff (no artifact, no credential); the 53-lesson library tier (no honest "Browse" home).

### 2.5 Prioritize / simplify / remove / expand

→ Consolidated in §7 (risks), §10 (roadmap), §12 (remove list). Headline calls: **prioritize** the truthful-surface rework + pack re-weave before the onboarding ships (the funnel should sell the fixed product); **simplify** review into one "Refresh" concept; **remove** visible XP/Level and the quest-map framing; **expand** packs to cover orphans, decision-item depth, and the seasonal moment layer.

---

## 3. Lens 2 — Financial-education audit: curriculum and concept gaps

**Accuracy and currency are not the issue** — the June 2026 audit verified every regulatory figure against primary sources (IRS Rev Proc 2025-32, Notice 2025-67, SSA, ED — including the Parent PLUS 9.07% published the morning of the audit) and fixed the single confirmed factual error (grace-period capitalization). The cadence + registry + `ContentInvariantTests` guard are genuine moats. This section is about **what's missing**.

The existing 118 lessons cover the prompt's "commonly misled" list well: pricing psychology (`concept_shopping_manipulation`), subscription audit (`subscription_math`), BNPL (`debt_bnpl_hidden_cost`), interest/fees/discounts/tipping math, debt repayment, credit scores, taxes, insurance, investing basics — all present and audited. The real gaps cluster around **harm avoidance, income events, and consumer-rights mechanics**:

### Tier 1 — build next (frequency × harm × format fit)

1. **Fraud & scam patterns (P2P/imposter/crypto-ATM)** — *the highest-harm gap in the app.* FTC-reported consumer fraud losses run $10B+/yr, and adults 20–29 report losing money to fraud *more often* than seniors. Zero coverage today. Perfectly fact-based decision items: "Your 'bank' calls about fraud and asks you to Zelle yourself the money back — what do you do?" (Never — banks don't ask that.) Teach the patterns (urgency, secrecy, unusual payment rails: gift cards, wire, crypto ATM), not reimbursement rules (volatile). Module: new lessons in Debt/Budgets + a "Protect Your Money" pack anchor. *Why it fits Numind:* pattern recognition under pressure is exactly a reps product.
2. **Salary negotiation math** — every 2–4 years for this demographic, with compounding lifetime payoff; the app teaches offer *comparison* (`offer_compare_d3`) but not negotiation itself. Teach: never give the first number when avoidable; counter on total comp; the $5k-at-28 compounding frame; "I need to think it over" as a script. Mix: 2 numerical (comp-delta, compounding) + 2 decision items. Module: Salary; pack: a "Job Offer" moment.
3. **Job-change money checklist (401(k) rollover)** — median US tenure ~4 years, so this hits the 22–40 user constantly; **41.4% of departing employees cash out their 401(k)** (UBC Sauder/HBR study of 162,360 separations), ~90% of them entirely — usually a five-figure lifetime mistake. Teach: the four options; the 20%-withholding indirect-rollover trap (mental-math native!); vesting timing (cross-link existing `salary_401k_vesting`); HSA portability; COBRA window. Fact-based, evergreen mechanics.
4. **Payday / title / cash-advance (EWA) loans + overdraft math** — ~12M Americans use payday loans yearly, skewing exactly to the financially anxious segment. The math is the app's core competency: "$15 per $100 for two weeks" → ~391% APR; a $35 overdraft on a $6 coffee → what effective rate? Tone matters (no shaming; teach the alternatives ladder: credit-union PALs, EWA caveats, negotiated payment plans). Module: Debt & Loans.
5. **Credit-report hygiene: free weekly reports, disputes, freezes** — pure fact-based, high leverage, zero math: AnnualCreditReport.com is free weekly (made permanent), freezes are free by federal law (2018), error rates are material, disputes are a defined FCRA process. Complements `concept_debt_credit_scores`, which teaches the *score* but not the *report rights*. One concept lesson + decision items.

### Tier 2 — next wave

6. **Tipflation decisions** — the June audit found the three tip lessons carry *zero* decision items (the math is there, the judgment isn't). Add the decision layer: pre/post-tax tipping, counter-service 20/25/30% screens, auto-gratuity double-tip catch. Closes an audit gap and a curriculum gap in one move.
7. **Shrinkflation & unit pricing** — weekly grocery exposure; $/oz comparison is native mental math; Smart Shopping module is the obvious home.
8. **Debt-collection rights + medical-debt rules (FDCPA)** — validation letters, the statute-of-limitations re-aging trap ("a $50 'good-faith' payment can restart the clock"), and medical-debt credit-reporting changes (teach the dispute *process*; hedge the thresholds — policy in flux). Pairs with the excellent `insurance_medical_bill_eob`.
9. **Co-signing & authorized users** — fact-based: co-signing = full liability + DTI hit on *your* mortgage application; authorized-user piggybacking as the legitimate credit-building variant.
10. **Subscription dark patterns & cancellation rights** — extends `subscription_math` from arithmetic to defense: roach-motel flows, trial-to-paid conversion by default, "pause instead" retention scripts. Teach the *patterns*, not the rule: the FTC's click-to-cancel rule was **vacated by the Eighth Circuit (July 2025)** and the FTC restarted rulemaking in Jan 2026 — rights currently vary by state. (Numind itself is a trial product; teaching this honestly is a brand asset, and our own cancellation flow must be clean.)
11. **Mortgage refinance & points break-even** — episodic but high-value; break-even months = closing costs ÷ monthly savings is mental-math native; rate environment keeps it queried.
12. **Renters insurance** — majority of renters uninsured at ~$15–25/mo; tiny fact lesson; slots into First Apartment pack (whose core app-gate is healthy but thin).

### Tier 3 — opportunistic

13. **529s + the SECURE 2.0 529→Roth rollover** (parent-aged end of the demo; genuinely exciting fact), 14. **variable-income budgeting** (gig/1099 — extends `salary_side_hustle`), 15. **beneficiary designations** ("the form that overrides your will" — one-screen fact lesson).

### What NOT to add (mission guardrail)

Stock-picking, crypto trading mechanics, credit-card churning optimization, "beat the market" content, individualized allocation advice. All YMYL-risky, all attract the wrong user, all rot fast. The existing behavioral-traps + index-fund framing is the correct ceiling for investing content.

---

## 4. Lens 3 — Learning-behavior audit

### What's working (genuinely, not politely)

- **Retrieval is the medium** — the app teaches by quizzing, not by video-then-quiz. 433 free-entry items are *production* practice, which beats recognition for durability.
- **Real spaced repetition** with an interval ladder to 30/60 days, mastery requiring ≥1 correct medium/hard item, and honest decay isolated to Freshness (not to achievements). Most consumer apps fake this; Numind doesn't.
- **Misconception-mapped distractors** (the June audit's consistent strength finding) make wrong answers diagnostic — each distractor names a real belief ("carry a balance to build credit").
- **Wrong-answer re-teaching** (shortcut + worked example on miss) closes the feedback loop properly.
- **Difficulty pyramid** is sane: 192 easy / 302 medium / 198 hard (28/44/29%).

### Where it fails the durability test — seven specific weaknesses

1. **Massed sameness masquerading as practice.** When 5–7 templates in a lesson share one formula (`tipAmount` ×7, `costPerUse` ×5), the learner is doing the same retrieval with cosmetic re-skins — that's *massed* practice, which feels productive and decays fast. Variability (different surface forms, directions, reverse-solves) is what drives transfer. Fix: the dedup program isn't just content hygiene, it's learning design — convert clones into break-evens, reversals ("what bill makes a $12 tip 20%?"), and comparisons.
2. **Blocked first exposure, interleaving only later.** Lessons are topic-blocked (correct for first learning) but nothing interleaves until the Daily Workout. Cheap, high-yield fix: every lesson session ends with **one item from a previous lesson** ("while you're here…"). One line of session-composition code; large retention literature behind it.
3. **A transfer ceiling at exactly one decision item per lesson.** 102 decision items is a real achievement, but one scenario per lesson = one surface form of the judgment. The skill the app sells (recognizing the decision *in the wild*) needs the same decision in 2–3 different costumes. Target: decision-relevant lessons grow to 2–3 scenario variants over time (same fact, different context — the audit's fact-based bar still applies).
4. **No application beyond the screen.** The app never asks the user to touch *their own* money. The highest-value behavioral mechanic available: **missions** — "Open your latest pay stub; find the FICA line; is it ≈7.65%?" / "Check one subscription's renewal price against what you signed up at." Self-reported, optional, privacy-clean (no account linking), and they convert knowledge into the first real-world rep. (Guardrail: missions earn acknowledgment, never Readiness — self-report can't gate an evidence-based claim.)
5. **No confidence calibration.** Users never predict before they see. Adding "How sure are you?" (3-tap: sure / think so / guessing) on decision items, then showing a calibration readout in Progress ("when you said *sure*, you were right 92%") builds the metacognition that prevents overconfident money decisions — *the* failure mode a YMYL product should care about. It's also a differentiated, adult progression dimension no competitor has. (The capstone predict-then-see concept from the Phase 5 spec — generalize it.)
6. **Concept lessons front-load text.** Several concept blocks are walls (the audit flagged `money_math_sinking_funds` at ~5 funds in one breath). The pretesting/generation effect says: open with the question *before* the teaching. Restructure concept lessons to question-first — ask the decision cold, let them commit, then teach. (Brilliant's entire format; see §9.)
7. **Adaptive difficulty isn't tuned to a success band.** Mastery/SRS logic is solid, but nothing holds users in the desirable-difficulty zone (~80–85% session success). Below that, frustration; above it, illusion of fluency. The DifficultyScorer has the signal; add the thermostat.

### Sequencing & feedback verdicts

Within-module hand-ordering is fine; the soft-lock removal (adults can jump) is correct. The missing sequencing layer is the **pack as suggested order** — which the onboarding will supply. Feedback is immediate and explanatory; the gap is *delayed* feedback at the session level (the Session Summary recaps, but doesn't say "the one thing to remember tomorrow" — add a single takeaway line, spaced-echoed in the next day's workout intro).

---

## 5. Gamification & scoring critique (deep dive)

Inventory of the current system and a verdict on each:

| Mechanic | Current state | Verdict |
|---|---|---|
| **XP** (10/15/25 by difficulty, monotonic, milestone bonuses) | Earned per correct answer, shown as popcorn + totals | **Engine: keep. Display: retire.** Difficulty-weighted effort is the right internal fuel (workout sizing, ring pacing, depth gate). As a *visible* number it's abstract calories — communicates nothing practical (the founder's own critique, validated). |
| **Level** (ladder, depth-gated >L8) | Home headline, BrandHeader ring, celebrated at 3/5/8/10/12/15 | **Retire from UI.** "Level 7" answers no user question. The depth gate (anti-easy-grinding) was clever engineering for an honest level — but if no level is shown, the gate's job is done by Readiness's depth gate anyway. |
| **Per-pack Readiness** (Not started → Learning → Almost ready → Ready → Sharp; 4 evidence gates) | Computed honestly; surfaced in PackDetail, Home headline count, Progress board | **The crown jewel — promote to hero.** Three fixes: (a) *cheap Ready*: every core is 3 lessons, so the app's strongest claim rests on its thinnest evidence — size cores to stakes (3–4 for Everyday Spending; 5–6 for Buying a Home, Open Enrollment); (b) *mute states*: "Ready" vs "Sharp" is user-meaningless — define Sharp as "Ready + fresh + applied" or fold it; (c) *invisible gates*: "Almost ready — 1 retention check away" should follow the pack everywhere, not live in detail view. |
| **Freshness** (SRS-derived staleness; restorable) | "N skills to refresh" chip; refresh-first workout | **Keep — best-named mechanic in the app.** Consolidate its three doors (Recall, chip, workout) into one "Refresh" concept. Tie copy to stakes: "Paycheck math fades before open enrollment." |
| **Streak** (+ freezes, rest day) | Daily Workout completion; forgiving economy | **Stays (constraint) — and deserves to.** The freeze/rest-day design is already the adult version. Avoid: guilt-tier notifications, paid streak repairs (subscription perk only), streak as identity. |
| **Milestones** (firstSession, 5/10 sessions, week/2-week streak, accuracyJump, **levelUp**, moduleCompleted, firstFreeze) | Celebration triggers | **Rebuild around capability.** Session-count and levelUp milestones celebrate *volume*. Replace with: first skill mastered, first pack Ready, first refresh save, first calibrated week, 3 packs Ready. moduleCompleted → packCompleted. |
| **7-axis radar** | Private diagnostic + Progress coverage map | **Correctly demoted — keep private.** It answers "where should I go next," not "how good am I." Never headline it again. |
| **Badges** | Volume badges retired in 9F; remnant inventory minimal | **Replace the concept with credentials** (§6: Readiness Cards). Adults don't want stickers; they want proof. |

**Does the current model communicate meaningful growth?** Readiness does; nothing else on screen does. **Does it motivate the right behavior?** The *engine* does (you can't grind easies to mastery; decay only touches Freshness). The *display* motivates XP-watching. **Can users tell what they're improving at?** Only by opening PackDetail. That's the gap: the answer to "what am I better at than last month?" should be one glance — "you can now read a paycheck, compare two job offers, and pick a health plan. 3 skills need a refresh."

**One score vs. dimensions vs. badges vs. mastery vs. leagues?** The honest architecture is already chosen and right: **scoped competence states (Readiness) + per-skill mastery + one habit metric (streak) + one decay metric (Freshness)**. No global score (Phase 9 killed it for cause — unvalidatable in YMYL), no leagues (below), badges → credentials, mastery levels per *skill* not per *user*.

---

## 6. Recommended scoring & progression model

Three visible layers, one hidden engine. Every visible number must answer *"what does this let me do?"*

### Layer 1 — Today (habit): streak + goal ring
A daily goal ring (Apple Fitness grammar) fills as the workout completes — fueled invisibly by the XP engine (so harder questions fill it faster, preserving the difficulty incentive without showing points). Streak + freezes unchanged. Session summary shows the ring closing, skills that moved, and one takeaway line. **No "+15 XP" anywhere.**

### Layer 2 — Skills (growth): mastery states + capability counts
Per-skill (lesson) states surfaced everywhere lessons appear: `Learning → Mastered → Needs refresh`. Aggregated as capability counts scoped to packs — "**5 of 6 First Paycheck skills**" — never against the global denominator (5/118 demotivates; 5/6 motivates). The Progress tab becomes a **skills ledger**: what you can do, what's fading, what's next (radar stays as the private "what's next" input). Later: the calibration readout joins this layer.

### Layer 3 — Decisions (meaning): Readiness + Readiness Cards
Readiness is the Home headline: focus-pack state + the named missing gate ("**Almost ready** — one retention check away"). State changes are THE celebration moments. On Ready, the user earns a **Readiness Card** — a clean, dated, shareable credential ("Open Enrollment — Ready · Nov 2026") collected in a wallet. Cards are the badge replacement: they assert something true and useful, they're inherently screenshot-able (organic acquisition), and they create the renewal hook ("next decision?"). Sharp = Ready + fresh + applied (or cut it).

### Hidden engine (unchanged in role, invisible in UI)
XP/difficulty weighting (fuels ring, sizes workouts), SRS priority (Freshness, retention gate), 7-axis coverage (recommendations), DifficultyScorer (+ new success-band thermostat).

### Credibility rules (the constitution)
1. No global 0–100 anything, ever. 2. **Ready is never granted without retention evidence** — not by the diagnostic, not by a streak, not by purchase. 3. Decay touches only Freshness. 4. Celebrate capability, never volume. 5. Every visible number answers "what does this let me do?" 6. Social comparison: none (see leagues, §9).

### Migration notes (concrete)
`MilestoneEngine.levelUp` → capability triggers; `BrandHeader` LevelRing → goal ring; Home headline → focus-pack Readiness; Session Summary "+X XP" → ring fill + skills moved; `celebratedLevels` deleted; depth-gate logic retires with visible Level (Readiness depth gate already owns anti-grind). Engines (`MomentumEngine` et al.) untouched.

---

## 7. Top product risks (ranked)

1. **Conversion risk — hard paywall with an unfelt product.** CalAI-style end-of-onboarding paywall means the diagnostic + Money Map reveal carry 100% of the value demonstration. If the diagnostic feels like a quiz instead of a demo (live ring/skill ticks, shortcut reveals, honest placement), trial starts die. *Mitigation:* diagnostic-as-demo quality bar; reveal shows capability language, not points; ship the truthful surface (§6) **before** the funnel so the paywall screenshots sell the adult product.
2. **Retention risk — daily habit on an episodic need.** Post-trial churn will concentrate where users feel "done" with their moment. *Mitigation:* seasonal moments calendar (open enrollment, tax season), Freshness as the honest comeback reason, second-pack recommendation at Ready, Year-in-Money recap.
3. **Category risk — the fin-ed graveyard.** Long Game dead, Zogo B2B, Mint dead. WTP for "learn finance" is weak. *Mitigation:* never market learning; market readiness ("walk into open enrollment knowing exactly what to pick"). Price against the cost of one bad decision, not against Duolingo.
4. **Credibility risk — one wrong number or one tacky mechanic.** The accuracy moat (registry, cadence, invariant tests, citations) is strong but annual-churn is forever; and a single childish surface (XP confetti) undercuts the "verified, serious" positioning the content earns. *Mitigation:* build the stale-content CI check (deferred task #122); apply §6's constitution; Robinhood's confetti retreat is the cautionary precedent.
5. **Structural risk — the spine doesn't carry the catalog.** 53 orphan lessons + 3-lesson cores + 4 shared lessons = the pack model the onboarding will sell is currently a façade over a module app. *Mitigation:* pack re-weave sprint (§10, P0) before the funnel ships.
6. **Sequencing risk — flying blind into funnel decisions.** Analytics (PostHog/Sentry) is parked in Phase 8 Group D *behind* the funnel work it should instrument. *Mitigation:* pull analytics forward; no A/B-able funnel without it.

---

## 8. Market & competitive analysis — patterns worth stealing (and refusing)

| App | Mechanic | Why it works | Fit for Numind | Adaptation / Avoid |
|---|---|---|---|---|
| **Duolingo** | Streak + freeze economy | Loss aversion on an identity habit | ✅ already adopted, adult-ified | Avoid guilt-tier notifications, paid streak repair |
| **Duolingo (2025)** | Hearts → **Energy** (depletes per exercise, even correct ones) | It "works" for freemium monetization — and triggered mass user revolt | ❌ **anti-pattern** | A paid product must never meter practice. No lives, hearts, energy, ever. The backlash is the proof. |
| **Duolingo** | Leagues/leaderboards | Competition drives time-on-app | ❌ | Money + public comparison = shame; small-N cold start = dead leagues; optimizes minutes, not competence. **Replace with seasonal moments: real deadlines beat fake ones.** |
| **Brilliant** | Question-first lessons (commit before taught), no grades | Generation/pretesting effect; respects adult intelligence | ✅✅ | Direct steal for concept-lesson rework (§4.6) |
| **Khan Academy** | Per-skill mastery levels (Familiar→Proficient→Mastered) + mastery challenges that can *demote* | Skill-scoped, evidence-based, decays honestly | ✅ | Numind's mastery+Freshness already mirrors it — adopt the *legible naming*, surface states everywhere. Note: Khan's energy-points era quietly died — points don't carry serious learning. |
| **Elevate** | Per-domain proficiency scores + percentile vs peers | Adults accept skill dimensions when domain-scoped | ⚠️ half | Keep domain-scoped progress (coverage map). **Refuse percentiles** — peer comparison on money knowledge reads as judgment. |
| **Oura / Whoop** | "Readiness/Recovery" — a daily state score that *prescribes today's plan* | A score earns trust by driving a recommendation, not by existing | ✅ grammar already used | Freshness+workout = same grammar. Avoid their pseudo-precision (0–100 vibes) — states > numbers. |
| **Apple Fitness** | Rings — one glanceable daily goal | Closure instinct; adult, premium, zero cartoon | ✅✅ | The Layer-1 replacement for XP counters (§6) |
| **Strava** | PRs/segments (self-competition) + annual recap | Compete with yourself; the recap is organic-share gold | ✅ partial | **Year-in-Money recap** ("3 decisions Ready, 41 skills, $-framing of what you can now navigate") in December. Skip speed-PRs — speed was deliberately de-emphasized (7a). |
| **YNAB** | "Age of Money" — one derived metric with real meaning; method-as-brand (Four Rules) | Metrics derived from *your reality* beat abstract points; a named method is teachable identity | ✅ principle | Readiness Cards are the analog. Consider naming the method (e.g., "Estimate → Decide → Verify") in onboarding copy. |
| **Robinhood** | Confetti, gamified discovery → then removed under scrutiny | Juice on money actions reads as manipulation once trust matters | ❌ anti-pattern | The precedent for stripping XP popcorn *before* anyone writes the think-piece. |
| **Monarch / Copilot** | No gamification; clean adult aesthetic as the differentiator | Their absence-of-game *is* positioning | ⚠️ | Numind keeps mechanics (it's a learning product) but must *dress* at Monarch's level. |
| **Headspace** | Streaks reframed as "consistency," minimal stats, content-led return | Tone: warm, zero pressure | ✅ tone | Borrow notification voice: invitations, not debts. |
| **Coinbase Earn** | Learn-to-earn (paid quiz completion) | Mercenary engagement | ❌ | Attracts reward-farmers, cheapens content, regulatory smell. Zogo's consumer app leaned on this and ended up B2B. |
| **Noom / CalAI** | Long personalization funnel → plan reveal → paywall at peak investment | Sunk cost + personalized promise | ✅ already adopted | Avoid their dark-renewal patterns (Noom's FTC-adjacent settlements) — especially since Numind *teaches* dark patterns. Our cancellation flow must be the counter-example. |
| **Chess.com** | Elo rating | A number adults trust because it *predicts outcomes* | Principle only | The lesson: credibility = predictive validity. Readiness is Numind's Elo — pass/fail against evidence. Don't invent a rating that predicts nothing. |

**The synthesis:** every serious-adult product that wins (Oura, Whoop, Strava, Khan, Brilliant, YNAB) anchors progress in **meaningful, scoped, evidence-bearing states** and keeps points invisible or absent. Every cautionary tale (Duolingo energy, Robinhood confetti, learn-to-earn) is a *visible abstract currency* getting between the user and the thing they came for. Numind's Phase 9 architecture already chose the right side; the UI hasn't finished moving.

---

## 9. Prioritized roadmap

**P0 — "Truthful surface + honest spine" (do first, ~1–2 sprints, mostly UI + packs.json)**
1. Retire visible XP/Level → goal ring + capability counts + Readiness-led Home (§6 migration notes).
2. Pack re-weave: place the ~53 orphans (most have obvious homes — `car_down_payment`→Car Buying, `concept_investing_*`→Investing Starter, disability/policy-priority→Open Enrollment or a new Protection pack); size cores to stakes (3–6); deliberately share load-bearing lessons across 2–3 packs; fix `everyday_spending`'s 1-app-item core gate.
3. Consolidate review: one "Refresh" concept (absorb Recall + chip + workout-refresh framing).
4. Readiness copy: capability sentences + named missing gate on every pack surface.
5. Worlds → demote to "Browse topics" library (or cut the carousel; keep theming in Learn).

**P0.5 — "Measurement before funnel"**
6. PostHog + Sentry (pull Phase 8 Group D forward). Define the activation metric now: **first pack Ready within 7 days** (with re-sized cores, tune so the median committed user can hit it).

**P1 — "Front door + paywall" (the launch block, already ideated)**
7. Onboarding funnel: goals→packs intake → adaptive diagnostic-as-demo (ring + skill ticks live, shortcut reveals; seeds Level-equivalents internally and pack states, **never Ready**) → Money Map reveal → account → trial paywall (CalAI placement).
8. RevenueCat + auth + hard-paywall states; notifications v1 (streak voice = Headspace, not debt collector).

**P1.5 — "Learning depth" (parallelizable content/engine work)**
9. Question-first rework of the ~20 talkiest concept lessons (Brilliant pattern).
10. Calibration v1: sure/think/guessing taps on decision items + Progress readout.
11. Dedup batch 1 (the ×7/×5 formula clones → break-evens, reversals, comparisons) + tip decision items + the June audit's P1 fixes (flat-rate car interest, `ins_premium_scenario_d2` range bug, W-2/1099 contradiction, "123%" display).
12. Interleaving: one prior-lesson item per lesson session; success-band thermostat (80–85%).

**P2 — "Curriculum wave 1 + moments"**
13. Tier-1 gap lessons: fraud/scams, salary negotiation, job-change/rollover, payday/overdraft, credit-report hygiene (+ a "Protect Your Money" pack).
14. Seasonal moments engine — **ship before September 2026** to catch open enrollment (Nov): time-boxed featured pack + targeted notifications + a dated Readiness Card. Tax season (Jan–Apr 2027) second.
15. Readiness Cards + wallet; second-pack recommendation at Ready.

**P3 — "Behavior + breadth"**
16. Missions (IRL application, ack-only credit); Year-in-Money recap (Dec); decision-item depth (2–3 variants on top lessons); curriculum wave 2 (tipflation/shrinkflation if not pulled earlier, FDCPA, co-sign, refi, renters, 529, variable income); Sharp tier definition or removal; stale-content CI (deferred #122).

---

## 10. Concrete product recommendations (the punch list)

1. Make Readiness the Home headline; Level/XP disappear from UI the same sprint.
2. Goal ring (XP-fueled, invisible fuel) replaces all point displays; milestones rebuilt on capability triggers.
3. Re-weave packs: no orphan lessons without a deliberate "library" decision; cores sized 3–6 by stakes; ≥20 lessons multi-pack so progress visibly compounds.
4. Diagnostic seeds placement and pack states but can never grant Ready (constitution rule #2).
5. Calibration taps on decision items; calibration readout as the adult flex metric.
6. One "Refresh" concept; copy ties staleness to upcoming real moments.
7. Readiness Cards as the badge system; dated, shareable, wallet-collected.
8. Seasonal moments as the competition replacement; open enrollment 2026 is the deadline that matters.
9. Question-first concept lessons; one interleaved review item per session; 80–85% success thermostat.
10. Curriculum: ship fraud-patterns and job-change/rollover before anything else new — highest harm × frequency for 22–40.
11. Estimation-tolerance audit on freeEntry grading (estimation brand ↔ exact-entry tension).
12. Tools tab gains moment triggers (calculator suggestions inside relevant packs/seasons; widget later).
13. Cancellation flow must be the industry counter-example (we teach dark patterns; we cannot run one).
14. Build the stale-content CI check; the registry is only as good as its enforcement.

## 11. What to remove, simplify, or avoid

**Remove:** visible XP numbers + Level + level-up celebrations (`celebratedLevels`); session-count milestones; Worlds quest-map framing + mascot emoji on adult surfaces; the ~30–40 formula-clone templates (fold into varied items); the two cartoon distractors flagged in June (50% cap-gains tax, wage garnishment).

**Simplify:** review entry points (3→1); Readiness states (define Sharp or cut to four); Home to ring + focus pack + refresh chip + streak; pack detail gate language to plain verbs ("practiced / proven / still fresh / applied").

**Avoid (standing list):** leagues/leaderboards/percentiles; energy/hearts/lives or any practice meter (Duolingo 2025 is the cautionary tale); learn-to-earn; a global 0–100 score of any name; confetti-grade juice on money outcomes (Robinhood precedent); paid streak repair; AI-generated content (existing rule); dark renewal/cancellation patterns (Noom precedent — and we *teach* this); diagnostic-granted competence; stock-picking/crypto-trading/churning curriculum.

---

## Sources (market & regulatory claims)

- Eighth Circuit vacatur of the FTC click-to-cancel rule (July 2025) and restarted rulemaking (Jan 2026): [WilmerHale](https://www.wilmerhale.com/en/insights/client-alerts/20250801-eighth-circuit-vacates-the-ftcs-click-to-cancel-rule-but-federal-and-state-regulators-likely-to-remain-active), [Crowell & Moring](https://www.crowell.com/en/insights/client-alerts/clicking-all-the-right-boxes-ftc-moves-to-revive-click-to-cancel-rule-following-eighth-circuit-vacatur), [Gibson Dunn](https://www.gibsondunn.com/ftc-restarts-negative-option-rulemaking-after-eighth-circuit-vacatur-enforcement-under-rosca-continues/)
- Duolingo hearts→energy backlash (2025): [Android Authority](https://www.androidauthority.com/quitting-duolingo-energy-system-3599842/), [Class Central](https://www.classcentral.com/report/duolingo-breaks-hearts-for-energy/), [duoplanet](https://duoplanet.com/duolingo-energy-system/)
- 41.4% 401(k) cash-out at job separation (UBC Sauder / HBR, 162,360 employees): [UBC Sauder](https://www.sauder.ubc.ca/news/insights/americans-are-cashing-out-their-retirement-savings-alarming-rate-study), [SmartAsset summary](https://smartasset.com/retirement/harvard-business-review-cashout-401k)
- Long Game discontinued post-Truist acquisition: [Banking Dive](https://www.bankingdive.com/news/truist-buys-gamified-finance-app-long-game/623089/), [Fioney](https://fioney.com/long-game-review/); Zogo's B2B model: [zogo.com](https://zogo.com/)

*Companion docs: content accuracy → `docs/ops/full-content-audit-2026-06.md`; scoring model spec → `docs/product/scoring-system-research.md`; onboarding ideation → session notes (June 2026), to be formalized in `docs/product/onboarding-funnel.md`.*
