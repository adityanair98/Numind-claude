export interface StudentLoanResult {
  monthlyPayment: number;
  totalPaid: number;
  totalInterest: number;
  months: number;
}

export interface PSLFResult {
  monthlyPayment: number;
  totalPaid: number;
  amountForgiven: number;
}

/**
 * Standard fixed-rate student loan amortization.
 */
export function computeStudentLoan(
  balance: number,
  annualRate: number,
  years: number
): StudentLoanResult {
  const months = years * 12;
  const r = annualRate / 100 / 12;

  if (months === 0) {
    return { monthlyPayment: 0, totalPaid: 0, totalInterest: 0, months: 0 };
  }

  let monthlyPayment: number;
  if (r === 0) {
    monthlyPayment = balance / months;
  } else {
    const factor = Math.pow(1 + r, months);
    monthlyPayment = balance * (r * factor) / (factor - 1);
  }

  const totalPaid = monthlyPayment * months;
  const totalInterest = totalPaid - balance;

  return { monthlyPayment, totalPaid, totalInterest, months };
}

/**
 * Income-Driven Repayment (IDR) monthly payment estimate.
 * Payment = discretionary income × IDR percentage / 12
 * Discretionary income = AGI − 150% × federal poverty line
 */
export function computeIDRPayment(
  annualIncome: number,
  idrPercent: number,
  povertyLine = 15060
): number {
  const discretionary = Math.max(0, annualIncome - povertyLine * 1.5);
  return (discretionary * idrPercent) / 100 / 12;
}

/**
 * PSLF: 120 qualifying payments, remaining balance forgiven tax-free.
 */
export function computePSLF(
  balance: number,
  monthlyPayment: number
): PSLFResult {
  const totalPaid = monthlyPayment * 120;
  const amountForgiven = Math.max(0, balance - totalPaid);

  return { monthlyPayment, totalPaid, amountForgiven };
}

/**
 * Refinancing savings: compare old vs new payment over remaining term.
 */
export function computeRefiSavings(
  balance: number,
  oldRate: number,
  oldYearsRemaining: number,
  newRate: number,
  newYears: number
): { oldTotal: number; newTotal: number; totalSavings: number; monthlySavings: number } {
  const oldResult = computeStudentLoan(balance, oldRate, oldYearsRemaining);
  const newResult = computeStudentLoan(balance, newRate, newYears);

  return {
    oldTotal: oldResult.totalPaid,
    newTotal: newResult.totalPaid,
    totalSavings: oldResult.totalPaid - newResult.totalPaid,
    monthlySavings: oldResult.monthlyPayment - newResult.monthlyPayment,
  };
}
