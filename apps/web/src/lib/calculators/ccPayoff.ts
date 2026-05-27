export interface CCPayoffInputs {
  /** Current credit card balance */
  balance: number;
  /** Annual percentage rate (e.g. 22 for 22%) */
  apr: number;
  /** Fixed monthly payment */
  monthlyPayment: number;
}

export interface CCPayoffResult {
  /** Whole-month estimate of payoff time (rounded up). `Infinity` if payment doesn't cover monthly interest. */
  months: number;
  /** Total dollars paid over the entire payoff (principal + interest) */
  totalPaid: number;
  /** Total interest paid */
  totalInterest: number;
  /** Monthly interest charge on the current balance */
  monthlyInterest: number;
  /** Principal portion of the first month's payment */
  principalSlice: number;
  /** True if the monthly payment is too small to ever pay off the balance */
  unpayable: boolean;
}

/**
 * Exact payoff months on a fixed monthly payment.
 * months = ln(p / (p − b·r)) / ln(1 + r), where r = APR / 1200.
 * Returns `unpayable: true` if payment doesn't even cover the first month's interest.
 */
export function computeCCPayoff(inputs: CCPayoffInputs): CCPayoffResult {
  const { balance, apr, monthlyPayment } = inputs;
  if (balance <= 0 || apr < 0 || monthlyPayment <= 0) {
    return {
      months: 0,
      totalPaid: 0,
      totalInterest: 0,
      monthlyInterest: 0,
      principalSlice: 0,
      unpayable: false,
    };
  }
  const r = apr / 1200;
  const monthlyInterest = balance * r;
  const principalSlice = monthlyPayment - monthlyInterest;

  // If the payment doesn't even cover the monthly interest, payoff is impossible.
  if (principalSlice <= 0) {
    return {
      months: Infinity,
      totalPaid: Infinity,
      totalInterest: Infinity,
      monthlyInterest,
      principalSlice: 0,
      unpayable: true,
    };
  }

  // months = ln(p / (p − b·r)) / ln(1 + r)
  const months = Math.ceil(
    Math.log(monthlyPayment / (monthlyPayment - balance * r)) /
      Math.log(1 + r)
  );
  const totalPaid = monthlyPayment * months;
  const totalInterest = totalPaid - balance;

  return {
    months,
    totalPaid,
    totalInterest,
    monthlyInterest,
    principalSlice,
    unpayable: false,
  };
}
