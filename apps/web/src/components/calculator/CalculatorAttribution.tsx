import Link from "next/link";

interface CalculatorAttributionProps {
  /** Last editorial review date (yyyy-mm-dd) for this calculator */
  lastReviewed: string;
  className?: string;
}

/**
 * Renders the per-calculator attribution footer with the last-reviewed date
 * and links to the site-wide /methodology and /editorial-standards pages.
 *
 * Strengthens E-E-A-T for YMYL finance content per Google's Quality Rater
 * Guidelines — visible signals about *who* maintains the calculator and
 * *when* it was last fact-checked materially affect trust.
 */
export function CalculatorAttribution({
  lastReviewed,
  className = "",
}: CalculatorAttributionProps) {
  // Format the ISO date as a human-readable "Month YYYY"
  const formattedDate = formatReviewDate(lastReviewed);

  return (
    <div
      className={`mt-section border-t border-brand-muted/10 pt-6 text-xs text-brand-muted ${className}`}
    >
      <p>
        <strong className="font-semibold text-brand-navy/80">
          Last reviewed:
        </strong>{" "}
        {formattedDate}. Numind&apos;s calculators are fact-checked against
        primary sources on an annual cadence and after material regulatory
        changes. See our{" "}
        <Link
          href="/methodology"
          className="text-brand-blue hover:underline"
        >
          calculator methodology
        </Link>{" "}
        for the formula, assumptions, and sources used here. See our{" "}
        <Link
          href="/editorial-standards"
          className="text-brand-blue hover:underline"
        >
          editorial standards
        </Link>{" "}
        for how we keep the content accurate.
      </p>
    </div>
  );
}

function formatReviewDate(isoDate: string): string {
  // Parse yyyy-mm-dd defensively — if malformed, fall back to the raw string
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(isoDate);
  if (!match) return isoDate;
  const [, year, month] = match;
  const monthName = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ][parseInt(month, 10) - 1];
  return `${monthName} ${year}`;
}
