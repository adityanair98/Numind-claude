import type { Metadata } from "next";
import { buildMetadata } from "@/lib/seo/metadata";

export const metadata: Metadata = buildMetadata({
  title: "Privacy Policy",
  description: "Numind privacy policy. Learn how we handle your data.",
  path: "/privacy",
});

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-screen py-section">
      <h1 className="font-display text-3xl font-bold text-brand-navy mb-6">Privacy Policy</h1>
      <div className="prose prose-brand-navy max-w-none space-y-4 text-brand-muted leading-relaxed">
        <p className="text-sm text-brand-muted">Last updated: May 2025</p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Overview</h2>
        <p>
          Numind (&quot;we&quot;, &quot;our&quot;, &quot;us&quot;) is a mobile application that helps users build
          practical mental math skills. This privacy policy explains how we collect, use, and protect your information.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Information We Collect</h2>
        <p>
          <strong>Account information:</strong> When you create an account, we collect your email address
          and authentication credentials (or Apple ID if using Sign in with Apple).
        </p>
        <p>
          <strong>Usage data:</strong> We collect anonymized usage data including lesson completion,
          quiz performance, and app engagement to improve the product. This data is not sold to third parties.
        </p>
        <p>
          <strong>Website calculators:</strong> Our free web calculators run entirely in your browser.
          No calculation inputs or results are sent to our servers.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">How We Use Your Information</h2>
        <p>We use your information to:</p>
        <ul className="list-disc pl-6 space-y-1">
          <li>Provide and improve the Numind app experience</li>
          <li>Sync your progress across devices</li>
          <li>Send streak reminders and relevant notifications (with your permission)</li>
          <li>Analyze aggregated usage patterns to improve content</li>
        </ul>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Data Security</h2>
        <p>
          We use industry-standard security measures to protect your data. Authentication is handled
          through Supabase with encrypted connections. Payment processing is handled entirely by Apple
          through the App Store — we never see or store your payment information.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Your Rights</h2>
        <p>
          You can request deletion of your account and all associated data at any time by contacting us.
          You can also export your data or modify your notification preferences within the app.
        </p>

        <h2 className="font-display text-xl font-bold text-brand-navy mt-8">Contact</h2>
        <p>
          If you have questions about this privacy policy, contact us at{" "}
          <a href="mailto:privacy@numind.app" className="text-brand-blue underline underline-offset-2">
            privacy@numind.app
          </a>.
        </p>
      </div>
    </div>
  );
}
