"use client";

import { useEffect, useRef, useState, useCallback } from "react";

type FormatStyle = "currency" | "currency-decimal";

interface AnimatedAnswerProps {
  /** The target numeric value to count to */
  value: number;
  /** Formatting style for the number */
  formatStyle?: FormatStyle;
  className?: string;
}

function formatNumber(n: number, style: FormatStyle): string {
  switch (style) {
    case "currency":
      return n.toLocaleString("en-US", {
        style: "currency",
        currency: "USD",
        maximumFractionDigits: 0,
      });
    case "currency-decimal":
      return n.toLocaleString("en-US", {
        style: "currency",
        currency: "USD",
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      });
    default:
      return n.toLocaleString("en-US");
  }
}

/**
 * A hero-style animated number that counts up from 0 to the target value
 * on first viewport entry. Used for answer-first SEO pages.
 */
export function AnimatedAnswer({
  value,
  formatStyle = "currency",
  className = "",
}: AnimatedAnswerProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const format = useCallback((n: number) => formatNumber(n, formatStyle), [formatStyle]);
  const [display, setDisplay] = useState(format(0));
  const [hasStarted, setHasStarted] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mediaQuery.matches) {
      setDisplay(format(value));
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasStarted) {
          setHasStarted(true);
          observer.disconnect();
        }
      },
      { threshold: 0.2 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [value, format, hasStarted]);

  useEffect(() => {
    if (!hasStarted) return;

    const start = performance.now();
    const duration = 1000;
    let raf: number;

    // For decimal values, animate with more precision
    const isDecimal = formatStyle === "currency-decimal";
    const multiplier = isDecimal ? 100 : 1;
    const targetInt = Math.round(value * multiplier);

    const step = (now: number) => {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = (eased * targetInt) / multiplier;
      setDisplay(format(isDecimal ? current : Math.round(current)));

      if (progress < 1) {
        raf = requestAnimationFrame(step);
      } else {
        setDisplay(format(value));
      }
    };

    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [hasStarted, value, format, formatStyle]);

  return (
    <span ref={ref} className={`tabular-nums ${className}`}>
      {display}
    </span>
  );
}
