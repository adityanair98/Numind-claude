# Content Value Audit — June 2026

**Scope:** all ~133 lessons / 791 templates, audited through a user-value lens.
**Method:** one deep audit agent per module (11) + an adversarial verifier per flagged
lesson (catches over-flagging of honest fundamentals). Run via the `content-value-audit`
workflow over per-module extracts.

## The lens (the user's own questions)

1. **Is the question/lesson beneficial?** Is the user learning / practicing a real,
   transferable skill — or is it trivial arithmetic, contrived, or a near-duplicate?
2. **Does the shortcut/hint map** to what each question actually tests? (One lesson has one
   `shortcut`, shown on every question; mixed lessons strain that.)
3. **Is the tip honest, specific, actionable knowledge** — or generic filler "for the sake
   of" a tip?

## Headline

| Metric | Count |
|---|---|
| Lessons clean ("good") | **111 / 133 (83%)** |
| Needs-work | 21 |
| Problem | 1 |
| **Generic-filler tips** | **0** |
| **Fully-mismatched shortcuts** | **0** |
| Partial-mapping shortcuts | 17 |
| Trivial-or-contrived questions (lesson-level) | 1 |

**Verdict:** the content is fundamentally healthy. The tips are real, sourced knowledge — not
AI filler. The mismatch problem (the salary_negotiation case) is real but **bounded and is
mostly mis-filed templates + incomplete shortcuts, not a structural gap.**

### Strategic finding
A **per-template-shortcut feature is NOT justified.** The "shortcut doesn't map" flags are
overwhelmingly (a) orphan templates that belong in a different lesson, and (b) shortcuts that
omit numbers their own questions need (e.g. the `20/4/10` lesson's shortcut states only the
"10"). Both are content fixes.

## The four problem patterns

### 1 · Misteaching — the lesson contradicts itself (P0, highest harm)
- **debt_cc_statement_cycle** — realWorldHint says timing "lowers your **interest**." The
  lesson's thesis is timing changes reported **utilization**, not interest. The hint teaches
  the misconception the lesson exists to correct.
- **car_down_payment** — shortcut + example conclude "invest the $6k, take a **smaller** down,"
  but the decision rewards "**put 20% down** to avoid being underwater." Opposite advice.
- **taxes_self_employment** — shortcut says set aside **35%**; decision rewards **25–30%**.
- **investing_fund_fees** — a "hard" template models fees as a **linear** drag inside a lesson
  whose whole point is that fees **compound**.

### 2 · Mis-filed orphan templates (P1)
A question whose formula has nothing to do with its lesson's shortcut:
`rule_of_72` (2 simple-interest balance Qs), `overtime_calc` (hourly→annual conversion),
`extra_payment_power` (no-payment monthly compounding), `money_math_50_30_20` (goal÷months),
`subscription_math` (monthly-vs-annual billing), `debt_avalanche_snowball` (single-rate interest).
→ relocate to the lesson that owns the formula, or cut.

### 3 · Redundant reps + fake difficulty (P2)
Identical formula behind reworded prompts + cosmetic d1/d2/d3 labels:
`housing_move_in_cost` (5→2 real formulas; a "d3 compare" that compares nothing),
`taxes_deductions` (5 identical net-pay), `taxes_self_employment` (4 identical SE-tax),
`overtime_calc` (3 identical OT-pay), `housing_rent_increase` (duplicate pair),
`subscription_math`, `price_per_use`, `investing_compound_growth`, `investing_fund_fees`,
`minimum_payment_trap`. → cut duplicates, fix difficulty labels; the freed slot should test
the skill the shortcut promises but never quizzes (break-even, FICA cap-crossing, state set-aside).

### 4 · Cross-lesson duplication (P3 — product decision)
`taxes_refund` ≈ `taxes_w4_adjust` (same refund-as-loan math + decision); three near-parallel
housing move-in lessons (`move_in_cost`, `first_month_true_cost`, …). → merge or sharply
differentiate (changes lesson/template counts + pack membership).

## Status (applied June 2026)
- **P0:** car_down_payment contradiction fixed. The other 3 "P0s" were **audit
  hallucinations** (already correct in live: debt_cc_statement_cycle hint,
  car_20_4_10 / car_lease_vs_buy shortcuts, taxes_self_employment %).
- **P1/P2 (verified-deterministic cuts):** removed orphan + exact-formula-duplicate
  templates across **13 lessons** (rule_of_72, housing_rent_increase, +10:
  taxes_deductions 6→3, housing_move_in_cost 6→3, money_math_50_30_20 6→4,
  overtime_calc 6→4, minimum_payment_trap, extra_payment_power, taxes_refund,
  investing_fund_fees, price_per_use, debt_avalanche_snowball). All identified by
  **formula comparison** (ground truth), not agent judgment.
- **Deferred:** new-template authoring; P3 lesson merges; ~5 lessons flagged on
  softer pedagogical grounds (bnpl, first_month_true_cost, subscription_math,
  investing_compound_growth, taxes_w4_adjust) where formulas are distinct.
- **Process note:** a multi-agent execution pass made unverified direct edits +
  hallucinated several findings; it was reverted. Only formula-verified cuts and
  the one real contradiction were kept. Lesson: audit content with deterministic
  checks (formula dup/orphan) — not agent judgment that can't be ground-truthed.

## Remediation tiers

| Tier | Lessons | Action |
|---|---|---|
| **P0** | 4 | Reconcile contradictions / fix the one factual hint error. |
| **P1** | ~13 | Relocate orphan templates (or cut); complete/tighten shortcuts. |
| **P2** | ~10 | Cut duplicate templates; fix mislabeled difficulty. |
| **P3** | merges | taxes_refund↔w4_adjust; housing move-in trio — needs a product call. |

**Out of scope for an autonomous sweep (deliberate):** authoring brand-new quiz templates to
fill freed slots (would be generated content — defer to a human-reviewed content pass), and the
P3 lesson merges.

## Per-lesson confirmed findings

(22 lessons; "strongest issue" + fix abbreviated — full detail in the workflow output.)

| Lesson | Pattern | Fix |
|---|---|---|
| debt_cc_statement_cycle | P0 hint error | Rewrite realWorldHint: timing changes utilization, not interest. |
| car_down_payment | P0 contradiction | Shortcut → negative-equity rule; fix example's "invest, take less down" conclusion. |
| taxes_self_employment | P0 + P2 | Reconcile set-aside % (align ~30–35%); collapse 4 identical SE-tax templates. |
| investing_fund_fees | P0 + P2 | Retire/re-tag the linear `fund_fee_decade_d3`; cut the `annual`/`compare` twin. |
| car_20_4_10_rule | P1 shortcut | Complete the shortcut to state all of 20% down / 4yr / 10%. |
| car_lease_vs_buy | P1 shortcut | Lead the shortcut with the keep-5yr→buy decision rule; demote F&I-fee detail. |
| overtime_calc | P1 orphan + P2 | Cut/relocate `salary_hourly_annual_d1`; collapse 3 identical OT-pay templates. |
| extra_payment_power | P1 orphan | Cut/relocate `cc_balance_interest_d2`; collapse the `saving`/`extra_d1` twin. |
| rule_of_72 | P1 orphan | Cut/relocate `total_with_interest_d2` + `investing_total_d3`; collapse bare-doubling pair. |
| money_math_50_30_20 | P1 + P2 | Trim 3 percent-of-income reps to 2; cut/relocate `target_savings_d3`. |
| subscription_math | P1 + P2 | Cut `yearly_cost_d1` duplicate; relocate/clarify `subscription_compare_d2`. |
| debt_avalanche_snowball | P1 question | Swap `debt_compare_rates_d2` (single-rate) for an avalanche-relevant item. |
| taxes_deductions | P2 | Collapse 5 identical net-pay calcs to 2 (flat + cap-cross). |
| housing_move_in_cost | P2 (problem) | Cut to 2 unique formulas; delete mislabeled `move_in_compare_d3`. |
| housing_first_month_true_cost | P2 | Cut `first_month_padding_rule_d1` (drills an invented formula); de-dup decision item. |
| housing_rent_increase | P2 | Cut the `basic`/`annual` duplicate pair (keep one). |
| debt_bnpl_hidden_cost | P2 | Cut `bnpl_simple_d1` (rehearses the benign sticker total); re-tag `stacked_d3`. |
| price_per_use | P2 | Cut one gym duplicate; (freed slot ⇒ break-even item, deferred). |
| investing_compound_growth | P2 | Reframe trivial pre-supplied-input drills toward the anchor recall. |
| minimum_payment_trap | P2 | Collapse 3 near-duplicate min-payment templates. |
| taxes_refund | P3 + P2 | Cut `basic`/`owe` duplicate; de-dup vs taxes_w4_adjust (merge — P3). |
| taxes_w4_adjust | P3 | Re-scope to W-4 mechanics / "Exempt" trap; offload refund math to taxes_refund (merge — P3). |

## Notes
- One module agent returned 12 of 13 lessons (negligible coverage gap).
- No lesson was rated "generic-filler" or "fully mismatched" — the content was written with
  real domain knowledge.
