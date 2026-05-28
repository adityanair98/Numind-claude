import type { Metadata } from "next";
import Link from "next/link";
import { buildMetadata } from "@/lib/seo/metadata";

export const metadata: Metadata = buildMetadata({
  title: "Calculator Methodology & Sources | Numind",
  description:
    "How each Numind calculator computes its result, the formulas used, the assumptions baked in, and the authoritative sources behind every regulated number.",
  path: "/methodology",
});

export default function MethodologyPage() {
  return (
    <div className="mx-auto max-w-3xl px-screen py-section">
      <h1 className="font-display text-3xl font-bold text-brand-navy mb-3">
        Calculator Methodology
      </h1>
      <p className="text-brand-muted mb-10">
        How each calculator computes its result, the assumptions baked in,
        and the authoritative sources behind every regulated number we
        quote.
      </p>

      <div className="space-y-10 text-brand-muted leading-relaxed">
        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            General principles
          </h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              Calculations run entirely in your browser. No inputs or
              results are sent to our servers.
            </li>
            <li>
              Every regulated number (tax brackets, contribution limits,
              federal loan rates, FLSA thresholds, etc.) is sourced from
              the relevant US authority (IRS, SSA, DOL, Federal Student
              Aid, CFPB, FDIC, HHS).
            </li>
            <li>
              When a number is a &quot;rule of thumb&quot; rather than a
              regulated value, we label it as such and explain the source
              (e.g. &quot;Fannie Mae 28% rule&quot; for housing
              affordability, &quot;1% rule&quot; for rental cash flow).
            </li>
            <li>
              For estimates that depend on assumptions (mortgage rate
              factor at 6%/30yr, ~1.5% annual tax+insurance on a home,
              ~7.65% FICA below the wage base), we display the assumption
              alongside the result.
            </li>
            <li>
              Calculations are designed to match the mental-math
              shortcuts Numind teaches in the iOS app, not the exact
              behavior of every US lender&apos;s billing system. For
              precise legal/tax/financial calculations affecting major
              decisions, consult a professional.
            </li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Per-calculator formulas &amp; sources
          </h2>

          <div className="space-y-6">
            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Paycheck Calculator{" "}
                <Link
                  href="/tools/paycheck-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> net = gross − federal − state −
                FICA. Federal uses 2025 progressive brackets per IRS Rev
                Proc 2024-40. State uses each state&apos;s flat or
                effective rate from <code>data/states.ts</code>. FICA is
                6.2% Social Security (up to the $176,100 wage base, per
                SSA) + 1.45% Medicare on all wages.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Salary Converter{" "}
                <Link
                  href="/tools/salary-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> annual = hourly × 2,000
                (full-time approximation: 40 hrs × 50 weeks). Biweekly =
                annual ÷ 26 (not ÷ 24). Sources: BLS standard full-time
                working-hour assumptions.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Rent Affordability + House Affordability{" "}
                <Link
                  href="/tools/house-affordability-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> max PITI = monthly gross ×
                0.28 (Fannie Mae 28/36 underwriting standard). Rate factor
                derived from the standard 30-year amortization formula:
                factor = (r/12 × (1+r/12)^360) / ((1+r/12)^360 − 1).
                Property tax + insurance assumed at ~1.5%/yr of price
                (varies by state).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Credit Card Payoff Calculator{" "}
                <Link
                  href="/tools/credit-card-payoff-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> months = ln(payment / (payment −
                balance × APR/1200)) / ln(1 + APR/1200) — the standard
                amortization formula solved for n. Assumes fixed monthly
                payment and no new purchases. Real issuer billing uses
                daily periodic rate × average daily balance (per CFPB
                disclosures), which lands within ~$2 of this estimate on
                typical balances.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Balance Transfer Calculator{" "}
                <Link
                  href="/tools/balance-transfer-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> fee = balance × fee%. Interest
                avoided = balance × old APR × promo months ÷ 12. Net
                benefit = interest avoided − fee. Required monthly to
                clear = (balance + fee) ÷ promo months. Source: industry
                norm of 3-5% transfer fees per major US issuers (Chase,
                Citi, Discover, BofA).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Investment Calculator{" "}
                <Link
                  href="/tools/investment-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> future value = P × (1 + r)^n for
                lump sum; monthly contributions compounded per period.
                Rule of 72 shown for doubling-time intuition. The 10% S&amp;P
                long-run figure is nominal (per S&amp;P historical data);
                inflation-adjusted return is closer to ~7% (per Robert
                Shiller&apos;s data series).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                401(k) Impact Calculator{" "}
                <Link
                  href="/tools/401k-impact-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> net cost = contribution ×
                (1 − marginal tax rate). Pre-tax 401(k) contributions
                reduce federal income tax but not FICA wages (per IRS).
                Employer match is proportional to (contribution % capped
                at match cap) × match rate. 2025 employee deferral limit:
                $23,500 (per IRS Notice 2024-80).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                HYSA Calculator{" "}
                <Link
                  href="/tools/hysa-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> annual interest = balance × APY%.
                APY (Annual Percentage Yield) is the regulated comparison
                number for savings products per the Truth in Savings Act /
                Regulation DD (FDIC). 4-5% current HYSA rates as of
                2024-25 per Bankrate / DepositAccounts tracking.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Loan Calculator{" "}
                <Link
                  href="/tools/loan-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> monthly payment via standard
                amortization. Total cost = payment × months. Total
                interest = total cost − principal. APR (per Reg Z / TILA)
                is the standardized comparison rate across lenders,
                including most required fees.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Insurance + FSA + Life Insurance Calculators{" "}
                <Link
                  href="/tools/insurance-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formulas:</strong> Premium × 12 = annual floor.
                Deductible + coinsurance capped at out-of-pocket max.
                FSA tax saving = election × marginal rate. Life insurance:
                10× rule or DIME method (Debt + Income replacement +
                Mortgage + Education − savings).{" "}
                <strong>Sources:</strong> IRS Rev Proc for HSA/FSA limits
                (2025 HSA $4,300/$8,550, FSA $3,300/year, HDHP min
                deductible $1,650/$3,300, per IRS Rev Proc 2024-25).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Car + Lease vs Buy Calculators{" "}
                <Link
                  href="/tools/car-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formulas:</strong> Total cost = payment × months.
                The 20/4/10 rule: 20% down, 4-year max term, 10% of gross
                income on all car costs. Depreciation defaults: 20% year
                1, ~15%/yr after (varies materially by model — per
                Edmunds and KBB residual data).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Student Loan Calculator{" "}
                <Link
                  href="/tools/student-loan-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Rate-of-thumb:</strong> ~$100-120 per $10,000
                borrowed at 4-7% APR on a 10-year standard repayment
                plan. <strong>Sources:</strong> Federal Student Aid for
                current rates (Parent PLUS 8.94% for 2025-26; Direct
                Subsidized/Unsubsidized undergrad 6.39%). PSLF: 120
                qualifying monthly payments while working full-time for a
                qualifying employer, per Federal Student Aid.
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                BNPL Calculator{" "}
                <Link
                  href="/tools/bnpl-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formula:</strong> Total cost = payments × payment
                amount. Late fee surcharge = late fee ÷ original price ×
                100. <strong>Sources:</strong> CFPB BNPL Market Trends
                reports for late-fee and overdraft statistics. Industry
                norm of $35 late fees verified against major BNPL
                provider terms (Klarna, Affirm, Afterpay).
              </p>
            </div>

            <div>
              <h3 className="font-display text-base font-bold text-brand-navy">
                Membership + Discount Calculators{" "}
                <Link
                  href="/tools/membership-calculator"
                  className="text-brand-blue text-sm font-normal hover:underline"
                >
                  ↗
                </Link>
              </h3>
              <p className="text-sm mt-1">
                <strong>Formulas:</strong> Break-even uses = fee ÷
                per-use saving (round up). Stacked discounts apply
                sequentially (not additively): final = price × (1 − d1) ×
                (1 − d2). No regulated values here — all arithmetic.
              </p>
            </div>
          </div>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Authority sources we reference
          </h2>
          <p className="mb-3">
            Every regulated number we publish traces back to one of these
            primary sources:
          </p>
          <ul className="list-disc pl-6 space-y-1 text-sm">
            <li>
              <strong>IRS:</strong> tax brackets, standard deduction,
              HSA/FSA/IRA/401(k) limits, capital gains rates, FICA wage
              base (via SSA), Additional Medicare Tax thresholds
            </li>
            <li>
              <strong>SSA (Social Security Administration):</strong>{" "}
              Social Security wage base, disability statistics
            </li>
            <li>
              <strong>DOL (Department of Labor):</strong> FLSA overtime
              + exempt salary threshold
            </li>
            <li>
              <strong>Federal Student Aid:</strong> federal Direct Loan
              rates (Subsidized, Unsubsidized, Parent PLUS), origination
              fees, IDR plan terms, PSLF eligibility
            </li>
            <li>
              <strong>HHS:</strong> federal poverty guidelines (used in
              IDR calculations)
            </li>
            <li>
              <strong>CFPB:</strong> credit-card billing disclosures,
              BNPL market trends, Truth in Lending Act / Reg Z
              clarifications
            </li>
            <li>
              <strong>FDIC:</strong> Truth in Savings Act / Reg DD, FDIC
              insurance limits, big-bank-vs-HYSA tracking via
              Bankrate/DepositAccounts
            </li>
            <li>
              <strong>FDA:</strong> generic drug bioequivalence (Orange
              Book)
            </li>
            <li>
              <strong>S&amp;P SPIVA:</strong> active fund vs index fund
              performance comparison
            </li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Curated learning paths
          </h2>
          <p>
            Calculators answer a single question. The Numind iOS app
            organizes the deeper financial-literacy curriculum into 10{" "}
            <Link href="/paths" className="text-brand-blue hover:underline">
              Life-Event Paths
            </Link>{" "}
            — short, ordered lesson sequences that map to a single
            real-world decision moment. Each path is 4–8 lessons (~14–24
            minutes total) and is grounded in the same primary-authority
            sources documented above; lesson titles and lesson order are
            published on each path&apos;s landing page.
          </p>
          <ul className="list-disc pl-6 space-y-1.5 mt-3">
            <li>
              <Link href="/paths/first_paycheck" className="text-brand-blue hover:underline">
                First Paycheck
              </Link>{" "}
              — gross vs net, FICA, marginal brackets, the W-4 adjustment
            </li>
            <li>
              <Link href="/paths/first_apartment" className="text-brand-blue hover:underline">
                First Apartment
              </Link>{" "}
              — 28% rule, true cost of renting, first-month cash, lease
              clauses
            </li>
            <li>
              <Link href="/paths/credit_card_cleanup" className="text-brand-blue hover:underline">
                Credit Card Cleanup
              </Link>{" "}
              — interest math, minimum-payment trap, balance transfer,
              avalanche vs snowball
            </li>
            <li>
              <Link href="/paths/open_enrollment" className="text-brand-blue hover:underline">
                Open Enrollment
              </Link>{" "}
              — HDHP vs PPO, HSA vs FSA, copay/coinsurance, OOP max
            </li>
            <li>
              <Link href="/paths/buying_a_home" className="text-brand-blue hover:underline">
                Buying a Home
              </Link>{" "}
              — Fannie Mae 28% rule, mortgage math, cash-to-close, buy vs
              rent
            </li>
            <li>
              <Link href="/paths/student_loan_repayment" className="text-brand-blue hover:underline">
                Student Loan Repayment
              </Link>{" "}
              — federal vs private, IDR, PSLF, refinance protection
              tradeoff
            </li>
            <li>
              <Link href="/paths/investing_starter" className="text-brand-blue hover:underline">
                Investing Starter Pack
              </Link>{" "}
              — 401(k) match, Roth vs Traditional, compound growth,
              emergency fund
            </li>
            <li>
              <Link href="/paths/car_buying" className="text-brand-blue hover:underline">
                Car Buying
              </Link>{" "}
              — monthly-vs-total trap, 20/4/10, lease vs buy, dealer
              tactics
            </li>
            <li>
              <Link href="/paths/everyday_spending" className="text-brand-blue hover:underline">
                Everyday Spending
              </Link>{" "}
              — tips, stacked discounts, sales tax, subscription math,
              membership worth
            </li>
            <li>
              <Link href="/paths/taxes_without_panic" className="text-brand-blue hover:underline">
                Taxes Without Panic
              </Link>{" "}
              — paycheck stub, brackets, deductions, refund framing, W-4
            </li>
          </ul>
        </section>
      </div>
    </div>
  );
}
