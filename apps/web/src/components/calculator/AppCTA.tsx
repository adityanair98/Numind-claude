import { Brain } from "lucide-react";
import { PillButton } from "@/components/ui/PillButton";

const APP_STORE_URL = "https://apps.apple.com/app/numind"; // placeholder

interface AppCTAProps {
  className?: string;
}

export function AppCTA({ className = "" }: AppCTAProps) {
  return (
    <section
      className={`rounded-card bg-brand-navy p-card text-center sm:p-8 ${className}`}
    >
      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-brand-teal/15">
        <Brain size={24} strokeWidth={1.75} className="text-brand-teal" aria-hidden="true" />
      </div>
      <h2 className="font-display text-xl font-bold text-white sm:text-2xl">
        Do this math in your head
      </h2>
      <p className="mx-auto mt-2 max-w-md text-sm text-white/60 leading-relaxed">
        This calculator gives you the answer. Numind trains you to get that answer in
        your head in 3 seconds — at the dinner table, in a job interview, while apartment
        shopping.
      </p>
      <div className="mt-5">
        <PillButton href={APP_STORE_URL} external>
          Download for iOS — Free Trial
        </PillButton>
      </div>
      <p className="mt-3 text-xs text-white/40">
        10 modules &middot; 56 lessons &middot; 275 practice questions
      </p>
    </section>
  );
}
