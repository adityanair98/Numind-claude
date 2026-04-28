import Foundation

struct QuizQuestion: Identifiable, Equatable {
    struct Choice: Identifiable, Equatable {
        let id: UUID
        let text: String
    }

    let id: UUID
    let templateId: String
    let prompt: String
    let choices: [Choice]       // always 4, shuffled
    let correctChoiceId: UUID   // matches one of choices
    let explanation: String
}
