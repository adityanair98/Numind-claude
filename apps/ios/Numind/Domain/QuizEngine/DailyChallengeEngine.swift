import Foundation

/// Selects the daily 10 quiz questions from mastered (or all) templates.
///
/// The selection is seeded with the current calendar date (YYYYMMDD), so:
///   - Every user sees the same question types on the same day.
///   - The set resets automatically at midnight.
///   - The exact numbers within each question are also fixed for the day.
///
/// Template pool priority:
///   - If the user has mastered at least one lesson, questions are drawn only from
///     mastered-lesson templates (concepts they've actually learned).
///   - If no lessons have been mastered yet (new user), falls back to all templates
///     so the daily challenge always has something to show.
struct DailyChallengeEngine {

    static let questionCount = 10

    // MARK: - Public API

    /// Generates today's daily challenge questions.
    ///
    /// - Parameters:
    ///   - repository: Content source (defaults to local JSON).
    ///   - progressData: If provided, filters to mastered-lesson templates only.
    ///                   Pass nil for backward-compat (uses all templates).
    static func dailyQuestions(
        from repository: ContentRepository,
        progressData: ProgressData? = nil
    ) -> [QuizQuestion] {
        // Determine template pool: mastered first, fall back to all.
        let pool: [QuizTemplate]
        if let progressData {
            let mastered = MasteredTemplatePool.templates(from: progressData, repository: repository)
            pool = mastered.isEmpty ? repository.allTemplates() : mastered
        } else {
            pool = repository.allTemplates()
        }

        guard !pool.isEmpty else { return [] }

        var rng = SeededRandomGenerator(seed: dailySeed())

        // Fisher-Yates shuffle with the daily seed so every user gets the same order.
        var shuffled = pool
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }
        let picked = Array(shuffled.prefix(questionCount))

        // Each question also uses a deterministic sub-seed so the variable
        // values (bill amounts, prices, etc.) stay fixed throughout the day.
        return picked.map { template in
            QuizEngine.generate(from: template, seed: rng.next())
        }
    }

    // MARK: - Private

    /// Produces a UInt64 seed from today's date in the form YYYYMMDD.
    static func dailySeed() -> UInt64 {
        let cal = Calendar.current
        let now = Date()
        let y = cal.component(.year,  from: now)
        let m = cal.component(.month, from: now)
        let d = cal.component(.day,   from: now)
        return UInt64(y * 10_000 + m * 100 + d)
    }
}
