export default function ToolsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      {/* Breadcrumb nav — shows on all /tools/* pages */}
      <nav
        aria-label="Breadcrumb"
        className="border-b border-brand-navy/5 bg-white"
      >
        <div className="mx-auto max-w-3xl px-screen py-2.5">
          <ol className="flex items-center gap-1.5 text-sm text-brand-muted">
            <li>
              <a href="/" className="hover:text-brand-navy transition-colors">
                Home
              </a>
            </li>
            <li aria-hidden="true" className="select-none">
              ›
            </li>
            <li>
              <a
                href="/tools"
                className="hover:text-brand-navy transition-colors"
              >
                Free Tools
              </a>
            </li>
          </ol>
        </div>
      </nav>
      {children}
    </>
  );
}
