export interface CarAffordabilityResult {
  maxMonthlyPayment: number;
  maxFinanced: number;
  maxCarPrice: number;
  downPaymentAmount: number;
}

export interface CarCostResult {
  downPayment: number;
  loanAmount: number;
  totalPayments: number;
  totalInterest: number;
  totalCost: number;
  valueAfterYear1: number;
  depreciationYear1: number;
}

/**
 * 20/4/10 rule affordability check.
 * 20% down, 4-year (48-month) max term, 10% of income max payment.
 */
export function computeAffordability(
  monthlyIncome: number
): CarAffordabilityResult {
  const maxMonthlyPayment = monthlyIncome * 0.1;
  const maxFinanced = maxMonthlyPayment * 48;
  const maxCarPrice = maxFinanced / 0.8; // 80% financed = 20% down
  const downPaymentAmount = maxCarPrice * 0.2;

  return { maxMonthlyPayment, maxFinanced, maxCarPrice, downPaymentAmount };
}

/**
 * Total cost of car purchase including interest and depreciation.
 */
export function computeCarCost(
  carPrice: number,
  downPercent: number,
  monthlyPayment: number,
  termMonths: number,
  depreciationPercent: number
): CarCostResult {
  const downPayment = carPrice * (downPercent / 100);
  const loanAmount = carPrice - downPayment;
  const totalPayments = monthlyPayment * termMonths;
  const totalInterest = totalPayments - loanAmount;
  const totalCost = downPayment + totalPayments;
  const depreciationYear1 = carPrice * (depreciationPercent / 100);
  const valueAfterYear1 = carPrice - depreciationYear1;

  return {
    downPayment,
    loanAmount,
    totalPayments,
    totalInterest,
    totalCost,
    valueAfterYear1,
    depreciationYear1,
  };
}
