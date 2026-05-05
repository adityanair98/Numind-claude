import Foundation

struct Module: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String        // SF Symbol name
    let color: ModuleColor  // semantic tone — resolved to Theme.Colors at display time
    let lessonIds: [String]
    let mascot: String      // emoji mascot (e.g. "☕", "🏷️")
    let glyph: String       // math symbol watermark (e.g. "%", "÷", "$")

    /// Short display name for tab strips and compact UI.
    var shortName: String {
        // Return the first word, capped at 8 characters.
        let firstWord = title.split(separator: " ").first.map(String.init) ?? title
        return String(firstWord.prefix(8))
    }
}
