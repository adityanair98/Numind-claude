/**
 * Life-Event Packs — curated lesson sequences that map to canonical user
 * decision moments (First Paycheck, First Apartment, Open Enrollment, etc.).
 *
 * Mirrors `apps/ios/Numind/Resources/LocalContent/packs.json`. Kept in sync
 * manually — if you change one, change the other. (See
 * `docs/ops/content-audit-cadence.md` for the pairing rule.)
 *
 * Each pack is a search-intent-aligned packaging of existing lessons. Lessons
 * live in `lessons.json` in the iOS bundle; on the web side we only need the
 * lesson IDs + a short title for the pack landing page's lesson list — the
 * canonical lesson content stays in the iOS app (the website's role is
 * acquisition, not curriculum delivery).
 */

export interface PackInfo {
  id: string;
  /** Display title — used on the pack card + landing-page hero */
  title: string;
  /** ~10-word marketing tagline */
  tagline: string;
  /** One-sentence framing of the user moment */
  hook: string;
  /** Longer description for the landing page above the lesson list */
  description: string;
  /** Ordered list of lesson IDs that compose the pack */
  lessonIds: string[];
  /**
   * Single lesson that best frames the decision — surfaced as the
   * "Start here" anchor on the pack landing page.
   */
  anchorLessonId: string;
  /** Rough total minutes for the pack (reading + quiz across all lessons) */
  estimatedMinutes: number;
  /** ISO date of last review */
  lastReviewed: string;
}

/**
 * Map of lesson ID → human-readable title, used to render the lesson list
 * on the pack landing page. Mirrors `lessons.json` titles.
 */
export const lessonTitles: Record<string, string> = {
  // Salary
  net_pay_check: "Gross vs net — what you actually keep",
  raise_impact: "What a % raise really adds",
  salary_total_comp: "Your salary isn't your compensation",
  investing_401k_match: "401(k) match — free money math",
  // Taxes
  concept_taxes_paycheck_stub: "Your paycheck stub + filing status",
  taxes_brackets: "Marginal tax brackets",
  taxes_w4_adjust: "Stop lending the government your money",
  // Housing
  housing_rent_affordability: "Rent affordability (28% rule)",
  housing_true_cost: "What renting actually costs you each month",
  housing_move_in_cost: "Move-in cost calculator",
  housing_first_month_true_cost: "First-month true cost — what it really takes to move in",
  housing_roommate_math: "The roommate math — $6,500/year",
  concept_housing_lease_clauses: "What's in a lease — clauses that matter",
  housing_affordability_full: "How much house can I afford?",
  housing_mortgage_vs_rent: "Mortgage payment, the right way",
  housing_cash_to_close: "Cash to close — the number that surprises first-time buyers",
  concept_housing_buy_vs_rent_framework: "Buy vs rent — the real decision framework",
  // Debt
  credit_card_interest: "How credit card interest works",
  minimum_payment_trap: "The minimum payment trap",
  debt_cc_payoff_time: "How long until you're debt-free?",
  debt_balance_transfer: "Balance transfer — is the 0% APR worth the fee?",
  debt_avalanche_snowball: "Pay off debt faster: avalanche vs snowball",
  debt_cc_statement_cycle: "Statement close vs due date — why timing your payment matters",
  concept_debt_credit_scores: "How credit scores actually work",
  debt_cc_rewards_vs_interest: "Credit card rewards vs interest — when 2% cashback is meaningless",
  // Insurance
  insurance_deductible_vs_premium: "Deductible vs premium tradeoff",
  insurance_copay_coinsurance: "Copay vs coinsurance",
  insurance_oop_max: "Out-of-pocket maximum",
  insurance_hdhp_vs_ppo: "HDHP vs PPO comparison",
  insurance_hsa_advantage: "HSA triple tax advantage",
  insurance_fsa_use_it: "FSA: free money or wasted money?",
  concept_insurance_open_enrollment: "Open enrollment — the 10-minute checklist",
  // Student Loans
  student_loan_monthly: "Student loan monthly payment",
  student_loan_total_cost: "Total cost of student loans",
  student_loan_grace_period: "Your loans are growing while you wait",
  student_loan_idr: "Income-driven repayment",
  student_loan_pslf: "PSLF forgiveness math",
  student_loan_employer_benefit: "Does your employer pay your student loans?",
  student_loan_refinance: "Refinancing savings",
  concept_sl_refi_protections_lost: "Federal loan protections you lose by refinancing",
  // Investing
  rule_of_72: "The Rule of 72 — when does it double?",
  investing_roth_vs_traditional: "Roth vs Traditional IRA — the basics",
  investing_roth_decision: "Roth vs Traditional — the decision",
  concept_investing_three_accounts: "Roth IRA vs Roth 401(k) vs Traditional 401(k) — same word, different account",
  investing_compound_growth: "Compound growth over time",
  investing_emergency_fund: "How much emergency fund do you actually need?",
  concept_investing_ef_location: "Where should your emergency fund actually sit?",
  // Car
  car_monthly_vs_total: "Monthly payment vs total cost",
  car_loan_term: "The hidden cost of '24 more months'",
  car_20_4_10_rule: "The 20/4/10 rule",
  car_total_cost_ownership: "What your car really costs per month",
  car_lease_vs_buy: "Lease vs buy — the 3-year math",
  concept_car_negotiation: "Dealer tactics — what to watch for",
  concept_car_warranty: "Manufacturer vs extended warranty",
};

export const packRegistry: PackInfo[] = [
  {
    id: "first_paycheck",
    title: "First Paycheck",
    tagline: "Make sense of your first real paycheck",
    hook: "You got the offer. The paycheck arrives. Why is it so much less than the salary you were quoted?",
    description:
      "Every adult sees their first real paycheck and thinks 'wait, where did the rest go?' This pack walks you through the answer in 7 short lessons: gross vs net, what each line item on your stub means, how marginal tax brackets actually work (hint: it's not the rate on all your income), and the one W-4 adjustment that gets you more money each paycheck instead of waiting for a refund.",
    lessonIds: [
      "net_pay_check",
      "concept_taxes_paycheck_stub",
      "taxes_brackets",
      "raise_impact",
      "salary_total_comp",
      "investing_401k_match",
      "taxes_w4_adjust",
    ],
    anchorLessonId: "net_pay_check",
    estimatedMinutes: 18,
    lastReviewed: "2026-05-26",
  },
  {
    id: "first_apartment",
    title: "First Apartment",
    tagline: "Budget your first place without getting surprised by the bill",
    hook: "You found a $1,800/month apartment. Why does it actually take $8,000 in cash to move in?",
    description:
      "Renting your first place is the most common first big-money decision after a new job. This pack covers what most renters underestimate by 35-55%: not just rent, but the rent-component cash (first + last + security + sometimes broker), the utility deposits and furniture setup, the move itself, and the lease clauses that bite later. Includes the 28% affordability rule, the true-cost-of-renting calc that adds insurance and utilities, the roommate-math savings comparison, and the lease clauses you should never sign without negotiating.",
    lessonIds: [
      "housing_rent_affordability",
      "housing_true_cost",
      "housing_move_in_cost",
      "housing_first_month_true_cost",
      "housing_roommate_math",
      "concept_housing_lease_clauses",
    ],
    anchorLessonId: "housing_first_month_true_cost",
    estimatedMinutes: 16,
    lastReviewed: "2026-05-26",
  },
  {
    id: "credit_card_cleanup",
    title: "Credit Card Cleanup",
    tagline: "Stop paying $$$ in interest. Start optimizing for payoff.",
    hook: "You have a balance. The minimum payment isn't moving the number. Where do you start?",
    description:
      "Credit-card debt is the most expensive consumer debt in America (avg APR ~22%, per CFPB). This pack is the complete playbook: how interest actually compounds, why minimum payments keep you treading water, how to estimate your real payoff time, when a 0% balance transfer is worth the fee, how to time your statement-close payments to fix your credit utilization, and the rewards-card trap that costs more in interest than it pays in cashback.",
    lessonIds: [
      "credit_card_interest",
      "minimum_payment_trap",
      "debt_cc_payoff_time",
      "debt_balance_transfer",
      "debt_avalanche_snowball",
      "debt_cc_statement_cycle",
      "concept_debt_credit_scores",
      "debt_cc_rewards_vs_interest",
    ],
    anchorLessonId: "debt_cc_payoff_time",
    estimatedMinutes: 22,
    lastReviewed: "2026-05-26",
  },
  {
    id: "open_enrollment",
    title: "Open Enrollment",
    tagline: "Pick your benefits in 10 minutes without guessing",
    hook: "Open enrollment is that 2-week window each fall when you lock in 12 months of medical, HSA/FSA, life, and disability decisions. Don't autopilot.",
    description:
      "Most workers re-elect last year's benefits on autopilot and leave $500-1,500/yr of tax savings on the table. This pack is the 10-minute decision tree: HDHP vs PPO based on your expected medical year, HSA vs FSA based on which plan you picked, DCFSA if you have childcare, commuter benefits if you commute, supplemental life if you have dependents, and the four add-ons (legal / identity / accident / cancer) you should almost always skip.",
    lessonIds: [
      "insurance_deductible_vs_premium",
      "insurance_copay_coinsurance",
      "insurance_oop_max",
      "insurance_hdhp_vs_ppo",
      "insurance_hsa_advantage",
      "insurance_fsa_use_it",
      "concept_insurance_open_enrollment",
    ],
    anchorLessonId: "concept_insurance_open_enrollment",
    estimatedMinutes: 20,
    lastReviewed: "2026-05-26",
  },
  {
    id: "buying_a_home",
    title: "Buying a Home",
    tagline: "How much you can afford — and how much cash you actually need",
    hook: "Mortgage calculators tell you the monthly payment. They don't tell you the $60K of cash you need before keys.",
    description:
      "Buying your first home is the largest single transaction most adults will ever make. This pack covers the full picture: the Fannie Mae 28% affordability rule, the mortgage-rate factor that lets you do mental mortgage math, the cash-to-close that's typically 5% of purchase price ON TOP of the down payment (most first-time buyers underestimate by $20-30K), and the buy-vs-rent decision framework calibrated for today's mortgage rates.",
    lessonIds: [
      "housing_affordability_full",
      "housing_mortgage_vs_rent",
      "housing_cash_to_close",
      "concept_housing_buy_vs_rent_framework",
    ],
    anchorLessonId: "housing_affordability_full",
    estimatedMinutes: 14,
    lastReviewed: "2026-05-26",
  },
  {
    id: "student_loan_repayment",
    title: "Student Loan Repayment",
    tagline: "Know what you owe — and the trap of refinancing federal loans",
    hook: "Federal IDR, PSLF, refinancing — the options feel infinite. Here's the math + the one rule that prevents most regret.",
    description:
      "Federal student-loan landscape is in active flux (post-SAVE rulings, evolving IDR plan availability). This pack gives you the durable math: what your monthly payment will be on standard 10-year, how much interest the loan costs over its life, when refinancing saves real money — and crucially, when it permanently forfeits federal protections (IDR, PSLF, deferment, discharge) that almost always exceed the rate savings for public-service workers. Also covers the IRC §127 employer benefit that can pay $5,250/yr tax-free toward your loans.",
    lessonIds: [
      "student_loan_monthly",
      "student_loan_total_cost",
      "student_loan_grace_period",
      "student_loan_idr",
      "student_loan_pslf",
      "student_loan_employer_benefit",
      "student_loan_refinance",
      "concept_sl_refi_protections_lost",
    ],
    anchorLessonId: "concept_sl_refi_protections_lost",
    estimatedMinutes: 22,
    lastReviewed: "2026-05-26",
  },
  {
    id: "investing_starter",
    title: "Investing Starter Pack",
    tagline: "The 4 decisions that matter — everything else is noise",
    hook: "You're ready to start investing. Skip the YouTube finance bros and the crypto pitches — here's what actually compounds.",
    description:
      "For most adults, investing is dominated by 4 decisions: capture the employer 401(k) match, pick Roth vs Traditional, automate monthly contributions, and let compounding do the work. This pack walks through each in order, including the three-accounts clarification (Roth IRA vs Roth 401(k) vs Traditional 401(k) — same word, different account), the emergency-fund prerequisite that keeps your portfolio safe from emergencies, and where to actually park the EF (HYSA at 4-5%, not the 0.01% big-bank account).",
    lessonIds: [
      "rule_of_72",
      "investing_401k_match",
      "investing_roth_vs_traditional",
      "investing_roth_decision",
      "concept_investing_three_accounts",
      "investing_compound_growth",
      "investing_emergency_fund",
      "concept_investing_ef_location",
    ],
    anchorLessonId: "investing_401k_match",
    estimatedMinutes: 24,
    lastReviewed: "2026-05-26",
  },
  {
    id: "car_buying",
    title: "Car Buying",
    tagline: "Walk into the dealership knowing the math",
    hook: "The salesperson's job is to get you to negotiate by monthly payment. Yours is to negotiate by out-the-door price.",
    description:
      "Car dealerships have refined their tactics over decades. This pack is your counter-playbook: the monthly-payment-vs-total-cost trap (a $400/mo car can cost $32K total), why the 20/4/10 rule keeps you from being car-poor, the lease-vs-buy math including acquisition + disposition fees most comparisons skip, the F&I markup that's pure dealer profit, and why extended warranties on reliable brands almost always lose money.",
    lessonIds: [
      "car_monthly_vs_total",
      "car_loan_term",
      "car_20_4_10_rule",
      "car_total_cost_ownership",
      "car_lease_vs_buy",
      "concept_car_negotiation",
      "concept_car_warranty",
    ],
    anchorLessonId: "concept_car_negotiation",
    estimatedMinutes: 20,
    lastReviewed: "2026-05-26",
  },
];

export function getPackBySlug(slug: string): PackInfo | undefined {
  return packRegistry.find((p) => p.id === slug);
}
