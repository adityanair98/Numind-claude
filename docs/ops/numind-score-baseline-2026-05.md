# Numind Score baseline — May 2026

This document captures the per-module Numind Score distribution for the
post-Phase-2 curriculum (102 lessons across 10 modules). It exists to
answer one engineering question: *do we need to recalibrate the
Numind Score weighting (currently Accuracy 60 / Difficulty 25 /
Speed 15) now that the curriculum has more concept lessons?*

## How this was measured

`NumindScoreBaselineTests.test_numindScore_conceptVsNumericalSpread`
runs a deterministic simulator:

| Parameter | Value |
|---|---|
| Accuracy | 80% (constant — 8 correct out of every 10 questions) |
| Time per question | 8.0 seconds |
| Sessions per lesson | 10 |
| Questions per session | 5 |
| Session window (engine config) | last 10 sessions |

For each lesson, the simulator builds 10 synthetic `SessionRecord`s
with the lesson's templates (rotating in order, generating real
questions via `QuizEngine.generate(seed:)` so per-question difficulty
is recorded correctly). It then feeds those into
`NumindScoreEngine.score(for: moduleId, sessions:)` and tabulates the
result per module.

The test is in `apps/ios/NumindTests/NumindScoreBaselineTests.swift`
and stays in the repo as an ongoing reference. It's a "tripwire" — it
will hard-fail if any module's concept-vs-numerical spread ever
exceeds 15 points, so a future content shift that breaks the
balance will be caught at CI time.

## Result

```
=== Numind Score Baseline (2026-05) ===
module                     | n_num | n_con |   num |   con | spread
----------------------------------------------------------------------
Smart Shopping             |     8 |     1 |  76.6 |  76.0 |    0.6
Budgets & Spending         |     6 |     1 |  77.5 |  76.0 |    1.5
Salary & Income            |     8 |     1 |  77.0 |  76.0 |    1.0
Investing Basics           |     8 |     6 |  76.6 |  76.0 |    0.6
Debt & Loans               |     7 |     3 |  77.4 |  75.7 |    1.8
Housing & Rent             |     7 |     2 |  77.6 |  76.0 |    1.6
Taxes & Paycheck           |     7 |     1 |  76.6 |  75.0 |    1.6
Insurance & Healthcare     |     8 |     2 |  77.9 |  75.5 |    2.4
Car & Big Purchases        |     8 |     2 |  77.8 |  76.0 |    1.8
Student Loans              |     7 |     3 |  76.9 |  75.7 |    1.2
----------------------------------------------------------------------
OVERALL                    |    74 |    22 |  77.2 |  75.8 |    1.4
```

Where:

- `n_num` = number of pure-numerical lessons in the module
- `n_con` = number of pure-concept lessons in the module
- `num` = average Numind Score across those numerical lessons (at the
  synthetic 80% accuracy + 8s/question profile above)
- `con` = average Numind Score across those concept lessons
- `spread` = `|num − con|`

(Lessons that mix concept and numerical templates — 6 lessons total
across the curriculum — are excluded from both buckets. They are not
the failure mode we're scoring for.)

## Interpretation

**Max module spread: 2.4 points (Insurance & Healthcare).
Curriculum-wide overall spread: 1.4 points.**

The plan's recalibration gate was "if any module's concept-vs-numerical
spread exceeds ~10 points, recalibrate." We are nowhere near that
threshold.

Concept lessons score very slightly lower than numerical lessons
(by 1–2 points on average), but the gap is small enough to be
indistinguishable from noise at the resolution the user sees on
screen — Numind Scores are displayed as integers 0–100. A 1.4-point
overall gap rounds to a 1-point gap at the UI layer, and most modules
round to 0–2 points.

The reason the spread is so small: at fixed accuracy (80%) and fixed
speed (8s/question, the "good" tier worth a 10-point speed bonus), the
only source of difference between concept and numerical sessions is
the difficulty-weighted accuracy component. Concept templates carry a
static difficulty tier (1/2/3); numerical templates derive their
difficulty from the actual generated numbers. The slight downward bias
of concept scores reflects that concept templates in the curriculum
tend to be assigned static `difficulty: 2` (medium) more often than
numerical templates land on the `medium` tier post-generation.

## Decision: **no recalibration**

WS-G.2 (re-weighting the engine to Accuracy 65 / Difficulty 25 /
Speed 10, or adding type-aware speed bonuses) is **not** triggered.

The current weighting (Accuracy 60 / Difficulty 25 / Speed 15) is
preserved.

If future curriculum work shifts the concept-lesson share substantially
(e.g. >50% of any module), re-run the baseline test and reassess. The
hard-fail tripwire at 15-point spread will catch any drift before it
ships.

## What would have triggered a recalibration

The synthetic methodology above is intentionally conservative — it
holds accuracy and speed constant. If real users systematically take
longer on concept questions (because reading 4 text options is slower
than tapping a numeric answer), concept-heavy sessions could drift
down by 5 speed points relative to numerical sessions in production.
That's still well under the 10-point gate, but it's the most plausible
real-world wedge.

Future work: once we have real per-question timing data from
production (post-PostHog launch), re-run this diagnostic with the
production accuracy/time distributions instead of the synthetic
constants, and compare.

## Related bugs surfaced

Running the diagnostic uncovered two latent bugs in the post-Phase-2
formula registry that the existing `test_allTemplates_generateValidQuestions`
test had not caught (because it only validates structure, not whether
the formula's variable names actually match what the template passes):

1. **`annualInterestViaApy`** (used by Investing APY HYSA templates
   from Batch 2b APR/APY split): formula expected variable name `apr`
   but templates pass `apy`. Fixed in this batch — formula now reads
   `apy` directly and returns `balance × apy / 100`, matching the
   explanation text and the mental-math shortcut taught in the
   lesson.

2. **`rule72`** (used by `apy_doubling_time_d2`): formula expected
   `interestRate` but the new template passes `apy`. Fixed in this
   batch — formula now accepts any of `interestRate`, `apy`, `apr`,
   or `rate`.

Both fixes are accompanied by parallel updates to
`FormulaOperationMap.swift` so per-question difficulty assessment
stays accurate.

## Where this fits in the audit cadence

This snapshot becomes a reference under `docs/ops/` (alongside
`content-audit-cadence.md`). The diagnostic test stays in the
codebase. The annual review process — when tax brackets, federal
loan rates, etc. drift in January / June / November — should re-run
this test as a final sanity check before shipping any quarter's
audit, especially after any batch of concept reframes.
