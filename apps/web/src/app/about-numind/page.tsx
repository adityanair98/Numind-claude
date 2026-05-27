import type { Metadata } from "next";
import Link from "next/link";
import { buildMetadata } from "@/lib/seo/metadata";

export const metadata: Metadata = buildMetadata({
  title: "About Numind — Financial Education Through Mental Math",
  description:
    "Numind teaches the math behind every real money decision so financial literacy becomes usable, not just memorizable. Learn what we build and why.",
  path: "/about-numind",
});

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-screen py-section">
      <h1 className="font-display text-3xl font-bold text-brand-navy mb-6">
        About Numind
      </h1>

      <div className="space-y-5 text-brand-muted leading-relaxed">
        <p className="text-lg text-brand-navy">
          Numind is a financial education app that heavily uses math as its
          teaching method.
        </p>

        <p>
          Every other financial-literacy app teaches concepts. They explain
          what compound interest is, what an income-driven repayment plan is,
          what the 20/4/10 car rule is. They stop there. Numind keeps going:
          we teach you the <em>mental math</em> behind each concept so you
          can actually use it the next time the situation comes up — at the
          restaurant, the dealership, on a job-offer call, during open
          enrollment, while comparing two health plans, while signing a
          lease.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-10 mb-3">
          What we build
        </h2>
        <p>
          The iOS app is the product. It contains 102 lessons across 10
          modules — Smart Shopping, Budgets, Salary, Investing, Debt,
          Housing, Taxes, Insurance, Car &amp; Big Purchases, and Student
          Loans. Each lesson is a financial literacy unit delivered as a{" "}
          <strong className="text-brand-navy">concept</strong> (the rule,
          plus the nuance most apps skip), a{" "}
          <strong className="text-brand-navy">shortcut</strong> (the mental
          math move that makes the concept usable in real time), and a{" "}
          <strong className="text-brand-navy">quiz</strong> (parametric
          practice with fresh numbers every retry).
        </p>
        <p>
          About one in five lessons covers material where the right teaching
          isn&apos;t arithmetic — credit-score factor weights, FLSA exempt
          classification, the post-SAVE student-loan landscape, asset
          allocation, dealer tactics, insurance policy priority. Those are
          concept-only lessons with text-MCQ questions. Together, the
          numerical lessons and concept lessons form one curriculum: math
          where math helps, concept where it doesn&apos;t.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-10 mb-3">
          The website
        </h2>
        <p>
          The free calculators on this site are an acquisition channel for
          the iOS app, not the product itself. Each calculator answers a
          high-volume search query (mortgage affordability, paycheck math,
          401(k) impact, credit card payoff time, etc.) and then surfaces
          the mental-math shortcut Numind teaches — the same shortcut you
          can carry around in your head once you&apos;ve practiced it. The
          calculator is the answer-now tool; the app is the skill-building
          loop.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-10 mb-3">
          Who we&apos;re for
        </h2>
        <p>
          Adults and young adults, roughly ages 22-40, who want to be
          financially competent and confident — without enrolling in a
          course, reading a personal-finance book, or sitting through a
          YouTube finance bro. The recurring pain isn&apos;t &quot;I
          don&apos;t know what compound interest is&quot; — it&apos;s
          &quot;I can&apos;t quickly tell if this deal is good right now.&quot;
          Numind solves that by training the mental math you can pull up at
          the moment a decision actually happens.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-10 mb-3">
          How we keep content accurate
        </h2>
        <p>
          Finance content is YMYL — &quot;Your Money Your Life.&quot; Stale
          numbers mislead users, and the cost of misleading anyone about
          their taxes, loans, or insurance is real. We treat content
          accuracy as a recurring process, not a one-time event. Read more
          on the{" "}
          <Link href="/methodology" className="text-brand-blue hover:underline">
            methodology page
          </Link>{" "}
          (which formulas each calculator uses, plus authority sources) and{" "}
          <Link
            href="/editorial-standards"
            className="text-brand-blue hover:underline"
          >
            editorial standards page
          </Link>{" "}
          (the cadence and review process behind every number we publish).
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-10 mb-3">
          Numind, briefly
        </h2>
        <p>
          <strong>Founded:</strong> 2024. <strong>Built in:</strong> Swift +
          SwiftUI (iOS), Next.js + Tailwind (web). <strong>Funded by:</strong>{" "}
          paid subscriptions to the iOS app — no ads, no data resale, no
          affiliate-link biases on the calculators. Calculations on this
          site run entirely in your browser (see our{" "}
          <Link href="/privacy" className="text-brand-blue hover:underline">
            privacy policy
          </Link>
          ).
        </p>
      </div>
    </div>
  );
}
