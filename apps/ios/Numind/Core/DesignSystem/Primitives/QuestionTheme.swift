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
    case housing
    case taxes

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
        case .housing:       return "house.fill"
        case .taxes:         return "doc.text.fill"
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
        case .housing:       return "key.fill"
        case .taxes:         return "building.columns.fill"
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
        case .housing:       return "Housing & Rent"
        case .taxes:         return "Taxes & Paycheck"
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
        case .housing:       return "Affordability & costs"
        case .taxes:         return "Brackets & take-home pay"
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
        case .housing:       return .rose
        case .taxes:         return .slate
        }
    }

    // MARK: - Template mapping

    /// Resolves a quiz template ID to its display theme.
    /// Falls back to .estimation for any unknown template.
    static func theme(for templateId: String) -> QuestionTheme {
        switch templateId {

        // ── Dining & Tips ────────────────────────────────────────────────────────
        case "tip_double_ten", "tip_twenty_total", "tip_pre_tax", "tip_post_tax",
             "tip_percent_basic", "tip_bill_total", "tip_split_tip",
             "tip_coffee_d1", "tip_taxi_d1", "tip_hair_salon_d2", "tip_hotel_service_d2",
             "tip_bar_d2", "tip_10_pct_d1", "tip_15_pct_d1", "tip_25_pct_d2",
             "tip_total_20_d1", "tip_total_15_d2", "tip_total_25_d2",
             "tip_group_per_person_d2", "tip_group_per_person_d3",
             "tip_18_d2", "tip_post_tax_scenario_d3":
            return .dining

        // ── Shopping & Discounts ─────────────────────────────────────────────────
        case "discount_ten_basic", "discount_ten_sale_price",
             "bogo_per_item", "bogo_savings",
             "stacked_discount_final", "stacked_discount_saving_calc",
             "unit_price_bulk_pack", "discount_amount_basic", "discount_sale_price",
             "discount_15_d1", "discount_20_d1", "discount_25_d1", "discount_50_d1",
             "discount_30_d2", "discount_clearance_d2", "discount_online_d2",
             "unit_price_grocery_d2", "unit_price_oz_d2",
             "bogo_scenario_d2", "discount_compare_d2", "discount_budget_d3",
             "stacked_scenario_d3":
            return .shopping

        // ── Everyday Spending ────────────────────────────────────────────────────
        case "cart_total", "unit_price_check", "tax_amount", "price_with_tax",
             "estimate_two_items",
             "tax_coffee_d1", "tax_electronics_d2", "price_tax_d1", "price_tax_scenario_d2",
             "cart_estimate_d1", "cart_estimate_d2":
            return .everydaySpend

        // ── Budget & Subscriptions ───────────────────────────────────────────────
        case "budget_remaining", "budget_after_purchase",
             "monthly_to_yearly", "yearly_to_monthly",
             "cost_per_use_calc", "cost_per_use_scenario",
             "budget_trip_d2", "subscription_compare_d2", "yearly_cost_d1",
             "cost_per_use_gym_d2", "budget_weekly_d2", "subscription_streaming_d1":
            return .budget

        // ── Paycheck & Income ────────────────────────────────────────────────────
        case "net_pay_deduction", "annual_to_monthly_pay",
             "raise_dollar_amount", "raise_new_salary",
             "overtime_pay_calc", "biweekly_to_annual", "weekly_to_annual",
             "salary_monthly_annual_d1", "salary_hourly_annual_d1", "salary_hourly_annual_d2",
             "salary_annual_hourly_d2", "salary_annual_hourly_d3",
             "net_pay_biweekly_d2", "net_pay_scenario_d2",
             "raise_dollar_d1", "raise_new_salary_d2", "raise_new_salary_d3",
             "overtime_d2", "overtime_scenario_d2",
             "biweekly_annual_d1", "weekly_annual_d1", "weekly_annual_d2":
            return .paycheck

        // ── Investing & Growth ───────────────────────────────────────────────────
        case "simple_interest_earned", "total_balance_with_interest",
             "rule_of_72_years", "roi_percent_calc", "dollar_return_calc",
             "simple_interest_d1", "simple_interest_d2",
             "total_with_interest_d1", "total_with_interest_d2",
             "rule72_d1", "rule72_scenario_d2",
             "roi_percent_d2", "roi_scenario_d2",
             "dollar_return_d1", "dollar_return_d2",
             "monthly_return_d2", "monthly_return_d3",
             "bond_simple_d2", "portfolio_gain_d2", "investing_total_d3":
            return .investing

        // ── Quick Math ───────────────────────────────────────────────────────────
        case "double_amount", "half_amount", "multiply_five", "split_five_ways",
             "triple_amount_d1", "quarter_d1",
             "double_quick_d1", "half_quick_d2", "split_three_ways_d1":
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

        // ── Housing & Rent ───────────────────────────────────────────────────────
        case "rent_afford_basic_d1", "rent_afford_scenario_d1",
             "rent_afford_reverse_d2", "rent_afford_compare_d2", "rent_afford_annual_d3",
             "rent_increase_basic_d1", "rent_increase_new_d1",
             "rent_increase_annual_d2", "rent_increase_scenario_d2", "rent_increase_compare_d3",
             "move_in_basic_d1", "move_in_no_broker_d1",
             "move_in_with_broker_d2", "move_in_scenario_d2", "move_in_compare_d3",
             "sqft_basic_d1", "sqft_compare_d1",
             "sqft_scenario_d2", "sqft_reverse_d2", "sqft_best_deal_d3",
             "mortgage_basic_d1", "mortgage_compare_d2",
             "mortgage_scenario_d2", "mortgage_interest_d2", "mortgage_vs_rent_d3":
            return .housing

        // ── Taxes & Paycheck ────────────────────────────────────────────────────
        case "bracket_basic_d1", "bracket_two_tier_d1",
             "bracket_scenario_d2", "bracket_compare_d2", "bracket_effective_d3",
             "deduction_basic_d1", "deduction_net_d1",
             "deduction_fica_d2", "deduction_scenario_d2", "deduction_compare_d3",
             "gross_net_basic_d1", "gross_net_monthly_d1",
             "gross_net_scenario_d2", "gross_net_compare_d2", "gross_net_reverse_d3",
             "refund_basic_d1", "refund_owe_d1",
             "refund_scenario_d2", "refund_compare_d2", "refund_monthly_d3",
             "se_tax_basic_d1", "se_tax_amount_d1",
             "se_tax_scenario_d2", "se_tax_compare_d2", "se_tax_quarterly_d3":
            return .taxes

        // ── Estimation (default) ─────────────────────────────────────────────────
        default:
            return .estimation
        }
    }
}
