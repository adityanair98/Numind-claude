import Foundation

/// A 20-second in-session teach moment: the lesson's concept + shortcut shown
/// right before that lesson's first practice rep of the day. New material
/// enters the Daily Workout through exactly this door (one bite per day).
struct TeachCard: Equatable, Identifiable {
    let id: String          // lessonId
    let lessonTitle: String
    let concept: String
    let shortcut: String
    let example: String?
}

/// The composed Daily Workout: ~5 minutes, three named segments.
///
/// - **Warm-up** — 2–3 quick reps from MASTERED skills (everyday-math biased,
///   SRS-picked, so the fun *is* the retention practice).
/// - **Focus** — 3–4 items advancing the focus pack's current gate; when new
///   material enters, a `TeachCard` precedes its first rep.
/// - **Decision** — exactly one "what would you do" application item.
///
/// The workout is state-driven: the same one button composes a learning day,
/// a consolidating day (whichever Readiness gate is failing), or a pure
/// maintenance day — the user never picks a mode.
struct DailyWorkoutPlan {
    enum Mode: Equatable {
        case learning
        case consolidating(ReadinessEngine.Gate)
        case maintenance
        case reviewOnly
        case noFocus
    }

    enum SegmentKind: String {
        case warmup = "Warm-up"
        case focus = "Focus"
        case decision = "Decision"
    }

    struct Segment {
        let kind: SegmentKind
        let questions: [QuizQuestion]
    }

    let mode: Mode
    let segments: [Segment]
    /// Present only when new material enters (the focus lesson was never
    /// attempted). At most one per day.
    let teachCard: TeachCard?

    /// Flattened question list, segment order preserved.
    var questions: [QuizQuestion] { segments.flatMap(\.questions) }

    /// Per-question segment label, aligned with `questions`.
    var segmentLabels: [String] {
        segments.flatMap { seg in seg.questions.map { _ in seg.kind.rawValue } }
    }

    /// Index in `questions` where the teach card shows (the focus segment's
    /// first question), or nil when there's no card today.
    var teachCardIndex: Int? {
        guard teachCard != nil,
              let focusIdx = segments.firstIndex(where: { $0.kind == .focus })
        else { return nil }
        return segments[..<focusIdx].reduce(0) { $0 + $1.questions.count }
    }
}

/// Phase 10 — composes the 3-segment Daily Workout. Replaces
/// `DailyChallengeEngine.dailyQuestions` (which kept `bonusRoundQuestions`,
/// `questionCount`, and the seed helpers).
///
/// Deterministic within a day: all selection randomness and question
/// generation flow from one date-seeded RNG, so pausing and resuming
/// rebuilds the identical workout.
enum DailyWorkoutEngine {

    static func plan(
        from repository: ContentRepository,
        progressData: ProgressData? = nil,
        focusPack: Pack? = nil,
        date: Date = Date()
    ) -> DailyWorkoutPlan {
        let sessions = progressData?.sessions ?? []
        let total = DailyChallengeEngine.questionCount(for: progressData)
        var rng = SeededRandomGenerator(seed: seed(for: date))

        let pool = repository.allTemplates()
        guard !pool.isEmpty else {
            return DailyWorkoutPlan(mode: .noFocus, segments: [], teachCard: nil)
        }
        let byId = Dictionary(pool.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

        let masteredLessonIds: Set<String> = {
            guard let data = progressData else { return [] }
            return Set(sessions.map(\.lessonId)).filter { data.hasMasteredLesson($0) }
        }()

        func priority(_ id: String) -> Double {
            SpacedRepetitionEngine.priorityScore(templateId: id, in: sessions)
        }
        func seededShuffle(_ templates: [QuizTemplate]) -> [QuizTemplate] {
            var arr = templates
            for i in stride(from: arr.count - 1, through: 1, by: -1) {
                let j = Int(rng.next() % UInt64(i + 1))
                arr.swapAt(i, j)
            }
            return arr
        }
        func generate(_ ids: [String]) -> [QuizQuestion] {
            ids.compactMap { byId[$0] }.map { QuizEngine.generate(from: $0, seed: rng.next()) }
        }

        // ── Review-only day: a heavy refresh backlog takes the whole workout
        // (Phase 6a rule, preserved). One application item among the targets
        // is hoisted into the decision slot when present.
        let refreshIds = FreshnessEngine.refreshTargets(
            masteredLessonIds: masteredLessonIds, sessions: sessions, repository: repository
        )
        if refreshIds.count >= 5 {
            var ids = Array(refreshIds.prefix(total)).filter { byId[$0] != nil }
            var segments: [DailyWorkoutPlan.Segment] = []
            if let appId = ids.first(where: { byId[$0]?.isApplicationItem == true }) {
                ids.removeAll { $0 == appId }
                segments.append(.init(kind: .focus, questions: generate(ids)))
                segments.append(.init(kind: .decision, questions: generate([appId])))
            } else {
                segments.append(.init(kind: .focus, questions: generate(ids)))
            }
            return DailyWorkoutPlan(mode: .reviewOnly, segments: segments, teachCard: nil)
        }

        // ── Mode resolution from the focus pack's Readiness state.
        let mode: DailyWorkoutPlan.Mode
        if let pack = focusPack {
            if let data = progressData {
                switch ReadinessEngine.state(for: pack, data: data, repository: repository) {
                case .notStarted, .learning:    mode = .learning
                case .almostReady(let g, _):    mode = .consolidating(g)
                case .ready, .sharp:            mode = .maintenance
                }
            } else {
                mode = .learning
            }
        } else {
            mode = .noFocus
        }

        var used = Set<String>()

        // ── Warm-up: quick reps from mastered skills (everyday-math biased,
        // easy templates, SRS-ranked). Day-1 fallback: easy templates from
        // `isCore` lessons. Slots fold into focus when the pool is empty.
        let warmupWanted = total <= 5 ? 2 : 3
        let warmupIds = warmupPicks(
            count: warmupWanted, masteredLessonIds: masteredLessonIds,
            repository: repository, priority: priority, shuffle: seededShuffle,
            excluding: used
        )
        used.formUnion(warmupIds)

        // ── Decision: reserve the application item before focus fills slots.
        let decisionId = decisionPick(
            focusPack: focusPack, pool: pool, repository: repository,
            priority: priority, excluding: used
        )
        if let d = decisionId { used.insert(d) }

        // ── Focus: advance the failing gate.
        let focusCount = max(0, total - warmupIds.count - (decisionId == nil ? 0 : 1))
        let (focusIds, teachCard) = focusPicks(
            mode: mode, count: focusCount, pack: focusPack, data: progressData,
            repository: repository, pool: pool,
            priority: priority, shuffle: seededShuffle, excluding: used
        )
        used.formUnion(focusIds)

        // ── Assemble in display order (generation order = display order so
        // the per-question seeds are stable).
        var segments: [DailyWorkoutPlan.Segment] = []
        if !warmupIds.isEmpty { segments.append(.init(kind: .warmup, questions: generate(warmupIds))) }
        if !focusIds.isEmpty { segments.append(.init(kind: .focus, questions: generate(focusIds))) }
        if let d = decisionId { segments.append(.init(kind: .decision, questions: generate([d]))) }

        return DailyWorkoutPlan(mode: mode, segments: segments, teachCard: teachCard)
    }

    // MARK: - Segment pickers

    private static func warmupPicks(
        count: Int,
        masteredLessonIds: Set<String>,
        repository: ContentRepository,
        priority: (String) -> Double,
        shuffle: ([QuizTemplate]) -> [QuizTemplate],
        excluding used: Set<String>
    ) -> [String] {
        guard count > 0 else { return [] }

        // Mastered-skill quick reps: easy first, medium acceptable, no hards.
        var pool = masteredLessonIds
            .flatMap { repository.templates(for: $0) }
            .filter { $0.difficulty <= 2 && !used.contains($0.id) }

        // Day-1 fallback: easy templates from core lessons.
        if pool.isEmpty {
            pool = repository.allTemplates().filter { t in
                t.difficulty == 1 && !used.contains(t.id)
                    && repository.lesson(forTemplateId: t.id)?.isCore == true
            }
        }
        guard !pool.isEmpty else { return [] }

        func isEMM(_ t: QuizTemplate) -> Bool {
            repository.lesson(forTemplateId: t.id)?.primarySkill == .everydayMoneyMath
        }

        // Seeded shuffle for tie-breaks, then: easy before medium,
        // everyday-math first, most-overdue first.
        let ranked = shuffle(pool).sorted { a, b in
            if a.difficulty != b.difficulty { return a.difficulty < b.difficulty }
            let emmA = isEMM(a), emmB = isEMM(b)
            if emmA != emmB { return emmA }
            return priority(a.id) > priority(b.id)
        }

        var picks: [String] = []
        for t in ranked where picks.count < count {
            if !picks.contains(t.id) { picks.append(t.id) }
        }
        return picks
    }

    private static func decisionPick(
        focusPack: Pack?,
        pool: [QuizTemplate],
        repository: ContentRepository,
        priority: (String) -> Double,
        excluding used: Set<String>
    ) -> String? {
        func candidates(in lessonIds: [String]) -> [QuizTemplate] {
            lessonIds.flatMap { repository.templates(for: $0) }
                .filter { $0.isApplicationItem && !used.contains($0.id) }
        }
        // Tiers: focus-pack core → focus-pack electives → anywhere.
        var tiers: [[QuizTemplate]] = []
        if let pack = focusPack {
            tiers.append(candidates(in: ReadinessEngine.coreLessons(for: pack)))
            tiers.append(candidates(in: pack.lessonIds))
        }
        tiers.append(pool.filter { $0.isApplicationItem && !used.contains($0.id) })

        for tier in tiers where !tier.isEmpty {
            // Most overdue / never-seen first — the decision rep that's due.
            return tier.max { priority($0.id) < priority($1.id) }?.id
        }
        return nil
    }

    private static func focusPicks(
        mode: DailyWorkoutPlan.Mode,
        count: Int,
        pack: Pack?,
        data: ProgressData?,
        repository: ContentRepository,
        pool: [QuizTemplate],
        priority: (String) -> Double,
        shuffle: ([QuizTemplate]) -> [QuizTemplate],
        excluding used: Set<String>
    ) -> (ids: [String], teach: TeachCard?) {
        guard count > 0 else { return ([], nil) }
        var picks: [String] = []
        var teach: TeachCard?

        func take(from templates: [QuizTemplate]) {
            for t in templates where picks.count < count {
                if !used.contains(t.id) && !picks.contains(t.id) { picks.append(t.id) }
            }
        }
        /// A lesson's templates, easy → hard, most-overdue first within a tier.
        func ladder(_ lessonId: String) -> [QuizTemplate] {
            repository.templates(for: lessonId).sorted { a, b in
                if a.difficulty != b.difficulty { return a.difficulty < b.difficulty }
                return priority(a.id) > priority(b.id)
            }
        }
        /// All `lessonIds` templates ranked purely by SRS priority (stalest first).
        func stalest(_ lessonIds: [String]) -> [QuizTemplate] {
            shuffle(lessonIds.flatMap { repository.templates(for: $0) })
                .sorted { priority($0.id) > priority($1.id) }
        }

        let core = pack.map { ReadinessEngine.coreLessons(for: $0) } ?? []

        switch mode {
        case .learning:
            // Advance the first core lesson that isn't mastered; new material
            // gets the day's one teach card.
            let target = core.first { data?.hasMasteredLesson($0) != true } ?? core.first
            if let lessonId = target, let lesson = repository.lesson(id: lessonId) {
                if data?.hasCompletedLesson(lessonId) != true {
                    teach = TeachCard(
                        id: lesson.id, lessonTitle: lesson.title,
                        concept: lesson.concept, shortcut: lesson.shortcut,
                        example: lesson.example.isEmpty ? nil : lesson.example
                    )
                }
                take(from: ladder(lessonId))
                // Continue into the next unmastered core lesson if this one
                // ran short (no second teach card — one bite per day).
                if picks.count < count {
                    let next = core.drop { $0 != lessonId }.dropFirst()
                        .first { data?.hasMasteredLesson($0) != true }
                    if let nextId = next { take(from: ladder(nextId)) }
                }
            }

        case .consolidating(.coverage):
            // Same as learning, anchored on the first UNATTEMPTED core lesson.
            let target = core.first { data?.hasCompletedLesson($0) != true } ?? core.first
            if let lessonId = target, let lesson = repository.lesson(id: lessonId) {
                if data?.hasCompletedLesson(lessonId) != true {
                    teach = TeachCard(
                        id: lesson.id, lessonTitle: lesson.title,
                        concept: lesson.concept, shortcut: lesson.shortcut,
                        example: lesson.example.isEmpty ? nil : lesson.example
                    )
                }
                take(from: ladder(lessonId))
            }

        case .consolidating(.depth):
            // Re-serve the hard (then medium) items of core lessons that
            // aren't yet mastered-with-hard.
            let lessons = core.filter { data?.masteredWithHard($0) != true }
            let hards = lessons.flatMap { repository.templates(for: $0) }
                .sorted { a, b in
                    if a.difficulty != b.difficulty { return a.difficulty > b.difficulty }
                    return priority(a.id) > priority(b.id)
                }
            take(from: hards)

        case .consolidating(.retention):
            // The retention checks: most-overdue core templates.
            take(from: stalest(core))

        case .consolidating(.application), .maintenance:
            // Maintenance reps over the pack (core first); the decision slot
            // carries the application gate.
            take(from: stalest(core))
            if picks.count < count, let pack { take(from: stalest(pack.lessonIds)) }

        case .reviewOnly:
            break // handled before mode dispatch

        case .noFocus:
            break // global fill below
        }

        // Global SRS fill — the .noFocus body and every mode's backstop.
        if picks.count < count {
            let fill = shuffle(pool.filter { !used.contains($0.id) && !picks.contains($0.id) })
                .sorted { priority($0.id) > priority($1.id) }
            take(from: fill)
        }
        return (picks, teach)
    }

    // MARK: - Seed

    /// YYYYMMDD seed for `date` — resets at midnight, injectable for tests.
    private static func seed(for date: Date) -> UInt64 {
        let cal = Calendar.current
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return UInt64(y * 10_000 + m * 100 + d)
    }
}
