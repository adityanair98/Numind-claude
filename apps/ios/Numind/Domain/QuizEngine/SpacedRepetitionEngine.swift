import Foundation

/// Lightweight spaced-repetition engine that prioritises quiz templates
/// based on a user's answer history stored in `SessionRecord.questionResults`.
///
/// No extra persistence is required — all computation runs over the existing
/// `ProgressData.sessions` array that is already saved to UserDefaults.
///
/// ## Scoring
/// Each template gets a **priority score** (higher = more urgently due):
/// - Never seen                       → `+∞`  (always surfaces first)
/// - Overdue (days since > interval)  → positive
/// - Not yet due                      → negative
///
/// The review interval is determined by recent accuracy + speed:
/// | Accuracy  | Fast-correct (< 8 s) | Interval |
/// |-----------|----------------------|----------|
/// | 100 % × 3+ fast | any            | 7 days   |
/// | 100 %     | < 3 fast             | 4 days   |
/// | ≥ 80 %    | any                  | 2 days   |
/// | ≥ 60 %    | any                  | 1 day    |
/// | < 60 %    | any                  | 0.5 days |
enum SpacedRepetitionEngine {

    // MARK: - Template sorting

    /// Returns templates for a lesson sorted so the most-due / most-struggled
    /// templates come first. Falls back to default order if no history exists.
    static func sortedTemplates(
        for lessonId: String,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> [QuizTemplate] {
        let templates = repository.templates(for: lessonId)
        guard !sessions.isEmpty else { return templates }
        return templates.sorted { a, b in
            priorityScore(templateId: a.id, in: sessions) >
            priorityScore(templateId: b.id, in: sessions)
        }
    }

    // MARK: - Priority scoring

    /// Higher score = more urgently needs review.
    /// `+∞` = never attempted. Positive = overdue. Negative = not yet due.
    static func priorityScore(templateId: String, in sessions: [SessionRecord]) -> Double {
        // Flatten all attempts for this template across every session, oldest first.
        let attempts = sessions
            .flatMap { session -> [(date: Date, isCorrect: Bool, seconds: Double)] in
                session.questionResults
                    .filter { $0.templateId == templateId }
                    .map { (session.date, $0.isCorrect, $0.timeSpentSeconds) }
            }
            .sorted { $0.date < $1.date }

        guard let last = attempts.last else { return .infinity }

        let daysSinceLast = Date().timeIntervalSince(last.date) / 86_400

        // Evaluate the most recent 5 attempts for recency-weighted accuracy.
        let recent = Array(attempts.suffix(5))
        let recentCorrect = recent.filter(\.isCorrect).count
        let accuracy = Double(recentCorrect) / Double(recent.count)
        let fastMastery = recent.filter { $0.isCorrect && $0.seconds < 8 }.count

        // Phase 6a — once a template has 3+ consecutive correct attempts at the
        // top of the ladder, it gets graduated to the long-term tier (30/60 day
        // intervals) so the user isn't drilled on what they've clearly retained.
        let consecutiveCorrect = attempts.reversed().prefix { $0.isCorrect }.count
        let longTermTier = consecutiveCorrect >= 3 && accuracy >= 1.0
            ? longTermInterval(consecutiveCorrect: consecutiveCorrect, totalAttempts: attempts.count)
            : nil

        let interval = longTermTier ?? reviewInterval(accuracy: accuracy, fastMastery: fastMastery)
        return daysSinceLast - interval          // positive = overdue
    }

    /// IDs of templates that are currently overdue (priorityScore > 0).
    /// Used by `DailyChallengeEngine` to gate pack-priority slots — when
    /// the user has a backlog of overdue items, the Daily Workout pivots
    /// to a review-only composition that day (Phase 6a).
    static func overdueTemplateIds(in sessions: [SessionRecord], pool: [QuizTemplate]) -> [String] {
        pool
            .filter { priorityScore(templateId: $0.id, in: sessions) > 0 }
            .map(\.id)
    }

    // MARK: - Due-count badge helper

    /// Number of templates in a lesson that are overdue (score > 0) or unseen.
    /// Returns 0 if the user has no history at all (first-time learners).
    static func dueCount(
        for lessonId: String,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return repository.templates(for: lessonId)
            .filter { priorityScore(templateId: $0.id, in: sessions) > 0 }
            .count
    }

    // MARK: - Private

    private static func reviewInterval(accuracy: Double, fastMastery: Int) -> Double {
        switch accuracy {
        case 1.0 where fastMastery >= 3: return 7    // mastered: weekly review
        case 1.0...:                     return 4    // all correct, slower: 4 days
        case 0.8...:                     return 2    // mostly right: 2 days
        case 0.6...:                     return 1    // more right than wrong: daily
        default:                         return 0.5  // struggling: twice a day
        }
    }

    /// Phase 6a — long-term review ladder. Once a template has 3+
    /// consecutive correct attempts at the standard ladder's top tier,
    /// the user has demonstrably retained it. Graduate to 14/30/60-day
    /// intervals so we're not drilling them on what they already know.
    private static func longTermInterval(consecutiveCorrect: Int, totalAttempts: Int) -> Double {
        switch consecutiveCorrect {
        case 3...4:  return 14
        case 5...7:  return 30
        default:     return 60
        }
    }
}
