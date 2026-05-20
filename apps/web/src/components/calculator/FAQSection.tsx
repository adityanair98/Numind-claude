"use client";

import { useState } from "react";

export interface FAQ {
  question: string;
  answer: string;
}

interface FAQSectionProps {
  faqs: FAQ[];
  className?: string;
}

export function FAQSection({ faqs, className = "" }: FAQSectionProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section className={className}>
      <h2 className="font-display text-xl font-bold text-brand-navy mb-4">
        Frequently Asked Questions
      </h2>
      <div className="space-y-2">
        {faqs.map((faq, i) => (
          <div
            key={i}
            className="rounded-button border border-brand-muted/10 bg-brand-card overflow-hidden"
          >
            <button
              onClick={() => setOpenIndex(openIndex === i ? null : i)}
              className="flex w-full cursor-pointer items-center justify-between px-4 py-3.5 text-left text-sm font-medium text-brand-navy hover:bg-brand-muted-tint transition-colors duration-200 focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-brand-blue"
              aria-expanded={openIndex === i}
            >
              {faq.question}
              <svg
                className={`h-4 w-4 shrink-0 text-brand-muted transition-transform ${openIndex === i ? "rotate-180" : ""}`}
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            {openIndex === i && (
              <div className="border-t border-brand-muted/10 px-4 py-3 text-sm text-brand-muted leading-relaxed">
                {faq.answer}
              </div>
            )}
          </div>
        ))}
      </div>
    </section>
  );
}
