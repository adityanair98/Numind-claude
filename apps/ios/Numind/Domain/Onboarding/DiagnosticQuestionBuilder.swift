import Foundation

/// Selects 8 diagnostic questions from the user's chosen topic interests.
///
/// Distribution:
/// - 2 topics → 4 questions each
/// - 3 topics → 3-3-2 split (topic with fewest templates gets 2)
/// - 4+ topics → 2 questions each
///
/// Each topic uses 1 easy (d1) + remaining harder (d2/d3) questions.
enum DiagnosticQuestionBuilder {

    /// A question paired with its source module ID.
    struct TaggedQuestion {
        let question: QuizQuestion
        let moduleId: String
    }

    /// Build questions with module ID tracking for diagnostic results.
    static func buildQuestionsWithModuleIds(
        topicInterests: Set<String>,
        repository: ContentRepository
    ) -> [TaggedQuestion] {
        let topics = Array(topicInterests).sorted()
        guard !topics.isEmpty else { return [] }

        let distribution = questionDistribution(topicCount: topics.count, total: 8)
        var tagged: [TaggedQuestion] = []

        for (index, topicId) in topics.enumerated() {
            let count = index < distribution.count ? distribution[index] : 2
            let lessons = repository.lessons(for: topicId)
            let templates = lessons.flatMap { repository.templates(for: $0.id) }
            guard !templates.isEmpty else { continue }

            let easyTemplates = templates.filter { $0.difficulty == 1 }
            let hardTemplates = templates.filter { $0.difficulty >= 2 }
            var topicQuestions: [TaggedQuestion] = []

            if let easyTemplate = easyTemplates.randomElement() ?? templates.randomElement() {
                let q = QuizEngine.generate(from: easyTemplate, targetDifficulty: .easy)
                topicQuestions.append(TaggedQuestion(question: q, moduleId: topicId))
            }

            let remainingCount = count - topicQuestions.count
            let hardPool = hardTemplates.isEmpty ? templates : hardTemplates
            var usedTemplateIds: Set<String> = []

            for _ in 0..<remainingCount {
                let available = hardPool.filter { !usedTemplateIds.contains($0.id) }
                let template = available.randomElement() ?? hardPool.randomElement()
                if let template {
                    let q = QuizEngine.generate(from: template)
                    topicQuestions.append(TaggedQuestion(question: q, moduleId: topicId))
                    usedTemplateIds.insert(template.id)
                }
            }

            tagged.append(contentsOf: topicQuestions)
        }

        return tagged.shuffled()
    }

    static func buildQuestions(
        topicInterests: Set<String>,
        repository: ContentRepository
    ) -> [QuizQuestion] {
        let topics = Array(topicInterests).sorted()
        guard !topics.isEmpty else { return [] }

        // Determine question count per topic
        let distribution = questionDistribution(topicCount: topics.count, total: 8)

        var questions: [QuizQuestion] = []

        for (index, topicId) in topics.enumerated() {
            let count = index < distribution.count ? distribution[index] : 2

            // Get all templates for lessons in this module
            let lessons = repository.lessons(for: topicId)
            let templates = lessons.flatMap { repository.templates(for: $0.id) }

            guard !templates.isEmpty else { continue }

            // Separate by difficulty
            let easyTemplates = templates.filter { $0.difficulty == 1 }
            let hardTemplates = templates.filter { $0.difficulty >= 2 }

            var topicQuestions: [QuizQuestion] = []

            // 1 easy question
            if let easyTemplate = easyTemplates.randomElement() ?? templates.randomElement() {
                let q = QuizEngine.generate(from: easyTemplate, targetDifficulty: .easy)
                topicQuestions.append(q)
            }

            // Remaining harder questions
            let remainingCount = count - topicQuestions.count
            let hardPool = hardTemplates.isEmpty ? templates : hardTemplates
            var usedTemplateIds: Set<String> = Set(topicQuestions.compactMap { _ in nil as String? })

            for _ in 0..<remainingCount {
                // Try to pick an unused template
                let available = hardPool.filter { !usedTemplateIds.contains($0.id) }
                let template = available.randomElement() ?? hardPool.randomElement()

                if let template {
                    let q = QuizEngine.generate(from: template)
                    topicQuestions.append(q)
                    usedTemplateIds.insert(template.id)
                }
            }

            questions.append(contentsOf: topicQuestions)
        }

        // Shuffle to avoid topic clustering
        return questions.shuffled()
    }

    // MARK: - Private

    /// Returns an array where each index is the question count for that topic.
    private static func questionDistribution(topicCount: Int, total: Int) -> [Int] {
        guard topicCount > 0 else { return [] }

        switch topicCount {
        case 1:
            return [total]
        case 2:
            let half = total / 2
            return [half, total - half]
        case 3:
            // 3-3-2 split — last topic gets fewer
            let base = total / 3      // 2
            let remainder = total % 3  // 2
            return (0..<3).map { i in
                base + (i < remainder ? 1 : 0)
            }
        default:
            // 4+ topics: 2 each, fill from first if any remainder
            let base = total / topicCount
            let remainder = total % topicCount
            return (0..<topicCount).map { i in
                base + (i < remainder ? 1 : 0)
            }
        }
    }
}
