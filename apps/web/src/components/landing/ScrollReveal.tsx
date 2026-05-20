"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";

interface ScrollRevealProps {
  children: ReactNode;
  className?: string;
  /** Stagger delay in ms applied to each direct child (for grids) */
  stagger?: number;
  /** Viewport threshold 0-1 to trigger */
  threshold?: number;
  /** Animation direction */
  direction?: "up" | "left" | "right" | "scale";
  /** Only animate once */
  once?: boolean;
}

export function ScrollReveal({
  children,
  className = "",
  stagger = 0,
  threshold = 0.15,
  direction = "up",
  once = true,
}: ScrollRevealProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    // Respect prefers-reduced-motion
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mediaQuery.matches) {
      setIsVisible(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          if (once) observer.unobserve(el);
        } else if (!once) {
          setIsVisible(false);
        }
      },
      { threshold, rootMargin: "0px 0px -40px 0px" }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [threshold, once]);

  const baseTransform = {
    up: "translateY(32px)",
    left: "translateX(32px)",
    right: "translateX(-32px)",
    scale: "scale(0.95)",
  }[direction];

  return (
    <div
      ref={ref}
      className={className}
      style={{
        // Apply stagger via CSS custom property — children use it
        ...(stagger > 0 ? { "--stagger": `${stagger}ms` } as React.CSSProperties : {}),
      }}
    >
      {stagger > 0 && Array.isArray(children)
        ? // Staggered children: each child gets its own reveal
          children.map((child, i) => (
            <div
              key={i}
              style={{
                opacity: isVisible ? 1 : 0,
                transform: isVisible ? "none" : baseTransform,
                transition: `opacity 0.5s ease-out ${i * stagger}ms, transform 0.5s ease-out ${i * stagger}ms`,
                height: "100%",
                minHeight: 0,
              }}
            >
              {child}
            </div>
          ))
        : // Single element reveal
          <div
            style={{
              opacity: isVisible ? 1 : 0,
              transform: isVisible ? "none" : baseTransform,
              transition: "opacity 0.6s ease-out, transform 0.6s ease-out",
            }}
          >
            {children}
          </div>
      }
    </div>
  );
}
