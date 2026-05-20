import Foundation

/// All data collected during the onboarding funnel.
/// Persisted inside `ProgressData.onboardingSignals`.
struct OnboardingSignals: Codable, Equatable {

    // MARK: - Phase 2: Data Collection

    var confidenceLevel: ConfidenceLevel?
    var motivations: Set<Motivation> = []
    var aspiration: Aspiration?
    var topicInterests: Set<String> = []          // module IDs
    var dailyMinutes: Int?                         // 5, 10, 15, 20
    var socialMediaMinutes: Int?                   // from screen 4
    var adhdStatus: ADHDStatus?
    var ageRange: AgeRange?

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

    /// Daily challenge question count derived from time commitment.
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

enum ConfidenceLevel: String, Codable, CaseIterable, Equatable {
    case struggle
    case getBy
    case decent
    case quick
}

enum Motivation: String, Codable, CaseIterable, Equatable, Hashable {
    case financialDecisions
    case buildConfidence
    case careerGrowth
    case staySharp
    case supportEducation
    case appearSharper
    case boostFocus
}

enum Aspiration: String, Codable, CaseIterable, Equatable {
    case tipInstantly
    case confidentWithMoney
    case spotGoodDeals
    case fasterThanPhone
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
/// NEVER create `SessionRecord`s or affect Numind Score.
struct DiagnosticResult: Codable, Equatable {
    let topicArea: String    // module ID
    let templateId: String
    let isCorrect: Bool
    let difficulty: Int      // 1, 2, or 3
}
