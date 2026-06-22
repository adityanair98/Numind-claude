import XCTest
@testable import Numind

/// Phase 10 — daily ring + the "ring closes from any real practice" streak
/// rule. Pure over DailyRingEngine/ProgressData — no store, no persistence.
final class DailyRingTests: XCTestCase {

    private func session(daysAgo: Int = 0, total: Int, lessonId: String = "tip_10_percent_trick") -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return SessionRecord(id: UUID(), lessonId: lessonId, moduleId: "smart_shopping",
                             date: date, correctCount: total, totalCount: total)
    }

    // MARK: - Target

    func test_target_defaultsToSeven() {
        XCTAssertEqual(DailyRingEngine.target(for: nil), 7)
        XCTAssertEqual(DailyRingEngine.target(for: ProgressData()), 7)
    }

    func test_target_capsAtEight_forHeavyWorkouts() {
        // 10 min/day onboarding → 12-question workout; the ring stays at 8 so
        // one full session always closes it.
        var data = ProgressData()
        var signals = OnboardingSignals()
        signals.dailyMinutes = 10
        data.onboardingSignals = signals
        XCTAssertEqual(DailyRingEngine.target(for: data), 8)
    }

    func test_target_floorsAtFive_forLightWorkouts() {
        // 3 min/day → 5-question workout; floored at 5 so the day isn't trivial.
        var data = ProgressData()
        var signals = OnboardingSignals()
        signals.dailyMinutes = 3
        data.onboardingSignals = signals
        XCTAssertEqual(DailyRingEngine.target(for: data), 5)
    }

    // MARK: - Counting

    func test_questionCount_sumsSplitRecords() {
        // The Daily Workout records one SessionRecord per module touched —
        // ring counting must sum across them, not look for a single record.
        let sessions = [session(total: 3), session(total: 2), session(total: 3)]
        XCTAssertEqual(DailyRingEngine.questionCount(on: Date(), sessions: sessions), 8)
    }

    func test_questionCount_ignoresOtherDays() {
        let sessions = [session(daysAgo: 1, total: 8), session(total: 2)]
        XCTAssertEqual(DailyRingEngine.questionCount(on: Date(), sessions: sessions), 2)
    }

    // MARK: - Closing

    func test_ring_closesExactlyAtThreshold() {
        var data = ProgressData()
        data.sessions = [session(total: 6)]
        XCTAssertFalse(DailyRingEngine.isClosed(on: Date(), data: data))   // 6 < 7
        data.sessions.append(session(total: 1))
        XCTAssertTrue(DailyRingEngine.isClosed(on: Date(), data: data))    // 7 == 7
        XCTAssertEqual(DailyRingEngine.progress(on: Date(), data: data), 1.0)
    }

    func test_markIfClosed_underThreshold_doesNotMarkDay() {
        var data = ProgressData()
        data.sessions = [session(total: 3)]
        DailyRingEngine.markIfClosed(&data)
        XCTAssertTrue(data.dailyWorkoutDates.isEmpty)
    }

    func test_markIfClosed_marksToday_andIsIdempotent() {
        var data = ProgressData()
        data.sessions = [session(total: 8)]
        DailyRingEngine.markIfClosed(&data)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(data.dailyWorkoutDates.contains(today))
        let countAfterFirst = data.dailyWorkoutDates.count
        DailyRingEngine.markIfClosed(&data)
        XCTAssertEqual(data.dailyWorkoutDates.count, countAfterFirst)
    }

    func test_lessonOnlyPractice_countsTowardStreak() {
        // The Phase 10 rule change: a user who never taps "Daily Workout"
        // but does a full lesson still gets their day.
        var data = ProgressData()
        data.sessions = [session(total: 7, lessonId: "net_pay_check")]
        DailyRingEngine.markIfClosed(&data)
        XCTAssertEqual(data.computeStreak(), 1)
    }

    // MARK: - The backfill regression (streak-anchor flip hazard)

    func test_firstRingClosure_backfillsLegacySessionDays_preservingStreak() {
        // Legacy lesson-only user: 5 consecutive session days, empty
        // dailyWorkoutDates, streak anchored on the session-day fallback.
        // ProgressData.activeDays switches to dailyWorkoutDates EXCLUSIVELY
        // once it's non-empty — without the backfill, the first ring closure
        // would collapse a 5-day streak to 1.
        var data = ProgressData()
        data.sessions = (1...5).map { session(daysAgo: $0, total: 6) }
        XCTAssertEqual(data.computeStreak(), 5)

        data.sessions.append(session(total: 8))   // today: ring closes
        DailyRingEngine.markIfClosed(&data)

        XCTAssertEqual(data.computeStreak(), 6)   // 5 backfilled + today
    }

    func test_freezeAndRestDays_stillCount() {
        // Ring-closed two days ago, frozen yesterday, ring-closed today → 3.
        let calendar = Calendar.current
        var data = ProgressData()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        data.sessions = [session(daysAgo: 2, total: 8)]
        DailyRingEngine.markIfClosed(&data, now: twoDaysAgo)
        data.frozenDates.insert(calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: Date())!))
        data.sessions.append(session(total: 8))
        DailyRingEngine.markIfClosed(&data)
        XCTAssertEqual(data.computeStreak(), 3)
    }
}
