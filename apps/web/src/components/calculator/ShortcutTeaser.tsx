import { Zap, ArrowRight } from "lucide-react";

const APP_STORE_URL = "https://apps.apple.com/app/numind"; // placeholder

interface ShortcutTeaserProps {
  teaser: string;
  className?: string;
}

/**
 * Compact inline teaser shown right below the calculator widget.
 * Highest-visibility spot — users see this immediately after getting their answer.
 * Shows a one-line mental math trick + a subtle app CTA.
 */
export function ShortcutTeaser({ teaser, className = "" }: ShortcutTeaserProps) {
  return (
    <div
      className={`flex items-start gap-3 rounded-xl border border-brand-yellow/20 bg-brand-yellow/[0.06] px-4 py-3.5 ${className}`}
    >
      <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-brand-yellow/20">
        <Zap size={14} strokeWidth={2} className="text-brand-navy" aria-hidden="true" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-brand-navy leading-snug">
          {teaser}
        </p>
        <a
          href={APP_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="group/cta mt-1.5 inline-flex items-center gap-1 text-xs font-semibold text-brand-blue hover:text-brand-blue/80 transition-colors"
        >
          Practice until you don&apos;t need this calculator
          <ArrowRight
            size={12}
            className="transition-transform duration-200 group-hover/cta:translate-x-0.5"
            aria-hidden="true"
          />
        </a>
      </div>
    </div>
  );
}
