# Content Audit Cadence

> **Owner:** Content / curriculum lead.
> **Last reviewed:** 2026-05-26.
> **Triggers updates:** annual review schedule, regulatory news, court rulings on financial regs.

Numind is a **financial education app**. A meaningful share of our content references regulated numbers — tax brackets, deduction limits, federal loan rates, FLSA thresholds, ACA out-of-pocket maximums. These numbers drift annually (sometimes mid-year, when courts vacate rules or new legislation passes). When they drift and our content doesn't, we ship financial misinformation.

This doc defines how we keep that content fresh.

---

## 1. Verification cadence

### Annual

| When | What to verify | Why |
|---|---|---|
| **Every January** | Federal tax brackets, standard deduction, FICA wage cap, Roth/Traditional IRA limits, HSA/FSA limits, capital gains brackets, federal poverty guidelines | IRS publishes the next year's values in mid-October; January is when filers actually use them. |
| **Every June** | Federal student loan rates (Direct Subsidized/Unsubsidized, Grad Unsub, Parent PLUS), origination fees | Federal Student Aid sets the rates after the May Treasury auction; new rates take effect July 1. |
| **Every November** | IRS announcements for *next* year's limits (retirement plans, HSA, FSA, OOP max) | IRS Rev Proc typically drops late October / early November. Update lesson content with the upcoming year's numbers so users get current info from the start of the new tax year. |

### Event-triggered (any time)

Any of these should trigger an immediate review of related lessons:

- **FLSA threshold court rulings** (e.g. Nov 2024 vacating the 2024 DOL rule). Affects: 3.3 Overtime, 3.9 Exempt vs Non-Exempt.
- **SAVE / IDR plan rulings.** Affects: 10.4 IDR, 10.10 Refi Protections, 10.5 PSLF.
- **Major tax legislation** (e.g. OBBBA 2025, TCJA expiration, future reform). Affects: 7.x Taxes module.
- **CFPB BNPL rulemaking.** Affects: 5.8 BNPL.
- **State-level rent control / lease law changes** for major markets (NY, CA). Affects: 6.x Housing module.
- **HSA / HDHP threshold updates** mid-year. Affects: 8.4 HDHP vs PPO, 8.5 HSA.

### Quarterly housekeeping

First Monday of each quarter:

1. Run the stale-lessons query:
   ```bash
   jq '[.[] | select(.lastVerified == null or (.lastVerified < "<one_year_ago>"))] | length' \
       apps/ios/Numind/Resources/LocalContent/lessons.json
   ```
2. List unstamped or >12-month-old lessons by module; queue review.
3. Skim recent regulatory news (`gov.uscourts.* PACER`, IRS Newsroom, Federal Student Aid Announcements) for anything not yet captured.

---

## 2. Source registry

Per-topic canonical authority. Every regulated claim in the curriculum cites one of these. Update the year and URL each time you verify.

> **See also**: [`regulatory-constants.md`](./regulatory-constants.md) for the per-number registry — every year-bound dollar threshold / rate / cap currently referenced in the curriculum, with current value, lesson IDs that reference it, and the next-refresh date.

| Topic | Authority | Canonical URL | Updates |
|---|---|---|---|
| Federal income tax brackets | IRS Rev Proc (annual) | https://www.irs.gov/forms-pubs/about-revenue-procedures | Annually each Oct/Nov for next year |
| Standard deduction | IRS Pub 501 / Rev Proc 2025-32 | https://www.irs.gov/forms-pubs/about-publication-501 | Annually; 2026 values current ($16,100 S / $24,150 HoH / $32,200 MFJ) |
| HSA contribution limits + HDHP thresholds | IRS Rev Proc (annual) | https://www.irs.gov/publications/p969 | Annually each May |
| FSA limits | IRS Rev Proc (annual) | https://www.irs.gov/publications/p969 | Annually each Oct/Nov |
| Roth/Traditional IRA limits + phaseouts | IRS Notice (annual) | https://www.irs.gov/retirement-plans | Annually each Oct/Nov |
| 401(k) contribution limits | IRS Notice (annual) | https://www.irs.gov/retirement-plans | Annually each Oct/Nov |
| Social Security wage cap + COLA | SSA | https://www.ssa.gov/oact/cola/ | Annually each Oct |
| Disability statistics | SSA Fact Sheet | https://www.ssa.gov/news/press/factsheets/basicfact-alt.pdf | Updated periodically |
| FLSA exempt salary threshold | DOL Wage & Hour | https://www.dol.gov/agencies/whd/overtime | Event-triggered (court rulings) |
| Federal Direct Loan rates (incl. Parent PLUS) | Federal Student Aid | https://studentaid.gov/understand-aid/types/loans/interest-rates | Annually each May/June |
| Origination fees on Direct Loans | Federal Student Aid | https://studentaid.gov/understand-aid/types/loans/interest-rates | Annually; relatively stable |
| Poverty guidelines (IDR formula input) | HHS | https://aspe.hhs.gov/poverty-guidelines | Annually each January |
| BNPL consumer behavior stats | CFPB BNPL Industry Report | https://www.consumerfinance.gov/data-research/research-reports/ | Updated periodically |
| Capital gains tax brackets | IRS Topic 409 | https://www.irs.gov/taxtopics/tc409 | Annually each Oct/Nov |
| Self-employment tax | IRS Schedule SE instructions | https://www.irs.gov/forms-pubs/about-schedule-se-form-1040 | Generally stable |
| Section 127 (employer student loan benefit) | IRC § 127 (post-OBBBA 2025 permanent) | https://www.irs.gov/publications/p15b | Event-triggered |
| Generic drug equivalence | FDA Orange Book | https://www.accessdata.fda.gov/scripts/cder/ob/ | Continuously updated |
| Extended warranty value stats | Consumer Reports surveys | https://www.consumerreports.org/ (subscription) | Periodic |
| Rental affordability / city rent data | Apartment List, Zumper, RentCafe | https://www.apartmentlist.com/research | Monthly |
| S&P / index fund vs active returns | S&P SPIVA Scorecard | https://www.spglobal.com/spdji/en/research-insights/spiva/ | Semi-annually |
| Federal CC interest stats | Federal Reserve G.19 | https://www.federalreserve.gov/releases/g19/current/ | Monthly |

---

## 3. Pre-merge checklist for regulated content changes

When a PR touches any lesson that references one of the topics above, the PR description must include:

- [ ] Lesson text updated (concept / shortcut / example).
- [ ] Swift constants updated, if any (formula bodies in `QuizEngine.swift`, `FormulaOperationMap.swift`).
- [ ] Template variable ranges + prompt text + explanation text updated where the affected number appears.
- [ ] `lastVerified` bumped to today on every touched lesson.
- [ ] Inline citation added — name the authority in parentheses (e.g. "(per IRS Pub 501, 2025)").
- [ ] Authority URL linked in the PR description (the canonical page, not the press release).
- [ ] `xcodebuild ... build` passes.
- [ ] `xcodebuild ... test` passes (`test_allTemplates_generateValidQuestions` will catch broken formula references).
- [ ] `jq` orphan + missing-reference check returns empty (see Phase 1 plan for the exact query).
- [ ] If a concept template was added, `correctConceptChoice` matches one of `conceptChoices`.

For multi-lesson updates (e.g. annual tax-bracket refresh affecting 5+ lessons), ship as a single PR titled `Content refresh: <topic> <year>` so the trail is searchable.

---

## 4. The first verification pass (Phase 1, May 2026)

This doc was created in Phase 2 of the content audit. The first end-to-end verification — visiting each lesson, fact-checking, stamping `lastVerified` — happened across Phases 1 and 2. Concretely:

- **Phase 1** (May 2026) stamped 6 lessons that touched the most-regulated content:
  - Overtime arithmetic + non-exempt caveat (3.3)
  - Parent PLUS rate update 9.08% → 8.94% (10.8)
  - Realistic minimum-payment formula replacing 2% simplification (5.2)
  - OOP max framing carve-outs (8.3)
  - IDR reframed to concept lesson post-SAVE (10.4)
  - Standard deduction expanded to include HoH (7.5)

- **Phase 2** (in flight) is rolling out `lastVerified` to the remaining 90 lessons module-by-module with the verify-then-stamp pattern. Every lesson that survives Phase 2 will carry a `lastVerified` date.

After Phase 2 completes, the steady-state cadence above kicks in: annual reviews + event triggers + quarterly housekeeping.

---

## 5. Process improvements (proposed, not yet built)

- **Stale-lesson CLI.** A small script that takes `lessons.json`, reports unstamped lessons + lessons older than N months, sorted by module. Speeds up the quarterly query.
- **Sources schema field.** Currently citations live inline in concept/shortcut text (visible to users). A future `sources: [String]?` field on `Lesson` could carry structured citation metadata — useful for a "show me the source" UI surface or an automated link-checker.
- **Regulatory-news bot.** A scheduled task that watches IRS Newsroom, Federal Student Aid Announcements, and DOL Wage & Hour for new releases — drops a notification into the team channel when something material drops.
- **Reviewer signaling on the marketing site.** Each web calculator gets a "Last reviewed: <date>" footer pulling from the corresponding lesson's `lastVerified`. Strengthens E-E-A-T for YMYL search ranking. (Planned for Phase 2 Batch 2g.)
