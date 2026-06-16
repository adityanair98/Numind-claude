# Numind Score Baseline — May 2026 (Phase 5g)

> **⚠️ Retired (Phase 9).** The global 0–100 Numind Score this doc baselines no
> longer exists — the composite/coverage-cap/subtitle engine and its
> `NumindScoreBaselineTests` were deleted when scoring moved to the two-currency
> XP/Level + per-pack Readiness model. Kept as a historical record only.
> Current model: `docs/product/scoring-system-research.md`; current regression
> coverage: `MomentumTests` / `ReadinessTests` / `FreshnessTests` / `MasteryTests`.

Diagnostic snapshot of the 7-axis Numind Score engine after the Phase 5
architecture redesign (per-module → per-skill-axis).

## Methodology

The diagnostic is the XCTest at
`apps/ios/NumindTests/NumindScoreBaselineTests.swift::test_axisBaseline_underUniformBehavior`.
It builds a synthetic user with uniform behavior across the entire
curriculum:

- 80% accuracy
- 8 seconds per question
- 10 simulated sessions per lesson
- 5 questions per session
- Sessions distributed across all 118 lessons in `lessons.json`

The engine output is dumped to stdout in a table and asserted against
the engineering tolerances below.

## Output (2026-05-27)

```
=== Numind Score Baseline — 7 Axes (Phase 5g) ===
axis                       |     q |  days |  scen | score | evidence
---------------------------------------------------------------------------
Everyday Money Math        |  1350 |     1 |   650 |    70 | Early Read
Cash Flow & Budgeting      |  1850 |     1 |   400 |    71 | Early Read
Income & Paycheck          |  1550 |     1 |   500 |    71 | Early Read
Debt & Credit              |  1450 |     1 |   250 |    70 | Early Read
Big Purchases              |  1250 |     1 |   150 |    71 | Early Read
Protection & Benefits      |   700 |     1 |     0 |    68 | Early Read
Investing & Future         |  1150 |     1 |   200 |    71 | Early Read
---------------------------------------------------------------------------
Composite: 63
Subtitle: Building real fluency. Strongest: Cash Flow & Budgeting. Focus next: Protection & Benefits.
```

## Engineering tolerances

| Check | Threshold | This run |
| --- | --- | --- |
| Every axis ≥ Early Read | 0 axes Untested | ✅ all 7 at Early Read |
| Max per-axis spread | ≤ 25 pts | ✅ 3 pts (68–71) |
| Composite under 80% uniform | ≥ 50 | ✅ 63 |

## Interpretation

The score engine produces a **tight, defensible distribution under
uniform behavior** — exactly what we want from a healthy scoring system.
Highlights:

- **Score floor is calibrated.** Composite of 63 under 80% uniform
  accuracy lands in the "Building real fluency" band — neither
  punitively low nor inflated. This is what we want a mid-engagement
  user to see.
- **Per-axis spread is 3 points.** Differences between axes come from
  the weighting profile (e.g. Protection & Benefits at 68 because its
  concept-heavy profile gives speed=0; the reweighting of speed across
  remaining components ends up slightly under-correcting given
  Protection's 0 scenarios). Within engineering tolerance.
- **Evidence levels are conservative.** Synthetic data has only 1
  distinct day, so even with 1850 questions in Cash Flow no axis hits
  "Developing" (which requires ≥ 2 distinct days) or "Reliable" (≥ 3
  distinct days + ≥ 2 scenario questions). Real users naturally
  distribute attempts over days, so this won't be a blocker in
  production.

## Per-axis sample counts

The synthetic 5q × 10 sessions × 118 lessons = 5,900 question results
get distributed 70/30 across primary/secondary axes. Per-axis counts
roughly track each axis's primary lesson count (see
`apps/ios/Numind/Domain/Skills/SkillAxis.swift`):

- Debt & Credit:        25 primary lessons → ~1,750 weighted (matches 1,450 + secondary share)
- Big Purchases:        21 primary lessons → ~1,470 weighted
- Income & Paycheck:    21 primary lessons → ~1,470 weighted
- Investing & Future:   17 primary lessons → ~1,190 weighted
- Cash Flow & Budgeting: 12 primary lessons → ~840 weighted (plus heavy secondary use → 1,850)
- Protection & Benefits: 12 primary lessons → ~840 weighted (low secondary use → 700)
- Everyday Money Math:  10 primary lessons → ~700 weighted (plus secondary share → 1,350)

## Recommendation

**No recalibration needed.** The 7-axis engine produces sensible scores
under uniform behavior. Per-axis spread is well under the 15-pt
recommendation gate (let alone the 25-pt hard-fail). Real-user data will
distribute across days, allowing axes to progress beyond Early Read into
Developing/Reliable.

The Phase 5d engine ships as-is.

---

*Generated: 2026-05-27. Source:
`apps/ios/NumindTests/NumindScoreBaselineTests.swift::test_axisBaseline_underUniformBehavior`.
Architecture: 7 SkillAxis cases (Everyday Money Math, Cash Flow &
Budgeting, Income & Paycheck, Debt & Credit, Big Purchases, Protection
& Benefits, Investing & Future), weighting profiles per axis
(numericalHeavy / conceptHeavy / mixedDecision), evidence levels by
distinct-question-count + distinct-day-count + scenario-count,
composite = weighted_radar_avg × coverage_factor − imbalance_penalty,
capped by # of covered axes (1→60, 2→60, 3→70, 4→78, 5→85, 6→92, 7→100).*

---

## Historical note (Phase 2, May 2026 — pre-5d)

Earlier in May 2026, before Phase 5, the Numind Score was per-module
(10 axes = 10 curriculum modules) with components Accuracy 60 /
Difficulty 25 / Speed 15. The Phase 2 baseline diagnostic showed the
concept-vs-numerical spread within tolerance (no recalibration needed).
That snapshot is preserved in git history. The Phase 5d redesign
replaced the per-module score with the per-skill-axis score documented
above; the historical per-module test still passes via the
ProgressStore.numindScore(for moduleId:) compatibility shim.
