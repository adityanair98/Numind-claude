import Foundation

/// All data collected during the onboarding funnel (v2 — decision-first).
/// Persisted inside `ProgressData.onboardingSignals`.
///
/// v2 (Phase 11): the funnel sells decision-readiness, not mental math.
/// `topicInterests` (module IDs) became `focusPackId` + `secondaryPackIds`
/// (Life-Event Packs), `aspiration` was absorbed into the moment picker
/// (the moment IS the aspiration), and `socialMediaMinutes` became
/// `feltMoments` (the insecurity-mirror checklist).
struct OnboardingSignals: Codable, Equatable {

    // MARK: - Phase 1–2: Problem framing + personalization

    /// "Which of these have happened to you?" — the insecurity mirror.
    var feltMoments: Set<FeltMoment> = []
    var confidenceLevel: ConfidenceLevel?
    var motivations: Set<Motivation> = []

    /// The life moment the user picked first — becomes the focus pack.
    var focusPackId: String?
    /// Up to 2 additional moments (pack IDs).
    var secondaryPackIds: Set<String> = []

    var dailyMinutes: Int?                         // 5, 10, 15, 20
    var adhdStatus: ADHDStatus?
    var ageRange: AgeRange?

    /// Pay cadence + a known payday — drives the payday moment + reminders
    /// (Phase 12). Optional for decode-compat.
    var paycheck: PaycheckSchedule?
    /// Month (1–12) the user's lease renews. Optional for decode-compat.
    var leaseRenewalMonth: Int?

    // MARK: - Phase 5: Priming

    var streakGoal: Int?                           // 3, 7, 14
    var trialReminderDays: Int?                    // 1, 2, or nil

    // MARK: - Phase 3: Diagnostic

    var diagnosticResults: [DiagnosticResult] = []
    var diagnosticDate: Date?

    // MARK: - Computed Calibration (set by DiagnosticCalibrator)

    var startingDifficulties: [String: StartingDifficulty] = [:]
    var recommendationPriority: [String] = []

    // MARK: - Derived

    /// All selected pack IDs, focus first.
    var selectedPackIds: [String] {
        var ids: [String] = []
        if let focus = focusPackId { ids.append(focus) }
        ids.append(contentsOf: secondaryPackIds.sorted().filter { $0 != focusPackId })
        return ids
    }

    /// Daily ring target derived from time commitment.
    var dailyChallengeCount: Int {
        switch dailyMinutes {
        case 5:  return 5
        case 10: return 8
        case 15: return 10
        case 20: return 12
        default: return 8
        }
    }
}

// MARK: - Supporting Enums

/// "Which of these have happened to you?" — screen 4 multi-select.
enum FeltMoment: String, Codable, CaseIterable, Equatable, Hashable {
    case acceptedWithoutNegotiating
    case guessedHealthPlan
    case carriedCardBalance
    case almostScammed
    case signedLeaseBlind
    case noneYet

    var displayText: String {
        switch self {
        case .acceptedWithoutNegotiating: return "Accepted a job offer without negotiating"
        case .guessedHealthPlan:          return "Picked a health plan by guessing"
        case .carriedCardBalance:         return "Carried a card balance longer than planned"
        case .almostScammed:              return "Got a scam text that almost got me"
        case .signedLeaseBlind:           return "Signed a lease without checking the numbers"
        case .noneYet:                    return "None of these (yet)"
        }
    }
}

enum ConfidenceLevel: String, Codable, CaseIterable, Equatable {
    case struggle
    case getBy
    case decent
    case quick
}

/// v2 motivations — money-decision outcomes, not math skills.
enum Motivation: String, Codable, CaseIterable, Equatable, Hashable {
    case stopLeavingMoney      // at work: negotiation, benefits, match
    case stopGettingTaken      // scams, fees, dealer tactics
    case decideWithConfidence  // anxiety → confidence
    case understandPaycheck    // paycheck, benefits, taxes
    case getAheadOfDebt
    case growMoney
    case staySharp             // maintenance identity
}

enum AgeRange: String, Codable, CaseIterable, Equatable {
    case age13to24
    case age25to34
    case age35to44
    case age45to54
    case age55to64
    case age65plus

    var displayText: String {
        switch self {
        case .age13to24: return "13–24"
        case .age25to34: return "25–34"
        case .age35to44: return "35–44"
        case .age45to54: return "45–54"
        case .age55to64: return "55–64"
        case .age65plus: return "65+"
        }
    }
}

enum ADHDStatus: String, Codable, CaseIterable, Equatable {
    case yes
    case no
    case thinkSo
    case preferNotToSay
    case unsure

    var displayText: String {
        switch self {
        case .yes:            return "Yes"
        case .no:             return "No"
        case .thinkSo:        return "I think so"
        case .preferNotToSay: return "Prefer not to say"
        case .unsure:         return "Unsure"
        }
    }

    /// Whether this status should trigger the supportive reveal card.
    var showsReveal: Bool {
        switch self {
        case .yes, .thinkSo, .unsure: return true
        case .no, .preferNotToSay:    return false
        }
    }
}

enum StartingDifficulty: String, Codable, Equatable {
    case beginner      // d1, standard unlock pace
    case foundation    // d1, faster d2 unlock
    case intermediate  // start at d2
}

/// A single question result from the onboarding diagnostic quiz.
/// Intentionally separate from `QuestionResult` — diagnostic results
/// NEVER create `SessionRecord`s, so Readiness stays honest (placement
/// language only; nothing is "mastered" by the diagnostic).
struct DiagnosticResult: Codable, Equatable {
    let topicArea: String    // module ID
    let templateId: String
    let isCorrect: Bool
    let difficulty: Int      // 1, 2, or 3
    /// Source lesson — drives the Money Map per-skill placement.
    /// Optional for decode-compat with pre-v2 saved signals.
    var lessonId: String?
}
