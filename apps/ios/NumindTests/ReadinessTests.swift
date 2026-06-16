import XCTest
@testable import Numind

/// Locks in the Phase 9 per-pack Readiness gates (coverage → depth → retention)
/// and the Almost-ready single-missing-gate logic. Uses a synthetic pack so the
/// fixtures are deterministic; real packs are exercised via the live repo.
final class ReadinessTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    // Synthetic 2-core-lesson pack. Its lesson IDs don't exist in the repo, so
    // the freshness (overdue) lookup returns no templates → a fully-gated pack
    // reads as `.sharp` (no overdue work outstanding).
    private func synthPack() -> Pack {
        Pack(id: "test_pack", title: "Test Path", tagline: "t", hook: "h", description: "d",
             lessonIds: ["core_a", "core_b"], coreLessonIds: ["core_a", "core_b"],
             anchorLessonId: "core_a", estimatedMinutes: 10, lastVerified: "2026-01-01")
    }

    private func qr(_ d: QuestionDifficulty?, _ correct: Bool) -> QuestionResult {
        QuestionResult(templateId: "t", isCorrect: correct, timeSpentSeconds: 5, difficulty: d)
    }

    private func session(lesson: String, daysAgo: Int, results: [QuestionResult]) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return SessionRecord(
            id: UUID(), lessonId: lesson, moduleId: "M", date: date,
            correctCount: results.filter(\.isCorrect).count,
            totalCount: results.count, questionResults: results
        )
    }

    /// Two sessions on distinct days that master-with-hard and retain `lesson`.
    private func fullyGated(_ lesson: String) -> [SessionRecord] {
        [session(lesson: lesson, daysAgo: 3, results: [qr(.hard, true), qr(.medium, true), qr(.easy, true)]),
         session(lesson: lesson, daysAgo: 0, results: [qr(.medium, true), qr(.easy, true)])]
    }

    /// Mastered + retained but with NO hard answer → depth gate fails.
    private func mediumGated(_ lesson: String) -> [SessionRecord] {
        [session(lesson: lesson, daysAgo: 3, results: [qr(.medium, true), qr(.medium, true), qr(.easy, true)]),
         session(lesson: lesson, daysAgo: 0, results: [qr(.medium, true)])]
    }

    private func progress(_ sessions: [SessionRecord]) -> ProgressData {
        var p = ProgressData(); p.sessions = sessions; return p
    }

    private func state(_ sessions: [SessionRecord]) -> ReadinessEngine.State {
        ReadinessEngine.state(for: synthPack(), data: progress(sessions), repository: repo)
    }

    // MARK: - Tests

    func test_notStarted_withNoSessions() {
        XCTAssertEqual(state([]), .notStarted)
    }

    func test_allGatesPass_isReadyOrSharp() {
        let s = state(fullyGated("core_a") + fullyGated("core_b"))
        switch s {
        case .ready, .sharp: break  // synthetic lessons → sharp, but accept either
        default: XCTFail("Expected ready/sharp, got \(s)")
        }
    }

    func test_almostReady_namesTheMissingDepthGate() {
        // Both core lessons mastered + retained, but neither has a hard answer.
        let s = state(mediumGated("core_a") + mediumGated("core_b"))
        guard case .almostReady(let missing, _) = s else {
            return XCTFail("Expected almostReady, got \(s)")
        }
        XCTAssertEqual(missing, .depth)
    }

    func test_almostReady_namesTheMissingRetentionGate() {
        // Both deep-mastered, but core_b was only correct on one day → retention fails.
        let coreA = fullyGated("core_a")
        let coreBOneDay = [session(lesson: "core_b", daysAgo: 0,
                                   results: [qr(.hard, true), qr(.medium, true), qr(.easy, true)])]
        guard case .almostReady(let missing, _) = state(coreA + coreBOneDay) else {
            return XCTFail("Expected almostReady (retention)")
        }
        XCTAssertEqual(missing, .retention)
    }

    func test_learning_whenMultipleGatesFail() {
        // core_a fully gated; core_b attempted once, low score, one day →
        // depth AND retention both fail → learning.
        let coreBWeak = [session(lesson: "core_b", daysAgo: 0,
                                 results: [qr(.easy, true), qr(.medium, false), qr(.hard, false)])]
        XCTAssertEqual(state(fullyGated("core_a") + coreBWeak), .learning)
    }

    func test_readyPackCount_isZero_withNoProgress() {
        XCTAssertEqual(ReadinessEngine.readyPackCount(data: ProgressData(), repository: repo), 0)
    }

    func test_coreLessons_fallsBackToAllLessonsWhenUntagged() {
        let untagged = Pack(id: "p", title: "P", tagline: "t", hook: "h", description: "d",
                            lessonIds: ["x", "y"], coreLessonIds: [],
                            anchorLessonId: "x", estimatedMinutes: 5, lastVerified: "2026-01-01")
        XCTAssertEqual(ReadinessEngine.coreLessons(for: untagged), ["x", "y"])
    }
}
