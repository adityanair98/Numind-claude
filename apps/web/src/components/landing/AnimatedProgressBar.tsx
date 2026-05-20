"use client";

import { useEffect, useRef, useState } from "react";

interface AnimatedProgressBarProps {
  label: string;
  pct: number;
  colorClass: string;
  /** Delay before animation starts (ms) */
  delay?: number;
}

export function AnimatedProgressBar({
  label,
  pct,
  colorClass,
  delay = 0,
}: AnimatedProgressBarProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [width, setWidth] = useState(0);
  const [displayPct, setDisplayPct] = useState(0);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mediaQuery.matches) {
      setWidth(pct);
      setDisplayPct(pct);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          const timeout = setTimeout(() => {
            setWidth(pct);

            // Animate the number
            const start = performance.now();
            const duration = 800;
            let raf: number;

            const step = (now: number) => {
              const elapsed = now - start;
              const progress = Math.min(elapsed / duration, 1);
              const eased = 1 - Math.pow(1 - progress, 3);
              setDisplayPct(Math.round(eased * pct));
              if (progress < 1) raf = requestAnimationFrame(step);
            };

            raf = requestAnimationFrame(step);
          }, delay);

          observer.disconnect();
          return () => clearTimeout(timeout);
        }
      },
      { threshold: 0.3 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [pct, delay]);

  return (
    <div ref={ref}>
      <div className="flex justify-between text-xs mb-1">
        <span className="text-white/60">{label}</span>
        <span className="text-white/40 tabular-nums">{displayPct}%</span>
      </div>
      <div className="h-1.5 rounded-full bg-white/10 overflow-hidden">
        <div
          className={`h-full rounded-full ${colorClass} transition-all duration-1000 ease-out`}
          style={{ width: `${width}%` }}
        />
      </div>
    </div>
  );
}
