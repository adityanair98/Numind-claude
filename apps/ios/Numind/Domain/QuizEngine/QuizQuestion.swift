import Foundation

struct QuizQuestion: Identifiable, Equatable {
    struct Choice: Identifiable, Equatable {
        let id: UUID
        let text: String
    }

    let id: UUID
    let templateId: String
    let difficulty: Int         // 1 = easy, 2 = medium, 3 = hard
    let prompt: String
    let choices: [Choice]       // always 4, shuffled
    let correctChoiceId: UUID   // matches one of choices
    let explanation: String
}
