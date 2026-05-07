import Foundation

// MARK: - Model

/// A single recommended lesson with the reason and urgency behind the suggestion.
struct LessonRecommendation: Identifiable {
    var id: String { lesson.id }
    let lesson: Lesson
    let module: Module
    let reason: Reason
    /// 0–1. Higher = more urgent. Drives display order.
    let urgency: Double

    enum Reason {
        /// The user has never touched this module.
        case neverAttempted
        /// Recent session data shows this module is weak (low Numind Score).
        case weakModule(moduleName: String)
        /// Continuing a partially started module.
        case inProgress(moduleName: String)
    }
}

// MARK: - Engine

/// Ranks lessons by weakness, surfacing the most urgent learning opportunities
/// based on each module's recent Numind Score.
///
/// Ranking order:
///   1. Incomplete modules with the lowest score → highest urgency
///   2. Never-attempted modules → mid urgency ("try something new")
///   3. Completed modules' weakest lessons → review urgency (keeps the list
///      populated even when every lesson has been finished at least once)
enum LessonRecommendationEngine {

    // MARK: - Public API

    /// Returns up to `limit` recommended lessons ordered by urgency (most urgent first).
    ///
    /// When all lessons are complete the engine falls back to review recommendations:
    /// the weakest module's first lesson is surfaced with `.weakModule` reason so the
    /// user always has a targeted action to take.
    ///
    /// - Parameters:
    ///   - repository: Content source for modules and lessons.
    ///   - sessions: All recorded sessions used to compute module scores.
    ///   - limit: Maximum number of recommendations to return.
    static func recommendations(
        repository: ContentRepository,
        sessions: [SessionRecord],
        limit: Int = 5
    ) -> [LessonRecommendation] {

        let modules = repository.allModules()

        typealias Candidate = (lesson: Lesson, module: Module, urgency: Double, reason: LessonRecommendation.Reason)
        var candidates: [Candidate] = []

        // Track fully-completed modules so we can fall back to review mode.
        var completedModules: [(module: Module, score: Int, lessons: [Lesson])] = []

        for module in modules {
            let lessons = repository.lessons(for: module.id)
            let moduleSessions = sessions.filter { $0.moduleId == module.id && !$0.isReviewSession }

            // Mastered = scored ≥ 75%. This gates lesson progression (same rule as Learn tab).
            let masteredIds = Set(
                moduleSessions.filter {
                    $0.totalCount > 0 && Double($0.correctCount) / Double($0.totalCount) >= 0.75
                }.map(\.lessonId)
            )
            // Attempted = any session exists (drives in-progress signal, not gating).
            let attemptedIds = Set(moduleSessions.map(\.lessonId))

            let score = NumindScoreEngine.score(for: module.id, sessions: sessions)

            guard let nextLesson = lessons.first(where: { !masteredIds.contains($0.id) }) else {
                // All lessons mastered — remember for review fallback.
                if !lessons.isEmpty && score > 0 {
                    completedModules.append((module: module, score: score, lessons: lessons))
                }
                continue
            }

            // Urgency: inverted score, boosted if the user is partially through.
            let inProgress = !attemptedIds.isEmpty && masteredIds.count < lessons.count
            let reason: LessonRecommendation.Reason
            var urgency: Double

            if score == 0 && attemptedIds.isEmpty {
                // Never attempted — interesting to surface, but below weak/in-progress modules.
                // 0.5 puts it in the middle: the user should see these as "try something new"
                // rather than them drowning out actionable "you're struggling here" signals.
                reason = .neverAttempted
                urgency = 0.5
            } else if inProgress {
                reason = .inProgress(moduleName: module.title)
                urgency = min(1.0, (1.0 - Double(score) / 100.0) + 0.15)
            } else {
                reason = .weakModule(moduleName: module.title)
                urgency = 1.0 - Double(score) / 100.0
            }

            candidates.append((lesson: nextLesson, module: module, urgency: urgency, reason: reason))
        }

        // Fallback: when all lessons are complete, surface the weakest modules'
        // first lesson as a review recommendation. The user always has something
        // actionable — "sharpen your weakest skill."
        if candidates.isEmpty && !completedModules.isEmpty {
            let sorted = completedModules.sorted { $0.score < $1.score }
            for entry in sorted.prefix(limit) {
                let urgency = 1.0 - Double(entry.score) / 100.0
                candidates.append((
                    lesson: entry.lessons[0],
                    module: entry.module,
                    urgency: urgency,
                    reason: .weakModule(moduleName: entry.module.title)
                ))
            }
        }

        return candidates
            .sorted { $0.urgency > $1.urgency }
            .prefix(limit)
            .map { LessonRecommendation(lesson: $0.lesson, module: $0.module, reason: $0.reason, urgency: $0.urgency) }
    }
}
