import Link from "next/link";
import {
  UtensilsCrossed,
  Tag,
  Briefcase,
  Home,
  BarChart3,
  CreditCard,
  Zap,
  BookOpen,
  Target,
  ArrowRight,
} from "lucide-react";
import { PillButton } from "@/components/ui/PillButton";
import { calculatorRegistry } from "@/lib/content/calculators";
import { CalculatorIcon } from "@/components/ui/CalculatorIcon";
import { ScrollReveal } from "@/components/landing/ScrollReveal";
import { AnimatedCounter } from "@/components/landing/AnimatedCounter";
import { AnimatedProgressBar } from "@/components/landing/AnimatedProgressBar";

const APP_STORE_URL = "https://apps.apple.com/app/numind"; // placeholder

const problemCards = [
  { Icon: UtensilsCrossed, text: "Splitting a dinner bill with friends" },
  { Icon: Tag, text: "Figuring out if that sale is actually good" },
  { Icon: Briefcase, text: "Comparing job offers and salary conversions" },
  { Icon: Home, text: "Checking if you can afford that apartment" },
  { Icon: BarChart3, text: "Understanding your paycheck deductions" },
  { Icon: CreditCard, text: "Estimating how much that loan really costs" },
];

const howItWorks = [
  {
    Icon: BookOpen,
    title: "Learn the shortcut",
    description: "Each lesson teaches a mental math trick for a real-world scenario.",
  },
  {
    Icon: Zap,
    title: "Practice with quizzes",
    description: "Adaptive quizzes build speed and accuracy through daily reps.",
  },
  {
    Icon: Target,
    title: "Track your progress",
    description: "Watch your number sense grow across 10 modules and 47 lessons.",
  },
];

export default function HomePage() {
  return (
    <>
      {/* ═══════════════════════════════════
          HERO — 3D gradient mesh, depth layers
          ═══════════════════════════════════ */}
      <section className="relative overflow-hidden bg-brand-navy">
        {/* Animated gradient mesh orbs */}
        <div className="absolute inset-0 opacity-40">
          <div className="absolute -top-32 -left-32 h-[500px] w-[500px] rounded-full bg-brand-blue/30 blur-[120px] animate-orb-1" />
          <div className="absolute top-1/2 right-0 h-[400px] w-[400px] rounded-full bg-brand-teal/25 blur-[100px] animate-orb-2" />
          <div className="absolute bottom-0 left-1/3 h-[300px] w-[300px] rounded-full bg-brand-yellow/15 blur-[80px] animate-orb-3" />
        </div>

        {/* Subtle grid pattern overlay */}
        <div
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage:
              "linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)",
            backgroundSize: "60px 60px",
          }}
        />

        <div className="relative mx-auto max-w-5xl px-screen py-20 sm:py-28">
          <div className="grid items-center gap-12 lg:grid-cols-2">
            {/* Copy */}
            <div className="text-center lg:text-left">
              <div className="animate-fade-in-up">
                <p className="inline-flex items-center gap-2 rounded-pill bg-brand-teal/10 px-4 py-1.5 text-xs font-semibold text-brand-teal uppercase tracking-wider">
                  <span className="h-1.5 w-1.5 rounded-full bg-brand-teal animate-pulse" />
                  Practical number sense
                </p>
              </div>

              <h1
                className="mt-6 font-display text-4xl font-bold leading-[1.1] text-white sm:text-5xl lg:text-[3.5rem] animate-fade-in-up"
                style={{ animationDelay: "100ms" }}
              >
                Get faster at
                <br />
                everyday{" "}
                <span
                  className="bg-clip-text text-transparent animate-shimmer"
                  style={{
                    backgroundImage: "linear-gradient(90deg, #2DC6B6, #2F6BFF, #2DC6B6)",
                    backgroundSize: "200% auto",
                  }}
                >
                  money math
                </span>
              </h1>

              <p
                className="mx-auto mt-5 max-w-lg text-lg text-white/55 leading-relaxed lg:mx-0 animate-fade-in-up"
                style={{ animationDelay: "200ms" }}
              >
                Short daily lessons that build the number skills you actually use — splitting
                bills, judging discounts, comparing salaries.
              </p>

              <div
                className="mt-8 flex flex-col items-center gap-3 sm:flex-row lg:justify-start animate-fade-in-up"
                style={{ animationDelay: "300ms" }}
              >
                <PillButton
                  href={APP_STORE_URL}
                  external
                  className="animate-glow-pulse"
                >
                  Download for iOS — Free Trial
                </PillButton>
                <PillButton href="/tools" variant="secondary">
                  Try Free Calculators
                </PillButton>
              </div>

              {/* Animated stat counters */}
              <div
                className="mt-6 flex items-center justify-center gap-6 lg:justify-start animate-fade-in-up"
                style={{ animationDelay: "500ms" }}
              >
                <div className="text-center">
                  <AnimatedCounter value={5} suffix=" min" className="text-lg font-bold text-white" />
                  <p className="text-[10px] text-white/30 uppercase tracking-wider">per day</p>
                </div>
                <div className="h-6 w-px bg-white/10" />
                <div className="text-center">
                  <AnimatedCounter value={10} className="text-lg font-bold text-white" />
                  <p className="text-[10px] text-white/30 uppercase tracking-wider">modules</p>
                </div>
                <div className="h-6 w-px bg-white/10" />
                <div className="text-center">
                  <AnimatedCounter value={47} className="text-lg font-bold text-white" />
                  <p className="text-[10px] text-white/30 uppercase tracking-wider">lessons</p>
                </div>
              </div>
            </div>

            {/* 3D App preview card — perspective floating */}
            <div
              className="hidden lg:flex justify-center animate-fade-in-up"
              style={{ animationDelay: "300ms", perspective: "1200px" }}
            >
              <div
                className="relative animate-float"
                style={{
                  transformStyle: "preserve-3d",
                  transform: "rotateY(-8deg) rotateX(4deg)",
                }}
              >
                {/* Animated glow behind card */}
                <div className="absolute -inset-6 rounded-[32px] bg-brand-blue/20 blur-2xl animate-glow-pulse" />

                {/* Main card */}
                <div className="relative w-72 rounded-[28px] border border-white/10 bg-gradient-to-br from-white/[0.12] to-white/[0.04] p-8 backdrop-blur-sm shadow-[0_32px_64px_rgba(0,0,0,0.4),0_16px_32px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.1)]">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-brand-teal to-brand-blue flex items-center justify-center">
                      <span className="font-display text-lg font-bold text-white">N</span>
                    </div>
                    <div>
                      <p className="font-display text-sm font-bold text-white">Numind</p>
                      <p className="text-xs text-white/40">Daily mental math</p>
                    </div>
                  </div>

                  {/* Animated progress bars */}
                  <div className="space-y-3">
                    <AnimatedProgressBar label="Tipping" pct={92} colorClass="bg-brand-teal" delay={600} />
                    <AnimatedProgressBar label="Salary Math" pct={68} colorClass="bg-brand-blue" delay={800} />
                    <AnimatedProgressBar label="Percentages" pct={85} colorClass="bg-brand-yellow" delay={1000} />
                  </div>

                  {/* Streak badge */}
                  <div className="mt-6 flex items-center justify-center gap-2 rounded-pill bg-brand-yellow/10 py-2.5 px-4">
                    <Zap size={14} className="text-brand-yellow" />
                    <span className="text-xs font-semibold text-brand-yellow">
                      <AnimatedCounter value={12} duration={800} /> day streak
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom fade to page bg */}
        <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-brand-bg to-transparent" />
      </section>

      {/* ═══════════════════════════════════
          PROBLEM STATEMENT — scroll-reveal staggered cards
          ═══════════════════════════════════ */}
      <section className="mx-auto max-w-5xl px-screen py-16 sm:py-20">
        <ScrollReveal>
          <div className="text-center mb-10">
            <h2 className="font-display text-2xl font-bold text-brand-navy sm:text-3xl">
              You probably reach for a calculator when...
            </h2>
            <p className="mt-2 text-brand-muted max-w-md mx-auto">
              These everyday moments should be instant. They can be.
            </p>
          </div>
        </ScrollReveal>

        <ScrollReveal stagger={100} className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {problemCards.map((item) => (
            <div
              key={item.text}
              className="group relative rounded-card bg-brand-card p-card cursor-default shadow-[0_2px_8px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_24px_rgba(16,34,74,0.08),0_2px_6px_rgba(16,34,74,0.04)] hover:-translate-y-0.5 transition-all duration-300"
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-icon-tile bg-brand-blue-tint mb-3 transition-colors duration-200 group-hover:bg-brand-blue/15">
                <item.Icon size={20} strokeWidth={1.75} className="text-brand-blue transition-transform duration-300 group-hover:scale-110" />
              </div>
              <p className="text-sm font-medium text-brand-navy leading-relaxed">{item.text}</p>
            </div>
          ))}
        </ScrollReveal>
      </section>

      {/* ═══════════════════════════════════
          HOW IT WORKS — scroll-reveal staggered pillars
          ═══════════════════════════════════ */}
      <section className="bg-brand-card border-y border-brand-muted/10">
        <div className="mx-auto max-w-5xl px-screen py-16 sm:py-20">
          <ScrollReveal>
            <div className="text-center mb-12">
              <h2 className="font-display text-2xl font-bold text-brand-navy sm:text-3xl">
                How Numind works
              </h2>
              <p className="mt-2 text-brand-muted max-w-md mx-auto">
                Three steps, five minutes a day. Your number sense gets sharper every session.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal stagger={150} className="grid gap-8 sm:grid-cols-3">
            {howItWorks.map((step, i) => (
              <div key={step.title} className="text-center group">
                <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-brand-navy shadow-[0_4px_16px_rgba(16,34,74,0.15)] transition-transform duration-300 group-hover:scale-110 group-hover:shadow-[0_8px_24px_rgba(16,34,74,0.25)]">
                  <step.Icon size={24} strokeWidth={1.75} className="text-brand-teal" />
                </div>
                <div className="mb-2 flex items-center justify-center gap-2">
                  <span className="flex h-5 w-5 items-center justify-center rounded-full bg-brand-blue-tint text-[10px] font-bold text-brand-blue">
                    {i + 1}
                  </span>
                  <h3 className="font-display text-base font-bold text-brand-navy">
                    {step.title}
                  </h3>
                </div>
                <p className="text-sm text-brand-muted leading-relaxed">
                  {step.description}
                </p>
              </div>
            ))}
          </ScrollReveal>
        </div>
      </section>

      {/* ═══════════════════════════════════
          FREE TOOLS — scroll-reveal calculator grid
          ═══════════════════════════════════ */}
      <section className="mx-auto max-w-5xl px-screen py-16 sm:py-20">
        <ScrollReveal>
          <div className="text-center mb-10">
            <h2 className="font-display text-2xl font-bold text-brand-navy sm:text-3xl">
              Free calculators, plus the shortcut
            </h2>
            <p className="mt-2 text-brand-muted max-w-md mx-auto">
              Every tool gives you the answer instantly — then teaches you the mental math
              trick behind it.
            </p>
          </div>
        </ScrollReveal>

        <ScrollReveal stagger={80} className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {calculatorRegistry.map((calc) => (
            <Link
              key={calc.slug}
              href={`/tools/${calc.slug}`}
              className="group cursor-pointer flex items-start gap-3 rounded-card border border-brand-muted/10 bg-brand-card p-card hover:border-brand-blue/20 hover:shadow-[0_4px_16px_rgba(47,107,255,0.08)] hover:-translate-y-0.5 transition-all duration-200"
            >
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-icon-tile bg-brand-blue-tint transition-all duration-200 group-hover:bg-brand-blue/15 group-hover:scale-110">
                <CalculatorIcon name={calc.icon} size={20} className="text-brand-blue" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-brand-navy group-hover:text-brand-blue transition-colors duration-200">
                  {calc.name}
                </h3>
                <p className="mt-0.5 text-xs text-brand-muted">{calc.description}</p>
              </div>
            </Link>
          ))}
        </ScrollReveal>

        <ScrollReveal>
          <div className="mt-8 text-center">
            <Link
              href="/tools"
              className="group inline-flex items-center gap-1.5 text-sm font-semibold text-brand-blue hover:text-brand-navy transition-colors duration-200"
            >
              View all tools
              <ArrowRight size={14} className="transition-transform duration-200 group-hover:translate-x-1" />
            </Link>
          </div>
        </ScrollReveal>
      </section>

      {/* ═══════════════════════════════════
          CTA — gradient background, scroll-reveal
          ═══════════════════════════════════ */}
      <section className="relative overflow-hidden">
        {/* Animated gradient background */}
        <div className="absolute inset-0 bg-brand-navy">
          <div className="absolute -top-24 -right-24 h-[400px] w-[400px] rounded-full bg-brand-blue/20 blur-[100px] animate-orb-2" />
          <div className="absolute -bottom-24 -left-24 h-[350px] w-[350px] rounded-full bg-brand-teal/15 blur-[80px] animate-orb-1" />
        </div>

        <div className="relative mx-auto max-w-4xl px-screen py-16 sm:py-20 text-center">
          <ScrollReveal direction="scale">
            <h2 className="font-display text-2xl font-bold text-white sm:text-3xl">
              Ready to ditch the calculator?
            </h2>
            <p className="mx-auto mt-3 max-w-md text-white/55">
              Numind builds real number fluency through short, daily practice.
              Start your free trial today.
            </p>
            <div className="mt-8">
              <PillButton
                href={APP_STORE_URL}
                external
                className="animate-glow-pulse"
              >
                Download for iOS — Free Trial
              </PillButton>
            </div>
            <p className="mt-4 text-xs text-white/25">
              Available on iOS &middot; Cancel anytime
            </p>
          </ScrollReveal>
        </div>
      </section>
    </>
  );
}
