import Foundation

/// Selects the daily quiz questions using spaced-repetition priority.
///
/// ## Selection logic
/// 1. Pool = ALL templates. Users already know the underlying math — lessons teach
///    shortcuts that make them faster, not prerequisites for answering. The daily
///    challenge surfaces weaknesses that motivate lesson discovery.
/// 2. Each template is scored by `SpacedRepetitionEngine` — overdue questions
///    (score > 0) surface first, never-seen templates get ∞ priority, then
///    questions closest to their review date.
/// 3. Equal-score ties (e.g. all templates unseen on day 1) are broken by a
///    date-seeded shuffle, giving day-over-day variety without losing stability.
/// 4. The top `questionCount` templates are taken and question variable values are
///    generated with a deterministic per-day seed so numbers stay consistent
///    if the user pauses and resumes.
///
/// The result is personal (driven by each user's SRS history), stable within a
/// day, and naturally transitions from exposure → review as history builds.
struct DailyChallengeEngine {

    /// Default question count. Overridden by onboarding time commitment.
    static let defaultQuestionCount = 7

    /// Effective question count, reading from onboarding signals if available.
    static func questionCount(for progressData: ProgressData?) -> Int {
        progressData?.onboardingSignals?.dailyChallengeCount ?? defaultQuestionCount
    }

    // MARK: - Public API

    /// Generates today's personalised daily challenge questions.
    static func dailyQuestions(
        from repository: ContentRepository,
        progressData: ProgressData? = nil
    ) -> [QuizQuestion] {
        let sessions = progressData?.sessions ?? []
        let count = questionCount(for: progressData)

        // Pool = all templates. SRS handles ordering — never-seen templates
        // get ∞ priority and surface first, naturally exposing all modules to
        // new users before transitioning to reinforcement mode.
        let pool = repository.allTemplates()
        guard !pool.isEmpty else { return [] }

        // Date-seeded shuffle for stable, daily-varying tiebreaking.
        var rng = SeededRandomGenerator(seed: dailySeed())
        var shuffled = pool
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }

        // Sort by SRS priority descending. Swift's sort is stable, so ties keep
        // their shuffled order — giving per-day variety for equal-priority items.
        let sorted = shuffled.sorted {
            SpacedRepetitionEngine.priorityScore(templateId: $0.id, in: sessions) >
            SpacedRepetitionEngine.priorityScore(templateId: $1.id, in: sessions)
        }

        let picked = Array(sorted.prefix(count))

        // Deterministic variable values for the day (rng has advanced past the shuffle).
        return picked.map { QuizEngine.generate(from: $0, seed: rng.next()) }
    }

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
