import XCTest
@testable import Numind

/// Locks in the Phase 9 mastery tightening: mastering a lesson now requires at
/// least one correct medium/hard answer (no mastering on easy-only), and
/// `masteredWithHard` (deep mastery) additionally needs a correct hard answer.
final class MasteryTests: XCTestCase {

    private func qr(_ d: QuestionDifficulty?, _ correct: Bool) -> QuestionResult {
        QuestionResult(templateId: "t", isCorrect: correct, timeSpentSeconds: 5, difficulty: d)
    }

    private func session(lesson: String, daysAgo: Int = 0, results: [QuestionResult]) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return SessionRecord(
            id: UUID(), lessonId: lesson, moduleId: "M", date: date,
            correctCount: results.filter(\.isCorrect).count,
            totalCount: results.count, questionResults: results
        )
    }

    private func progress(_ sessions: [SessionRecord]) -> ProgressData {
        var p = ProgressData(); p.sessions = sessions; return p
    }

    // MARK: - Depth requirement

    func test_easyOnly_doesNotMaster() {
        // 100% but every graded answer is easy → not mastered (Phase 9 rule).
        let p = progress([session(lesson: "L", results: [qr(.easy, true), qr(.easy, true), qr(.easy, true)])])
        XCTAssertFalse(p.hasMasteredLesson("L"))
    }

    func test_oneMediumCorrect_masters() {
        let p = progress([session(lesson: "L", results: [qr(.easy, true), qr(.medium, true), qr(.easy, true)])])
        XCTAssertTrue(p.hasMasteredLesson("L"))
    }

    func test_ungradedLegacySession_stillMastersByScore() {
        // No per-question difficulty (legacy) → depth check is skipped.
        let legacy = SessionRecord(id: UUID(), lessonId: "L", moduleId: "M", date: Date(),
                                   correctCount: 5, totalCount: 5)
        XCTAssertTrue(progress([legacy]).hasMasteredLesson("L"))
    }

    // MARK: - Deep mastery (mastered-with-hard)

    func test_masteredWithHard_requiresCorrectHard() {
        // Mastered via a correct medium, but no hard → not deep mastery.
        let mediumOnly = progress([session(lesson: "L", results: [qr(.medium, true), qr(.medium, true)])])
        XCTAssertTrue(mediumOnly.hasMasteredLesson("L"))
        XCTAssertFalse(mediumOnly.masteredWithHard("L"))

        // Add a correct hard → deep mastery.
        let withHard = progress([session(lesson: "L", results: [qr(.medium, true), qr(.hard, true)])])
        XCTAssertTrue(withHard.masteredWithHard("L"))
    }

    func test_wrongHard_doesNotCountAsDeepMastery() {
        // 6/7 ≈ 86% masters the lesson (via mediums), but the only hard is wrong
        // → not deep mastery.
        let results = Array(repeating: qr(.medium, true), count: 6) + [qr(.hard, false)]
        let p = progress([session(lesson: "L", results: results)])
        XCTAssertTrue(p.hasMasteredLesson("L"))
        XCTAssertFalse(p.masteredWithHard("L"))
    }

    // MARK: - Two-session path

    func test_twoSessions_nonConsecutiveDays_master() {
        // 80% each, 3 days apart, both include a medium correct → mastered.
        let s1 = session(lesson: "L", daysAgo: 3, results: [qr(.medium, true), qr(.easy, true), qr(.easy, true), qr(.hard, true), qr(.easy, false)])
        let s2 = session(lesson: "L", daysAgo: 0, results: [qr(.medium, true), qr(.easy, true), qr(.easy, true), qr(.easy, true), qr(.hard, false)])
        XCTAssertTrue(progress([s1, s2]).hasMasteredLesson("L"))
    }
}
