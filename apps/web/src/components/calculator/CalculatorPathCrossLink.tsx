import Link from "next/link";
import { getPackBySlug, type PackInfo } from "@/lib/content/packs";

/**
 * Calculator-slug → recommended-pack mapping. Each calc routes to its
 * single strongest-match pack — the path whose user moment most directly
 * involves the calculator's primary concept. Calcs without a clean
 * single-pack match are intentionally omitted (the cross-link block won't
 * render for them).
 *
 * Skipped (intentional): loan-calculator (too generic), discount-calculator
 * (taught inline in Everyday Spending but the pack is broader), bnpl-calculator
 * (no canonical pack yet), membership-calculator (covered inside
 * Everyday Spending but the calc is narrow). All are still discoverable via
 * the global /paths nav.
 */
const CALC_TO_PACK: Record<string, string> = {
  "paycheck-calculator": "first_paycheck",
  "salary-calculator": "first_paycheck",
  "401k-impact-calculator": "first_paycheck",
  "rent-calculator": "first_apartment",
  "house-affordability-calculator": "buying_a_home",
  "credit-card-payoff-calculator": "credit_card_cleanup",
  "balance-transfer-calculator": "credit_card_cleanup",
  "investment-calculator": "investing_starter",
  "hysa-calculator": "investing_starter",
  "insurance-calculator": "open_enrollment",
  "fsa-calculator": "open_enrollment",
  "life-insurance-calculator": "open_enrollment",
  "car-calculator": "car_buying",
  "lease-vs-buy-calculator": "car_buying",
  "student-loan-calculator": "student_loan_repayment",
};

/**
 * Looks up the strongest-match pack for a calculator slug. Returns
 * `undefined` for calcs without a curated path match — the parent renders
 * nothing in that case.
 */
export function packForCalculator(slug: string): PackInfo | undefined {
  const parent = slug.split("/")[0]; // strip programmatic sub-segments
  const packId = CALC_TO_PACK[parent];
  if (!packId) return undefined;
  return getPackBySlug(packId);
}

interface Props {
  /** The calculator slug. Sub-pages (e.g. `paycheck-calculator/california`) work too. */
  calculatorSlug: string;
  className?: string;
}

export function CalculatorPathCrossLink({ calculatorSlug, className = "" }: Props) {
  const pack = packForCalculator(calculatorSlug);
  if (!pack) return null;

  return (
    <div
      className={`rounded-card border border-brand-teal/30 bg-brand-teal/5 p-card ${className}`}
    >
      <div className="flex items-center justify-between gap-4 flex-col sm:flex-row sm:items-start">
        <div className="flex-1">
          <span className="inline-block rounded-full bg-brand-teal/15 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-brand-teal">
            Take the path
          </span>
          <h3 className="mt-2.5 font-display text-lg font-bold text-brand-navy">
            {pack.title}
          </h3>
          <p className="mt-1.5 text-sm text-brand-muted leading-relaxed">
            {pack.tagline}
          </p>
          <div className="mt-2 flex items-center gap-3 text-xs text-brand-muted">
            <span>{pack.lessonIds.length} lessons</span>
            <span aria-hidden="true">·</span>
            <span>~{pack.estimatedMinutes} min</span>
          </div>
        </div>
        <Link
          href={`/paths/${pack.id}`}
          className="shrink-0 cursor-pointer rounded-button bg-brand-navy px-5 py-2.5 text-sm font-semibold text-white hover:bg-brand-navy/90 transition-colors duration-200"
        >
          View path →
        </Link>
      </div>
    </div>
  );
}
