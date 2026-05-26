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
             "membership_net_saving_d2", "membership_compare_d3", "membership_decision_d3",
             // V3 concept lessons
             "concept_anchoring_d1", "concept_decoy_pricing_d2", "concept_charm_pricing_d2",
             "concept_inflated_msrp_d3", "concept_bogo_inflation_d3":
            return .shopping

        // ── Everyday Spending (tax) ──────────────────────────────────────────────
        case "tax_amount", "price_with_tax", "tax_electronics_d2",
             "pre_tax_max_d2", "budget_asymmetry_d3":
            return .everydaySpend

        // ── Budget & Subscriptions ───────────────────────────────────────────────
        case "cost_per_use_calc", "cost_per_use_scenario",
             "subscription_compare_d2", "yearly_cost_d1",
             "cost_per_use_gym_d2", "mm_cpu_book_d1", "mm_cpu_daily_d2",
             // Subscription audit
             "sub_audit_total_d1", "sub_audit_annual_d2", "sub_audit_cut_d3",
             // 50/30/20
             "needs_50_d1", "savings_20_d1", "all_three_buckets_d2",
             "over_budget_d3", "target_savings_d3",
             // Latte factor
             "daily_to_annual_d1", "workday_to_annual_d1",
             "daily_habit_savings_d2", "habit_compare_d2", "multi_habit_annual_d3",
             // Weekly/monthly
             "weekly_to_monthly_d1", "biweekly_to_monthly_d1", "monthly_to_weekly_d2",
             "wrong_multiplier_shortfall_d3", "biweekly_annual_check_d2",
             // V3 concept lessons
             "concept_needs_definition_d1", "concept_needs_gym_d2", "concept_needs_streaming_d2",
             "concept_needs_over_50_d3", "concept_needs_job_loss_d3":
            return .budget

        // ── Paycheck & Income ────────────────────────────────────────────────────
        case "net_pay_deduction", "annual_to_monthly_pay",
             "raise_dollar_amount", "raise_new_salary",
             "overtime_pay_calc", "biweekly_to_annual", "weekly_to_annual",
             "salary_monthly_annual_d1", "salary_hourly_annual_d1",
             "net_pay_biweekly_d2", "net_pay_scenario_d2",
             "raise_dollar_d1", "raise_new_salary_d2",
             "overtime_d2", "overtime_scenario_d2",
             "biweekly_annual_d1", "weekly_annual_d1",
             "inflation_raise_real_d1", "inflation_raise_dollars_d1",
             "inflation_raise_scenario_d2", "inflation_raise_compare_d2",
             "inflation_raise_negative_d3",
             // Phase 2 reworks
             "raise_after_tax_monthly_d3", "total_weekly_with_ot_d3", "job_offer_compare_d3",
             // Hourly to salary
             "hourly_to_annual_d1", "annual_to_hourly_d1", "hourly_nonround_d2",
             "offer_compare_d3", "annual_nonround_d3",
             // Total compensation
             "total_comp_sum_d1", "total_comp_difference_d2", "total_comp_hourly_d3",
             "missing_benefit_d2", "benefits_pct_d2",
             // Side hustle
             "net_hourly_d1", "side_hustle_simple_d1", "worth_it_compare_d3",
             "hourly_compare_d3", "side_hustle_annual_d2",
             // V3 concept lessons
             "concept_exempt_def_d1", "concept_nonexempt_def_d1", "concept_exempt_threshold_d2",
             "concept_exempt_misclass_d2", "concept_exempt_tradeoff_d3":
            return .paycheck

        // ── Investing & Growth ───────────────────────────────────────────────────
        case "rule_of_72_years", "roi_percent_calc", "dollar_return_calc",
             "total_with_interest_d2",
             "rule72_d1", "rule72_scenario_d2",
             "roi_percent_d2", "portfolio_gain_d2", "investing_total_d3",
             "match_amount_d1", "total_with_match_d1",
             "match_scenario_d2", "match_percent_d2", "match_annual_d3",
             "roth_after_tax_d1", "traditional_tax_saved_d1",
             "roth_scenario_d2", "traditional_scenario_d2",
             "compound_total_d1", "compound_interest_earned_d1",
             // Phase 3 reworks
             "roi_compare_d3", "roth_growth_value_d3",
             "compound_pct_interest_d2", "compound_early_vs_late_d3", "compound_backwards_d3",
             // DCA
             "dca_total_invested_d1", "dca_shares_bought_d1", "dca_avg_cost_d2",
             "dca_vs_lump_sum_d3", "dca_consistency_d2",
             // Fund fees
             "fund_fee_annual_d1", "fund_fee_diff_d2", "fund_fee_compare_d1",
             "fund_fee_decade_d3", "fund_fee_30yr_d3",
             // Emergency fund
             "ef_essentials_sum_d1", "ef_target_d1", "ef_runway_d2",
             "ef_runway_after_cut_d3", "ef_months_to_target_d3",
             // Rental yield
             "yield_gross_d1", "yield_monthly_check_d1", "yield_compare_d2",
             "yield_net_d3", "yield_decision_d3",
             // On track
             "on_track_multiple_d1", "on_track_target_d1", "on_track_gap_d2",
             "on_track_close_gap_d3", "on_track_extra_save_d3",
             // V3 concept lessons
             "concept_stock_def_d1", "concept_bond_def_d1", "concept_index_fund_d2",
             "concept_etf_vs_mutual_d2", "concept_risk_return_rank_d3",
             "concept_alloc_120_d1", "concept_alloc_bonds_role_d2", "concept_target_date_d2",
             "concept_alloc_too_conservative_d3", "concept_crash_response_d3",
             "concept_loss_aversion_d1", "concept_panic_sell_d2", "concept_market_timing_myth_d2",
             "concept_wait_for_dip_d3", "concept_panic_sell_2020_d3":
            return .investing

        // ── Debt & Loans ─────────────────────────────────────────────────────────
        case "cc_monthly_interest", "cc_monthly_interest_scenario",
             "cc_annual_interest", "cc_interest_year_d3",
             "cc_minimum_payment", "cc_minimum_payment_scenario",
             "loan_total_repayment", "loan_total_interest_paid",
             "dti_ratio_basic", "dti_ratio_scenario", "dti_add_payments", "dti_housing_only",
             "cc_extra_payment_saving",
             "cc_rate_check_d1", "cc_min_balance_d1", "cc_new_balance_d2",
             "cc_interest_check_d2", "loan_repayment_d1",
             "cc_extra_d1", "cc_annual_cost_d2", "cc_balance_interest_d2",
             // Phase 3 reworks
             "loan_interest_tax_d3", "save_vs_borrow_d3",
             "new_dti_with_payment_d3", "principal_reduction_d3",
             // Avalanche/snowball
             "debt_priority_d1", "avalanche_monthly_saving_d2",
             "snowball_difference_d3", "debt_compare_rates_d2", "psychology_premium_d3",
             // APR vs APY
             "apr_apy_which_higher_d1", "monthly_rate_d1", "apy_from_apr_d2",
             "apr_apy_compare_d3", "apy_yearly_cost_d3",
             // BNPL
             "bnpl_simple_d1", "bnpl_late_fee_d2", "bnpl_surcharge_pct_d3",
             "bnpl_stacked_d3", "bnpl_annual_d2",
             // V3 concept lessons
             "concept_fico_largest_d1", "concept_utilization_max_d2", "concept_close_old_card_d2",
             "concept_hard_inquiry_d3", "concept_no_debt_myth_d3",
             "concept_good_debt_d1", "concept_bad_debt_d1", "concept_interest_threshold_d2",
             "concept_mortgage_short_d3", "concept_payoff_vs_invest_d3":
            return .debt

        // ── Housing & Rent ───────────────────────────────────────────────────────
        case "rent_afford_basic_d1", "rent_afford_scenario_d1",
             "rent_afford_reverse_d2", "rent_afford_annual_d3", "rent_min_income_d3",
             "rent_increase_basic_d1", "rent_increase_new_d1",
             "rent_increase_annual_d2", "rent_above_avg_d2", "rent_renew_vs_move_d3",
             "move_in_basic_d1", "move_in_no_broker_d1",
             "move_in_with_broker_d2", "move_in_scenario_d2", "move_in_compare_d3",
             // Mortgage reworks
             "mortgage_rate_factor_d1", "mortgage_per_100k_d1", "mortgage_rate_compare_d2",
             "mortgage_pi_taxes_d3", "mortgage_vs_rent_decision_d3",
             // Roommate
             "roommate_basic_d1", "roommate_utilities_d2", "roommate_unequal_d3",
             "roommate_annual_d2", "roommate_compare_d3",
             // True cost
             "true_cost_sum_d1", "true_cost_extra_d1", "true_cost_compare_d2",
             "true_cost_pct_d2", "true_cost_vs_28_d3",
             // Lease break
             "lease_break_fee_d1", "lease_break_total_d2", "lease_break_breakeven_d2",
             "lease_stay_savings_d3", "lease_break_decision_d3",
             // V3 concept lessons
             "concept_buy_rent_short_d1", "concept_buy_rent_long_d2", "concept_buy_rent_200x_d2",
             "concept_buy_rent_opportunity_d3", "concept_buy_rent_mobility_d3",
             "concept_lease_termination_d1", "concept_lease_auto_renewal_d2", "concept_lease_deposit_d2",
             "concept_lease_illegal_clause_d3", "concept_lease_wear_tear_d3":
            return .housing

        // ── Taxes & Paycheck ────────────────────────────────────────────────────
        case "bracket_basic_d1", "bracket_two_tier_d1",
             "bracket_scenario_d2", "bracket_compare_d2", "bracket_effective_d3",
             "deduction_basic_d1", "deduction_net_d1",
             "deduction_fica_d2", "deduction_scenario_d2", "deduction_compare_d3",
             "refund_basic_d1", "refund_owe_d1",
             "se_tax_basic_d1", "se_tax_amount_d1",
             "se_tax_scenario_d2", "se_tax_compare_d2",
             // Phase 4 reworks
             "refund_monthly_loan_d2", "refund_invested_d2", "refund_annual_loss_d3",
             "se_quarterly_combined_d3",
             // Standard vs itemized
             "itemized_sum_d1", "itemized_vs_standard_d1", "itemized_saving_d2",
             "itemized_decision_d3", "itemized_strategy_d3",
             // Capital gains
             "capgains_short_d1", "capgains_long_d1", "capgains_saving_d2",
             "capgains_timing_d3", "capgains_compare_d3",
             // W-4 adjust
             "w4_bump_d1", "w4_bump_biweekly_d1", "w4_invested_d2",
             "w4_annual_growth_d2", "w4_lifetime_d3",
             // V3 concept lessons
             "concept_paycheck_fica_d1", "concept_paycheck_pretax_d1", "concept_paycheck_401k_cost_d2",
             "concept_paycheck_post_tax_d2", "concept_paycheck_check_error_d3",
             "concept_filing_default_d1", "concept_filing_hoh_d2", "concept_filing_mfs_idr_d2",
             "concept_filing_mfj_default_d3", "concept_filing_status_choice_d3":
            return .taxes

        // ── Insurance & Healthcare ──────────────────────────────────────────────
        case "ins_annual_premium_d1", "ins_worst_case_d1",
             "ins_deduct_compare_d2", "ins_premium_scenario_d2",
             "ins_coinsurance_d1", "ins_copay_total_d1",
             "ins_coinsurance_big_d2",
             "ins_oop_total_d1", "ins_oop_scenario_d1",
             "ins_oop_calc_d2", "ins_oop_compare_d2", "ins_oop_cap_d3",
             "ins_hdhp_annual_d1", "ins_ppo_annual_d1",
             "ins_hdhp_vs_ppo_d2", "ins_plan_scenario_d2",
             "ins_hsa_saving_d1", "ins_hsa_annual_d1",
             "ins_hsa_scenario_d2", "ins_hsa_compare_d2",
             // Phase 5 reworks
             "ins_exposure_range_d3", "ins_er_visit_d3", "ins_copay_vs_coins_d2",
             "ins_visits_breakeven_d3", "ins_hsa_retirement_d3",
             // FSA
             "fsa_tax_saving_d1", "fsa_net_result_d2", "fsa_breakeven_d3",
             "fsa_election_compare_d2", "fsa_max_safe_d3",
             // Life
             "life_basic_10x_d1", "life_dime_adjusted_d2", "life_quote_compare_d2",
             "life_per_100k_d2", "life_lifetime_d3",
             // Prescription
             "rx_annual_saving_d1", "rx_multiple_d2", "rx_goodrx_d3",
             "rx_monthly_diff_d1", "rx_lifetime_d2",
             // V3 concept lessons
             "concept_insurance_priority_top_d1", "concept_insurance_skip_d1",
             "concept_insurance_overinsured_d2", "concept_insurance_disability_priority_d3",
             "concept_insurance_warranty_d3",
             "concept_disability_prob_d1", "concept_disability_own_occ_d2", "concept_disability_cap_d2",
             "concept_disability_elim_period_d3", "concept_disability_supplemental_d3":
            return .insurance

        // ── Car & Big Purchases ─────────────────────────────────────────────────
        case "car_total_cost_d1", "car_interest_paid_d1",
             "car_monthly_scenario_d2", "car_total_compare_d2", "car_term_impact_d3",
             "car_term_total_d1", "car_term_difference_d1",
             "car_term_scenario_d2", "car_payment_compare_d2",
             "car_down_amount_d1", "car_loan_after_down_d1",
             "car_down_scenario_d2", "car_down_compare_d2",
             "car_max_payment_d1", "car_20pct_down_d1",
             "car_10pct_rule_d2", "car_rule_scenario_d2", "car_afford_check_d3",
             "car_year1_value_d1", "car_depreciation_d1",
             "car_year2_value_d2", "car_depreciation_scenario_d2",
             // Phase 5 reworks
             "car_term_extra_cost_d3", "car_down_savings_total_d3", "car_total_cost_3yr_d3",
             // TCO
             "car_tco_basic_d1", "car_tco_compare_d2", "car_tco_keep_vs_buy_d3",
             "car_tco_vs_income_d2", "car_tco_annual_d2",
             // Lease vs Buy
             "lease_total_cost_d1", "buy_net_cost_d2", "lease_vs_buy_3yr_d3",
             "lease_monthly_d1", "lease_vs_buy_lifetime_d3",
             // Trade-in vs Private
             "trade_in_premium_d1", "trade_in_hourly_d2", "trade_in_tax_benefit_d2",
             "trade_in_adjusted_d3", "trade_in_decision_d3",
             // V3 concept lessons
             "concept_dealer_otd_d1", "concept_dealer_payment_trap_d2", "concept_dealer_fi_office_d2",
             "concept_dealer_finance_markup_d3", "concept_dealer_gap_insurance_d3",
             "concept_warranty_manufacturer_d1", "concept_warranty_extended_math_d2",
             "concept_warranty_self_insure_d2", "concept_warranty_when_worth_d3", "concept_warranty_cpo_d3":
            return .carBuying

        // ── Student Loans & Education ───────────────────────────────────────────
        case "sl_monthly_estimate_d1",
             "sl_total_cost_d1", "sl_total_interest_d1",
             "sl_total_scenario_d2", "sl_cost_compare_d2",
             "sl_refi_saving_d1", "sl_refi_annual_d1",
             "sl_refi_scenario_d2", "sl_refi_compare_d2",
             // IDR is now a concept lesson — old numerical templates removed.
             "concept_idr_definition_d1", "concept_idr_forgiveness_d1",
             "concept_idr_eligibility_d2", "concept_idr_recertification_d2",
             "concept_idr_plans_in_flux_d3",
             "sl_pslf_total_d1", "sl_pslf_forgiven_d1",
             "sl_pslf_scenario_d2", "sl_pslf_compare_d2", "sl_pslf_decision_d3",
             // Phase 5 reworks
             "sl_rule_thumb_d1", "sl_rule_apply_d2", "sl_per10k_compare_d2", "sl_monthly_range_d3",
             "sl_interest_pct_d3", "sl_refi_vs_pslf_d3",
             // Employer Benefit
             "sl_employer_monthly_d1", "sl_employer_5yr_d2",
             "sl_employer_with_interest_d3", "sl_employer_vs_raise_d2", "sl_employer_lifetime_d3",
             // Grace Period
             "sl_daily_interest_d1", "sl_grace_total_d1",
             "sl_grace_vs_interest_only_d3", "sl_grace_capitalization_d2", "sl_grace_lifetime_d3",
             // Parent PLUS
             "plus_vs_private_annual_d1", "plus_vs_private_10yr_d2",
             "plus_origination_d2", "plus_total_cost_d3", "plus_decision_d3",
             // V3 concept lessons
             "concept_sl_sub_def_d1", "concept_sl_unsub_def_d1", "concept_sl_who_qualifies_d2",
             "concept_sl_balance_growth_d3", "concept_sl_grad_loans_d3",
             "concept_sl_refi_lose_idr_d1", "concept_sl_refi_one_way_d2", "concept_sl_refi_teacher_d2",
             "concept_sl_refi_when_makes_sense_d3", "concept_sl_refi_vs_protections_d3":
            return .studentLoans

        // ── Fallback ─────────────────────────────────────────────────────────────
        default:
            return .quickMath
        }
    }
}
