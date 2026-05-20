"use client";

import { useEffect, useRef, useState } from "react";

interface AnimatedValueProps {
  /** Formatted string like "$2,352" — extracts the number and animates it */
  value: string;
  className?: string;
}

/**
 * Extracts the numeric portion from a formatted currency/percentage string,
 * animates it from the previous value to the new one, and preserves the
 * original formatting (prefix, suffix, decimals).
 */
export function AnimatedValue({ value, className = "" }: AnimatedValueProps) {
  const prevValue = useRef(value);
  const [display, setDisplay] = useState(value);
  const rafRef = useRef<number>(0);

  useEffect(() => {
    // Respect prefers-reduced-motion
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mediaQuery.matches) {
      setDisplay(value);
      prevValue.current = value;
      return;
    }

    const from = parseNumeric(prevValue.current);
    const to = parseNumeric(value);

    // If we can't parse either, just snap
    if (from === null || to === null || from === to) {
      setDisplay(value);
      prevValue.current = value;
      return;
    }

    const duration = 400; // ms — snappy
    const start = performance.now();

    const step = (now: number) => {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      // Ease-out cubic for snappy feel
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = from + (to - from) * eased;
      setDisplay(formatLike(value, current));

      if (progress < 1) {
        rafRef.current = requestAnimationFrame(step);
      } else {
        setDisplay(value);
        prevValue.current = value;
      }
    };

    cancelAnimationFrame(rafRef.current);
    rafRef.current = requestAnimationFrame(step);

    return () => cancelAnimationFrame(rafRef.current);
  }, [value]);

  return <span className={className}>{display}</span>;
}

/** Extract the first number from a formatted string */
function parseNumeric(str: string): number | null {
  // Remove currency symbols, commas, whitespace — keep digits, dots, minus
  const cleaned = str.replace(/[^0-9.\-]/g, "");
  const num = parseFloat(cleaned);
  return isNaN(num) ? null : num;
}

/** Format a number to match the style of the template string */
function formatLike(template: string, num: number): string {
  // Detect if template has decimals
  const decimalMatch = template.match(/\.(\d+)/);
  const decimals = decimalMatch ? decimalMatch[1].length : 0;

  // Detect prefix (everything before the first digit or minus)
  const prefixMatch = template.match(/^([^0-9\-]*)/);
  const prefix = prefixMatch ? prefixMatch[1] : "";

  // Detect suffix (everything after the last digit)
  const suffixMatch = template.match(/[0-9]([^0-9]*)$/);
  const suffix = suffixMatch ? suffixMatch[1] : "";

  const absNum = Math.abs(Math.round(num * Math.pow(10, decimals)) / Math.pow(10, decimals));
  const formatted = absNum.toLocaleString("en-US", {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });

  const sign = num < 0 ? "−" : "";

  return `${prefix}${sign}${formatted}${suffix}`;
}
