import Foundation

/// Generates a large queue of MCQ questions from mastered templates for Blitz mode.
///
/// Blitz mode is a 60-second sprint — the player answers as many questions as
/// possible. The queue is pre-generated (shuffle templates, generate questions)
/// and sized well above what any player can finish in 60s (~45 questions).
/// MCQ only: free-entry is excluded because typing under time pressure is
/// frustrating rather than skill-testing.
enum BlitzEngine {

    /// Minimum number of questions in the pre-generated queue.
    /// At ~2s per question, 45 is more than enough for a 60s session.
    static let queueSize = 45

    /// Generates the question queue for a Blitz session.
    ///
    /// - Parameters:
    ///   - progressData: Used to filter templates to mastered lessons only.
    ///   - repository: Content source (defaults to local JSON).
    /// - Returns: Array of pre-generated MCQ questions, or empty if no mastered lessons.
    static func generateQuestionQueue(
        from progressData: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> [QuizQuestion] {
        let templates = MasteredTemplatePool.mcqTemplates(from: progressData, repository: repository)
        guard !templates.isEmpty else { return [] }

        var shuffled = templates.shuffled()
        var questions: [QuizQuestion] = []

        // Cycle through templates until we have enough questions.
        // Using a different seed per question ensures different variable values
        // even when the same template appears multiple times.
        var idx = 0
        while questions.count < queueSize {
            let template = shuffled[idx % shuffled.count]
            questions.append(QuizEngine.generate(from: template))
            idx += 1

            // Re-shuffle when we complete a full cycle to avoid monotony.
            if idx % shuffled.count == 0 {
                shuffled.shuffle()
            }
        }

        return questions
    }
}
