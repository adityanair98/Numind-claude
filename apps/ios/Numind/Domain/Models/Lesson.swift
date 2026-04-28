import Foundation

struct Lesson: Codable, Identifiable, Equatable {
    let id: String
    let moduleId: String
    let title: String
    let concept: String
    let shortcut: String
    let example: String
    let quizTemplateIds: [String]
}
