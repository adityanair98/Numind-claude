import Foundation

/// Selects 8 diagnostic questions for the onboarding diagnostic-as-demo
/// (Phase 11 v2 — pack-aware).
///
/// Composition:
/// - ~5 from the FOCUS pack's core lessons (1 easy entry, then a d1→d3
///   ladder across distinct core lessons)
/// - ~2 from secondary packs (their anchor/core lessons)
/// - 1 "what would you do" application item from the focus pack, served last
///
/// Each question carries its lesson's title + shortcut so the quiz can show
/// the shortcut reveal after every answer — the diagnostic doubles as the
/// product demo that carries the end-of-funnel paywall.
enum DiagnosticQuestionBuilder {

    /// A question paired with its source metadata.
    struct TaggedQuestion {
        let question: QuizQuestion
        let moduleId: String
        let lessonId: String
        let lessonTitle: String
        let shortcut: String
        let isApplication: Bool
    }

    static func build(
        focusPackId: String?,
        secondaryPackIds: Set<String>,
        repository: ContentRepository,
        total: Int = 8
    ) -> [TaggedQuestion] {
        guard let focusId = focusPackId,
              let focusPack = repository.pack(id: focusId) else {
            return []
        }

        let focusLessons = coreLessons(of: focusPack, repository: repository)
        var used = Set<String>()           // template IDs already picked
        var ordered: [TaggedQuestion] = []

        // ── 1 application item from the focus pack, reserved for the END ──
        let applicationPick = pickApplication(
            from: focusLessons, repository: repository, excluding: used
        )
        if let app = applicationPick { used.insert(app.question.templateId) }

        // ── Secondary-pack questions (1 each, max 2) ──
        var secondaryPicks: [TaggedQuestion] = []
        for packId in secondaryPackIds.sorted().prefix(2) {
            guard let pack = repository.pack(id: packId) else { continue }
            let lessons = coreLessons(of: pack, repository: repository)
            if let pick = pickOne(from: lessons, repository: repository,
                                  maxDifficulty: 2, excluding: used) {
                secondaryPicks.append(pick)
                used.insert(pick.question.templateId)
            }
        }

        // ── Focus-pack ladder fills the rest ──
        let focusCount = total - secondaryPicks.count - (applicationPick == nil ? 0 : 1)
        var focusPicks: [TaggedQuestion] = []

        // Entry question: one easy from the first core lesson.
        if let first = focusLessons.first,
           let easy = pickOne(from: [first], repository: repository,
                              maxDifficulty: 1, excluding: used) {
            focusPicks.append(easy)
            used.insert(easy.question.templateId)
        }

        // Ladder: rotate across distinct core lessons, harder as we go.
        var lessonCursor = focusLessons.isEmpty ? [] : Array(focusLessons.dropFirst()) + focusLessons
        while focusPicks.count < focusCount && !lessonCursor.isEmpty {
            let lesson = lessonCursor.removeFirst()
            let targetDifficulty = focusPicks.count < focusCount / 2 ? 2 : 3
            if let pick = pickOne(from: [lesson], repository: repository,
                                  preferredDifficulty: targetDifficulty,
                                  excluding: used) {
                focusPicks.append(pick)
                used.insert(pick.question.templateId)
            }
        }

        // Assemble: focus ladder, then secondaries interleaved, decision last.
        ordered = focusPicks
        for (i, pick) in secondaryPicks.enumerated() {
            let slot = min(ordered.count, (i + 1) * 2 + 1)
            ordered.insert(pick, at: slot)
        }
        if let app = applicationPick { ordered.append(app) }

        return ordered
    }

    // MARK: - Private

    /// The pack's readiness-defining lessons, falling back to all lessons.
    private static func coreLessons(of pack: Pack, repository: ContentRepository) -> [Lesson] {
        let ids = pack.coreLessonIds.isEmpty ? pack.lessonIds : pack.coreLessonIds
        return ids.compactMap { repository.lesson(id: $0) }
    }

    private static func tag(_ template: QuizTemplate, lesson: Lesson,
                            targetDifficulty: QuestionDifficulty? = nil) -> TaggedQuestion {
        let question: QuizQuestion
        if let target = targetDifficulty {
            question = QuizEngine.generate(from: template, targetDifficulty: target)
        } else {
            question = QuizEngine.generate(from: template)
        }
        return TaggedQuestion(
            question: question,
            moduleId: lesson.moduleId,
            lessonId: lesson.id,
            lessonTitle: lesson.title,
            shortcut: lesson.shortcut,
            isApplication: template.isApplicationItem
        )
    }

    /// Pick one non-application template from the given lessons near the
    /// preferred difficulty.
    private static func pickOne(
        from lessons: [Lesson],
        repository: ContentRepository,
        maxDifficulty: Int = 3,
        preferredDifficulty: Int? = nil,
        excluding used: Set<String>
    ) -> TaggedQuestion? {
        for lesson in lessons.shuffled() {
            let pool = repository.templates(for: lesson.id)
                .filter { !used.contains($0.id) && !$0.isApplicationItem && $0.difficulty <= maxDifficulty }
            guard !pool.isEmpty else { continue }

            let template: QuizTemplate?
            if let preferred = preferredDifficulty {
                template = pool.filter { $0.difficulty == preferred }.randomElement()
                    ?? pool.max(by: { abs($0.difficulty - preferred) > abs($1.difficulty - preferred) })
            } else {
                template = pool.filter { $0.difficulty == 1 }.randomElement() ?? pool.randomElement()
            }
            guard let template else { continue }

            let target: QuestionDifficulty? = template.difficulty == 1 ? .easy : nil
            return tag(template, lesson: lesson, targetDifficulty: target)
        }
        return nil
    }

    /// Pick one "what would you do" decision item from the lessons.
    private static func pickApplication(
        from lessons: [Lesson],
        repository: ContentRepository,
        excluding used: Set<String>
    ) -> TaggedQuestion? {
        for lesson in lessons.shuffled() {
            let pool = repository.templates(for: lesson.id)
                .filter { !used.contains($0.id) && $0.isApplicationItem }
            if let template = pool.randomElement() {
                return tag(template, lesson: lesson)
            }
        }
        return nil
    }
}
