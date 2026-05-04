import Foundation

/// Builds a quiz session that covers multiple lessons.
/// Used for module review/checkpoint nodes on the learning path.
enum CheckpointQuizEngine {

    /// Samples templates from the given lessons and generates `targetCount` questions.
    /// Templates from all lessons are interleaved so the session genuinely tests breadth.
    /// Each `QuizEngine.generate` call uses a fresh random seed → different numbers
    /// and different answer choices every time (retries feel genuinely fresh).
    static func build(
        lessonIds: [String],
        repository: ContentRepository = LocalContentRepository(),
        targetCount: Int = 8
    ) -> [QuizQuestion] {
        // Gather templates per lesson to allow even sampling across lessons.
        let perLesson: [[QuizTemplate]] = lessonIds.map { repository.templates(for: $0) }
        let allTemplates = perLesson.flatMap { $0 }
        guard !allTemplates.isEmpty else { return [] }

        // Round-robin through lessons so every lesson is represented roughly equally.
        var questions: [QuizQuestion] = []
        var lessonIdx = 0
        var localIdx  = [Int](repeating: 0, count: perLesson.count)

        while questions.count < targetCount {
            // Skip empty lessons.
            var attempts = 0
            while perLesson[lessonIdx % perLesson.count].isEmpty {
                lessonIdx += 1
                attempts  += 1
                if attempts > perLesson.count { break }
            }
            let bucket = perLesson[lessonIdx % perLesson.count]
            if !bucket.isEmpty {
                let templatePos = localIdx[lessonIdx % perLesson.count] % bucket.count
                questions.append(QuizEngine.generate(from: bucket[templatePos]))
                localIdx[lessonIdx % perLesson.count] += 1
            }
            lessonIdx += 1
        }

        questions.shuffle()
        return questions
    }
}
