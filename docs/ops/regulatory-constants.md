# Regulatory constants — year-bound numbers in the curriculum

This doc lists every regulated dollar threshold, percentage, or rate that
**drifts annually** in the Numind curriculum, with the current value, the
authority source, and the date it next needs to be refreshed.

Pair this with `content-audit-cadence.md` — that doc says *when* to refresh;
this doc says *what* to refresh.

Convention: every lesson that references one of these values should include
an explicit year tag inline (e.g. `"(2025)"` or `"in 2025"`) so a user
reading the lesson can tell at a glance whether the number is still current.

## Quick rules

1. **Every January** — the IRS releases inflation-adjusted values that take effect for the calendar year. Update tax brackets, standard deduction, retirement-plan limits, FSA cap, HSA limits.
2. **Every June** — federal student-loan rates reset based on the May Treasury auction. New rates take effect July 1.
3. **Every October-November** — the IRS announces *next* year's values. Update proactively so January users see current numbers.
4. **Event-triggered** — court rulings on FLSA/SAVE, CFPB rulemaking, major tax legislation. Update immediately.

## Per-number registry

### Tax (annual, every January)

| Constant | 2025 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Standard deduction — Single | $15,750 | IRS Rev Proc 2024-40 | `taxes_brackets`, `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2026 (when IRS publishes 2026 values) |
| Standard deduction — HoH | $23,625 | IRS Rev Proc 2024-40 | `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2026 |
| Standard deduction — MFJ | $31,500 | IRS Rev Proc 2024-40 | `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2026 |
| Federal tax brackets — Single | 10%/$11,925 → 12%/$48,475 → 22%/$103,350 → 24%/$197,300 → 32%/$250,525 → 35%/$626,350 → 37%+ | IRS Rev Proc 2024-40 | `taxes_brackets` (all 4 numerical templates) | Jan 2026 |
| Long-term capital gains brackets | 0% / 15% / 20% at adjusted thresholds | IRS | `taxes_capital_gains` | Jan 2026 |
| Social Security wage base (FICA cap) | $176,100 | SSA | `taxes_deductions`, `concept_taxes_paycheck_stub` | Oct 2025 announcement applies to 2026 |
| Additional Medicare Tax threshold | $200K single / $250K MFJ | IRS | `taxes_deductions` | Not indexed — only changes by legislation |

### Retirement plans (annual, every November announcement)

| Constant | 2025 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| IRA contribution limit | $7,000 (under 50) / $8,000 (50+) | IRS Rev Proc 2024-25 | `investing_roth_vs_traditional`, `investing_roth_decision` | Nov 2025 for 2026 |
| 401(k) elective deferral | $23,500 | IRS | (referenced indirectly in `investing_401k_match`, `salary_401k_paycheck_impact`) | Nov 2025 for 2026 |
| Roth IRA phaseout (single) | $150K start, $165K full phaseout | IRS Rev Proc 2024-40 | `investing_roth_vs_traditional`, `investing_roth_decision` | Nov 2025 for 2026 |
| Roth IRA phaseout (MFJ) | $236K start, $246K full phaseout | IRS Rev Proc 2024-40 | `investing_roth_vs_traditional`, `investing_roth_decision` | Nov 2025 for 2026 |
| RMD start age | 73 (per SECURE 2.0) | IRC § 401(a)(9) | `investing_roth_decision` | Legislation-bound; SECURE 2.0 raises to 75 starting 2033 |

### HSA / FSA (annual, every May/Oct announcements respectively)

| Constant | 2025 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| HSA limit — self-only | $4,300 | IRS Rev Proc 2024-25 | `insurance_hsa_advantage` | May 2025 for 2026 |
| HSA limit — family | $8,550 | IRS Rev Proc 2024-25 | `insurance_hsa_advantage` | May 2025 for 2026 |
| HDHP min deductible (HSA eligibility) — self | $1,650 | IRS Rev Proc 2024-25 | `insurance_hsa_advantage` | May 2025 for 2026 |
| HDHP min deductible — family | $3,300 | IRS Rev Proc 2024-25 | `insurance_hsa_advantage` | May 2025 for 2026 |
| Health FSA cap | $3,300 | IRS Rev Proc 2024-40 | `insurance_fsa_use_it` | Oct 2025 for 2026 |
| Health FSA carryover max | $660 | IRS Rev Proc 2024-40 | `insurance_fsa_use_it` | Oct 2025 for 2026 |

### Student loans (annual, every June for rates; per-tier-of-degree fixed)

| Constant | 2025-26 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Direct Subsidized / Unsubsidized (undergrad) | 6.53% | Federal Student Aid | `student_loan_monthly`, `student_loan_total_cost`, `student_loan_grace_period`, `concept_sl_subsidized_vs_unsubsidized` | June 2026 for 2026-27 |
| Direct Unsubsidized (graduate) | 8.08% | Federal Student Aid | (referenced) | June 2026 |
| Direct PLUS (grad/Parent PLUS) | 8.94% | Federal Student Aid | `student_loan_parent_plus`, `concept_sl_subsidized_vs_unsubsidized` | June 2026 |
| Origination fee — Direct Subsidized/Unsubsidized | 1.057% | Federal Student Aid | (referenced indirectly) | Updated periodically; current fee table valid through Oct 1, 2026 |
| Origination fee — Direct PLUS | 4.228% | Federal Student Aid | `student_loan_parent_plus` | Current fee table valid through Oct 1, 2026 |
| IRC § 127 employer benefit cap | $5,250/yr tax-free | IRC § 127 (made permanent by OBBBA 2025) | `student_loan_employer_benefit` | Not indexed; legislative only |
| Subsidized loan annual limits (undergrad) | $3,500-$5,500 by year | Federal Student Aid | `concept_sl_subsidized_vs_unsubsidized` | Set by Higher Education Act; legislative only |

### IDR / forgiveness (event-triggered, **unstable**)

| Topic | Current state (May 2026) | Source | Lessons referencing | Refresh trigger |
|---|---|---|---|---|
| SAVE plan | Vacated in court 2024-2025; ED is transitioning borrowers off SAVE into legal repayment plans | Federal Student Aid SAVE updates | `student_loan_idr` | Any ED announcement / court ruling |
| PAYE / IBR / ICR | Available; specific eligibility windows for new enrollees | Federal Student Aid | `student_loan_idr`, `student_loan_pslf` | Any policy change |
| PSLF | 120 qualifying payments still operative | Federal Student Aid PSLF page | `student_loan_pslf`, `concept_sl_refi_protections_lost` | Any policy change |

**Verification cadence for IDR content:** every quarter, plus on any federal court ruling. The lesson copy intentionally avoids quoting specific monthly amounts because the formula varies materially across plans.

### Federal poverty guidelines (annual, every January)

| Constant | 2025 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Federal poverty line — 1 person, contiguous US | $15,650 | HHS Poverty Guidelines | `student_loan_idr` (IDR formula reference) | Jan 2026 |
| FPL — 4 person household | $32,150 | HHS Poverty Guidelines | (referenced indirectly) | Jan 2026 |

### Employment law (event-triggered)

| Constant | Current value | Source | Lessons referencing | Refresh trigger |
|---|---|---|---|---|
| FLSA salary threshold (exempt) — Federal | $35,568 / yr ($684 / week) | DOL (per Nov 15, 2024 Texas court vacatur of the 2024 increase) | `concept_salary_exempt_status` | Any future DOL rulemaking or court ruling |
| FLSA HCE (highly compensated exempt) | $107,432 / yr | DOL | `concept_salary_exempt_status` | Any DOL change |
| State FLSA thresholds (CA, NY, WA, etc.) | Variable; CA $68,640+ as of 2025 | State DOL pages | `concept_salary_exempt_status` (mentioned, not enumerated) | State-level updates |

### Consumer-credit / banking (varies)

| Constant | Current value | Source | Lessons referencing | Refresh trigger |
|---|---|---|---|---|
| Typical credit-card APR (avg) | ~22-24% | CFPB Consumer Credit Card Market Report | `credit_card_interest`, `minimum_payment_trap`, `debt_cc_payoff_time` (used as example default) | CFPB report cycle |
| FDIC insurance per depositor per bank | $250,000 | FDIC | `investing_apy_savings`, web HYSA calculator | Legislative only |
| BNPL stats (CFPB) | ~9 loans/yr avg; 2x overdraft risk | CFPB BNPL Market Trends | `debt_bnpl_hidden_cost` | CFPB report cycle |

### Real estate (varies by market; refresh annually)

| Constant | Current value | Source | Lessons referencing | Refresh trigger |
|---|---|---|---|---|
| State property tax effective rates | per-state from 0.32% (HI) to 2.49% (NJ) | Tax Foundation 2024 owner-occupied housing report | `states.ts` (web), used in `house-affordability-calculator/[state]` | Tax Foundation annual report (typically Q1) |
| Mortgage rate factor table | 0.0054 (5%) / 0.006 (6%) / 0.00665 (7%) | Amortization math; rates from Freddie Mac PMMS | `housing_mortgage_vs_rent`, `housing_affordability_full` | Re-verify when prevailing rates shift > 0.5% |
| "1% rule" / rent ratios | ~0.7-1.0% in most markets, < 0.5% in high-cost metros | Apartment List + Zumper market data | `investing_rental_yield` | Refresh annually |

## How to use this doc

**For per-lesson edits:** when you touch a lesson that references a value in
the table above, also check the row to confirm the value is still current
for the year tagged inline.

**For quarterly housekeeping passes:** run through this doc top to bottom.
Any row where the "next refresh" date has passed needs verification against
the authority source URL.

**For annual major updates (January / June / November):** update every row in
the relevant section, then sweep every lesson that references those values
and stamp `lastVerified` on touched entries.

## Authority source URLs

- IRS Revenue Procedures: https://www.irs.gov/forms-instructions/revenue-procedures
- IRS retirement-plan limits: https://www.irs.gov/retirement-plans/cost-of-living-adjustments-for-retirement-items
- SSA wage base & COLA: https://www.ssa.gov/cola/
- DOL FLSA exempt thresholds: https://www.dol.gov/agencies/whd/overtime
- Federal Student Aid interest rates: https://studentaid.gov/understand-aid/types/loans/interest-rates
- HHS Poverty Guidelines: https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines
- CFPB Consumer Credit Card Market Report: https://www.consumerfinance.gov/data-research/research-reports/
- FDIC insurance: https://www.fdic.gov/resources/deposit-insurance/
- Tax Foundation property tax data: https://taxfoundation.org/data/all/state/property-taxes/

When updating the lessons, prefer the *exact wording* the authority uses
for the constant (e.g. "Social Security wage base" not "SS cap") to keep
citations precise.
