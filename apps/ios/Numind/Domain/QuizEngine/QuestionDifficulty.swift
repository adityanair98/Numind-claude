import Foundation

/// The mental effort required to solve a quiz question in your head.
///
/// Difficulty is assessed from the *actual generated numbers*, not from the
/// template type. The same template can produce Easy, Medium, or Hard questions
/// depending on the percentage / amount combination and how clean the
/// intermediate values are during mental computation.
enum QuestionDifficulty: Int, Codable, Comparable, CaseIterable {
    case easy   = 1
    case medium = 2
    case hard   = 3

    static func < (lhs: QuestionDifficulty, rhs: QuestionDifficulty) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }
}

// MARK: - Mental operation primitives

/// A single mental arithmetic step with its actual resolved operands.
///
/// The difficulty of a question is the aggregate of difficulty across all
/// the `MentalOp`s in its computation chain — not a property of the template.
enum MentalOp {
    /// Find X% of Y  (e.g. 15% of $86)
    case percentOf(pct: Double, amount: Double)
    /// Divide A by B  (e.g. $120 ÷ 4 people)
    case divide(a: Double, by: Double)
    /// Multiply A by B  (e.g. $43 × 3 nights)
    case multiply(a: Double, by: Double)
    /// Add two values  (e.g. $86 + $12.90 tip)
    case add(a: Double, b: Double)
    /// Subtract B from A  (e.g. $120 − $36 discount)
    case subtract(b: Double, from: Double)
}
