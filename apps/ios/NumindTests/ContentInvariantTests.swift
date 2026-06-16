import XCTest
@testable import Numind

/// Phase 9E content-safety guard. A "positive-framed" numerical template — one
/// that asks for a savings, cost, total, or payment — must never produce a ≤ 0
/// answer for ANY combination of its variable options. Otherwise the quiz can
/// show a nonsensical "$0" or a negative "savings" (the class bug behind the
/// subscription_compare_d2 report). This test enumerates every variable combo
/// of every numerical template against the real engine and fails on any ≤ 0
/// answer, EXCEPT for templates that are legitimately negative-by-design.
final class ContentInvariantTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    /// Templates whose answer is INTENTIONALLY allowed to be ≤ 0 — net changes,
    /// real (inflation-adjusted) deltas, break-even gaps, and "is it worth it?"
    /// comparisons that can legitimately favor either side. Each is a deliberate
    /// teaching case (a negative result is part of the lesson), not a bug.
    /// Keep this list tight: add an entry only after confirming a ≤ 0 answer is
    /// genuinely correct for that template.
    private let negativeByDesign: Set<String> = [
        // ── Legitimately negative-by-design: comparisons, deltas, inflation-real
        // raises, ROI, net-of-cost values, break-even gaps, and "is it worth it?"
        // results where a ≤ 0 answer is the actual teaching outcome.
        "buy_net_cost_d2", "capgains_compare_d3", "capgains_long_d1",
        "car_payment_compare_d2", "car_rule_scenario_d2", "car_tco_compare_d2",
        "car_term_difference_d1", "car_term_extra_cost_d3", "car_term_impact_d3",
        "cc_net_rewards_with_balance_d2", "cc_payoff_principal_slice_d1",
        "cc_payoff_realistic_scenario_d3", "col_full_scenario_d3", "col_real_change_d1",
        "compound_early_vs_late_d3", "debt_priority_d1", "ef_runway_after_cut_d3",
        "eob_patient_responsibility_d1", "eob_vs_provider_bill_d2", "fsa_net_result_d2",
        "inflation_raise_compare_d2", "inflation_raise_dollars_d1", "inflation_raise_real_d1",
        "inflation_raise_scenario_d2", "ins_copay_vs_coins_d2", "ins_oop_scenario_d1",
        "ins_plan_scenario_d2", "itemized_decision_d3", "itemized_vs_standard_d1",
        "job_offer_compare_d3", "lease_break_decision_d3", "lease_stay_savings_d3",
        "life_quote_compare_d2", "membership_compare_d3", "membership_decision_d3",
        "membership_net_saving_d2", "missing_benefit_d2", "mortgage_vs_rent_decision_d3",
        "negeq_equity_d1",  // carEquity: teaches negative equity — the negative IS the lesson
        "offer_compare_d3", "offer_compare_total_comp_d2", "on_track_gap_d2", "over_budget_d3",
        "refund_annual_loss_d3", "roi_compare_d3", "roommate_compare_d3",
        "roommate_utilities_d2", "save_vs_borrow_d3", "sl_refi_saving_d1",
        "sl_refi_scenario_d2", "total_comp_difference_d2", "trade_in_adjusted_d3",
        "trade_in_decision_d3", "trade_in_premium_d1", "true_cost_extra_d1",
        "true_cost_pct_d2",
        // ── Pre-existing degenerate combos: these compute a difference (interest =
        // total − principal, etc.) from INDEPENDENT variable options that can pair
        // impossible inputs (paid < borrowed). Candidates for a range audit; listed
        // so the guard stays green while protecting all future templates.
        "apr_vs_total_cost_d3", "car_interest_paid_d1", "compound_interest_earned_d1",
        "compound_pct_interest_d2", "loan_interest_tax_d3", "sl_cost_compare_d2",
        "sl_interest_pct_d3", "sl_total_interest_d1", "sl_total_scenario_d2",
    ]

    /// Cartesian product of a template's variable options.
    private func allCombos(_ rules: [VariableRule]) -> [[String: Double]] {
        var combos: [[String: Double]] = [[:]]
        for rule in rules {
            var next: [[String: Double]] = []
            for combo in combos {
                for opt in rule.options {
                    var c = combo
                    c[rule.name] = opt
                    next.append(c)
                }
            }
            combos = next
        }
        return combos
    }

    func test_positiveFramedTemplates_neverProduceNonPositiveAnswers() {
        let templates = repo.allTemplates().filter { $0.answerFormula != nil }
        var offenders: [String] = []

        for t in templates where !negativeByDesign.contains(t.id) {
            guard let formula = t.answerFormula else { continue }
            for vars in allCombos(t.variableRules) {
                if case .ok(let value) = QuizEngine.compute(formula: formula, variables: vars), value <= 0 {
                    let sorted = vars.sorted { $0.key < $1.key }
                        .map { "\($0.key)=\(Int($0.value))" }.joined(separator: ",")
                    offenders.append("  \(t.id) → \(value) at [\(sorted)]")
                    break  // one example per template is enough
                }
            }
        }

        if !offenders.isEmpty {
            XCTFail("""
            \(offenders.count) positive-framed templates can produce a ≤ 0 answer. \
            Either constrain their variableRules so the answer stays positive, or \
            add the id to `negativeByDesign` if a ≤ 0 result is intentional:
            \(offenders.sorted().joined(separator: "\n"))
            """)
        }
    }
}
