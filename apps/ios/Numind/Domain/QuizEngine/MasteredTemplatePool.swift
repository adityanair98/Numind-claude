import Foundation

/// Filters the quiz template pool to only lessons the user has mastered (≥75%).
///
/// Used by all game modes (Blitz, Speed Drill, Enhanced Daily Challenge) to ensure
/// users only get questions on concepts they have already learned and passed.
enum MasteredTemplatePool {

    // MARK: - Public API

    /// All templates from lessons the user has mastered.
    /// Returns an empty array if no lessons have been mastered yet.
    static func templates(
        from progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> [QuizTemplate] {
        let masteredIds = masteredTemplateIds(from: progressData, repository: repository)
        guard !masteredIds.isEmpty else { return [] }
        return repository.allTemplates().filter { masteredIds.contains($0.id) }
    }

    /// MCQ-only templates from mastered lessons.
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

    /// Returns true if the user has mastered at least one lesson (game modes are unlocked).
    static func hasUnlockedModes(
        progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> Bool {
        !masteredTemplateIds(from: progressData, repository: repository).isEmpty
    }

    // MARK: - Private

    /// Collects the set of template IDs that belong to any mastered lesson.
    private static func masteredTemplateIds(
        from progressData: ProgressData,
        repository: ContentRepository
    ) -> Set<String> {
        let allLessons = repository.allModules()
            .flatMap { repository.lessons(for: $0.id) }

        return Set(
            allLessons
                .filter { progressData.hasMasteredLesson($0.id) }
                .flatMap { $0.quizTemplateIds }
        )
    }
}
