# Onboarding Funnel v2 — decision-first (Phase 11 baseline)

> **Status:** Built as a testable baseline (June 2026). RevenueCat purchase,
> Supabase auth, and real notification scheduling remain stubs. This doc is
> the as-built spec; iterate copy/order here, then sync the build.

## What changed from v1 (the "math app" funnel)

v1 sold mental-math self-improvement ("Real math. Real life.", screen-time
guilt, 37.8× kaizen, LVL 1–3 diagnostic badge). v2 sells **decision
readiness**: the user picks a real upcoming life moment, the diagnostic
demos the actual product (shortcut reveals, live goal ring, capability
language), and the paywall closes on "be ready for [their moment]".

Three structural changes:
1. **Topic picker → Life-Moment Picker.** The 12 Life-Event Packs wearing
   real-life names ("A job offer or salary talk"). First pick = focus pack
   (set live on Home at completion); up to 2 secondaries.
2. **Diagnostic → diagnostic-as-demo.** Pack-weighted questions, a shortcut
   reveal card after EVERY answer, the goal ring filling live, one
   "what would you do" decision item last. No grades, no flash-and-move-on.
3. **Results → Money Map.** The LVL badge is dead. Per-core-skill placement
   (Solid start / Shaky / New to you) + the honesty line: "Nothing here is
   Ready yet — Ready is earned. Most apps hand out badges. We don't."

## Screen-by-screen (27 screens, anonymous throughout)

| # | Screen | v1 → v2 | Signal collected |
|---|--------|---------|------------------|
| 1 | Welcome Hook (dark) | "Money decisions don't wait." Value props: decision-sized sessions / the moments / honest progress | — |
| 2 | Social Proof (dark) | "2 in 3 adults say money is a significant source of stress" (APA Stress in America) + "nobody showed them the 20-second version of the math" | — |
| 3 | Moments Framing | NEW frame: "You don't need a finance course. You need to be ready on the day it happens." | — |
| 4 | Insecurity Mirror (question→reveal) | NEW, replaces screen-time. "Which of these have happened to you?" → verified cost reveal (41% 401(k) cash-out, $24B unclaimed match, $4.5B FSA forfeited) | `feltMoments` |
| 5 | Confidence | "When a money decision lands on you, how do you handle it?" (freeze / muddle / second-guess / sharp) | `confidenceLevel` |
| 6 | Motivations | 7 money-decision outcomes (stop leaving money on the table, stop getting taken, …) | `motivations` (≤3) |
| 7 | Life-Moment Picker | NEW keystone. 12 packs as moments; first = focus (badged "YOUR FOCUS") | `focusPackId`, `secondaryPackIds` |
| 8 | Mirroring | Pack-keyed stakes headline + motivation/feltMoment bullets | — |
| 9 | The Deadline (dark) | NEW. Dated moments: real countdown (Open enrollment Nov 1, Tax day Apr 15 via `MomentsRegistry`). Undated: cost-of-waiting | — |
| 10 | Time Commitment | Same 4 cards; output = daily ring target (5/8/10/12 questions) | `dailyMinutes` |
| 11 | Kaizen (dark) | Hours/yr stat kept; 37.8× replaced with "every moment this year, met prepared" | — |
| 12 | ADHD | KEPT (TikTok-acquired 22–40 audience skews high-ADHD; product shape genuinely fits). "decision-sized sessions" supportive line; EndeavorOTC stat unchanged | `adhdStatus` |
| 13 | Name | unchanged | userName |
| 14 | Age | unchanged | `ageRange` |
| 15 | Diagnostic Intro | "where you stand on [pack]"; chips: ~3 min / No grades / Shortcuts; "we'll show you the shortcut behind every question — that's the product" | — |
| 16 | Diagnostic-as-demo | ~5 focus-core ladder (1 easy entry → d2/d3) + 2 secondary + 1 application item last. Shortcut reveal card after each answer (lesson placement word + THE SHORTCUT). GoalRing fills per question answered | `diagnosticResults` (with `lessonId`) |
| 17 | Preparing (dark) | steps: mapping moments / placing skills / building readiness plan | calibration runs |
| 18 | Money Map | Focus card ("N core skills stand between you and Ready; starting strong on M"), per-skill placement rows + beads, secondary chips, honesty card | — |
| 19 | Personalized Plan | Ring card (anything counts) + Path card (4 named gates: learn → prove → hold → apply) + DATED timeline ("Ready around Oct 18, before Nov 1") | — |
| 20 | Payday Capture | Moved before the notifications ask (strongest permission case). For "twice a month," a second day-of-month is captured explicitly. "When do you get paid?" — cadence cards (weekly/biweekly/semimonthly/monthly) + most-recent-payday date + prominent Skip. "We'll time your sessions to your money." | `paycheck` (PaycheckSchedule, optional) |
| 21 | Notifications | Mocks: open ring / fading skills (Freshness) / moment countdown | permission |
| 22 | Paywall Priming | Coffee anchor vs Numind/WEEK ($3.99 < one coffee); Quick Math → verified mistake costs (401k cash-out −$2,000+, unclaimed match, FSA forfeits) vs $29.99/yr annual plan. Pricing: $3.99/wk or $29.99/yr (save 85%) | — |
| 23 | Streak Goal | "How many days in a row will you close your ring?" 7 recommended (past-trial lever) | `streakGoal` |
| 24 | Projection (dark) | Capability rows: skills at solid / questions practiced / **on track to** Ready by date / first refresh. Badge-flex row deleted | — |
| 25 | Trial Reminder | unchanged (trust counterweight) | `trialReminderDays` |
| 26 | Paywall | Feature list → 12 paths · 134 skills / Readiness / 12 calculators / refresh + streak protection / moment alerts. RevenueCat TODO | — |
| 27 | Welcome Confirm | "[Pack] is your focus. Let's close your first ring." Pills: min/day · ring target · ring streak. CTA "Start today's workout" | completion |

**Account creation (Sign in with Apple via Supabase) slots between 25 and 26
when auth ships** — anonymous until maximum sunk cost, account framed as
"save your Money Map."

**Personalization is visible (post-feedback pass, June 2026):** the
insecurity-mirror reveal shows one verified cost stat PER selected felt
moment, tagged "You said · [their words]"; the mirroring screen's bullets
carry "You picked · [their card]" tags; motivation cards share one accent
color (selection ≠ theme rainbow); in the life-moment grid only the FOCUS
carries its pack color — secondaries get a neutral check. Age buckets:
Under 18 / 18–24 split (was 13–24).

**Habit-buyer copy branch (Phase 12):** when `focusPackId == "everyday_spending"`
or motivations include `.staySharp`, Kaizen and Projection render the
fluency-ladder variant ("Week one, tips stop needing your phone. Month one,
you read a paycheck like a native.") — selling 5 min/day of compounding
fluency instead of a dated moment.

## Signals model (v2)

`OnboardingSignals`: `feltMoments` (new), `confidenceLevel`, `motivations`
(enum rewritten), `focusPackId` + `secondaryPackIds` (replace
`topicInterests`), `dailyMinutes`, `adhdStatus`, `ageRange`, `streakGoal`,
`trialReminderDays`, `diagnosticResults` (+`lessonId` per result),
`startingDifficulties`, `recommendationPriority`, `paycheck` (Phase 12: cadence + anchor date for payday-anchored sessions; also editable in Profile), `leaseRenewalMonth` (optional). `Aspiration` deleted —
the moment IS the aspiration. `completeOnboarding()` sets the focus pack
live on ProgressStore.

## Honesty constraints (non-negotiable)

- Diagnostic results never create SessionRecords → Readiness stays earned.
  The Money Map uses placement language only (Solid start ≠ mastered).
- Projection says "**on track to** Ready", never "Ready by" as a promise.
- No XP, points, levels, or confetti anywhere before screen 27's one-time
  arrival moment.
- Stat claims use figures verified in `search-demand-research-2026-06.md`
  / the regulatory-constants registry; the APA money-stress stat needs a
  final citation pass before App Store screenshots.

## Analytics

`onboarding_step_viewed(step)` on every advance, `diagnostic_started
(focus_pack)`, `onboarding_completed(focus_pack, streak_goal)` — funnel
drop-off per screen is the first dashboard to build once PostHog keys land.

## Open ideation questions for testing

1. Screen count: 27 is CalAI-length; test cutting 3/12 (framing/kaizen)
   if drop-off clusters there.
2. Deadline screen for undated moments — keep, or skip straight to time
   commitment?
3. Should the application item in the diagnostic come FIRST (hook via
   "whoa, real scenario") instead of last (climax)? A/B candidate.
4. Money Map secondary chips: enough, or show a 12-pack mini-grid?
5. Trial length 7d vs 5d; annual price anchor.
