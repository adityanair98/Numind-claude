import Foundation

/// Scores a chain of mental arithmetic operations and maps the total
/// to a `QuestionDifficulty` tier.
///
/// Each `MentalOp` is scored independently based on the actual numeric
/// operands — percentage friendliness, number roundness, intermediate
/// cleanliness, and answer cleanliness. The scores sum to a total that
/// maps to `.easy`, `.medium`, or `.hard`.
enum DifficultyScorer {

    // MARK: - Public API

    static func score(operations: [MentalOp]) -> QuestionDifficulty {
        let total = operations.reduce(0) { $0 + scoreOp($1) }
        switch total {
        case ..<3:  return .easy
        case ..<6:  return .medium
        default:    return .hard
        }
    }

    // MARK: - Per-operation scoring

    private static func scoreOp(_ op: MentalOp) -> Int {
        switch op {
        case .percentOf(let pct, let amount):
            return scorePercentOf(pct: pct, amount: amount)
        case .divide(let a, let b):
            return scoreDivide(a: a, by: b)
        case .multiply(let a, let b):
            return scoreMultiply(a: a, by: b)
        case .add(let a, let b):
            return scoreAdd(a: a, b: b)
        case .subtract(let b, let from):
            return scoreSubtract(b: b, from: from)
        }
    }

    // MARK: - percentOf

    /// Higher score = more mental steps or messier intermediates.
    private static func scorePercentOf(pct: Double, amount: Double) -> Int {
        var score = percentScore(pct)
        let result = pct / 100.0 * amount
        // Penalise messy intermediates — e.g. 10% of $137 = $13.70 (one decimal)
        // but 18% of $137 requires 20% = $27.40, 2% = $2.74 (both messy).
        if !isClean(result) { score += 1 }
        // Extra penalty when both the percentage and amount are awkward.
        if percentScore(pct) >= 2 && !isRound(amount) { score += 1 }
        return score
    }

    /// 0 = trivial (10%, 50%, 100%), 1 = one step (20%, 25%, 5%),
    /// 2 = two sub-steps (15%, 30%, 75%), 3 = multi-step decomposition.
    private static func percentScore(_ pct: Double) -> Int {
        let p = Int(pct)
        switch p {
        case 10, 50, 100:      return 0   // just move the decimal / halve
        case 20, 25, 5, 1:    return 1   // ÷5, ÷4, ÷20 — one clean operation
        case 15, 30, 75, 40:  return 2   // 10%+5%, 3×10%, etc.
        default:               return 3   // 18%, 22%, 33% — multi-step
        }
    }

    // MARK: - divide

    private static func scoreDivide(a: Double, by b: Double) -> Int {
        guard b != 0 else { return 0 }
        let result = a / b
        if isClean(result) && b <= 4 { return 0 }   // e.g. $120 ÷ 4 = $30
        if isClean(result)           { return 1 }   // clean result, larger divisor
        if result.truncatingRemainder(dividingBy: 0.5) == 0 { return 2 }  // x.5 result
        return 3                                     // ugly remainder
    }

    // MARK: - multiply

    private static func scoreMultiply(a: Double, by b: Double) -> Int {
        let result = a * b
        if isClean(result) && (isRound(a) || isRound(b)) { return 0 }
        if isClean(result)  { return 1 }
        if !isClean(result) { return 2 }
        return 2
    }

    // MARK: - add

    private static func scoreAdd(a: Double, b: Double) -> Int {
        let result = a + b
        if isClean(a) && isClean(b) && isClean(result) { return 0 }
        if isClean(result) { return 1 }
        return 2   // decimal carry
    }

    // MARK: - subtract

    private static func scoreSubtract(b: Double, from a: Double) -> Int {
        let result = a - b
        if isClean(a) && isClean(b) && isClean(result) { return 0 }
        if isClean(result) { return 1 }
        return 2   // decimal borrow
    }

    // MARK: - Helpers

    /// A "clean" number has at most one decimal place that is .0, .25, .5, or .75.
    static func isClean(_ n: Double) -> Bool {
        let frac = n - floor(n)
        // Whole number
        if frac == 0 { return true }
        // Quarter increments
        let quarterFrac = (frac * 4).rounded()
        return abs(frac - quarterFrac / 4) < 0.001
    }

    /// A "round" number is divisible by 5 with no decimal part.
    static func isRound(_ n: Double) -> Bool {
        n.truncatingRemainder(dividingBy: 5) == 0 && n == floor(n)
    }
}
