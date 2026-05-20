import Foundation

/// Computes the Numind Score — a 0–100 composite that reflects how well a
/// user can handle questions in each module and overall.
///
/// ## Per-module score (0–100)
///   Accuracy   (0–60): recent correct rate × 60  — primary driver
///   Difficulty (0–25): weighted correct answers by adaptive difficulty tier
///   Speed      (0–15): avg time per question → 15 / 10 / 5 / 0  — bonus, not penalty
///
/// ## Overall score
///   Unweighted average across all modules (unattempted modules contribute 0).
///
/// Speed is deliberately down-weighted so anxious users who are accurate but
/// slow still see a score that reflects their competence.
enum NumindScoreEngine {

    // MARK: - Configuration

    static let maxScore: Int = 100

    private static let accuracyMax:   Int = 60
    private static let difficultyMax: Int = 25
    private static let speedMax:      Int = 15

    /// Number of most-recent sessions to examine per module.
    private static let sessionWindow: Int = 10

    // Speed thresholds (seconds per question)
    private static let fastThreshold: Double = 5
    private static let goodThreshold: Double = 10
    private static let okThreshold:   Double = 15

    // MARK: - Public API

    /// Returns a 0–100 score for a single module based on recent sessions.
    static func score(for moduleId: String, sessions: [SessionRecord]) -> Int {
        let recent = recentSessions(moduleId: moduleId, in: sessions)
        guard !recent.isEmpty else { return 0 }

        let acc  = accuracyScore(sessions: recent)
        let spd  = speedScore(sessions: recent)
        let diff = difficultyScore(sessions: recent, allSessions: sessions)

        return min(maxScore, acc + spd + diff)
    }

    /// Returns a 0–100 overall Numind Score — the unweighted average across
    /// all module IDs. Modules with no history contribute 0.
    static func overallScore(moduleIds: [String], sessions: [SessionRecord]) -> Int {
        guard !moduleIds.isEmpty else { return 0 }
        let total = moduleIds.reduce(0) { $0 + score(for: $1, sessions: sessions) }
        return total / moduleIds.count
    }

    // MARK: - Component: Accuracy (0–60)

    private static func accuracyScore(sessions: [SessionRecord]) -> Int {
        let correct   = sessions.reduce(0) { $0 + $1.correctCount }
        let total     = sessions.reduce(0) { $0 + $1.totalCount }
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * Double(accuracyMax))
    }

    // MARK: - Component: Speed (0–15)

    private static func speedScore(sessions: [SessionRecord]) -> Int {
        let results = sessions.flatMap(\.questionResults)

        // Use per-question timing when available; fall back to a neutral half-score
        // for legacy sessions that predate per-question recording.
        guard !results.isEmpty else { return speedMax / 2 }

        let avgTime = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
        switch avgTime {
        case ..<fastThreshold: return 15   // bolt-fast
        case ..<goodThreshold: return 10   // good
        case ..<okThreshold:   return 5    // ok
        default:               return 0
        }
    }

    // MARK: - Component: Difficulty (0–25)

    private static func difficultyScore(
        sessions: [SessionRecord],
        allSessions: [SessionRecord]
    ) -> Int {
        let results = sessions.flatMap(\.questionResults)
        guard !results.isEmpty else { return 0 }

        var weightedCorrect: Double = 0
        var weightedTotal:   Double = 0

        for result in results {
            // Prefer the stored difficulty (recorded at generation time).
            // Fall back to the adaptive engine's estimate for legacy results.
            let tier: QuestionDifficulty = result.difficulty
                ?? AdaptiveDifficultyEngine.targetDifficulty(
                    for: result.templateId, in: allSessions
                )
            let weight = Double(tier.rawValue)   // easy=1, medium=2, hard=3
            weightedTotal   += weight
            if result.isCorrect { weightedCorrect += weight }
        }

        guard weightedTotal > 0 else { return 0 }
        return Int((weightedCorrect / weightedTotal) * Double(difficultyMax))
    }

    // MARK: - Helpers

    private static func recentSessions(
        moduleId: String,
        in sessions: [SessionRecord]
    ) -> [SessionRecord] {
        sessions
            .filter { $0.moduleId == moduleId && !$0.isReviewSession }
            .sorted { $0.date > $1.date }
            .prefix(sessionWindow)
            .map { $0 }
    }
}
