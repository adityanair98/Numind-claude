import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";

export const metadata: Metadata = buildMetadata({
  title: "Terms of Service",
  description: "Numind terms of service. Rules and guidelines for using our app and website.",
  path: "/terms",
});

export default function TermsPage() {
  return (
    <div className="mx-auto max-w-3xl px-screen py-section">
      <h1 className="font-display text-3xl font-bold text-brand-navy mb-6">Terms of Service</h1>
      <div className="prose prose-brand-navy max-w-none space-y-4 text-brand-muted leading-relaxed">
        <p className="text-sm text-brand-muted">Last updated: May 2025</p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Acceptance of Terms</h2>
        <p>
          By using the Numind app or website, you agree to these terms of service. If you do not agree,
          please do not use our services.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">The Service</h2>
        <p>
          Numind provides educational content for building practical mental math skills through
          lessons, quizzes, and progress tracking. Our website offers free calculator tools
          for common money math scenarios.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Subscriptions</h2>
        <p>
          Numind offers a free trial followed by a paid subscription. Subscriptions are billed through
          the Apple App Store and are subject to Apple&apos;s terms and conditions. You can cancel your
          subscription at any time through your Apple ID settings.
        </p>
        <p>
          Refunds are handled by Apple according to their refund policy. We do not process payments
          directly.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Calculator Tools</h2>
        <p>
          Our free web calculators are provided for informational and educational purposes only.
          Results are estimates and should not be used as the sole basis for financial decisions.
          Tax calculations are approximations — consult a tax professional for precise figures.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Intellectual Property</h2>
        <p>
          All content, design, and educational material in Numind is owned by us and protected
          by copyright. You may not reproduce, distribute, or create derivative works without
          written permission.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Limitation of Liability</h2>
        <p>
          Numind is an educational tool, not financial advice. We are not liable for any financial
          decisions made based on our calculators or educational content. Use at your own discretion.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Changes to Terms</h2>
        <p>
          We may update these terms from time to time. Continued use of the service after changes
          constitutes acceptance of the updated terms.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Contact</h2>
        <p>
          Questions about these terms? Contact us at{" "}
          <a href="mailto:legal@numind.app" className="text-brand-blue underline underline-offset-2">
            legal@numind.app
          </a>.
        </p>
      </div>
    </div>
  );
}
