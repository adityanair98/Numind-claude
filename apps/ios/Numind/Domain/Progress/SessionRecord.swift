import Foundation

/// Per-question result captured during a quiz session.
/// Used by Review Mistakes (M44), Spaced Repetition (M45), and Speed Bonus XP (M46).
struct QuestionResult: Codable {
    let templateId: String
    let isCorrect: Bool
    /// Seconds from question appearing to the user tapping "Check answer".
    let timeSpentSeconds: Double
}

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let lessonId: String
    let moduleId: String
    let date: Date
    let correctCount: Int
    let totalCount: Int
    /// Per-question breakdown. Defaults to empty for backward compat (pre-M43 data).
    var questionResults: [QuestionResult] = []
    /// Speed bonus XP earned this session. Defaults to 0 for backward compat.
    var bonusXP: Int = 0
}
