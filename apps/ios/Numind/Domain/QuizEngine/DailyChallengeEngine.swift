import Foundation

/// Selects the daily 5 quiz questions from all available templates.
///
/// The selection is seeded with the current calendar date (YYYYMMDD), so:
///   - Every user sees the same questions on the same day.
///   - The set resets automatically at midnight.
///   - The exact numbers within each question are also fixed for the day.
struct DailyChallengeEngine {

    static let questionCount = 5

    // MARK: - Public API

    static func dailyQuestions(from repository: ContentRepository) -> [QuizQuestion] {
        let allTemplates = repository.allTemplates()
        guard !allTemplates.isEmpty else { return [] }

        var rng = SeededRandomGenerator(seed: dailySeed())

        // Shuffle all templates with the daily seed and take the first N.
        // With 47+ templates spanning 6 modules this naturally gives variety.
        var shuffled = allTemplates
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
