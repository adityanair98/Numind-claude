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

    /// Short display name for radar chart labels, tab strips, and compact UI.
    var shortName: String {
        switch id {
        case "smart_shopping": return "Shopping"
        case "student_loans":  return "Loans"
        case "money_math":     return "Budgets"
        default:
            let firstWord = title.split(separator: " ").first.map(String.init) ?? title
            return firstWord.trimmingCharacters(in: .punctuationCharacters)
        }
    }
}
