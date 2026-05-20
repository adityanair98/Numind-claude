import { Lightbulb } from "lucide-react";
import type { ShortcutContent } from "@/components/calculator/CalculatorShell";

interface MentalMathCardProps {
  shortcut: ShortcutContent;
  className?: string;
}

export function MentalMathCard({ shortcut, className = "" }: MentalMathCardProps) {
  return (
    <div className={`rounded-card bg-brand-yellow-tint border border-brand-yellow/20 p-card ${className}`}>
      <div className="flex items-start gap-3">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-yellow/25">
          <Lightbulb size={18} strokeWidth={1.75} className="text-brand-navy" aria-hidden="true" />
        </div>
        <div className="flex-1">
          <h2 className="font-display text-lg font-bold text-brand-navy">
            {shortcut.title}
          </h2>

          <ol className="mt-3 space-y-2">
            {shortcut.steps.map((step, i) => (
              <li key={i} className="flex gap-3 text-sm text-brand-navy/80">
                <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-brand-yellow/30 text-xs font-bold text-brand-navy">
                  {i + 1}
                </span>
                {step}
              </li>
            ))}
          </ol>

          <div className="mt-4 rounded-button bg-white/60 px-4 py-3">
            <p className="text-xs font-medium text-brand-muted uppercase tracking-wider mb-1">
              Example
            </p>
            <p className="text-sm text-brand-navy">{shortcut.example}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
