export interface DiscountResult {
  originalPrice: number;
  discountAmount: number;
  salePrice: number;
  discountPercent: number;
}

/** Single discount: price × (1 − rate) */
export function computeDiscount(price: number, discountPercent: number): DiscountResult {
  const rate = discountPercent / 100;
  const discountAmount = price * rate;
  const salePrice = price - discountAmount;

  return {
    originalPrice: price,
    discountAmount,
    salePrice,
    discountPercent: price > 0 ? discountPercent : 0,
  };
}

export interface StackedDiscountResult extends DiscountResult {
  /** What people wrongly think the total discount is (additive) */
  naiveDiscountPercent: number;
  /** The actual combined discount percentage */
  actualDiscountPercent: number;
}

/** Stacked discounts: price × (1 − rate1) × (1 − rate2) */
export function computeStackedDiscount(
  price: number,
  discount1Percent: number,
  discount2Percent: number
): StackedDiscountResult {
  const rate1 = discount1Percent / 100;
  const rate2 = discount2Percent / 100;
  const salePrice = price * (1 - rate1) * (1 - rate2);
  const discountAmount = price - salePrice;
  const actualDiscountPercent = price > 0 ? (discountAmount / price) * 100 : 0;

  return {
    originalPrice: price,
    discountAmount,
    salePrice,
    discountPercent: actualDiscountPercent,
    naiveDiscountPercent: discount1Percent + discount2Percent,
    actualDiscountPercent,
  };
}
