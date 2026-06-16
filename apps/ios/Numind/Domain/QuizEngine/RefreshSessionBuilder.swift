import Foundation

/// Builds the single consolidated **Refresh** session (Phase 10-A8).
///
/// Phase 7a left two overlapping review entry points on Home: Recall
/// ("review your weak spots", all-time wrong answers) and Refresh (stale
/// mastered skills, Phase 9 Freshness). This builder merges them into one
/// inventory so there is exactly one "keep it sharp" affordance:
///
/// 1. **Stale skills first** — overdue templates from mastered lessons
///    (`FreshnessEngine.refreshTargets`), most overdue first. These are the
///    skills the user owns and is about to lose; restoring them is the
///    session's primary job.
/// 2. **Unfixed mistakes second** — templates whose *most recent* attempt
///    was wrong, newest miss first. A template the user has since answered
///    correctly is considered fixed and never re-served here (the old Recall
///    re-served all-time mistakes forever).
///
/// Deduped, capped at `questionLimit`, regenerated with fresh values so the
/// user practices the method, not the memorised number. Pure over the
/// session log — no stored state.
enum RefreshSessionBuilder {

    static let questionLimit = 8

    struct RefreshSession {
        let questions: [QuizQuestion]
        /// Distinct lessons covered — drives the "Refresh N skills" copy.
        let skillCount: Int
    }

    // MARK: - Inventory

    /// Ordered, deduped template IDs: stale mastered targets, then templates
    /// whose latest attempt was wrong.
    static func inventory(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository(),
        limit: Int = questionLimit
    ) -> [String] {
        var ids: [String] = []
        var seen = Set<String>()

        for id in FreshnessEngine.refreshTargets(
            masteredLessonIds: masteredLessonIds,
            sessions: sessions,
            repository: repository
        ) where seen.insert(id).inserted {
            ids.append(id)
        }

        for id in unfixedMistakeIds(in: sessions) where seen.insert(id).inserted {
            ids.append(id)
        }

        return Array(ids.prefix(limit))
    }

    /// Distinct lessons the inventory touches — the honest "N skills" count
    /// for the Home card (templates of the same lesson count once).
    static func skillCount(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> Int {
        let ids = inventory(
            masteredLessonIds: masteredLessonIds,
            sessions: sessions,
            repository: repository
        )
        let lessons = Set(ids.compactMap { repository.lesson(forTemplateId: $0)?.id })
        return lessons.count
    }

    // MARK: - Session

    /// Fresh-value question set for the consolidated Refresh session, or nil
    /// when there is nothing stale and no unfixed mistakes.
    static func build(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> RefreshSession? {
        let ids = inventory(
            masteredLessonIds: masteredLessonIds,
            sessions: sessions,
            repository: repository
        )
        let questions: [QuizQuestion] = ids.compactMap { id in
            guard let template = repository.template(id: id) else { return nil }
            return QuizEngine.generate(from: template)
        }
        guard !questions.isEmpty else { return nil }

        let lessons = Set(questions.compactMap { repository.lesson(forTemplateId: $0.templateId)?.id })
        return RefreshSession(questions: questions, skillCount: lessons.count)
    }

    // MARK: - Internal

    /// Templates whose most recent attempt across the session log was wrong,
    /// ordered newest miss first (template id breaks date ties for stable
    /// ordering).
    private static func unfixedMistakeIds(in sessions: [SessionRecord]) -> [String] {
        var latest: [String: (date: Date, isCorrect: Bool)] = [:]
        for record in sessions {
            for result in record.questionResults {
                if let existing = latest[result.templateId], existing.date > record.date {
                    continue
                }
                latest[result.templateId] = (record.date, result.isCorrect)
            }
        }
        return latest
            .filter { !$0.value.isCorrect }
            .sorted {
                if $0.value.date != $1.value.date { return $0.value.date > $1.value.date }
                return $0.key < $1.key
            }
            .map(\.key)
    }
}
