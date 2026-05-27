import Link from "next/link";

const toolLinks = [
  { label: "Paycheck Calculator", href: "/tools/paycheck-calculator" },
  { label: "Salary Converter", href: "/tools/salary-calculator" },
  { label: "Rent Affordability", href: "/tools/rent-calculator" },
  { label: "Investment Calculator", href: "/tools/investment-calculator" },
  { label: "Discount Calculator", href: "/tools/discount-calculator" },
  { label: "Loan Calculator", href: "/tools/loan-calculator" },
];

const companyLinks = [
  { label: "Life-Event Paths", href: "/paths" },
  { label: "About Numind", href: "/about-numind" },
  { label: "Calculator Methodology", href: "/methodology" },
  { label: "Editorial Standards", href: "/editorial-standards" },
  { label: "Privacy Policy", href: "/privacy" },
  { label: "Terms of Service", href: "/terms" },
];

export function Footer() {
  return (
    <footer className="border-t border-brand-muted/10 bg-brand-card">
      <div className="mx-auto max-w-6xl px-screen py-12">
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {/* Brand */}
          <div className="sm:col-span-2 lg:col-span-1">
            <Link href="/" className="font-display text-lg font-bold text-brand-navy">
              <span className="text-brand-teal">N</span>umind
            </Link>
            <p className="mt-2 text-sm text-brand-muted leading-relaxed">
              Financial education through mental math. Become financially fluent in 5 minutes a day.
            </p>
          </div>

          {/* Free Tools */}
          <div>
            <h3 className="text-sm font-semibold text-brand-navy">Free Tools</h3>
            <ul className="mt-3 space-y-2">
              {toolLinks.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-brand-muted hover:text-brand-navy transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h3 className="text-sm font-semibold text-brand-navy">Company</h3>
            <ul className="mt-3 space-y-2">
              {companyLinks.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-brand-muted hover:text-brand-navy transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Download */}
          <div>
            <h3 className="text-sm font-semibold text-brand-navy">Get the App</h3>
            <p className="mt-3 text-sm text-brand-muted">
              Available on iOS. Learn the mental math behind every calculator on this site.
            </p>
            <a
              href="https://apps.apple.com/app/numind"
              target="_blank"
              rel="noopener noreferrer"
              className="mt-3 inline-block cursor-pointer rounded-button bg-brand-navy px-5 py-2.5 text-sm font-medium text-white hover:bg-brand-navy/90 transition-colors duration-200"
            >
              Download for iOS
            </a>
          </div>
        </div>

        <div className="mt-10 border-t border-brand-muted/10 pt-6 text-center text-xs text-brand-muted">
          &copy; {new Date().getFullYear()} Numind. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
