import Foundation

/// The 7 competency axes that drive the Numind Score radar.
///
/// These intentionally do NOT map 1:1 to the 10 curriculum modules.
/// The modules organize *content*; axes measure *competency*. A renter without
/// student loans shouldn't see their composite score dragged down by an empty
/// Student Loans axis — instead, student-loan lessons feed Debt & Credit
/// (and sometimes Income & Paycheck or Big Purchases as a secondary).
///
/// See `docs/ops/numind-score-baseline-2026-XX.md` (Phase 5g snapshot) for
/// the per-axis distribution at curriculum-wide level.
enum SkillAxis: String, Codable, CaseIterable, Equatable {
    case everydayMoneyMath   = "everyday_money_math"
    case cashFlowAndBudgeting = "cash_flow_and_budgeting"
    case incomeAndPaycheck    = "income_and_paycheck"
    case debtAndCredit        = "debt_and_credit"
    case bigPurchases         = "big_purchases"
    case protectionAndBenefits = "protection_and_benefits"
    case investingAndFuture   = "investing_and_future"

    /// User-facing display name (used in radar labels, subtitle copy, evidence labels).
    var displayName: String {
        switch self {
        case .everydayMoneyMath:    return "Everyday Money Math"
        case .cashFlowAndBudgeting: return "Cash Flow & Budgeting"
        case .incomeAndPaycheck:    return "Income & Paycheck"
        case .debtAndCredit:        return "Debt & Credit"
        case .bigPurchases:         return "Big Purchases"
        case .protectionAndBenefits: return "Protection & Benefits"
        case .investingAndFuture:   return "Investing & Future"
        }
    }

    /// Short label for the radar chart spokes (≤14 chars target for legibility).
    var shortName: String {
        switch self {
        case .everydayMoneyMath:    return "Everyday Math"
        case .cashFlowAndBudgeting: return "Cash Flow"
        case .incomeAndPaycheck:    return "Income"
        case .debtAndCredit:        return "Debt & Credit"
        case .bigPurchases:         return "Big Purchases"
        case .protectionAndBenefits: return "Protection"
        case .investingAndFuture:   return "Investing"
        }
    }

    /// Per-axis composite weight (sums to 1.0). Debt is over-weighted because
    /// mistakes there are both common and financially damaging; Protection
    /// and Investing are under-weighted because they're slower-moving and
    /// less universally applicable in day-to-day life.
    var compositeWeight: Double {
        switch self {
        case .debtAndCredit:        return 0.20
        case .everydayMoneyMath:    return 0.15
        case .cashFlowAndBudgeting: return 0.15
        case .incomeAndPaycheck:    return 0.15
        case .bigPurchases:         return 0.15
        case .protectionAndBenefits: return 0.10
        case .investingAndFuture:   return 0.10
        }
    }

    /// Per-axis weighting profile for skill score normalization.
    /// Different content types reward different competency components.
    var weightingProfile: WeightingProfile {
        switch self {
        // Mental-math-heavy: speed matters; scenarios less so
        case .everydayMoneyMath, .cashFlowAndBudgeting, .debtAndCredit:
            return .numericalHeavy
        // Concept-driven: no speed component; retention + scenarios matter
        case .protectionAndBenefits:
            return .conceptHeavy
        // Decision-heavy: scenarios get the biggest single share
        case .incomeAndPaycheck, .bigPurchases, .investingAndFuture:
            return .mixedDecision
        }
    }
}

/// Component-weight templates for axis score calculation.
///
/// Weights are: (accuracy, speed, retention, scenario). They sum to 1.0.
/// When a lesson has no scenario-eligible questions, the scenario component
/// reweights proportionally across the available components (don't penalize
/// users for content that doesn't generate scenarios).
struct WeightingProfile: Equatable {
    let accuracy: Double
    let speed: Double
    let retention: Double
    let scenario: Double

    static let numericalHeavy = WeightingProfile(
        accuracy: 0.55, speed: 0.20, retention: 0.20, scenario: 0.05
    )

    static let conceptHeavy = WeightingProfile(
        accuracy: 0.65, speed: 0.00, retention: 0.25, scenario: 0.10
    )

    static let mixedDecision = WeightingProfile(
        accuracy: 0.45, speed: 0.05, retention: 0.20, scenario: 0.30
    )
}

/// Question-level multipliers applied to a single attempt before per-axis
/// accumulation. All multipliers default to 1.0 (no effect) until enough
/// evidence is gathered to justify the adjustment.
enum QuestionMultiplier {

    /// Difficulty multiplier — harder questions worth more points.
    /// Mirrors the existing `QuestionDifficulty` enum used by `DifficultyScorer`.
    static func difficulty(_ tier: QuestionDifficulty) -> Double {
        switch tier {
        case .easy:   return 1.0
        case .medium: return 1.2
        case .hard:   return 1.5
        }
    }

    /// Review multiplier — questions answered after a calendar gap reward
    /// genuine retention. Gap = days since the most-recent prior attempt on
    /// the same template (regardless of correctness).
    /// - Returns: 1.0 for new/same-day, scaling up to 1.3 for 11+ day gaps.
    static func review(daysSinceLastAttempt: Double) -> Double {
        switch daysSinceLastAttempt {
        case ..<1:    return 1.0  // first attempt or same-day repeat
        case 1..<4:   return 1.1  // 1-3 day gap
        case 4..<11:  return 1.2  // 4-10 day gap
        default:      return 1.3  // 11+ day gap, proves real retention
        }
    }

    /// Speed multiplier — only applies after enough attempts that a
    /// fast-vs-slow signal is meaningful. Don't penalize new users for
    /// taking time to understand new content.
    /// - Parameter attempts: how many prior attempts the user has on this template
    /// - Parameter seconds: how long this attempt took
    /// - Returns: 1.0 for first 3 attempts; thereafter 0.9/1.0/1.1 based on speed
    static func speed(priorAttempts: Int, seconds: Double) -> Double {
        guard priorAttempts >= 3 else { return 1.0 }
        switch seconds {
        case ..<5:   return 1.1   // fast
        case ..<15:  return 1.0   // normal
        default:     return 0.9   // slow
        }
    }
}

/// Evidence labels per axis — communicates score confidence to the user.
/// Thresholds are by distinct-question-count on that axis (any source: pack,
/// lesson quiz, Daily Workout, drill mode).
enum EvidenceLevel: String, Codable, Equatable {
    case untested   // 0-4 questions — score hidden, axis dimmed on radar
    case earlyRead  // 5-14 questions — score shown with "Early Read" label
    case developing // 15-29 questions across ≥2 days
    case reliable   // 30+ questions, ≥3 distinct days, ≥2 scenario questions

    /// User-facing label (no abbreviation; rendered as small text under the axis score).
    var label: String {
        switch self {
        case .untested:   return "Untested"
        case .earlyRead:  return "Early Read"
        case .developing: return "Developing"
        case .reliable:   return "Reliable"
        }
    }

    /// Coverage weight — used in the composite formula's coverage factor.
    /// Untested = 0 (axis not measured). Early Read = half (signal but not strong).
    /// Developing + Reliable = full (axis counts as covered).
    var coverageWeight: Double {
        switch self {
        case .untested:   return 0.0
        case .earlyRead:  return 0.5
        case .developing: return 1.0
        case .reliable:   return 1.0
        }
    }
}
