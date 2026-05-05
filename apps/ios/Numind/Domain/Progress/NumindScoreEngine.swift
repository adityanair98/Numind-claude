import Foundation

/// Computes the Numind Score — a 0–100 composite that reflects how well a
/// user can handle questions in each module and overall.
///
/// ## Per-module score (0–100)
///   Accuracy  (0–50): recent correct rate × 50
///   Speed     (0–30): avg time per question → 30 / 20 / 10 / 0
///   Difficulty (0–20): weighted correct answers by adaptive difficulty tier
///
/// ## Overall score
///   Unweighted average across all modules (unattempted modules contribute 0).
///
/// The difficulty component is an approximation until `QuestionResult` stores
/// the actual difficulty tier that was presented (Step 11). Until then it uses
/// `AdaptiveDifficultyEngine` to infer each template's expected difficulty from
/// the user's history.
enum NumindScoreEngine {

    // MARK: - Configuration

    static let maxScore: Int = 100

    private static let accuracyMax:   Int = 50
    private static let speedMax:      Int = 30
    private static let difficultyMax: Int = 20

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

    // MARK: - Component: Accuracy (0–50)

    private static func accuracyScore(sessions: [SessionRecord]) -> Int {
        let correct   = sessions.reduce(0) { $0 + $1.correctCount }
        let total     = sessions.reduce(0) { $0 + $1.totalCount }
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * Double(accuracyMax))
    }

    // MARK: - Component: Speed (0–30)

    private static func speedScore(sessions: [SessionRecord]) -> Int {
        let results = sessions.flatMap(\.questionResults)

        // Use per-question timing when available; fall back to a neutral half-score
        // for legacy sessions that predate per-question recording.
        guard !results.isEmpty else { return speedMax / 2 }

        let avgTime = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
        switch avgTime {
        case ..<fastThreshold: return speedMax           // ≥ bolt-fast
        case ..<goodThreshold: return speedMax * 2 / 3  // good
        case ..<okThreshold:   return speedMax / 3      // ok
        default:               return 0
        }
    }

    // MARK: - Component: Difficulty (0–20)

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
