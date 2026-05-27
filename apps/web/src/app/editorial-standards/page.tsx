import type { Metadata } from "next";
import Link from "next/link";
import { buildMetadata } from "@/lib/seo/metadata";

export const metadata: Metadata = buildMetadata({
  title: "Editorial Standards | Numind",
  description:
    "How Numind keeps financial calculators and lessons accurate: annual review cadence, event-triggered updates, source registry, and pre-merge fact-check checklist.",
  path: "/editorial-standards",
});

export default function EditorialStandardsPage() {
  return (
    <div className="mx-auto max-w-3xl px-screen py-section">
      <h1 className="font-display text-3xl font-bold text-brand-navy mb-3">
        Editorial Standards
      </h1>
      <p className="text-brand-muted mb-10">
        How we keep financial calculators and lessons accurate as tax
        brackets, federal loan rates, and FLSA thresholds drift annually.
      </p>

      <div className="space-y-8 text-brand-muted leading-relaxed">
        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Why this page exists
          </h2>
          <p>
            Finance is YMYL — &quot;Your Money Your Life&quot; in
            Google&apos;s search quality framework. Stale numbers in a
            finance calculator can directly mislead users about their
            taxes, paycheck, loans, or insurance. We treat content
            accuracy as a recurring process, not a one-time event. This
            page documents how that process works, so anyone reviewing
            our content (Google&apos;s quality raters, our own team, the
            user reading a calculator on this site) can verify we have a
            real maintenance discipline behind every number we publish.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Review cadence
          </h2>

          <h3 className="font-display text-base font-semibold text-brand-navy mt-4 mb-2">
            Annual reviews
          </h3>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              <strong>Every January</strong> — federal tax brackets,
              standard deduction, FICA wage cap, Roth/Traditional IRA
              limits, HSA/FSA limits, capital gains brackets, federal
              poverty guidelines. (IRS releases these values in mid-Oct;
              January is when filers begin actually using them.)
            </li>
            <li>
              <strong>Every June</strong> — federal student-loan rates
              (Direct Subsidized, Direct Unsubsidized, Grad Unsubsidized,
              Parent PLUS) and origination fees. (Federal Student Aid sets
              rates based on the May Treasury auction; new rates take
              effect July 1.)
            </li>
            <li>
              <strong>Every November</strong> — IRS announcements for
              next year&apos;s limits (retirement, HSA, FSA, OOP max),
              applied proactively so January users see current values.
            </li>
          </ul>

          <h3 className="font-display text-base font-semibold text-brand-navy mt-6 mb-2">
            Event-triggered reviews
          </h3>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              FLSA threshold court rulings (e.g. the Nov 2024 ruling
              vacating the 2024 DOL salary-threshold increase).
            </li>
            <li>
              SAVE / IDR plan rulings affecting student-loan repayment
              math.
            </li>
            <li>
              Major tax legislation (e.g. OBBBA 2025, TCJA expiration,
              future reform).
            </li>
            <li>
              CFPB rulemaking affecting BNPL, overdraft fees, or other
              consumer-credit standards.
            </li>
            <li>
              State-level rent control / lease law changes for major
              markets (NY, CA).
            </li>
            <li>
              HSA / HDHP threshold updates that take effect mid-year.
            </li>
          </ul>

          <h3 className="font-display text-base font-semibold text-brand-navy mt-6 mb-2">
            Quarterly housekeeping
          </h3>
          <p>
            First Monday of each quarter we audit lessons that haven&apos;t
            been re-verified within the last 12 months, sweep recent
            regulatory news, and refresh anything that&apos;s drifted.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Source standards
          </h2>
          <p>
            Every regulated number traces back to a primary US authority
            (IRS, SSA, DOL, Federal Student Aid, CFPB, FDIC, HHS, FDA, or
            an S&amp;P/SPIVA-style data publisher). When we cite a
            number, we name the source inline in the lesson or calculator
            so users can verify it themselves. The full per-topic
            authority registry lives in the calculator{" "}
            <Link href="/methodology" className="text-brand-blue hover:underline">
              methodology page
            </Link>
            .
          </p>
          <p className="mt-3">
            When a number is a rule-of-thumb rather than a regulated
            value (e.g. the &quot;1% rule&quot; for rental cash flow, the
            &quot;120 minus your age&quot; allocation rule), we label it
            as such, name its origin, and avoid presenting it as
            universal law.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Pre-merge fact-check checklist
          </h2>
          <p className="mb-3">
            Every pull request that touches regulated content has to pass
            this checklist before merging:
          </p>
          <ul className="list-disc pl-6 space-y-1 text-sm">
            <li>Lesson or calculator text updated with the new value.</li>
            <li>Underlying code constants updated, if any.</li>
            <li>
              <code className="text-xs">lastReviewed</code> bumped to
              today on every touched entry.
            </li>
            <li>
              Inline citation added (authority named in parentheses next
              to the new value).
            </li>
            <li>
              Authority URL linked in the pull-request description.
            </li>
            <li>Full test suite passes (39 iOS tests + web build).</li>
            <li>
              Reference-integrity checks: no orphan template IDs, no
              missing references.
            </li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            What &quot;last reviewed&quot; means on a calculator page
          </h2>
          <p>
            Each calculator page shows the date of its most recent
            editorial review. A review means: we re-confirmed every
            quoted number against its primary source, checked the formula
            against the latest regulatory guidance, and re-ran the math
            against a representative scenario. If a calculator&apos;s
            review date is more than 12 months old, it&apos;s flagged in
            the quarterly housekeeping pass.
          </p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Independence and bias
          </h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              No affiliate links on calculator pages. We don&apos;t
              recommend specific banks, credit cards, or insurance
              providers in exchange for revenue.
            </li>
            <li>
              No advertising. Numind is funded by paid subscriptions to
              the iOS app — the website&apos;s only role is to surface
              the mental-math shortcut and route to the app.
            </li>
            <li>
              No data resale. Calculations run in your browser. See the{" "}
              <Link href="/privacy" className="text-brand-blue hover:underline">
                privacy policy
              </Link>{" "}
              for details.
            </li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-brand-navy mb-3">
            Reporting an error
          </h2>
          <p>
            If you spot a number that looks wrong on a calculator or
            lesson, please email{" "}
            <a
              href="mailto:editorial@numind.app"
              className="text-brand-blue hover:underline"
            >
              editorial@numind.app
            </a>{" "}
            with the page URL, the value, and the source you believe is
            correct. Reports are reviewed within five business days; if
            we agree, the fix ships in the next release.
          </p>
        </section>
      </div>
    </div>
  );
}
