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

/// Ranks incomplete lessons by weakness, surfacing the most urgent learning
/// opportunities based on each module's recent Numind Score.
///
/// Ranking order:
///   1. Modules with the lowest Numind Score (weakest) → highest urgency
///   2. Within a module, incomplete lessons appear in content order
///   3. Modules where the user is already in progress get a small boost
///      (they're close to completion, finishing is high-value)
enum LessonRecommendationEngine {

    // MARK: - Public API

    /// Returns up to `limit` recommended lessons ordered by urgency (most urgent first).
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

        // Per-module: current score and first incomplete lesson
        var candidates: [(lesson: Lesson, module: Module, urgency: Double, reason: LessonRecommendation.Reason)] = []

        for module in modules {
            let lessons         = repository.lessons(for: module.id)
            let completedIds    = Set(sessions.filter { $0.moduleId == module.id && !$0.isReviewSession }.map(\.lessonId))
            let score           = NumindScoreEngine.score(for: module.id, sessions: sessions)
            let completedCount  = completedIds.count

            guard let nextLesson = lessons.first(where: { !completedIds.contains($0.id) }) else {
                continue  // all lessons in this module are done — skip
            }

            // Urgency: inverted score, boosted if the user is partially through.
            var urgency = 1.0 - Double(score) / 100.0
            let inProgress = completedCount > 0 && completedCount < lessons.count
            if inProgress { urgency = min(1.0, urgency + 0.15) }

            let reason: LessonRecommendation.Reason
            if score == 0 && completedCount == 0 {
                reason = .neverAttempted
            } else if inProgress {
                reason = .inProgress(moduleName: module.title)
            } else {
                reason = .weakModule(moduleName: module.title)
            }

            candidates.append((lesson: nextLesson, module: module, urgency: urgency, reason: reason))
        }

        return candidates
            .sorted { $0.urgency > $1.urgency }
            .prefix(limit)
            .map { LessonRecommendation(lesson: $0.lesson, module: $0.module, reason: $0.reason, urgency: $0.urgency) }
    }
}
