import type { FAQ } from "@/components/calculator/FAQSection";

export const salaryFAQs: FAQ[] = [
  {
    question: "How do I convert hourly wage to annual salary?",
    answer:
      "Multiply your hourly rate by 2,080 (40 hours per week times 52 weeks per year). For example, $25 per hour equals $52,000 per year before taxes.",
  },
  {
    question: "What is $25 an hour annually?",
    answer:
      "$25 per hour is $52,000 per year, $4,333 per month, $2,000 biweekly, or $1,000 per week, assuming 40 hours per week.",
  },
  {
    question: "Why use 2,080 hours instead of 2,000?",
    answer:
      "2,080 is the exact product of 40 hours per week times 52 weeks. Using 2,000 underestimates your annual salary by about 4%, costing you roughly $800 on a $20/hour wage.",
  },
  {
    question: "Is biweekly the same as twice a month?",
    answer:
      "No. Biweekly means every two weeks (26 pay periods per year). Semi-monthly means twice a month (24 periods). Biweekly gives you two extra paychecks per year.",
  },
  {
    question: "How much is $50,000 a year per hour?",
    answer:
      "$50,000 per year is approximately $24.04 per hour ($50,000 / 2,080), $961.54 per week, or $1,923.08 biweekly.",
  },
];

export const rentFAQs: FAQ[] = [
  {
    question: "How much rent can I afford on my salary?",
    answer:
      "A common guideline is the 28% rule: your monthly rent should not exceed 28% of your gross monthly income. On a $60,000 salary, that means a maximum rent of about $1,400 per month.",
  },
  {
    question: "What is the 28% rule for rent?",
    answer:
      "The 28% rule states that your housing costs (rent or mortgage) should not exceed 28% of your gross monthly income. This helps ensure you have enough left for savings, food, transportation, and other expenses.",
  },
  {
    question: "Can I afford $1,500 rent on a $50,000 salary?",
    answer:
      "$50,000 gross annual salary equals about $4,167 per month. 28% of that is $1,167. At $1,500 per month, you would be spending 36% of your gross income on rent, which is above the recommended threshold.",
  },
  {
    question: "What is a good debt-to-income ratio?",
    answer:
      "Lenders generally prefer a total DTI ratio below 36%, including all monthly debt payments plus housing costs. For rent specifically, staying at or below 28% of gross income is the standard guideline.",
  },
  {
    question: "Should I use gross or net income for rent calculations?",
    answer:
      "The 28% rule uses gross income (before taxes). Some financial advisors suggest using 30% of net (after-tax) income for a more conservative estimate that better reflects what you actually take home.",
  },
];

export const paycheckFAQs: FAQ[] = [
  {
    question: "How much tax is taken out of my paycheck?",
    answer:
      "For most workers, federal income tax (10-37%), Social Security (6.2%), and Medicare (1.45%) are deducted. Most earners in the $40K-$100K range lose about 25-30% total to all taxes combined.",
  },
  {
    question: "What is FICA tax?",
    answer:
      "FICA stands for the Federal Insurance Contributions Act. It includes Social Security tax (6.2% on income up to $168,600 in 2025) and Medicare tax (1.45% on all income, plus an additional 0.9% on income over $200,000).",
  },
  {
    question: "How do I calculate my take-home pay?",
    answer:
      "Start with your gross pay, then subtract federal income tax, state income tax (if applicable), Social Security (6.2%), Medicare (1.45%), and any pre-tax deductions like 401(k) contributions.",
  },
  {
    question: "Do all states have income tax?",
    answer:
      "No. Nine states have no state income tax: Alaska, Florida, Nevada, New Hampshire, South Dakota, Tennessee, Texas, Washington, and Wyoming. New Hampshire only taxes interest and dividend income.",
  },
  {
    question: "How much is $75,000 a year after taxes?",
    answer:
      "On a $75,000 salary, you can expect roughly $56,000-$60,000 after federal and FICA taxes, depending on your filing status and state. That is approximately $4,700-$5,000 per month take-home.",
  },
];

export const investmentFAQs: FAQ[] = [
  {
    question: "What is compound interest?",
    answer:
      "Compound interest means you earn interest on both your original investment and on previously earned interest. Over time this creates exponential growth, which is why starting early matters so much.",
  },
  {
    question: "What is the Rule of 72?",
    answer:
      "The Rule of 72 is a quick way to estimate how long it takes to double your money. Divide 72 by the annual interest rate. At 8% return, your money doubles in about 9 years (72 / 8 = 9).",
  },
  {
    question: "How much will $10,000 grow in 10 years?",
    answer:
      "At a 7% annual return, $10,000 grows to about $19,672 in 10 years. At 10%, it reaches about $25,937. The Rule of 72 says 7% doubles in ~10.3 years, which matches closely.",
  },
  {
    question: "What is a realistic rate of return?",
    answer:
      "The S&P 500 has averaged about 10% annually before inflation (about 7% after inflation) over long periods. A conservative estimate for diversified portfolios is 6-8% long-term.",
  },
];

export const discountFAQs: FAQ[] = [
  {
    question: "How do I calculate percent off?",
    answer:
      "Multiply the original price by the discount percentage (as a decimal). For 30% off a $80 item: $80 x 0.30 = $24 off, so you pay $56.",
  },
  {
    question: "Is buy 2 get 1 free the same as 33% off?",
    answer:
      "Yes, effectively. You pay for 2 items but get 3, so each item costs 2/3 of the original price, which is the same as a 33.3% discount per item.",
  },
  {
    question: "Do stacked discounts add up?",
    answer:
      "No. A 20% off plus 10% off is not 30% off. The second discount applies to the already-reduced price. 20% then 10% = 28% total discount (you pay 80% then 90% of that: 0.8 x 0.9 = 0.72).",
  },
  {
    question: "How do I calculate sale price from original price?",
    answer:
      "Subtract the discount amount from the original price. Or multiply the original price by (1 - discount rate). For 25% off: original x 0.75 = sale price.",
  },
];

export const loanFAQs: FAQ[] = [
  {
    question: "How do I calculate total interest on a loan?",
    answer:
      "Multiply your monthly payment by the total number of months, then subtract the original loan amount. The difference is the total interest paid.",
  },
  {
    question: "What is APR vs interest rate?",
    answer:
      "The interest rate is the base cost of borrowing. APR (Annual Percentage Rate) includes the interest rate plus fees and other charges, giving you the true yearly cost of the loan.",
  },
  {
    question: "How much does a $10,000 loan cost?",
    answer:
      "It depends on the rate and term. At 6% for 3 years, you would pay about $304/month and $10,933 total ($933 in interest). At 15% for 5 years, the total jumps to about $14,275 ($4,275 in interest).",
  },
  {
    question: "Should I pay off debt or invest?",
    answer:
      "Generally, pay off high-interest debt first (credit cards at 15-25%). If your debt rate is below 6-7%, investing may earn more over time. Always make minimum payments on all debts regardless.",
  },
];

export const insuranceFAQs: FAQ[] = [
  {
    question: "What is the difference between a deductible and a premium?",
    answer:
      "Your premium is the monthly amount you pay for insurance regardless of whether you use it. Your deductible is the amount you pay out of pocket before insurance starts covering costs. Lower premiums usually mean higher deductibles, and vice versa.",
  },
  {
    question: "What is coinsurance and how does it work?",
    answer:
      "After you meet your deductible, coinsurance is the percentage of costs you share with your insurer. If your coinsurance is 20%, you pay 20% and the insurer pays 80% until you hit your out-of-pocket maximum.",
  },
  {
    question: "What is an out-of-pocket maximum?",
    answer:
      "The out-of-pocket maximum is the most you will pay for covered services in a plan year. Once you reach this amount through deductibles, copays, and coinsurance, your plan covers 100% of covered costs for the rest of the year.",
  },
  {
    question: "Is an HDHP or PPO better for me?",
    answer:
      "HDHPs have lower premiums but higher deductibles. They work best for healthy people who rarely visit the doctor and want to use an HSA for tax savings. PPOs cost more monthly but cover more per visit, which is better if you have regular medical needs.",
  },
  {
    question: "What is an HSA and why is it valuable?",
    answer:
      "A Health Savings Account (HSA) is available with HDHPs. Contributions are tax-deductible, growth is tax-free, and withdrawals for medical expenses are tax-free. It is the only account with a triple tax advantage.",
  },
];

export const carFAQs: FAQ[] = [
  {
    question: "What is the 20/4/10 rule for buying a car?",
    answer:
      "The 20/4/10 rule recommends putting at least 20% down, financing for no more than 4 years, and keeping total car costs (payment plus insurance) under 10% of your gross monthly income.",
  },
  {
    question: "How much does a car depreciate in the first year?",
    answer:
      "New cars typically lose 15-25% of their value in the first year. After 5 years, most cars are worth about 40% of their original price. Buying a 2-3 year old car lets someone else absorb the steepest depreciation.",
  },
  {
    question: "Is a longer car loan a bad idea?",
    answer:
      "Longer loans (72-84 months) have lower monthly payments but cost significantly more in total interest. A 72-month loan can cost $2,000-$5,000 more in interest than a 48-month loan on the same car. You also risk owing more than the car is worth.",
  },
  {
    question: "How much should I put down on a car?",
    answer:
      "Aim for at least 20% down to avoid being upside-down on the loan, where you owe more than the car is worth. A larger down payment also reduces your loan amount, which means less interest paid over time.",
  },
];

export const studentLoanFAQs: FAQ[] = [
  {
    question: "What is income-driven repayment (IDR)?",
    answer:
      "IDR plans cap your monthly payment at a percentage (usually 10-20%) of your discretionary income. After 20-25 years, any remaining balance is forgiven, though the forgiven amount may be taxable income.",
  },
  {
    question: "What is Public Service Loan Forgiveness (PSLF)?",
    answer:
      "PSLF forgives your remaining federal student loan balance after 120 qualifying payments (10 years) while working full-time for a qualifying employer like government or nonprofits. The forgiven amount is tax-free.",
  },
  {
    question: "Should I refinance my student loans?",
    answer:
      "Refinancing can lower your interest rate, but you lose federal protections like IDR, PSLF, and forbearance. It makes sense if you have a stable income, good credit, and do not need federal loan benefits.",
  },
  {
    question: "How much does a $30,000 student loan cost in total?",
    answer:
      "On a standard 10-year plan at 5% interest, a $30,000 loan costs about $38,184 total with $318/month payments. On a 20-year extended plan, the total rises to about $47,500 even though the monthly payment drops to $198.",
  },
  {
    question: "What is the $100 per $10K rule?",
    answer:
      "A quick estimate for student loan payments on a standard 10-year plan: you will pay roughly $100-$120 per month for every $10,000 borrowed. So $40,000 in loans means roughly $400-$480 per month.",
  },
];

export const bnplFAQs: FAQ[] = [
  {
    question: "Is Buy Now Pay Later actually free?",
    answer:
      "Only if you pay every installment on time. Most BNPL services charge a late fee of around $35 (or 25% of the missed payment, whichever is greater) for any payment that's even a day late. On a $300 purchase, a single $35 late fee adds an 11.7% surcharge to the original price.",
  },
  {
    question: "Does BNPL hurt my credit score?",
    answer:
      "It depends on the provider. Affirm and some others now report to credit bureaus, including missed payments. Klarna, Afterpay, and others may report only missed payments. As of 2025, the CFPB classifies BNPL plans as credit and is increasing scrutiny.",
  },
  {
    question: "How risky is stacking multiple BNPL plans?",
    answer:
      "Very. Per CFPB and Bankrate research, 49% of BNPL users report financial problems and 24% have made a late payment. Stacking three plans at $75/month each creates $225/month of invisible debt that doesn't show on your credit card statement.",
  },
  {
    question: "What's the safest way to use BNPL?",
    answer:
      "Only use it when you'd otherwise pay cash, set up autopay to avoid late fees, never stack multiple plans, and treat the payment schedule as a non-negotiable bill. If you can't afford the full price today, you probably can't afford 4 payments either.",
  },
];

export const membershipFAQs: FAQ[] = [
  {
    question: "How do I know if a Costco membership is worth it?",
    answer:
      "Calculate your break-even uses: $65 annual fee divided by your average per-visit savings. If you typically save $8 per visit, you need 9 visits per year to break even. For households that do their main grocery shopping at Costco, this is almost always worth it.",
  },
  {
    question: "Is DashPass actually a good deal?",
    answer:
      "DashPass costs about $9.99/month and saves you the delivery fee ($3-$8) on eligible orders. Break-even is roughly 2-4 orders per month. If you order delivery less than that, you're losing money on the membership.",
  },
  {
    question: "Should I cancel memberships I rarely use?",
    answer:
      "Yes. Most memberships auto-renew. Audit your subscriptions quarterly — calculate your actual usage vs the break-even number. If you're below break-even consistently, cancel and resubscribe later if needed.",
  },
  {
    question: "What's the catch with Amazon Prime?",
    answer:
      "Prime is $139/year ($14.99/month). It pays for itself if you would otherwise pay $5-$15 in shipping per order on 10+ orders annually. Plus video and music. For frequent shoppers, it's almost always worth it; for occasional shoppers, the math is closer.",
  },
];

export const leaseVsBuyFAQs: FAQ[] = [
  {
    question: "Is leasing or buying a car cheaper?",
    answer:
      "Buying is almost always cheaper if you keep the car past the loan term. Leasing locks you into perpetual payments and you own nothing at the end. Over a 10-year period of buying one car versus leasing three, you typically save $15,000-$30,000 by buying.",
  },
  {
    question: "When does leasing actually make sense?",
    answer:
      "When you need a business write-off, drive low mileage, want a new car every 2-3 years and don't care about ownership, or have unstable income where flexibility matters. For most people, these conditions don't apply.",
  },
  {
    question: "What's a residual value and why does it matter?",
    answer:
      "Residual value is what the car is worth at the end of your loan or lease. When you buy, the residual value offsets your total payments — you have an asset to sell. When you lease, the residual is what determines your monthly payment, but you don't keep it.",
  },
  {
    question: "How do I compare lease vs buy honestly?",
    answer:
      "Compare over the same time period. Lease total = monthly x months. Buy net cost = (monthly payment x months) - car's value at end. The option with the lower net cost wins. If buy net is even close to lease cost, buying wins because you also have a tradeable asset.",
  },
];

export const fsaFAQs: FAQ[] = [
  {
    question: "What is the FSA 'use it or lose it' rule?",
    answer:
      "Funds you elect to your Flexible Spending Account at the start of the year must be spent on qualified medical or dependent care expenses by year-end (or by the grace period deadline). Anything unspent is forfeited to your employer. Some plans allow up to $640 rollover.",
  },
  {
    question: "How much should I elect to my FSA?",
    answer:
      "Only elect what you'll definitely spend on qualified expenses. Your break-even is your election times (1 minus your tax rate). In a 25% bracket, you must spend at least 75% of your election to come out ahead — otherwise the forfeited money outweighs your tax savings.",
  },
  {
    question: "What's the difference between an FSA and an HSA?",
    answer:
      "FSAs are use-it-or-lose-it and tied to your employer (you lose the account if you leave). HSAs roll over forever, are portable, can be invested, and have a triple tax advantage. HSAs require enrollment in a High-Deductible Health Plan; FSAs don't.",
  },
  {
    question: "Can I buy things with my FSA?",
    answer:
      "Yes, FSAs cover qualified medical expenses including prescriptions, eyeglasses, contact lenses, dental work, doctor visit copays, OTC medications, sunscreen SPF 15+, menstrual products, and more. Check FSAStore.com for a comprehensive eligible-items list.",
  },
];

export const lifeInsuranceFAQs: FAQ[] = [
  {
    question: "How much life insurance do I really need?",
    answer:
      "The 10× rule: multiply your annual salary by 10 for a baseline. Better: use the DIME method — Debt + Income replacement (salary x 10) + Mortgage balance + Education costs - existing savings. The result is roughly how much coverage your family needs to maintain their lifestyle if you die.",
  },
  {
    question: "Should I buy term or whole life insurance?",
    answer:
      "Term life for almost everyone under 60. Term covers a specific period (typically 20-30 years) and is 10-15 times cheaper than whole life for the same coverage. Whole life only makes sense for specific estate planning needs or high-net-worth situations — not basic family protection.",
  },
  {
    question: "How much does life insurance cost?",
    answer:
      "For a healthy 35-year-old, a 20-year $500,000 term policy costs roughly $25-$40/month. A 30-year $1,000,000 policy is roughly $55-$80/month. Smokers, older applicants, and those with health conditions pay more. Always shop multiple quotes — premiums vary 30-50% between insurers.",
  },
  {
    question: "When can I stop carrying life insurance?",
    answer:
      "When your dependents would be financially OK if you died. Typically when your kids are grown and self-sufficient, your mortgage is paid off, and your retirement savings can support your spouse independently. For most people that's around age 60-70.",
  },
];
