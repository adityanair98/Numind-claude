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
    case debt
    case housing
    case taxes
    case insurance
    case carBuying
    case studentLoans

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
        case .debt:          return "exclamationmark.circle.fill"
        case .housing:       return "house.fill"
        case .taxes:         return "doc.text.fill"
        case .insurance:     return "cross.case.fill"
        case .carBuying:     return "car.fill"
        case .studentLoans:  return "graduationcap.fill"
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
        case .debt:          return "banknote.fill"
        case .housing:       return "key.fill"
        case .taxes:         return "building.columns.fill"
        case .insurance:     return "heart.text.square.fill"
        case .carBuying:     return "key.radiowaves.forward.fill"
        case .studentLoans:  return "book.closed.fill"
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
        case .debt:          return "Debt & Loans"
        case .housing:       return "Housing & Rent"
        case .taxes:         return "Taxes & Paycheck"
        case .insurance:     return "Insurance"
        case .carBuying:     return "Car Buying"
        case .studentLoans:  return "Student Loans"
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
        case .debt:          return "Credit cards & loans"
        case .housing:       return "Affordability & costs"
        case .taxes:         return "Brackets & take-home pay"
        case .insurance:     return "Premiums & deductibles"
        case .carBuying:     return "Loans & depreciation"
        case .studentLoans:  return "Repayment & forgiveness"
        }
    }

    /// The module color palette used for tints.
    var moduleColor: ModuleColor {
        switch self {
        case .dining:        return .blue
        case .shopping:      return .blue
        case .everydaySpend: return .yellow
        case .budget:        return .yellow
        case .paycheck:      return .green
        case .investing:     return .indigo
        case .quickMath:     return .orange
        case .debt:          return .coral
        case .housing:       return .rose
        case .taxes:         return .slate
        case .insurance:     return .purple
        case .carBuying:     return .teal
        case .studentLoans:  return .orange
        }
    }

    // MARK: - Template mapping

    /// Resolves a quiz template ID to its display theme.
    /// Falls back to .quickMath for any unknown template.
    static func theme(for templateId: String) -> QuestionTheme {
        switch templateId {

        // ── Dining & Tips ────────────────────────────────────────────────────────
        case "tip_double_ten",
             "tip_percent_basic", "tip_bill_total", "tip_split_tip",
             "tip_bar_d2", "tip_10_pct_d1", "tip_15_pct_d1",
             "tip_total_15_d2", "tip_total_25_d2",
             "tip_group_per_person_d2", "tip_group_per_person_d3",
             "tip_18_d2", "tip_post_tax_scenario_d3",
             "tip_per_hundred_d1":
            return .dining

        // ── Shopping & Discounts ─────────────────────────────────────────────────
        case "bogo_per_item", "bogo_savings",
             "stacked_discount_final", "stacked_discount_saving_calc",
             "discount_25_d1",
             "unit_price_grocery_d2",
             "bogo_scenario_d2", "discount_compare_d2", "discount_budget_d3",
             "stacked_scenario_d3",
             "coupon_save_d1", "cashback_amount_d1", "coupon_plus_cashback_d2",
             "coupon_vs_cashback_compare_d3", "coupon_cashback_final_d3",
             "disc_tax_simple_d1", "disc_tax_amount_d2", "disc_tax_nonround_d2",
             "disc_tax_stacked_d3", "disc_tax_compare_d3",
             "membership_breakeven_d1", "membership_annual_d1",
             "membership_net_saving_d2", "membership_compare_d3", "membership_decision_d3":
            return .shopping

        // ── Everyday Spending ────────────────────────────────────────────────────
        case "cart_total", "unit_price_check", "tax_amount", "price_with_tax",
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
             "biweekly_annual_d1", "weekly_annual_d1", "weekly_annual_d2",
             "inflation_raise_real_d1", "inflation_raise_dollars_d1",
             "inflation_raise_scenario_d2", "inflation_raise_compare_d2",
             "inflation_raise_negative_d3":
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
             "bond_simple_d2", "portfolio_gain_d2", "investing_total_d3",
             "match_amount_d1", "total_with_match_d1",
             "match_scenario_d2", "match_percent_d2", "match_annual_d3",
             "roth_after_tax_d1", "traditional_tax_saved_d1",
             "roth_scenario_d2", "traditional_scenario_d2", "roth_vs_trad_compare_d3",
             "compound_total_d1", "compound_interest_earned_d1",
             "compound_10yr_d2", "compound_20yr_d2", "compound_compare_d3":
            return .investing

        // ── Debt & Loans ─────────────────────────────────────────────────────────
        case "cc_monthly_interest", "cc_monthly_interest_scenario",
             "cc_annual_interest", "cc_interest_year_d3",
             "cc_minimum_payment", "cc_minimum_payment_scenario",
             "loan_total_repayment", "loan_heavy_interest",
             "loan_total_interest_paid",
             "dti_ratio_basic", "dti_ratio_scenario", "dti_add_payments", "dti_housing_only",
             "cc_extra_payment_saving", "cc_balance_after_interest":
            return .debt

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

        // ── Insurance & Healthcare ──────────────────────────────────────────────
        case "ins_annual_premium_d1", "ins_worst_case_d1",
             "ins_deduct_compare_d2", "ins_premium_scenario_d2", "ins_breakeven_d3",
             "ins_coinsurance_d1", "ins_copay_total_d1",
             "ins_coinsurance_big_d2", "ins_copay_scenario_d2", "ins_coinsurance_compare_d3",
             "ins_oop_total_d1", "ins_oop_scenario_d1",
             "ins_oop_calc_d2", "ins_oop_compare_d2", "ins_oop_cap_d3",
             "ins_hdhp_annual_d1", "ins_ppo_annual_d1",
             "ins_hdhp_vs_ppo_d2", "ins_plan_scenario_d2", "ins_breakeven_visits_d3",
             "ins_hsa_saving_d1", "ins_hsa_annual_d1",
             "ins_hsa_scenario_d2", "ins_hsa_compare_d2", "ins_hsa_total_d3":
            return .insurance

        // ── Car & Big Purchases ─────────────────────────────────────────────────
        case "car_total_cost_d1", "car_interest_paid_d1",
             "car_monthly_scenario_d2", "car_total_compare_d2", "car_term_impact_d3",
             "car_term_total_d1", "car_term_difference_d1",
             "car_term_scenario_d2", "car_payment_compare_d2", "car_term_interest_d3",
             "car_down_amount_d1", "car_loan_after_down_d1",
             "car_down_scenario_d2", "car_down_compare_d2", "car_down_savings_d3",
             "car_max_payment_d1", "car_20pct_down_d1",
             "car_10pct_rule_d2", "car_rule_scenario_d2", "car_afford_check_d3",
             "car_year1_value_d1", "car_depreciation_d1",
             "car_year2_value_d2", "car_depreciation_scenario_d2", "car_depreciation_compare_d3":
            return .carBuying

        // ── Student Loans & Education ───────────────────────────────────────────
        case "sl_monthly_d1", "sl_monthly_estimate_d1",
             "sl_monthly_scenario_d2", "sl_payment_compare_d2", "sl_monthly_detail_d3",
             "sl_total_cost_d1", "sl_total_interest_d1",
             "sl_total_scenario_d2", "sl_cost_compare_d2", "sl_cost_detail_d3",
             "sl_refi_saving_d1", "sl_refi_annual_d1",
             "sl_refi_scenario_d2", "sl_refi_compare_d2", "sl_refi_total_d3",
             "sl_idr_payment_d1", "sl_idr_estimate_d1",
             "sl_idr_scenario_d2", "sl_idr_compare_d2", "sl_idr_savings_d3",
             "sl_pslf_total_d1", "sl_pslf_forgiven_d1",
             "sl_pslf_scenario_d2", "sl_pslf_compare_d2", "sl_pslf_decision_d3":
            return .studentLoans

        // ── Fallback ─────────────────────────────────────────────────────────────
        default:
            return .quickMath
        }
    }
}
