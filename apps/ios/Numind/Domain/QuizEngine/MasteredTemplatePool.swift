import Foundation

/// Filters the quiz template pool to only lessons the user has completed (any attempt).
///
/// Used by all game modes (Blitz, Speed Drill, Daily Challenge, etc.) to ensure
/// users only get questions on concepts they have already encountered.
/// Completion-based: any attempt at a lesson adds its templates to the pool.
/// Mastery (≥75%) is tracked separately for gold stars but does NOT gate access.
enum MasteredTemplatePool {

    // MARK: - Public API

    /// All templates from lessons the user has completed (any attempt).
    /// Returns an empty array if no lessons have been completed yet.
    static func templates(
        from progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> [QuizTemplate] {
        let completedIds = completedTemplateIds(from: progressData, repository: repository)
        guard !completedIds.isEmpty else { return [] }
        return repository.allTemplates().filter { completedIds.contains($0.id) }
    }

    /// MCQ-only templates from completed lessons.
    ///
    /// Used by Speed Drill and Blitz — free-entry questions are excluded
    /// because typing under time pressure is frustrating, not skill-testing.
    static func mcqTemplates(
        from progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> [QuizTemplate] {
        templates(from: progressData, repository: repository)
            .filter { ($0.inputMode ?? .multipleChoice) == .multipleChoice }
    }

    /// Returns true if the user has completed at least one lesson (game modes are unlocked).
    static func hasUnlockedModes(
        progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> Bool {
        !completedTemplateIds(from: progressData, repository: repository).isEmpty
    }

    // MARK: - Private

    /// Collects the set of template IDs that belong to any completed lesson.
    private static func completedTemplateIds(
        from progressData: ProgressData,
        repository: ContentRepository
    ) -> Set<String> {
        let allLessons = repository.allModules()
            .flatMap { repository.lessons(for: $0.id) }

        return Set(
            allLessons
                .filter { progressData.hasCompletedLesson($0.id) }
                .flatMap { $0.quizTemplateIds }
        )
    }
}
