import Foundation

/// **Freshness** — the restorable staleness signal (Phase 9). It is the *only*
/// thing that decays, and it **never** touches XP, Level, or mastery stars.
/// Surfaced as opportunity ("N skills to refresh"); reviewing raises it.
///
/// Pure over the session log via `SpacedRepetitionEngine.priorityScore`. A
/// template is "stale" when it has been seen (finite score) and is overdue
/// (score > 0); never-seen templates (`+∞`) are excluded so freshness only
/// reflects skills the user has actually built.
enum FreshnessEngine {

    /// Overdue (seen + past-due) template IDs among mastered lessons, most
    /// overdue first. Feeds the refresh session + the Daily Workout.
    static func refreshTargets(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository(),
        limit: Int? = nil
    ) -> [String] {
        var scored: [(id: String, score: Double)] = []
        for lessonId in masteredLessonIds {
            for t in repository.templates(for: lessonId) {
                let s = SpacedRepetitionEngine.priorityScore(templateId: t.id, in: sessions)
                if s.isFinite && s > 0 { scored.append((t.id, s)) }
            }
        }
        let sorted = scored.sorted { $0.score > $1.score }.map(\.id)
        return limit.map { Array(sorted.prefix($0)) } ?? sorted
    }

    /// Mastered lessons that have ≥1 overdue (seen) template.
    static func staleLessons(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> [String] {
        masteredLessonIds.filter { lessonId in
            repository.templates(for: lessonId).contains { t in
                let s = SpacedRepetitionEngine.priorityScore(templateId: t.id, in: sessions)
                return s.isFinite && s > 0
            }
        }
    }

    static func staleCount(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> Int {
        staleLessons(masteredLessonIds: masteredLessonIds, sessions: sessions, repository: repository).count
    }

    /// Fraction of mastered lessons currently fresh (0–1). 1.0 when none are mastered.
    static func freshnessPercent(
        masteredLessonIds: Set<String>,
        sessions: [SessionRecord],
        repository: ContentRepository = LocalContentRepository()
    ) -> Double {
        guard !masteredLessonIds.isEmpty else { return 1.0 }
        let stale = staleCount(masteredLessonIds: masteredLessonIds, sessions: sessions, repository: repository)
        return Double(masteredLessonIds.count - stale) / Double(masteredLessonIds.count)
    }
}
