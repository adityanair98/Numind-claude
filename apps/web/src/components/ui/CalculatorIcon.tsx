import {
  Wallet,
  ArrowLeftRight,
  Home,
  TrendingUp,
  Tag,
  Landmark,
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
