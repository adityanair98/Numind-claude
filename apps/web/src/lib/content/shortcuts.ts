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

export const insuranceShortcut: ShortcutContent = {
  title: "The Worst-Case-Year Test",
  teaser: "Premiums x 12 + deductible = your worst year. Compare that number across plans.",
  steps: [
    "Multiply monthly premium by 12 to get annual premium cost.",
    "Add the full deductible — that is your worst-case year if you hit the deductible.",
    "For the true ceiling, use: premiums x 12 + out-of-pocket max. That is the absolute most you will pay.",
  ],
  example:
    "$350/mo premium + $2,000 deductible: $350 x 12 = $4,200 + $2,000 = $6,200 worst case. Compare to a $200/mo plan with $5,000 deductible: $2,400 + $5,000 = $7,400.",
};

export const carShortcut: ShortcutContent = {
  title: "The 20/4/10 Rule",
  teaser: "20% down, 4-year loan max, payment under 10% of monthly income.",
  steps: [
    "Put at least 20% down to avoid being underwater on the loan.",
    "Finance for no more than 4 years (48 months) — longer loans cost thousands more in interest.",
    "Keep the monthly payment under 10% of your gross monthly income.",
  ],
  example:
    "$5,000/month income: max payment = $500. At 48 months that is $24,000 financed + 20% down = $30,000 max car price.",
};

export const studentLoanShortcut: ShortcutContent = {
  title: "The $100 per $10K Rule",
  teaser: "Roughly $100/month per $10,000 borrowed on a standard 10-year plan.",
  steps: [
    "For a quick estimate: divide your balance by $10,000, multiply by roughly $100-$120.",
    "Total cost = monthly payment x 120 months. Subtract the balance to see total interest.",
    "PSLF: if you qualify, total paid = IDR payment x 120. The rest is forgiven tax-free.",
  ],
  example:
    "$35,000 in loans: ~$350-$420/month on a 10-year plan. Over 10 years, you pay ~$42,000-$50,400 total, meaning $7,000-$15,400 in interest.",
};

export const bnplShortcut: ShortcutContent = {
  title: "The BNPL Surcharge Math",
  teaser: "4 'easy' payments + one missed = up to a 12% surcharge on the price.",
  steps: [
    "Total cost as advertised = price (split into 4 payments). No interest if paid on time.",
    "Miss one payment: industry-standard $35 late fee (some hit 25% of the missed payment).",
    "Surcharge % = late fee divided by original price x 100. On a $300 item, $35 late = 11.7% extra.",
  ],
  example:
    "$300 item on 4-payment BNPL = $75 per payment. Miss one = +$35 fee = $335 total, an 11.7% surcharge. Stack three plans? $225/month of invisible debt that doesn't show on your card statement.",
};

export const membershipShortcut: ShortcutContent = {
  title: "The Break-even Use Rule",
  teaser: "Monthly fee divided by per-use savings = how many uses you need to break even.",
  steps: [
    "Break-even uses = fee divided by per-use saving (round up). Below that, you lose money.",
    "DashPass $10/month saving $3/order = ~4 orders/month to break even. Order 8 = save $14/month.",
    "Annual saving once you're above break-even = (uses x saving - fee) x 12.",
  ],
  example:
    "Costco at $65/year, save ~$8/visit on groceries. Break-even = $65 / $8 = 9 visits/year. Go 30 times? ($30 x $8 - $65) = $175/year saved on groceries alone.",
};

export const leaseVsBuyShortcut: ShortcutContent = {
  title: "Lease vs Buy in 3 Years",
  teaser: "Lease total = payments. Buy net cost = payments minus residual value.",
  steps: [
    "Lease cost over term = monthly lease x months. You own nothing at the end.",
    "Buy net cost over same period = monthly payment x months - car's value at term end.",
    "If buy net cost < lease cost, buying wins. Almost always true if you keep the car past the loan.",
  ],
  example:
    "Lease $350/mo x 36 = $12,600 spent, $0 owned. Buy $500/mo x 36 = $18,000 paid, car worth $20,000 (you BUILT $2,000 equity). Buying wins by $14,600 over 3 years.",
};

export const fsaShortcut: ShortcutContent = {
  title: "The 75% Rule for FSAs",
  teaser: "You must spend at least (1 - tax rate) of your election to come out ahead.",
  steps: [
    "Tax savings = election x your marginal tax rate.",
    "Use-it-or-lose-it: unspent funds at year-end are forfeited (some plans allow $640 rollover).",
    "Break-even spend = election x (1 - tax rate). In a 25% bracket, you must spend 75% of what you elect.",
  ],
  example:
    "Elect $2,850 at 25% bracket: save $712 in tax. Must spend at least $2,137 (75%) to come out ahead. Spend $1,800? You'd forfeit $1,050 for net -$338 — worse than not electing at all.",
};

export const lifeInsuranceShortcut: ShortcutContent = {
  title: "The 10x Salary Rule",
  teaser: "Multiply your annual salary by 10 for a baseline life insurance need.",
  steps: [
    "Quick baseline: annual salary x 10 = baseline coverage.",
    "DIME method (better): Debt + Income (10x) + Mortgage + Education costs - savings = adjusted coverage.",
    "Buy term, not whole life. 20-30 year term is typically 10-15x cheaper than whole life.",
  ],
  example:
    "$70,000 salary: baseline = $700,000. Mortgage $280k, savings $50k: adjusted = $700k + $280k - $50k = $930,000 coverage. Term life cost: roughly $40-$60/month for a healthy 35-year-old.",
};

export const houseAffordabilityShortcut: ShortcutContent = {
  title: "The 28% Rule, Step by Step",
  teaser: "Max PITI = monthly gross × 0.28. Loan = PITI ÷ rate factor (0.006 at 6%).",
  steps: [
    "Max PITI (principal + interest + tax + insurance) = monthly gross × 0.28 (Fannie Mae's standard).",
    "Subtract est. monthly tax + insurance (~1.5%/yr of price ÷ 12). What's left is your max P&I.",
    "Max loan = P&I ÷ rate factor: 0.0054 at 5%, 0.006 at 6%, 0.0067 at 7%.",
    "Max purchase price = max loan ÷ (1 - down %). Add PMI (~0.5%/yr) if down < 20%.",
  ],
  example:
    "$7,000/mo gross at 6.5% rate, 10% down: max PITI = $1,960. After ~$300 tax+ins, max P&I = $1,660. Max loan ≈ $263k. Max purchase price ≈ $292k.",
};

export const ccPayoffShortcut: ShortcutContent = {
  title: "The Principal-Slice Rule",
  teaser: "Net principal per month = payment − (balance × APR ÷ 1200). Smaller slice = longer payoff.",
  steps: [
    "Monthly interest charge = balance × APR ÷ 1200.",
    "Net principal reduction = monthly payment − interest charge.",
    "Months to payoff ≈ ln(payment / (payment − balance × r)) / ln(1 + r), where r = APR / 1200.",
    "Rule of thumb: every extra $50/month roughly cuts a year off a $5,000 balance at 22% APR.",
  ],
  example:
    "$5,000 at 22% APR with $150/mo: monthly interest $92, principal slice $58, payoff ~51 months. Bump to $200/mo → principal slice $108 → payoff ~31 months (nearly half).",
};

export const k401ImpactShortcut: ShortcutContent = {
  title: "The Pre-Tax Discount",
  teaser: "Net paycheck cost = contribution × (1 − marginal tax rate). The IRS pays the rest.",
  steps: [
    "Pre-tax 401(k) contributions reduce taxable income but not FICA wages.",
    "Net paycheck reduction = contribution × (1 − marginal income tax rate). At 22%: $300 contribution costs $234 take-home.",
    "Employer match is FREE money on top — capture at least up to the match cap before doing anything else with extra cash.",
    "Roth 401(k) is different: full contribution comes out of take-home (no upfront tax break).",
  ],
  example:
    "$5,000/mo gross, 6% contribution = $300/mo. At 22% bracket, tax saved = $66. Net cost = $234. With a 50%/6% employer match, free $150 also goes in. $600 total into the account for $234 out-of-pocket.",
};

export const hysaShortcut: ShortcutContent = {
  title: "The 450x Multiplier",
  teaser: "5% HYSA on $10k = $500/year. 0.01% big-bank = $1/year. Same balance, 500x the interest.",
  steps: [
    "Annual interest = balance × APY ÷ 100.",
    "Rule of 72: at X% APY, your money doubles in 72/X years.",
    "The gap between best-in-class HYSA (~4-5% APY in 2025-26) and a major bank's 0.01% APY is the biggest free-money lever in personal finance.",
    "FDIC-insured to $250k per depositor, per bank — same protection as a brick-and-mortar savings account.",
  ],
  example:
    "$10,000 idle in a Bank of America savings (0.01% APY) earns $1/year. Same $10,000 in a Marcus or Ally HYSA at 4.5% APY earns $450/year. Per Bankrate's HYSA tracking, top rates have stayed above 4% throughout 2024-25.",
};

export const balanceTransferShortcut: ShortcutContent = {
  title: "The Fee-vs-Interest Test",
  teaser: "Worth it if (old APR × promo months / 12) > transfer fee %.",
  steps: [
    "Transfer fee = balance × fee % (typically 3-5%).",
    "Interest avoided = balance × old APR × promo months / 12.",
    "Net benefit = interest avoided − fee. Positive = worth doing.",
    "Required monthly payment to clear (balance + fee) before promo ends: (balance + fee) / promo months. If you can't sustain this, leftover balance hits the new card's regular APR.",
  ],
  example:
    "$8,000 at 22% APR, 18-month 0% promo, 3% fee: fee = $240, interest avoided ≈ $2,640, net benefit ≈ $2,400. Required monthly: ~$458 to fully clear before promo ends.",
};
