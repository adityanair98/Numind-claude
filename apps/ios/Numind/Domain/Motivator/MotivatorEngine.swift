import Foundation

/// Pure evaluation logic for mid-session motivator checkpoints.
///
/// The engine is stateless — it takes the current session state and returns
/// an optional motivator type. The ViewModel owns the state tracking
/// (which indices have shown motivators, cooldown management).
///
/// Hard constraints:
/// - NEVER fires after the last question (guard: `remainingAfter > 0`)
/// - Maximum 2 full-screen motivators per session (configurable)
/// - Minimum 2-question cooldown between motivators
/// - Speed Drill: max 1 motivator, no coaching
enum MotivatorEngine {

    /// Evaluate whether a full-screen motivator should appear after the current question.
    ///
    /// - Parameters:
    ///   - correctFlags: Array of `isCorrect` bools for all answered questions (in order).
    ///   - totalQuestions: Total number of questions in the session.
    ///   - justAnsweredIndex: 0-based index of the question that was just answered.
    ///   - motivatorsShownAt: Indices where full-screen motivators were already shown.
    ///   - maxMotivators: Maximum number of motivators allowed per session.
    ///   - isSpeedDrill: If true, cap at 1 motivator and skip coaching.
    /// - Returns: The type of motivator to show, or `nil`.
    static func evaluate(
        correctFlags: [Bool],
        totalQuestions: Int,
        justAnsweredIndex: Int,
        motivatorsShownAt: [Int],
        maxMotivators: Int = 2,
        isSpeedDrill: Bool = false
    ) -> MotivatorType? {
        let answeredCount = correctFlags.count
        let remainingAfter = totalQuestions - answeredCount

        // ── HARD CONSTRAINT: never after the last question ──
        guard remainingAfter > 0 else { return nil }

        // ── Cap check ──
        let effectiveMax = isSpeedDrill ? 1 : maxMotivators
        guard motivatorsShownAt.count < effectiveMax else { return nil }

        // ── Cooldown: at least 2 questions since last motivator ──
        if let lastShown = motivatorsShownAt.last {
            guard justAnsweredIndex - lastShown >= 2 else { return nil }
        }

        // ── Priority evaluation (first match wins) ──

        // 1. COACHING — 2+ wrong in last 3 answers, but only after a wrong answer.
        //    Showing a "Take a Breath" coaching screen right after a correct answer
        //    feels tone-deaf — the user just succeeded, don't undermine that moment.
        if !isSpeedDrill, correctFlags.last == false {
            let recentWindow = correctFlags.suffix(3)
            let recentWrong = recentWindow.filter { !$0 }.count
            if recentWrong >= 2 {
                return .coaching
            }
        }

        // 2. MOMENTUM — 3+ consecutive correct from end
        let streak = consecutiveCorrectFromEnd(correctFlags)
        if streak >= 3 {
            return .momentum
        }

        // 3. PROGRESS — at the halfway point
        let halfway = totalQuestions / 2
        if answeredCount == halfway && halfway >= 3 {
            return .progress
        }

        // 4. NEAR FINISH — 2 questions remaining, accuracy >= 60%
        if remainingAfter == 2 {
            let correctCount = correctFlags.filter { $0 }.count
            let accuracy = answeredCount > 0 ? Double(correctCount) / Double(answeredCount) : 0
            if accuracy >= 0.6 {
                return .nearFinish
            }
        }

        return nil
    }

    /// Evaluate whether an inline encouragement overlay should appear on the feedback screen.
    ///
    /// - Parameters:
    ///   - isCorrect: Whether the current answer was correct.
    ///   - timeSpent: Seconds the user took to answer.
    ///   - hintWasRevealed: Whether the hint was shown before answering.
    ///   - consecutiveCorrect: Current streak of consecutive correct answers.
    ///   - inlineShownAt: Indices where inline encouragement was already shown.
    ///   - currentIndex: 0-based index of the current question.
    /// - Returns: Whether to show inline encouragement.
    static func evaluateInline(
        isCorrect: Bool,
        timeSpent: Double,
        hintWasRevealed: Bool,
        consecutiveCorrect: Int,
        inlineShownAt: [Int],
        currentIndex: Int
    ) -> Bool {
        // Must be correct
        guard isCorrect else { return false }

        // Cooldown: at least 3 questions since last inline
        if let lastShown = inlineShownAt.last {
            guard currentIndex - lastShown >= 3 else { return false }
        }

        // Any of these conditions:
        // a) Fast answer (< 5 seconds) — suggests shortcut internalization
        if timeSpent < 5.0 { return true }

        // b) Used hint and still got it right — learning is working
        if hintWasRevealed { return true }

        // c) 3+ consecutive correct — pattern forming
        if consecutiveCorrect >= 3 { return true }

        return false
    }

    // MARK: - Helpers

    private static func consecutiveCorrectFromEnd(_ flags: [Bool]) -> Int {
        var count = 0
        for correct in flags.reversed() {
            if correct { count += 1 } else { break }
        }
        return count
    }
}
