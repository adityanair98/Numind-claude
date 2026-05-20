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
