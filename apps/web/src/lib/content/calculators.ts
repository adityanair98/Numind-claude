export type CalculatorIconName =
  | "wallet"
  | "arrow-left-right"
  | "home"
  | "trending-up"
  | "tag"
  | "landmark";

export interface CalculatorInfo {
  name: string;
  slug: string;
  description: string;
  icon: CalculatorIconName;
}

export const calculatorRegistry: CalculatorInfo[] = [
  {
    name: "Paycheck Calculator",
    slug: "paycheck-calculator",
    description:
      "Estimate your take-home pay after federal, state, and FICA taxes.",
    icon: "wallet",
  },
  {
    name: "Salary Converter",
    slug: "salary-calculator",
    description:
      "Convert between hourly, weekly, biweekly, monthly, and annual pay.",
    icon: "arrow-left-right",
  },
  {
    name: "Rent Affordability",
    slug: "rent-calculator",
    description:
      "Find out how much rent you can afford based on your income.",
    icon: "home",
  },
  {
    name: "Investment Calculator",
    slug: "investment-calculator",
    description:
      "See how your money grows with compound interest over time.",
    icon: "trending-up",
  },
  {
    name: "Discount Calculator",
    slug: "discount-calculator",
    description:
      "Calculate savings and final price for any percent-off discount.",
    icon: "tag",
  },
  {
    name: "Loan Calculator",
    slug: "loan-calculator",
    description:
      "Estimate total interest and repayment timeline for any loan.",
    icon: "landmark",
  },
];
