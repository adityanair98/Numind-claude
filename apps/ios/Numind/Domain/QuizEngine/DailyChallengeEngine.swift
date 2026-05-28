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

    /// Generates today's personalised Daily Workout questions.
    ///
    /// When `focusPack` is set, the first ~3 slots are prioritized toward
    /// the pack's next undone lessons (a "pack-aware" workout). The remaining
    /// slots fall through to the standard SRS-driven selection. The result
    /// is a 6Q workout that advances the user's chosen Life-Event Path while
    /// still surfacing spaced-repetition reviews.
    static func dailyQuestions(
        from repository: ContentRepository,
        progressData: ProgressData? = nil,
        focusPack: Pack? = nil
    ) -> [QuizQuestion] {
        let sessions = progressData?.sessions ?? []
        let count = questionCount(for: progressData)

        var rng = SeededRandomGenerator(seed: dailySeed())

        // Mastered lesson IDs from prior sessions (used both for pack lesson
        // selection AND to skip already-mastered lessons in the pack queue).
        let masteredIds: Set<String> = {
            var ids: Set<String> = []
            for s in sessions where s.totalCount > 0 {
                let acc = Double(s.correctCount) / Double(s.totalCount)
                if acc >= 0.75 { ids.insert(s.lessonId) }
            }
            return ids
        }()

        // Pool needed up-front for both the SRS-overdue check and the
        // remaining-slot selection.
        let pool = repository.allTemplates()
        guard !pool.isEmpty else { return [] }

        // Phase 6a — when the user has a meaningful SRS backlog, pivot to
        // a review-only workout. Otherwise the pack-priority slots would
        // crowd out retention practice.
        let overdueIds = SpacedRepetitionEngine.overdueTemplateIds(in: sessions, pool: pool)
        let reviewOnlyMode = overdueIds.count >= 5

        // ── Slot 1-2: pack-priority templates ─────────────────────────────
        // Phase 6a — capped at 2 (was 3). When a focus pack is set AND the
        // user isn't behind on SRS, pick templates from the pack's next 2
        // undone lessons (in pack order). Each lesson contributes 1 template.
        var packTemplates: [QuizTemplate] = []
        if let pack = focusPack, !reviewOnlyMode {
            let packLessonIds = pack.lessonIds.filter { !masteredIds.contains($0) }
            let packSlots = min(2, packLessonIds.count, count)
            for lessonId in packLessonIds.prefix(packSlots) {
                let templatesForLesson = repository.templates(for: lessonId)
                if let pick = templatesForLesson.randomElement(using: &rng) {
                    packTemplates.append(pick)
                }
            }
        }

        let pickedPackIds = Set(packTemplates.map(\.id))
        var remaining = pool.filter { !pickedPackIds.contains($0.id) }

        // Date-seeded shuffle for stable, daily-varying tiebreaking.
        for i in stride(from: remaining.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            remaining.swapAt(i, j)
        }

        // Sort by SRS priority descending. Stable sort preserves shuffle order
        // within equal-priority groups (per-day variety for ties).
        let sortedRemaining = remaining.sorted {
            SpacedRepetitionEngine.priorityScore(templateId: $0.id, in: sessions) >
            SpacedRepetitionEngine.priorityScore(templateId: $1.id, in: sessions)
        }

        let remainingSlots = count - packTemplates.count
        let pickedRemaining = Array(sortedRemaining.prefix(max(0, remainingSlots)))

        let combined = packTemplates + pickedRemaining
        return combined.map { QuizEngine.generate(from: $0, seed: rng.next()) }
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
