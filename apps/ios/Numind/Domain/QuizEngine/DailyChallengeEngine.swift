import Foundation

/// Workout sizing + the Bonus Round.
///
/// Phase 10: the Daily Workout's composition lives in `DailyWorkoutEngine`
/// (the 3-segment warm-up / focus / decision plan). This engine retains the
/// per-user question-count derivation, the date seed, and the random-seeded
/// Bonus Round.
struct DailyChallengeEngine {

    /// Default question count. Overridden by onboarding time commitment.
    static let defaultQuestionCount = 7

    /// Effective question count, reading from onboarding signals if available.
    static func questionCount(for progressData: ProgressData?) -> Int {
        progressData?.onboardingSignals?.dailyChallengeCount ?? defaultQuestionCount
    }

    // MARK: - Public API
    //
    // Phase 10: daily composition moved to `DailyWorkoutEngine.plan` (the
    // 3-segment workout). This engine keeps the question-count derivation,
    // the date seed, and the Bonus Round.

    // MARK: - Bonus Round

    /// Generates a bonus round with a random seed — always different from the daily set.
    static func bonusRoundQuestions(
        from repository: ContentRepository,
        progressData: ProgressData? = nil
    ) -> [QuizQuestion] {
        // Same open pool as the daily challenge.
        let pool = repository.allTemplates()
        guard !pool.isEmpty else { return [] }

        var rng = SeededRandomGenerator(seed: UInt64.random(in: 0 ... .max))
        var shuffled = pool
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }
        let picked = Array(shuffled.prefix(defaultQuestionCount))
        return picked.map { QuizEngine.generate(from: $0, seed: rng.next()) }
    }

    // MARK: - Private

    /// Seed from today's date in YYYYMMDD form — resets automatically at midnight.
    static func dailySeed() -> UInt64 {
        let cal = Calendar.current
        let now = Date()
        let y = cal.component(.year,  from: now)
        let m = cal.component(.month, from: now)
        let d = cal.component(.day,   from: now)
        return UInt64(y * 10_000 + m * 100 + d)
    }
}
