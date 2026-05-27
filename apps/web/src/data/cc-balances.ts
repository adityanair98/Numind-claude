export interface CCBalanceData {
  slug: string;
  /** Numeric balance in dollars */
  balance: number;
  /** Display label, e.g. "$5,000" */
  label: string;
  /** SEO target query */
  query: string;
  /**
   * Suggested example monthly payment for the FAQ + widget default.
   * Tuned to keep the canonical example finite and not absurd (avoid
   * "payment ≤ monthly interest" infinite-payoff at the highest balances).
   */
  exampleMonthlyPayment: number;
}

function fmtMoney(n: number): string {
  return n.toLocaleString("en-US");
}

const balances = [
  { balance: 1000, exampleMonthlyPayment: 50 },
  { balance: 2000, exampleMonthlyPayment: 75 },
  { balance: 3000, exampleMonthlyPayment: 100 },
  { balance: 5000, exampleMonthlyPayment: 200 },
  { balance: 7500, exampleMonthlyPayment: 250 },
  { balance: 10000, exampleMonthlyPayment: 300 },
  { balance: 15000, exampleMonthlyPayment: 400 },
  { balance: 20000, exampleMonthlyPayment: 500 },
  { balance: 25000, exampleMonthlyPayment: 600 },
];

export const ccBalances: CCBalanceData[] = balances.map(({ balance, exampleMonthlyPayment }) => ({
  slug: `${balance}-balance`,
  balance,
  label: `$${fmtMoney(balance)}`,
  query: `how long to pay off $${fmtMoney(balance)} credit card debt`,
  exampleMonthlyPayment,
}));

export function getCCBalanceBySlug(slug: string): CCBalanceData | undefined {
  return ccBalances.find((b) => b.slug === slug);
}
