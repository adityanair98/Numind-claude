import Foundation

// MARK: - Motivator type

/// The category of mid-session motivator to display.
enum MotivatorType: Equatable {
    case momentum       // "You're on a roll" — triggered by a correct-answer streak
    case coaching       // "Quick reset" — triggered after consecutive wrong answers
    case progress       // "Halfway there" — triggered at the session midpoint
    case nearFinish     // "Almost done" — triggered with 2 questions remaining
}

// MARK: - Full-screen checkpoint

/// All the data needed to render a mid-session motivator interstitial.
///
/// Flat struct with optional fields per type. This is simpler than an enum with
/// associated values for SwiftUI rendering and `Equatable` conformance.
struct MotivatorCheckpoint: Equatable, Identifiable {
    let id = UUID()
    let type: MotivatorType

    // ── Momentum ──
    var streak: Int = 0
    var avgTimeLastN: Double? = nil
    var paceImproving: Bool = false

    // ── Coaching ──
    var tipTitle: String = ""
    var tipBody: String = ""
    var example: String? = nil

    // ── Progress / shared stats ──
    var completed: Int = 0
    var total: Int = 0
    var accuracy: Double = 0
    var avgTime: Double? = nil

    // ── Near Finish ──
    var dailyStreak: Int = 0

    // ── Resolved copy ──
    var headline: String = ""
    var subtitle: String = ""
    var bodyText: String = ""
    var ctaLabel: String = "Keep going"
    var secondaryLabel: String? = nil

    // Equatable — ignore UUID for comparison
    static func == (lhs: MotivatorCheckpoint, rhs: MotivatorCheckpoint) -> Bool {
        lhs.type == rhs.type
            && lhs.streak == rhs.streak
            && lhs.completed == rhs.completed
            && lhs.total == rhs.total
    }
}

// MARK: - Inline encouragement (non-blocking overlay)

/// Lightweight data for the small overlay shown on the feedback screen
/// when the user demonstrates good pattern recognition.
struct InlineEncouragement: Equatable, Identifiable {
    let id = UUID()
    let headline: String
    let subtitle: String

    static func == (lhs: InlineEncouragement, rhs: InlineEncouragement) -> Bool {
        lhs.headline == rhs.headline && lhs.subtitle == rhs.subtitle
    }
}
