import {
  Wallet,
  ArrowLeftRight,
  Home,
  TrendingUp,
  Tag,
  Landmark,
  Shield,
  Car,
  GraduationCap,
  CreditCard,
  BadgePercent,
  Key,
  HeartPulse,
  ShieldCheck,
  House,
  CalendarClock,
  PiggyBank,
  Banknote,
  Repeat,
  type LucideProps,
} from "lucide-react";
import type { CalculatorIconName } from "@/lib/content/calculators";

const iconMap: Record<CalculatorIconName, React.FC<LucideProps>> = {
  wallet: Wallet,
  "arrow-left-right": ArrowLeftRight,
  home: Home,
  "trending-up": TrendingUp,
  tag: Tag,
  landmark: Landmark,
  shield: Shield,
  car: Car,
  "graduation-cap": GraduationCap,
  "credit-card": CreditCard,
  "badge-percent": BadgePercent,
  key: Key,
  "heart-pulse": HeartPulse,
  "shield-check": ShieldCheck,
  house: House,
  "calendar-clock": CalendarClock,
  "piggy-bank": PiggyBank,
  banknote: Banknote,
  repeat: Repeat,
};

interface CalculatorIconProps {
  name: CalculatorIconName;
  size?: number;
  className?: string;
}

export function CalculatorIcon({
  name,
  size = 24,
  className = "",
}: CalculatorIconProps) {
  const Icon = iconMap[name];
  return <Icon size={size} strokeWidth={1.75} className={className} />;
}
