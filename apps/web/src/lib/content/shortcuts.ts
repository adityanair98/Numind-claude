import type { ShortcutContent } from "@/components/calculator/CalculatorShell";

export const salaryShortcut: ShortcutContent = {
  title: "The 2,080 Rule",
  teaser: "Double the hourly rate, add three zeros. $25/hr ≈ $50,000.",
  steps: [
    "Multiply your hourly rate by 2,080 to get annual salary (40 hrs/wk x 52 weeks).",
    "For a quick estimate: double the hourly rate and add three zeros. $25/hr ≈ $50,000.",
    "Watch out: biweekly = 26 pay periods, NOT 24. Treating it as 24 loses you two paychecks a year.",
  ],
  example:
    "$30/hr x 2,080 = $62,400/year. That's $5,200/month or $2,400 every two weeks.",
};

export const rentShortcut: ShortcutContent = {
  title: "The 28% Rule (Quick Version)",
  teaser: "Max rent ≈ ¼ of your monthly gross, plus a little. That's the 28% rule.",
  steps: [
    "Take your monthly gross income (annual salary / 12).",
    "Multiply by 0.28 — that's your max rent.",
    "Quick shortcut: take a quarter of your monthly gross and add a little more.",
  ],
  example:
    "$60,000 salary = $5,000/month gross. $5,000 x 0.28 = $1,400 max rent. Quick check: $5,000 / 4 = $1,250 + a bit = ~$1,400.",
};

export const paycheckShortcut: ShortcutContent = {
  title: "The 25-30% Rule",
  teaser: "Knock off 25% from gross — that's roughly your take-home pay.",
  steps: [
    "For a quick take-home estimate, subtract about 25-30% from your gross pay.",
    "Most earners in the $40K-$100K range lose ~25% to federal + state + FICA combined.",
    "Higher earners (>$100K) should estimate closer to 30-35%.",
  ],
  example:
    "$75,000 salary: knock off 25% → $75,000 x 0.75 = ~$56,250 take-home, or about $4,687/month.",
};

export const investmentShortcut: ShortcutContent = {
  title: "The Rule of 72",
  teaser: "Divide 72 by the interest rate — that's how many years to double your money.",
  steps: [
    "Divide 72 by the annual interest rate to find how many years it takes to double your money.",
    "At 8% return: 72 / 8 = 9 years to double.",
    "Works for any growth rate — inflation, debt interest, investment returns.",
  ],
  example:
    "$10,000 invested at 7% annual return: 72 / 7 ≈ 10.3 years to reach $20,000.",
};

export const discountShortcut: ShortcutContent = {
  title: "Fraction Shortcuts for Discounts",
  teaser: "10% off? Move the decimal. 25% off? Divide by 4. Stack from there.",
  steps: [
    "10% off = move the decimal one place left. $45 → $4.50 off.",
    "25% off = divide by 4. $80 / 4 = $20 off, pay $60.",
    "33% off (buy 2 get 1 free) = divide by 3. Three $15 items = $10 each effective.",
  ],
  example:
    "30% off a $70 shirt: 10% = $7, so 30% = $7 x 3 = $21 off. You pay $49.",
};

export const loanShortcut: ShortcutContent = {
  title: "The True Cost Formula",
  teaser: "Total cost = payment × months. Subtract the principal — that's your interest.",
  steps: [
    "Total cost = monthly payment x number of months. Subtract the loan amount = total interest paid.",
    "Credit card rule: at 20% APR, monthly interest ≈ balance x 0.017 (divide APR by 12).",
    "Doubling your minimum payment can cut repayment time by more than half.",
  ],
  example:
    "$10,000 loan at $300/month for 40 months: total paid = $12,000. Interest = $2,000.",
};
