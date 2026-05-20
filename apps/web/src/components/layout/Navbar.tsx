"use client";

import Link from "next/link";
import { useState } from "react";
import { PillButton } from "@/components/ui/PillButton";

const APP_STORE_URL = "https://apps.apple.com/app/numind"; // placeholder

export function Navbar() {
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 bg-brand-card/95 backdrop-blur-sm border-b border-brand-muted/10">
      <nav className="mx-auto flex h-16 max-w-6xl items-center justify-between px-screen">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2 font-display text-xl font-bold text-brand-navy">
          <span className="text-brand-teal">N</span>umind
        </Link>

        {/* Desktop links */}
        <div className="hidden items-center gap-8 md:flex">
          <Link href="/tools" className="text-sm font-medium text-brand-muted hover:text-brand-navy transition-colors">
            Free Tools
          </Link>
          <PillButton href={APP_STORE_URL} size="sm" external>
            Get the App
          </PillButton>
        </div>

        {/* Mobile hamburger */}
        <button
          onClick={() => setMobileOpen(!mobileOpen)}
          className="flex cursor-pointer flex-col gap-1.5 md:hidden p-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-blue"
          aria-label="Toggle menu"
        >
          <span className={`block h-0.5 w-5 bg-brand-navy transition-transform ${mobileOpen ? "translate-y-2 rotate-45" : ""}`} />
          <span className={`block h-0.5 w-5 bg-brand-navy transition-opacity ${mobileOpen ? "opacity-0" : ""}`} />
          <span className={`block h-0.5 w-5 bg-brand-navy transition-transform ${mobileOpen ? "-translate-y-2 -rotate-45" : ""}`} />
        </button>
      </nav>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="border-t border-brand-muted/10 bg-brand-card px-screen py-4 md:hidden">
          <Link
            href="/tools"
            className="block py-3 text-sm font-medium text-brand-muted"
            onClick={() => setMobileOpen(false)}
          >
            Free Tools
          </Link>
          <div className="pt-2">
            <PillButton href={APP_STORE_URL} size="sm" external className="w-full">
              Get the App
            </PillButton>
          </div>
        </div>
      )}
    </header>
  );
}
