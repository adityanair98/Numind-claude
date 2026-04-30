import Foundation

/// Visual theme for a quiz question, derived from its templateId.
/// Maps each template to a scene label, SF Symbols, and module color.
/// Lives in Core/DesignSystem — this is a UI concern, not a domain rule.
enum QuestionTheme {
    case dining
    case shopping
    case everydaySpend
    case budget
    case paycheck
    case investing
    case quickMath
    case estimation
    case debt
    case travel

    // MARK: - Display properties

    /// Primary SF Symbol shown in the icon circle.
    var symbolName: String {
        switch self {
        case .dining:        return "fork.knife"
        case .shopping:      return "tag.fill"
        case .everydaySpend: return "cart.fill"
        case .budget:        return "creditcard.fill"
        case .paycheck:      return "banknote"
        case .investing:     return "chart.line.uptrend.xyaxis"
        case .quickMath:     return "plusminus"
        case .estimation:    return "gauge.medium"
        case .debt:          return "exclamationmark.circle.fill"
        case .travel:        return "airplane"
        }
    }

    /// Large ghost symbol on the right — reinforces the scene.
    var accentSymbol: String {
        switch self {
        case .dining:        return "receipt"
        case .shopping:      return "bag.fill"
        case .everydaySpend: return "dollarsign.circle.fill"
        case .budget:        return "calendar"
        case .paycheck:      return "briefcase.fill"
        case .investing:     return "arrow.up.right.circle.fill"
        case .quickMath:     return "multiply.circle.fill"
        case .estimation:    return "function"
        case .debt:          return "banknote.fill"
        case .travel:        return "globe.americas.fill"
        }
    }

    /// Short bold label shown in the banner.
    var label: String {
        switch self {
        case .dining:        return "Restaurant Bill"
        case .shopping:      return "Shopping"
        case .everydaySpend: return "Everyday Spending"
        case .budget:        return "Budget & Plans"
        case .paycheck:      return "Paycheck"
        case .investing:     return "Investing"
        case .quickMath:     return "Quick Math"
        case .estimation:    return "Estimation"
        case .debt:          return "Debt & Loans"
        case .travel:        return "Travel Money"
        }
    }

    /// Secondary line below the label.
    var sublabel: String {
        switch self {
        case .dining:        return "Tipping & bill split"
        case .shopping:      return "Discounts & savings"
        case .everydaySpend: return "Tax, totals & prices"
        case .budget:        return "Subscriptions & tracking"
        case .paycheck:      return "Salary & income"
        case .investing:     return "Interest & returns"
        case .quickMath:     return "Doubling & splitting"
        case .estimation:    return "Mental math shortcuts"
        case .debt:          return "Credit cards & loans"
        case .travel:        return "Currency & spending abroad"
        }
    }

    /// The module color palette used for tints.
    var moduleColor: ModuleColor {
        switch self {
        case .dining:        return .blue
        case .shopping:      return .teal
        case .everydaySpend: return .yellow
        case .budget:        return .yellow
        case .paycheck:      return .green
        case .investing:     return .indigo
        case .quickMath:     return .orange
        case .estimation:    return .orange
        case .debt:          return .coral
        case .travel:        return .purple
        }
    }

    // MARK: - Template mapping

    /// Resolves a quiz template ID to its display theme.
    /// Falls back to .estimation for any unknown template.
    static func theme(for templateId: String) -> QuestionTheme {
        switch templateId {

        // ── Dining & Tips ────────────────────────────────────────────────────────
        case "tip_double_ten", "tip_twenty_total", "tip_pre_tax", "tip_post_tax",
             "tip_percent_basic", "tip_bill_total", "tip_split_tip":
            return .dining

        // ── Shopping & Discounts ─────────────────────────────────────────────────
        case "discount_ten_basic", "discount_ten_sale_price",
             "bogo_per_item", "bogo_savings",
             "stacked_discount_final", "stacked_discount_saving_calc",
             "unit_price_bulk_pack", "discount_amount_basic", "discount_sale_price":
            return .shopping

        // ── Everyday Spending ────────────────────────────────────────────────────
        case "cart_total", "unit_price_check", "tax_amount", "price_with_tax",
             "estimate_two_items":
            return .everydaySpend

        // ── Budget & Subscriptions ───────────────────────────────────────────────
        case "budget_remaining", "budget_after_purchase",
             "monthly_to_yearly", "yearly_to_monthly",
             "cost_per_use_calc", "cost_per_use_scenario":
            return .budget

        // ── Paycheck & Income ────────────────────────────────────────────────────
        case "net_pay_deduction", "annual_to_monthly_pay",
             "raise_dollar_amount", "raise_new_salary",
             "overtime_pay_calc", "biweekly_to_annual", "weekly_to_annual":
            return .paycheck

        // ── Investing & Growth ───────────────────────────────────────────────────
        case "simple_interest_earned", "total_balance_with_interest",
             "rule_of_72_years", "roi_percent_calc", "dollar_return_calc":
            return .investing

        // ── Quick Math ───────────────────────────────────────────────────────────
        case "double_amount", "half_amount", "multiply_five", "split_five_ways":
            return .quickMath

        // ── Debt & Loans ─────────────────────────────────────────────────────────
        case "cc_monthly_interest", "cc_monthly_interest_scenario",
             "cc_annual_interest", "cc_interest_year_d3",
             "cc_minimum_payment", "cc_minimum_payment_scenario",
             "loan_total_repayment", "loan_heavy_interest",
             "loan_total_interest_paid",
             "dti_ratio_basic", "dti_ratio_scenario", "dti_add_payments", "dti_housing_only",
             "cc_extra_payment_saving", "cc_balance_after_interest":
            return .debt

        // ── Travel Money ─────────────────────────────────────────────────────────
        case "currency_to_usd", "currency_to_usd_scenario",
             "usd_to_foreign_calc", "currency_convert_freeentry",
             "airport_markup_cost", "foreign_transaction_fee_calc", "total_with_fee_calc",
             "days_on_budget_calc", "travel_budget_remaining_calc",
             "split_hotel_room_calc", "hotel_per_night_calc", "split_accommodation_calc",
             "travel_insurance_cost_calc", "total_trip_with_insurance", "foreign_fee_total_saved":
            return .travel

        // ── Estimation (default) ─────────────────────────────────────────────────
        default:
            return .estimation
        }
    }
}
