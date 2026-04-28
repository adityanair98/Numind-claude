import Foundation

struct Module: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String        // SF Symbol name
    let color: ModuleColor  // semantic tone — resolved to Theme.Colors at display time
    let lessonIds: [String]
}
