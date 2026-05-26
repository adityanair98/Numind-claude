import Foundation

struct Lesson: Codable, Identifiable, Equatable {
    let id: String
    let moduleId: String
    let title: String
    let concept: String
    let shortcut: String
    let example: String
    let quizTemplateIds: [String]
    /// ISO date (yyyy-mm-dd) tracking when this lesson's content was last fact-checked
    /// against primary sources. Optional — older lessons may not have it yet.
    /// Used by the content audit workflow to surface stale entries.
    let lastVerified: String?
}
