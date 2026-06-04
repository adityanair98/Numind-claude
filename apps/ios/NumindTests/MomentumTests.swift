import XCTest
@testable import Numind

/// Locks in the Phase 9 XP/Level model (replaces the deleted composite-score
/// baselines). Pure over MomentumEngine — no repo, no persistence.
final class MomentumTests: XCTestCase {

    // MARK: - Helpers

    private func qr(_ d: QuestionDifficulty?, _ correct: Bool) -> QuestionResult {
        QuestionResult(templateId: "t", isCorrect: correct, timeSpentSeconds: 5, difficulty: d)
    }

    private func session(results: [QuestionResult], correctCount: Int? = nil) -> SessionRecord {
        SessionRecord(
            id: UUID(), lessonId: "L", moduleId: "M", date: Date(),
            correctCount: correctCount ?? results.filter(\.isCorrect).count,
            totalCount: results.count,
            questionResults: results
        )
    }

    // MARK: - Per-answer XP

    func test_xp_isDifficultyWeighted() {
        XCTAssertEqual(MomentumEngine.xp(for: .easy), 10)
        XCTAssertEqual(MomentumEngine.xp(for: .medium), 15)
        XCTAssertEqual(MomentumEngine.xp(for: .hard), 25)
    }

    func test_xp_nilDifficulty_treatedAsEasy() {
        XCTAssertEqual(MomentumEngine.xp(for: nil), 10)
    }

    func test_xp_onlyCorrectAnswersEarn() {
        // Base XP sums correct difficulty XP; wrong answers earn nothing.
        let s = session(results: [qr(.easy, true), qr(.medium, true), qr(.hard, false), qr(.hard, true)])
        XCTAssertEqual(MomentumEngine.baseXP(sessions: [s]), 10 + 15 + 0 + 25)
    }

    func test_baseXP_legacyFallback_whenNoQuestionResults() {
        // Pre-difficulty sessions fall back to correctCount × 10.
        let legacy = SessionRecord(id: UUID(), lessonId: "L", moduleId: "M", date: Date(),
                                   correctCount: 3, totalCount: 5)
        XCTAssertEqual(MomentumEngine.baseXP(sessions: [legacy]), 30)
    }

    // MARK: - Milestone bonuses

    func test_totalXP_addsMasteryAndReadyBonuses() {
        let s = session(results: [qr(.hard, true)])  // base 25
        let total = MomentumEngine.totalXP(sessions: [s], masteredLessonCount: 2, readyPackCount: 1)
        XCTAssertEqual(total, 25 + 2 * 50 + 1 * 150)
    }

    func test_xp_isMonotonic_neverSubtracts() {
        // Adding a wrong-only session never lowers XP.
        let good = session(results: [qr(.hard, true), qr(.medium, true)])
        let bad  = session(results: [qr(.hard, false), qr(.easy, false)])
        let before = MomentumEngine.totalXP(sessions: [good], masteredLessonCount: 0)
        let after  = MomentumEngine.totalXP(sessions: [good, bad], masteredLessonCount: 0)
        XCTAssertGreaterThanOrEqual(after, before)
        XCTAssertEqual(after, before)  // wrong answers add exactly 0
    }

    // MARK: - Level ladder

    func test_levelByXP_ladderBoundaries() {
        XCTAssertEqual(MomentumEngine.levelByXP(0), 1)
        XCTAssertEqual(MomentumEngine.levelByXP(79), 1)
        XCTAssertEqual(MomentumEngine.levelByXP(80), 2)
        XCTAssertEqual(MomentumEngine.levelByXP(179), 2)
        XCTAssertEqual(MomentumEngine.levelByXP(180), 3)
        XCTAssertEqual(MomentumEngine.levelByXP(12_800), 15)
        XCTAssertEqual(MomentumEngine.levelByXP(999_999), 15)  // capped at ladder top
    }

    func test_xpToNextLevel_andTopLevel() {
        XCTAssertEqual(MomentumEngine.xpToNextLevel(0), 80)
        XCTAssertEqual(MomentumEngine.xpToNextLevel(80), 100)   // 180 − 80
        XCTAssertNil(MomentumEngine.xpToNextLevel(12_800))      // top level
    }

    func test_levelProgress_isFractionThroughCurrentLevel() {
        XCTAssertEqual(MomentumEngine.levelProgress(0), 0.0, accuracy: 0.001)
        XCTAssertEqual(MomentumEngine.levelProgress(40), 0.5, accuracy: 0.001)  // halfway 0→80
        XCTAssertEqual(MomentumEngine.levelProgress(12_800), 1.0, accuracy: 0.001)
    }

    // MARK: - Depth gate above L8

    func test_level_isDepthGatedAboveEight() {
        // 2150 XP earns ladder level 9, but the gate needs +1 deep mastery.
        XCTAssertEqual(MomentumEngine.level(xp: 2150, deepMasteryCount: 0), 8)
        XCTAssertEqual(MomentumEngine.level(xp: 2150, deepMasteryCount: 1), 9)
    }

    func test_isDepthGated_reflectsTheCap() {
        XCTAssertTrue(MomentumEngine.isDepthGated(xp: 2150, deepMasteryCount: 0))
        XCTAssertFalse(MomentumEngine.isDepthGated(xp: 2150, deepMasteryCount: 1))
        // Below L8 the gate never applies.
        XCTAssertFalse(MomentumEngine.isDepthGated(xp: 500, deepMasteryCount: 0))
    }

    func test_easyOnlyGrind_cannotReachTop() {
        // 1000 easy-correct answers = 10_000 XP (ladder L14) but 0 deep mastery →
        // capped at L8. Depth, not volume, unlocks the top.
        let easyAnswers = (0..<1000).map { _ in qr(.easy, true) }
        let s = session(results: easyAnswers)
        let xp = MomentumEngine.totalXP(sessions: [s], masteredLessonCount: 0, readyPackCount: 0)
        XCTAssertGreaterThan(MomentumEngine.levelByXP(xp), 8)
        XCTAssertEqual(MomentumEngine.level(xp: xp, deepMasteryCount: 0), 8)
    }
}
