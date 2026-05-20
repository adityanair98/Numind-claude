export interface LoanResult {
  monthlyPayment: number;
  totalPayment: number;
  totalInterest: number;
  /** Number of months to pay off */
  months: number;
}

/**
 * Fixed-rate loan amortization.
 * M = P × [r(1+r)^n] / [(1+r)^n − 1]
 */
export function computeLoanPayment(
  principal: number,
  annualRate: number,
  years: number
): LoanResult {
  const months = years * 12;
  const r = annualRate / 100 / 12;

  if (months === 0) {
    return { monthlyPayment: 0, totalPayment: 0, totalInterest: 0, months: 0 };
  }

  let monthlyPayment: number;
  if (r === 0) {
    monthlyPayment = principal / months;
  } else {
    const factor = Math.pow(1 + r, months);
    monthlyPayment = principal * (r * factor) / (factor - 1);
  }

  const totalPayment = monthlyPayment * months;
  const totalInterest = totalPayment - principal;

  return { monthlyPayment, totalPayment, totalInterest, months };
}

/**
 * Given a fixed monthly payment, how many months to pay off?
 */
export function computePayoffTime(
  principal: number,
  annualRate: number,
  monthlyPayment: number
): LoanResult {
  const r = annualRate / 100 / 12;

  if (r === 0) {
    const months = Math.ceil(principal / monthlyPayment);
    return {
      monthlyPayment,
      totalPayment: monthlyPayment * months,
      totalInterest: 0,
      months,
    };
  }

  // Check if payment covers interest
  const monthlyInterest = principal * r;
  if (monthlyPayment <= monthlyInterest) {
    return {
      monthlyPayment,
      totalPayment: Infinity,
      totalInterest: Infinity,
      months: Infinity,
    };
  }

  // n = −log(1 − rP/M) / log(1 + r)
  const months = Math.ceil(
    -Math.log(1 - (r * principal) / monthlyPayment) / Math.log(1 + r)
  );
  const totalPayment = monthlyPayment * months;
  const totalInterest = totalPayment - principal;

  return { monthlyPayment, totalPayment, totalInterest, months };
}
