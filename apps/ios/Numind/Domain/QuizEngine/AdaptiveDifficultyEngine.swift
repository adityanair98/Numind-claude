import Foundation

/// Recommends a target `QuestionDifficulty` for a quiz template based on
/// the user's recent history with that specific template.
///
/// Called by session builders (daily challenge, SRS workout) to pass a
/// `targetDifficulty` to `QuizEngine.generate`, so questions adapt to
/// what each user can handle — not a static per-template tier.
///
/// Decision logic (per template, last `windowSize` results):
///   ≥ 80% accurate + avg speed < fastThreshold → Hard
///   ≥ 80% accurate                             → Medium
///   ≥ 50% accurate                             → Medium
///   < 50% accurate                             → Easy
///   Never seen                                 → Easy (start accessible)
enum AdaptiveDifficultyEngine {

    // MARK: - Configuration

    /// How many recent results to examine per template.
    private static let windowSize = 10

    /// Seconds threshold below which answers are considered fluent (fast).
    private static let fastThreshold: Double = 8

    // MARK: - Public API

    /// Returns the recommended target difficulty for `templateId` given all
    /// recorded sessions. Pass this as `targetDifficulty` to `QuizEngine.generate`.
    static func targetDifficulty(for templateId: String, in sessions: [SessionRecord]) -> QuestionDifficulty {
        let recent = recentResults(for: templateId, in: sessions)

        // First encounter — start at easy to build confidence.
        guard !recent.isEmpty else { return .easy }

        let accuracy = Double(recent.filter(\.isCorrect).count) / Double(recent.count)
        let avgSpeed = recent.map(\.timeSpentSeconds).reduce(0, +) / Double(recent.count)

        switch accuracy {
        case 0.8...:
            // High accuracy — escalate if also fast, else stay at medium.
            return avgSpeed < fastThreshold ? .hard : .medium
        case 0.5..<0.8:
            return .medium
        default:
            // Struggling — back off to easy.
            return .easy
        }
    }

    // MARK: - Helpers

    private static func recentResults(
        for templateId: String,
        in sessions: [SessionRecord]
    ) -> [QuestionResult] {
        // Walk sessions newest-first, collect results for this template up to windowSize.
        let sortedSessions = sessions.sorted { $0.date > $1.date }
        var results: [QuestionResult] = []
        for session in sortedSessions {
            for result in session.questionResults where result.templateId == templateId {
                results.append(result)
                if results.count == windowSize { return results }
            }
        }
        return results
    }
}
