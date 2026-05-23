export type CalculatorIconName =
  | "wallet"
  | "arrow-left-right"
  | "home"
  | "trending-up"
  | "tag"
  | "landmark"
  | "shield"
  | "car"
  | "graduation-cap"
  | "credit-card"
  | "badge-percent"
  | "key"
  | "heart-pulse"
  | "shield-check";

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
  {
    name: "Insurance Calculator",
    slug: "insurance-calculator",
    description:
      "Compare health plan costs — premiums, deductibles, and out-of-pocket totals.",
    icon: "shield",
  },
  {
    name: "Car Calculator",
    slug: "car-calculator",
    description:
      "Calculate true car cost with the 20/4/10 rule, down payment, and depreciation.",
    icon: "car",
  },
  {
    name: "Student Loan Calculator",
    slug: "student-loan-calculator",
    description:
      "Compare repayment plans, refinancing savings, and PSLF forgiveness amounts.",
    icon: "graduation-cap",
  },
  {
    name: "BNPL Calculator",
    slug: "bnpl-calculator",
    description:
      "See the real cost of Buy Now Pay Later — late fees, surcharge %, and stacked plan debt.",
    icon: "credit-card",
  },
  {
    name: "Membership Break-even",
    slug: "membership-calculator",
    description:
      "Calculate when Costco, DashPass, Uber One, and other memberships actually pay for themselves.",
    icon: "badge-percent",
  },
  {
    name: "Lease vs Buy",
    slug: "lease-vs-buy-calculator",
    description:
      "Compare the true 3-year cost of leasing vs buying a car, including residual value.",
    icon: "key",
  },
  {
    name: "FSA Calculator",
    slug: "fsa-calculator",
    description:
      "Find your FSA break-even election — how much to elect without losing money to use-it-or-lose-it.",
    icon: "heart-pulse",
  },
  {
    name: "Life Insurance Calculator",
    slug: "life-insurance-calculator",
    description:
      "Estimate how much term life insurance you need with the 10× rule and the DIME method.",
    icon: "shield-check",
  },
];
