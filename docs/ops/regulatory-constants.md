# Regulatory constants — year-bound numbers in the curriculum

This doc lists every regulated dollar threshold, percentage, or rate that
**drifts annually** in the Numind curriculum, with the current value, the
authority source, and the date it next needs to be refreshed.

Pair this with `content-audit-cadence.md` — that doc says *when* to refresh;
this doc says *what* to refresh.

Convention: every lesson that references one of these values should include
an explicit year tag inline (e.g. `"(2026)"` or `"in 2026"`) so a user
reading the lesson can tell at a glance whether the number is still current.

> **Last full refresh: 2026-05 (verified against primary IRS/SSA/HHS/FSA
> sources).** This pass absorbed the 2026 inflation adjustments
> (Rev Proc 2025-32, Notice 2025-67, Rev Proc 2025-19) **and** the
> One Big Beautiful Bill Act (OBBBA, July 2025): DCFSA cap $5,000 → $7,500,
> SALT cap $10,000 → $40,000+, TCJA bracket structure made permanent,
> §127 employer student-loan benefit made permanent, the RAP repayment plan
> replacing SAVE/legacy IDR for new borrowers, and the March 2025 PSLF
> executive order narrowing qualifying employers.

## Quick rules

1. **Every January** — the IRS releases inflation-adjusted values that take effect for the calendar year. Update tax brackets, standard deduction, retirement-plan limits, FSA cap, HSA limits.
2. **Every June** — federal student-loan rates reset based on the May Treasury auction. New rates take effect July 1.
3. **Every October-November** — the IRS announces *next* year's values. Update proactively so January users see current numbers.
4. **Event-triggered** — court rulings on FLSA/SAVE, CFPB rulemaking, major tax legislation. Update immediately.

## Per-number registry

### Tax (annual, every January)

| Constant | 2026 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Standard deduction — Single | $16,100 | IRS Rev Proc 2025-32 | `taxes_brackets`, `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2027 (when IRS publishes 2027 values) |
| Standard deduction — HoH | $24,150 | IRS Rev Proc 2025-32 | `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2027 |
| Standard deduction — MFJ | $32,200 | IRS Rev Proc 2025-32 | `taxes_standard_vs_itemized`, `concept_taxes_paycheck_stub` | Jan 2027 |
| Federal tax brackets — Single | 10%/$12,400 → 12%/$50,400 → 22%/$105,700 → 24%/$201,775 → 32%/$256,225 → 35%/$640,600 → 37%+ | IRS Rev Proc 2025-32 | `taxes_brackets` (all 4 numerical templates) | Jan 2027 |
| Long-term capital gains brackets — Single | 0% to $49,450 → 15% to $545,500 → 20%+ | IRS Rev Proc 2025-32 | `taxes_capital_gains` | Jan 2027 |
| Net Investment Income Tax (NIIT) | 3.8% on the lesser of net investment income or MAGI over $200K single / $250K MFJ | IRC § 1411 | `taxes_capital_gains` | NOT indexed — statutory thresholds |
| Social Security wage base (FICA cap) | $184,500 | SSA (Oct 2025 announcement) | `taxes_deductions`, `concept_taxes_paycheck_stub` | Oct 2026 announcement applies to 2027 |
| Additional Medicare Tax threshold | $200K single / $250K MFJ | IRS | `taxes_deductions` | Not indexed — only changes by legislation |
| SALT deduction cap | $40,400 (2026); phased down 30% of MAGI over $500K joint / $250K MFS, floor $10K; reverts to $10K in 2030 | OBBBA 2025 (P.L. 119-21) | `taxes_standard_vs_itemized` | Annually 2026-2029; reverts 2030 |

### Retirement plans (annual, every November announcement)

| Constant | 2026 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| IRA contribution limit | $7,500 (under 50) / $8,600 (50+) | IRS Notice 2025-67 | `investing_roth_vs_traditional`, `investing_roth_decision`, `concept_investing_three_accounts` | Nov 2026 for 2027 |
| IRA catch-up (50+) | $1,100 (now inflation-indexed per SECURE 2.0) | IRS Notice 2025-67 | `concept_investing_three_accounts` | Nov 2026 for 2027 |
| 401(k) elective deferral | $24,500 | IRS Notice 2025-67 | `investing_401k_match` (indirect), `salary_401k_paycheck_impact` (indirect), `concept_investing_three_accounts` | Nov 2026 for 2027 |
| 401(k) catch-up (50+) | $8,000 | IRS Notice 2025-67 | `concept_investing_three_accounts` | Nov 2026 for 2027 |
| 401(k) super catch-up (ages 60-63) | $11,250 (SECURE 2.0) | IRS Notice 2025-67 | `concept_investing_three_accounts` | Nov 2026 for 2027 |
| Overall §415 contribution cap (employee + employer) | $72,000 | IRS Notice 2025-67 | `concept_investing_three_accounts` | Nov 2026 for 2027 |
| Roth IRA phaseout (single) | $153K start, $168K full phaseout | IRS Notice 2025-67 | `investing_roth_vs_traditional`, `investing_roth_decision`, `concept_investing_three_accounts` | Nov 2026 for 2027 |
| Roth IRA phaseout (MFJ) | $242K start, $252K full phaseout | IRS Notice 2025-67 | `investing_roth_vs_traditional`, `investing_roth_decision`, `concept_investing_three_accounts` | Nov 2026 for 2027 |
| Roth 401(k) catch-up mandate | Catch-up must be Roth (after-tax) if prior-year FICA wages > $150K (SECURE 2.0, effective 2026) | IRS Notice 2025-67 | `concept_investing_three_accounts` | Legislative |
| RMD start age (Traditional) | 73 (per SECURE 2.0) | IRC § 401(a)(9) | `investing_roth_decision`, `concept_investing_three_accounts` | Legislation-bound; SECURE 2.0 raises to 75 starting 2033 |
| Roth 401(k) RMD removal | Eliminated in 2024 (per SECURE 2.0) | IRC § 401(a)(9)(H) | `concept_investing_three_accounts` | Legislative |
| IRS supplemental withholding rate | 22% (≤$1M cumulative supplemental wages); 37% above | IRS Pub 15 | `salary_rsu_basics` | Annually via IRS Pub 15 |
| ESPP §423 annual purchase cap | $25,000 of fair-market-value stock | IRC § 423(b)(8) | `investing_espp_discount` | NOT inflation-indexed; legislative only |
| Maximum ESPP discount | 15% | IRC § 423(b)(6) | `investing_espp_discount` | NOT indexed; legislative only |
| ESPP qualifying disposition windows | 2 years from grant + 1 year from purchase | IRC § 423(a) | `investing_espp_discount` | NOT indexed; legislative only |
| CARD Act grace period minimum | 21 days between statement close and due date | CARD Act of 2009 / Reg Z (12 CFR § 1026.5) | `debt_cc_statement_cycle` | NOT indexed; rule is statutory |

### HSA / FSA / DCFSA / commuter (annual, various announcement dates)

| Constant | 2026 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| HSA limit — self-only | $4,400 | IRS Rev Proc 2025-19 | `insurance_hsa_advantage`, `concept_insurance_open_enrollment` | May 2026 for 2027 |
| HSA limit — family | $8,750 | IRS Rev Proc 2025-19 | `insurance_hsa_advantage`, `concept_insurance_open_enrollment` | May 2026 for 2027 |
| HDHP min deductible (HSA eligibility) — self | $1,700 | IRS Rev Proc 2025-19 | `insurance_hsa_advantage`, `concept_insurance_open_enrollment` | May 2026 for 2027 |
| HDHP min deductible — family | $3,400 | IRS Rev Proc 2025-19 | `insurance_hsa_advantage` | May 2026 for 2027 |
| HDHP max out-of-pocket — self / family | $8,500 / $17,000 | IRS Rev Proc 2025-19 | `insurance_hsa_advantage` | May 2026 for 2027 |
| Health FSA cap | $3,400 | IRS Rev Proc 2025-32 | `insurance_fsa_use_it`, `concept_insurance_open_enrollment` | Oct 2026 for 2027 |
| Health FSA carryover max | $680 | IRS Rev Proc 2025-32 | `insurance_fsa_use_it`, `concept_insurance_open_enrollment` | Oct 2026 for 2027 |
| Dependent Care FSA cap (per household) | $7,500 ($3,750 MFS) — raised from $5,000 by OBBBA 2025, first increase since 1986 | OBBBA 2025 / IRC § 129(a)(2)(A) | `concept_insurance_open_enrollment`, `insurance_fsa_use_it` | NOT inflation-indexed; legislative only |
| Commuter (transit + parking) cap | $340/mo each | IRS Rev Proc 2025-32 / § 132(f)(2) | `concept_insurance_open_enrollment` | Annually each Oct/Nov |

### Student loans (annual, every June for rates; per-tier-of-degree fixed)

| Constant | 2026-27 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Direct Subsidized / Unsubsidized (undergrad) | 6.52% | Federal Student Aid (May 2026 Treasury auction) | `student_loan_monthly`, `student_loan_total_cost`, `student_loan_grace_period`, `concept_sl_subsidized_vs_unsubsidized` | June 2027 for 2027-28 |
| Direct Unsubsidized (graduate) | 8.07% | Federal Student Aid | (referenced) | June 2027 |
| Direct PLUS (grad/Parent PLUS) | 9.07% | Federal Student Aid | `student_loan_parent_plus`, `concept_sl_subsidized_vs_unsubsidized` | June 2027 |
| Origination fee — Direct Subsidized/Unsubsidized | 1.057% | Federal Student Aid | (referenced indirectly) | Updated periodically; current fee table valid through Oct 1, 2026 |
| Origination fee — Direct PLUS | 4.228% | Federal Student Aid | `student_loan_parent_plus` | Current fee table valid through Oct 1, 2026 |
| Parent PLUS borrowing limits (new borrowers on/after July 1 2026) | $20,000/yr per student, $65,000 aggregate per student | OBBBA 2025 | `student_loan_parent_plus` | Legislative |
| IRC § 127 employer benefit cap | $5,250/yr tax-free | IRC § 127 (made permanent by OBBBA 2025) | `student_loan_employer_benefit` | Not indexed; legislative only |
| Subsidized loan annual limits (undergrad) | $3,500-$5,500 by year | Federal Student Aid | `concept_sl_subsidized_vs_unsubsidized` | Set by Higher Education Act; legislative only |

### IDR / forgiveness (event-triggered, **unstable**)

| Topic | Current state (May 2026) | Source | Lessons referencing | Refresh trigger |
|---|---|---|---|---|
| RAP (Repayment Assistance Plan) | Created by OBBBA 2025. The default income-driven option for borrowers taking out **new** loans on/after July 1, 2026. Payments scale 1%-10% of AGI by income band, $10/mo floor, forgiveness after 360 qualifying payments (30 yrs). | OBBBA 2025 / Federal Student Aid | `student_loan_idr` | Any ED rulemaking |
| SAVE plan | Vacated in court; permanently closed. Borrowers migrated off into IBR or RAP. No longer accepting enrollees. | Federal Student Aid | `student_loan_idr` | Historical — closed |
| Legacy IDR (PAYE / ICR) | Closing to new enrollees; existing borrowers being transitioned. IBR remains the statutory income-driven plan for pre-July-2026 borrowers. | Federal Student Aid | `student_loan_idr`, `student_loan_pslf` | Any policy change |
| PSLF | 120 qualifying payments still operative. March 2025 executive order **narrowed the definition of a qualifying employer** (excludes orgs engaged in certain activities); rule in active litigation. | Federal Student Aid PSLF page / EO March 2025 | `student_loan_pslf`, `concept_sl_refi_protections_lost` | Any policy change / court ruling |

**Verification cadence for IDR content:** every quarter, plus on any federal court ruling. The lesson copy intentionally avoids quoting specific monthly amounts because the formula varies materially across plans.

### Federal poverty guidelines (annual, every January)

| Constant | 2026 value | Source | Lessons referencing | Next refresh |
|---|---|---|---|---|
| Federal poverty line — 1 person, contiguous US | $15,960 | HHS Poverty Guidelines | `student_loan_idr` (IDR formula reference) | Jan 2027 |
| FPL — 4 person household | $33,000 | HHS Poverty Guidelines | (referenced indirectly) | Jan 2027 |

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
