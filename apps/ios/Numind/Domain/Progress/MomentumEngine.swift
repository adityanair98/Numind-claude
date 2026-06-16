import Foundation

/// Momentum — the effort currency (Phase 9 score redesign).
///
/// XP measures *effort + consistency*, never competence (competence lives in
/// per-lesson mastery and per-pack Readiness). XP is **monotonic — it never
/// goes down** — and is a pure function over the session log, so it recomputes
/// from history with no stored state.
///
/// - Per correct answer: `10 × difficulty` → easy 10 / medium 15 / hard 25.
///   (Wide hard premium so depth pays meaningfully.)
/// - Milestones: +50 per lesson mastered, +150 per pack reaching Ready.
/// - Level: a front-loaded ladder, **depth-gated above L8** so easy-only volume
///   can't grind to the top (each level past 8 also needs one "deep mastery" —
///   a lesson mastered with a correct hard question, or a pack at Ready).
enum MomentumEngine {

    /// Cumulative XP required to *reach* each level (1-based: `ladder[0]` = L1).
    static let ladder: [Int] = [
        0, 80, 180, 320, 500, 750, 1100, 1550,
        2150, 2950, 4000, 5400, 7200, 9600, 12800
    ]

    /// Levels 1–8 are reachable by XP alone; 9+ each require one extra deep mastery.
    static let depthGateStartLevel = 8

    static let lessonMasteryBonus = 50
    static let packReadyBonus     = 150

    // MARK: - XP

    /// XP awarded for a single correct answer at the given difficulty.
    /// `nil` (legacy sessions without per-question difficulty) is treated as easy.
    static func xp(for difficulty: QuestionDifficulty?) -> Int {
        switch difficulty {
        case .hard:   return 25
        case .medium: return 15
        default:      return 10
        }
    }

    /// Base XP = Σ per-correct difficulty XP across all sessions. Monotonic.
    /// Falls back to `correctCount × 10` for legacy sessions that predate
    /// per-question results (so no historical XP is lost).
    static func baseXP(sessions: [SessionRecord]) -> Int {
        sessions.reduce(0) { acc, s in
            if s.questionResults.isEmpty {
                return acc + s.correctCount * 10
            }
            return acc + s.questionResults.reduce(0) {
                $0 + ($1.isCorrect ? xp(for: $1.difficulty) : 0)
            }
        }
    }

    /// Total XP = base + milestone bonuses. The caller supplies the milestone
    /// counts: `ProgressData` provides mastered-lesson count (pure); `ProgressStore`
    /// adds the ready-pack count (needs the content repo + ReadinessEngine).
    static func totalXP(
        sessions: [SessionRecord],
        masteredLessonCount: Int,
        readyPackCount: Int = 0
    ) -> Int {
        baseXP(sessions: sessions)
            + masteredLessonCount * lessonMasteryBonus
            + readyPackCount * packReadyBonus
    }

    // MARK: - Level

    /// Highest level reachable by XP alone (ignores the depth gate). 1-based.
    static func levelByXP(_ xp: Int) -> Int {
        var lvl = 1
        for (i, threshold) in ladder.enumerated() where xp >= threshold {
            lvl = i + 1
        }
        return lvl
    }

    /// Effective level = XP level, capped above L8 by `deepMasteryCount`
    /// (lessons mastered-with-hard + packs at Ready). Never exceeds the ladder.
    static func level(xp: Int, deepMasteryCount: Int) -> Int {
        min(levelByXP(xp), depthGateStartLevel + max(0, deepMasteryCount))
    }

    /// XP needed to reach the next ladder threshold, or `nil` at the top level.
    static func xpToNextLevel(_ xp: Int) -> Int? {
        let lvl = levelByXP(xp)
        guard lvl < ladder.count else { return nil }
        return ladder[lvl] - xp
    }

    /// Progress (0–1) through the current XP level toward the next.
    static func levelProgress(_ xp: Int) -> Double {
        let lvl = levelByXP(xp)
        guard lvl < ladder.count else { return 1 }
        let lower = ladder[lvl - 1], upper = ladder[lvl]
        guard upper > lower else { return 1 }
        return Double(xp - lower) / Double(upper - lower)
    }

    /// True when the user has the XP for the next level but is held back by the
    /// depth gate (needs another deep mastery to advance). Drives the
    /// "earn a deep mastery to unlock Level N" copy instead of "X XP to go".
    static func isDepthGated(xp: Int, deepMasteryCount: Int) -> Bool {
        levelByXP(xp) > depthGateStartLevel + max(0, deepMasteryCount)
    }
}
