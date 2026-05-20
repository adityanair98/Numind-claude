import { AnimatedValue } from "@/components/calculator/AnimatedValue";

interface BreakdownItem {
  label: string;
  value: string;
  highlight?: boolean;
}

interface CalculatorOutputProps {
  /** The primary result label (e.g., "Your take-home pay") */
  label: string;
  /** The primary formatted result (e.g., "$3,846") */
  value: string;
  /** Optional period suffix (e.g., "/month") */
  period?: string;
  /** Breakdown table below the primary result */
  breakdown?: BreakdownItem[];
  className?: string;
}

export function CalculatorOutput({
  label,
  value,
  period,
  breakdown,
  className = "",
}: CalculatorOutputProps) {
  return (
    <div className={`rounded-card bg-brand-navy p-card text-white ${className}`}>
      <p className="text-sm text-white/60">{label}</p>
      <p className="mt-1 font-display text-4xl font-bold tracking-tight tabular-nums">
        <AnimatedValue value={value} />
        {period && <span className="text-lg font-normal text-white/50"> {period}</span>}
      </p>

      {breakdown && breakdown.length > 0 && (
        <div className="mt-4 space-y-2 border-t border-white/10 pt-4">
          {breakdown.map((item) => (
            <div key={item.label} className="flex items-center justify-between text-sm">
              <span className={item.highlight ? "text-white font-medium" : "text-white/60"}>
                {item.label}
              </span>
              <span className={`tabular-nums ${item.highlight ? "text-brand-teal font-semibold" : "text-white/80"}`}>
                <AnimatedValue value={item.value} />
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
