export interface HysaBalanceData {
  slug: string;
  /** Numeric balance in dollars */
  balance: number;
  /** Display label, e.g. "$10,000" */
  label: string;
  /** SEO target query */
  query: string;
}

function fmtMoney(n: number): string {
  return n.toLocaleString("en-US");
}

const balances = [1000, 5000, 10000, 20000, 25000, 50000, 75000, 100000, 250000, 500000];

export const hysaBalances: HysaBalanceData[] = balances.map((balance) => ({
  slug: `${balance}-balance`,
  balance,
  label: `$${fmtMoney(balance)}`,
  query: `how much interest does $${fmtMoney(balance)} earn in a high-yield savings account`,
}));

export function getHysaBalanceBySlug(slug: string): HysaBalanceData | undefined {
  return hysaBalances.find((b) => b.slug === slug);
}
