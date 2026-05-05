import Foundation

struct QuizQuestion: Identifiable, Equatable {
    struct Choice: Identifiable, Equatable {
        let id: UUID
        let text: String
    }

    let id: UUID
    let templateId: String
    let difficulty: QuestionDifficulty
    let inputMode: InputMode    // multipleChoice or freeEntry
    let answerFormat: AnswerFormat
    let correctValue: Double    // raw numeric answer (for free-entry validation)
    let scenario: String?       // optional real-world context shown above the prompt
    let prompt: String
    let choices: [Choice]       // always 4, shuffled (used even in freeEntry for feedback)
    let correctChoiceId: UUID   // matches one of choices
    let explanation: String
}
