import { type ReactNode } from "react";

interface NumindCardProps {
  children: ReactNode;
  className?: string;
  /** Override the default white background */
  tint?: "blue" | "teal" | "yellow" | "muted";
}

const tintClasses: Record<string, string> = {
  blue: "bg-brand-blue-tint",
  teal: "bg-brand-teal-tint",
  yellow: "bg-brand-yellow-tint",
  muted: "bg-brand-muted-tint",
};

export function NumindCard({ children, className = "", tint }: NumindCardProps) {
  const bg = tint ? tintClasses[tint] : "bg-brand-card shadow-[0_2px_8px_rgba(0,0,0,0.06)]";

  return (
    <div className={`rounded-card p-card ${bg} ${className}`}>
      {children}
    </div>
  );
}
