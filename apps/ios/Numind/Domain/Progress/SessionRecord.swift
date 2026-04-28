import Foundation

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let lessonId: String
    let moduleId: String
    let date: Date
    let correctCount: Int
    let totalCount: Int
}
