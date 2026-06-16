import XCTest
@testable import Numind

/// Phase 10 — capability milestones (volume/level/module-completion cases
/// retired; completion celebrations live in the Celebration queue).
final class MilestoneEngineTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(lessonId: String, moduleId: String = "smart_shopping",
                             correct: Int = 5, total: Int = 5) -> SessionRecord {
        SessionRecord(id: UUID(), lessonId: lessonId, moduleId: moduleId,
                      date: Date(), correctCount: correct, totalCount: total)
    }

    private func makeProgress(sessions: [SessionRecord] = []) -> ProgressData {
        var p = ProgressData()
        p.sessions = sessions
        return p
    }

    // MARK: - First skill mastered

    func test_firstSkillMastered_firesOnce_withLessonName() {
        let before = makeProgress()
        let after = makeProgress(sessions: [makeSession(lessonId: "net_pay_check")])

        let m = MilestoneEngine.check(
            before: before, after: after, shownIds: [],
            beforeMastered: [], afterMastered: ["net_pay_check"],
            lessonNames: ["net_pay_check": "Gross vs net"]
        )
        guard case .firstSkillMastered(let name) = m else {
            return XCTFail("expected firstSkillMastered, got \(String(describing: m))")
        }
        XCTAssertEqual(name, "Gross vs net")

        // Already shown → never again.
        let again = MilestoneEngine.check(
            before: before, after: after, shownIds: [m!.id],
            beforeMastered: [], afterMastered: ["net_pay_check"],
            lessonNames: ["net_pay_check": "Gross vs net"]
        )
        XCTAssertNil(again)
    }

    func test_firstSkillMastered_doesNotFire_whenAlreadyHadMastery() {
        let m = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["tip_10_percent_trick"],
            afterMastered: ["tip_10_percent_trick", "net_pay_check"]
        )
        XCTAssertNil(m)
    }

    // MARK: - Pack readiness

    func test_firstPackReady_firesWithPackName() {
        let m = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],   // mastery quiet
            beforeReadyPackIds: [], afterReadyPackIds: ["first_paycheck"],
            packNames: ["first_paycheck": "First Paycheck"]
        )
        guard case .firstPackReady(let name) = m else {
            return XCTFail("expected firstPackReady, got \(String(describing: m))")
        }
        XCTAssertEqual(name, "First Paycheck")
    }

    func test_firstPackReady_doesNotFire_forSecondPack() {
        let m = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeReadyPackIds: ["first_paycheck"],
            afterReadyPackIds: ["first_paycheck", "everyday_spending"]
        )
        XCTAssertNil(m)
    }

    func test_threePacksReady_firesOnCrossingThree() {
        let m = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(),
            shownIds: ["milestone_first_pack_ready"],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeReadyPackIds: ["a", "b"],
            afterReadyPackIds: ["a", "b", "c"]
        )
        guard case .threePacksReady = m else {
            return XCTFail("expected threePacksReady, got \(String(describing: m))")
        }
    }

    // MARK: - Refresh save

    func test_firstRefreshSave_firesOnlyForRefreshSessions_thatReduceStaleness() {
        // Refresh session that restored a skill → fires.
        let fires = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeStaleCount: 3, afterStaleCount: 2,
            lastSessionLessonId: "refresh_review"
        )
        guard case .firstRefreshSave = fires else {
            return XCTFail("expected firstRefreshSave, got \(String(describing: fires))")
        }

        // Same staleness drop from a normal lesson → silent.
        let lessonPath = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeStaleCount: 3, afterStaleCount: 2,
            lastSessionLessonId: "net_pay_check"
        )
        XCTAssertNil(lessonPath)

        // Refresh session with no staleness change → silent.
        let noChange = MilestoneEngine.check(
            before: makeProgress(), after: makeProgress(), shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeStaleCount: 2, afterStaleCount: 2,
            lastSessionLessonId: "refresh_review"
        )
        XCTAssertNil(noChange)
    }

    // MARK: - Streak + freeze (preserved from Phase 9)

    func test_weekStreak_firesOnCrossingSeven() {
        let calendar = Calendar.current
        var before = makeProgress()
        before.dailyWorkoutDates = Set((1...6).map {
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: -$0, to: Date())!)
        })
        var after = before
        after.dailyWorkoutDates.insert(calendar.startOfDay(for: Date()))

        let m = MilestoneEngine.check(
            before: before, after: after, shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"]
        )
        guard case .firstWeekStreak = m else {
            return XCTFail("expected firstWeekStreak, got \(String(describing: m))")
        }
    }

    func test_firstFreeze_firesWhenFreezeAwarded() {
        let before = makeProgress()
        var after = makeProgress()
        after.availableFreezes = 1

        let m = MilestoneEngine.check(
            before: before, after: after, shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"]
        )
        guard case .firstFreeze = m else {
            return XCTFail("expected firstFreeze, got \(String(describing: m))")
        }
    }

    // MARK: - Priority

    func test_capabilityOutranksStreak() {
        // Pack readiness + week streak in the same transition → pack first.
        let calendar = Calendar.current
        var before = makeProgress()
        before.dailyWorkoutDates = Set((1...6).map {
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: -$0, to: Date())!)
        })
        var after = before
        after.dailyWorkoutDates.insert(calendar.startOfDay(for: Date()))

        let m = MilestoneEngine.check(
            before: before, after: after, shownIds: [],
            beforeMastered: ["x"], afterMastered: ["x"],
            beforeReadyPackIds: [], afterReadyPackIds: ["p"],
            packNames: ["p": "Pack"]
        )
        guard case .firstPackReady = m else {
            return XCTFail("capability should outrank streak, got \(String(describing: m))")
        }
    }
}
