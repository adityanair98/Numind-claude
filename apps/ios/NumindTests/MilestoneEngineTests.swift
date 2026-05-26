import XCTest
@testable import Numind

final class MilestoneEngineTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(lessonId: String, moduleId: String) -> SessionRecord {
        SessionRecord(
            id: UUID(),
            lessonId: lessonId,
            moduleId: moduleId,
            date: Date(),
            correctCount: 5,
            totalCount: 5
        )
    }

    private func makeProgress(sessions: [SessionRecord]) -> ProgressData {
        var p = ProgressData()
        p.sessions = sessions
        return p
    }

    /// 15 baseline sessions in `other_mod` so session-count milestones
    /// (firstSession/fiveSessions/tenSessions) have already fired and won't
    /// outrank moduleCompleted in priority during these tests.
    private var baselineSessions: [SessionRecord] {
        (1...15).map { makeSession(lessonId: "padding_\($0)", moduleId: "other_mod") }
    }

    // MARK: - Module completion bug regression

    /// Bug: prior to this fix, finishing the FIRST lesson in a module would fire
    /// .moduleCompleted because the check was `afterLessons.count > beforeLessons.count`
    /// (any new lesson) instead of "all lessons completed". Lock that in.
    func test_moduleCompleted_doesNotFireOnFirstLesson() {
        let before = makeProgress(sessions: baselineSessions)
        let after = makeProgress(sessions: baselineSessions + [makeSession(lessonId: "lesson_a", moduleId: "test_mod")])

        let result = MilestoneEngine.check(
            before: before,
            after: after,
            shownIds: [],
            moduleNames: ["test_mod": "Test Module"],
            moduleLessonCounts: ["test_mod": 5]   // 5 lessons total — should not fire on 1
        )

        if case .moduleCompleted = result {
            XCTFail("moduleCompleted should not fire when only 1 of 5 lessons is done")
        }
    }

    func test_moduleCompleted_doesNotFireMidwayThrough() {
        let lessons = ["a", "b", "c"].map { makeSession(lessonId: "lesson_\($0)", moduleId: "test_mod") }
        let before = makeProgress(sessions: baselineSessions + Array(lessons.prefix(2)))   // 2 lessons done
        let after = makeProgress(sessions: baselineSessions + lessons)                     // 3 lessons done

        let result = MilestoneEngine.check(
            before: before,
            after: after,
            shownIds: [],
            moduleNames: ["test_mod": "Test Module"],
            moduleLessonCounts: ["test_mod": 5]   // still 2 more to go
        )

        if case .moduleCompleted = result {
            XCTFail("moduleCompleted should not fire when only 3 of 5 lessons are done")
        }
    }

    func test_moduleCompleted_firesOnFinalLesson() {
        let fourLessons = ["a", "b", "c", "d"].map { makeSession(lessonId: "lesson_\($0)", moduleId: "test_mod") }
        let fiveLessons = fourLessons + [makeSession(lessonId: "lesson_e", moduleId: "test_mod")]

        let before = makeProgress(sessions: baselineSessions + fourLessons)
        let after = makeProgress(sessions: baselineSessions + fiveLessons)

        let result = MilestoneEngine.check(
            before: before,
            after: after,
            shownIds: [],
            moduleNames: ["test_mod": "Test Module"],
            moduleLessonCounts: ["test_mod": 5]
        )

        guard case .moduleCompleted(let name) = result else {
            XCTFail("moduleCompleted should fire when crossing 4 → 5 of 5 lessons. Got: \(String(describing: result))")
            return
        }
        XCTAssertEqual(name, "Test Module")
    }

    func test_moduleCompleted_doesNotRefireAfterCompletion() {
        // Already completed all 5 lessons; user replays one — should NOT re-trigger
        let allLessons = ["a", "b", "c", "d", "e"].map { makeSession(lessonId: "lesson_\($0)", moduleId: "test_mod") }
        let before = makeProgress(sessions: baselineSessions + allLessons)
        // Replaying lesson_a adds a session but no new lesson
        let after = makeProgress(sessions: baselineSessions + allLessons + [makeSession(lessonId: "lesson_a", moduleId: "test_mod")])

        let result = MilestoneEngine.check(
            before: before,
            after: after,
            shownIds: ["milestone_module_Test Module"],   // already shown
            moduleNames: ["test_mod": "Test Module"],
            moduleLessonCounts: ["test_mod": 5]
        )

        // Even ignoring shownIds, the engine's threshold-crossing logic should not fire:
        // beforeLessons.count = 5 (not < 5), so the crossedThreshold guard fails.
        if case .moduleCompleted = result {
            XCTFail("moduleCompleted should not fire on lesson replay after completion")
        }
    }

    func test_moduleCompleted_ignoresReviewSessions() {
        // 5 real lesson sessions + 1 review session — only the 5 real lessons should count
        let lessons = ["a", "b", "c", "d", "e"].map { makeSession(lessonId: "lesson_\($0)", moduleId: "test_mod") }
        let withReview = lessons + [makeSession(lessonId: "review_test_mod_0", moduleId: "test_mod")]

        let before = makeProgress(sessions: baselineSessions + Array(lessons.prefix(4)))
        let after = makeProgress(sessions: baselineSessions + withReview)

        let result = MilestoneEngine.check(
            before: before,
            after: after,
            shownIds: [],
            moduleNames: ["test_mod": "Test Module"],
            moduleLessonCounts: ["test_mod": 5]
        )

        guard case .moduleCompleted = result else {
            XCTFail("moduleCompleted should fire when 5 real lessons + a review are done")
            return
        }
    }

    func test_moduleCompleted_doesNotFireWithoutLessonCounts() {
        // Without moduleLessonCounts, we have no way to know what "complete" means.
        // Engine should safely skip the check rather than fire spuriously.
        let lessons = ["a"].map { makeSession(lessonId: "lesson_\($0)", moduleId: "test_mod") }
        let after = makeProgress(sessions: baselineSessions + lessons)

        let result = MilestoneEngine.check(
            before: makeProgress(sessions: baselineSessions),
            after: after,
            shownIds: [],
            moduleNames: ["test_mod": "Test Module"]
            // moduleLessonCounts omitted
        )

        if case .moduleCompleted = result {
            XCTFail("moduleCompleted should not fire when moduleLessonCounts is unsupplied")
        }
    }
}
