import Foundation

struct Module: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String        // SF Symbol name
    let color: String       // Theme.Colors key — resolved at display time
    let lessonIds: [String]
}
