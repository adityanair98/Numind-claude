import Link from "next/link";
import { calculatorRegistry } from "@/lib/content/calculators";
import { CalculatorIcon } from "@/components/ui/CalculatorIcon";

interface RelatedToolsProps {
  slugs: string[];
  className?: string;
}

export function RelatedTools({ slugs, className = "" }: RelatedToolsProps) {
  const tools = slugs
    .map((slug) => calculatorRegistry.find((c) => c.slug === slug))
    .filter(Boolean);

  if (tools.length === 0) return null;

  return (
    <section className={className}>
      <h2 className="font-display text-xl font-bold text-brand-navy mb-4">
        Related Tools
      </h2>
      <div className="grid gap-3 sm:grid-cols-2">
        {tools.map((tool) => (
          <Link
            key={tool!.slug}
            href={`/tools/${tool!.slug}`}
            className="group cursor-pointer flex items-start gap-3 rounded-card border border-brand-muted/10 bg-brand-card p-card hover:border-brand-blue/30 hover:shadow-[0_2px_12px_rgba(47,107,255,0.08)] transition-all duration-200"
          >
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-icon-tile bg-brand-blue-tint">
              <CalculatorIcon name={tool!.icon} size={18} className="text-brand-blue" />
            </div>
            <div>
              <h3 className="font-display text-sm font-bold text-brand-navy group-hover:text-brand-blue transition-colors duration-200">
                {tool!.name}
              </h3>
              <p className="mt-1 text-xs text-brand-muted line-clamp-2">
                {tool!.description}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
