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
    /// Per-question breakdown. Defaults to empty for backward compatibility with
    /// sessions recorded before M43 (existing UserDefaults data decodes cleanly).
    var questionResults: [QuestionResult] = []
}
