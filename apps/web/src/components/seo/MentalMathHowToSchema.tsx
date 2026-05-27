import { StructuredData } from "./StructuredData";
import type { ShortcutContent } from "@/components/calculator/CalculatorShell";

interface MentalMathHowToSchemaProps {
  /** Calculator name, used as part of the HowTo title */
  name: string;
  /** The mental-math shortcut content (steps + example) */
  shortcut: ShortcutContent;
  /** Absolute URL of the calculator page */
  url: string;
}

/**
 * Emits schema.org/HowTo JSON-LD describing the mental-math shortcut as a
 * procedural how-to. Eligible for Google's HowTo rich result (numbered steps
 * displayed in the SERP).
 *
 * The HowTo describes the *mental math* — not "how to use the calculator."
 * The calculator is the answer-now tool; the HowTo is the skill we're
 * teaching users to actually carry around in their head.
 */
export function MentalMathHowToSchema({
  name,
  shortcut,
  url,
}: MentalMathHowToSchemaProps) {
  return (
    <StructuredData
      data={{
        "@context": "https://schema.org",
        "@type": "HowTo",
        name: `${shortcut.title} — do the math behind the ${name} in your head`,
        description: shortcut.teaser,
        url,
        totalTime: "PT2M",
        step: shortcut.steps.map((stepText, idx) => ({
          "@type": "HowToStep",
          position: idx + 1,
          name: `Step ${idx + 1}`,
          text: stepText,
        })),
      }}
    />
  );
}
