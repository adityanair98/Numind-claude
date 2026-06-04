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
    /// Phase 9 composition order:
    /// 1. **Refresh first** — overdue templates from the user's *mastered*
    ///    skills (FreshnessEngine), so retention practice leads the workout.
    /// 2. **Active-pack core** — up to 2 templates from the focus pack's core
    ///    lessons not yet mastered (skipped on a heavy refresh backlog).
    /// 3. **SRS fill** — the remaining slots by spaced-repetition priority.
    ///
    /// Stable within a day (date-seeded) and naturally shifts exposure →
    /// review → refresh as history builds.
    static func dailyQuestions(
        from repository: ContentRepository,
        progressData: ProgressData? = nil,
        focusPack: Pack? = nil
    ) -> [QuizQuestion] {
        let sessions = progressData?.sessions ?? []
        let count = questionCount(for: progressData)
        var rng = SeededRandomGenerator(seed: dailySeed())

        let pool = repository.allTemplates()
        guard !pool.isEmpty else { return [] }
        let byId = Dictionary(pool.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

        // Properly-mastered lessons (Phase 9 rule) — for refresh + pack-skip.
        let masteredLessonIds: Set<String> = {
            guard let data = progressData else { return [] }
            return Set(sessions.map(\.lessonId)).filter { data.hasMasteredLesson($0) }
        }()

        // Build the ordered, de-duplicated template-id list.
        var ordered: [String] = []
        func add(_ id: String) {
            if byId[id] != nil && !ordered.contains(id) { ordered.append(id) }
        }

        // 1. Refresh targets (seen + overdue, from mastered skills).
        let refreshIds = FreshnessEngine.refreshTargets(
            masteredLessonIds: masteredLessonIds, sessions: sessions, repository: repository
        )
        let reviewOnlyMode = refreshIds.count >= 5
        let refreshCap = reviewOnlyMode ? count : max(1, count / 2)
        for id in refreshIds.prefix(refreshCap) { add(id) }

        // 2. Active-pack core lessons not yet mastered (≤2), unless behind on refresh.
        if let pack = focusPack, !reviewOnlyMode {
            let core = pack.coreLessonIds.isEmpty ? pack.lessonIds : pack.coreLessonIds
            let undone = core.filter { !masteredLessonIds.contains($0) }
            var packAdded = 0
            for lessonId in undone where packAdded < 2 {
                if let pick = repository.templates(for: lessonId).randomElement(using: &rng),
                   !ordered.contains(pick.id) {
                    add(pick.id); packAdded += 1
                }
            }
        }

        // 3. SRS-sorted fill for the remaining slots.
        var remaining = pool.filter { !ordered.contains($0.id) }
        for i in stride(from: remaining.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            remaining.swapAt(i, j)
        }
        let sorted = remaining.sorted {
            SpacedRepetitionEngine.priorityScore(templateId: $0.id, in: sessions) >
            SpacedRepetitionEngine.priorityScore(templateId: $1.id, in: sessions)
        }
        for t in sorted where ordered.count < count { add(t.id) }

        return Array(ordered.prefix(count))
            .compactMap { byId[$0] }
            .map { QuizEngine.generate(from: $0, seed: rng.next()) }
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
