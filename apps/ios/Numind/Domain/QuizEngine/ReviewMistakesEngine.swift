import Foundation

/// Builds a review quiz session from wrong answers in a completed session.
///
/// Key property: every call regenerates questions with a **fresh random seed**,
/// so variable values differ from the original attempt — users cannot memorise
/// numbers, only the underlying pattern.
enum ReviewMistakesEngine {

    /// Returns a `QuizSessionViewModel` containing fresh re-generations of every
    /// incorrectly answered template, or `nil` if there are no wrong answers.
    ///
    /// - Parameters:
    ///   - results: The `QuizResult` array from a finished `QuizSessionViewModel`.
    ///   - moduleColor: Passed through to the review session's banner tint.
    ///   - lessonShortcut: The hint text shown in the "Shortcut" card during review.
    ///   - repository: Content source (defaults to the bundled JSON).
    @MainActor
    static func build(
        from results: [QuizSessionViewModel.QuizResult],
        moduleColor: ModuleColor = .muted,
        lessonShortcut: String = "Same question types, different numbers — focus on the method, not the answer.",
        repository: ContentRepository = LocalContentRepository()
    ) -> QuizSessionViewModel? {
        // Collect unique wrong template IDs in the order they were answered.
        var seen = Set<String>()
        let wrongIds = results
            .filter { !$0.isCorrect }
            .map    { $0.question.templateId }
            .filter { seen.insert($0).inserted }   // deduplicate, preserve order

        guard !wrongIds.isEmpty else { return nil }

        // Re-generate each template with a new random seed → fresh variable values.
        let questions: [QuizQuestion] = wrongIds.compactMap { id in
            guard let template = repository.template(id: id) else { return nil }
            return QuizEngine.generate(from: template)
        }

        guard !questions.isEmpty else { return nil }

        return QuizSessionViewModel(
            questions: questions,
            title: "Review Mistakes",
            shortcut: lessonShortcut,
            moduleColor: moduleColor
        )
    }

}
