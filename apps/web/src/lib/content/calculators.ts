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
  | "shield-check"
  | "house"
  | "calendar-clock"
  | "piggy-bank"
  | "banknote"
  | "repeat";

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
  {
    name: "House Affordability",
    slug: "house-affordability-calculator",
    description:
      "Max purchase price from income, mortgage rate, down payment, taxes, and insurance — using the 28% rule.",
    icon: "house",
  },
  {
    name: "Credit Card Payoff Calculator",
    slug: "credit-card-payoff-calculator",
    description:
      "How many months until you're debt-free at a fixed monthly payment — plus total interest paid along the way.",
    icon: "calendar-clock",
  },
  {
    name: "401(k) Impact Calculator",
    slug: "401k-impact-calculator",
    description:
      "What a pre-tax 401(k) contribution actually costs your paycheck after the tax break, plus the employer match it captures.",
    icon: "piggy-bank",
  },
  {
    name: "HYSA Calculator",
    slug: "hysa-calculator",
    description:
      "Annual interest from a high-yield savings account vs the 0.01% your big bank pays — and Rule-of-72 doubling time.",
    icon: "banknote",
  },
  {
    name: "Balance Transfer Calculator",
    slug: "balance-transfer-calculator",
    description:
      "Is the 0% APR promo worth the 3-5% transfer fee? Net benefit, breakeven APR, and the payoff plan.",
    icon: "repeat",
  },
];
