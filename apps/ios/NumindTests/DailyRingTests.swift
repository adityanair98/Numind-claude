import XCTest
@testable import Numind

/// Phase 10 — daily ring + the "ring closes from any real practice" streak
/// rule. Mostly pure over DailyRingEngine/ProgressData; the final section adds
/// store-level regressions for the batch-recording + freeze audit fixes (H2/M3).
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

    func test_markActiveDay_subTargetPractice_stillMarksDay() {
        // Audit fix H3: the streak counts "you showed up," not "you hit the
        // daily volume goal." A sub-target session (3 < target 7) still marks
        // the day — previously it was silently dropped and broke the streak.
        var data = ProgressData()
        data.sessions = [session(total: 3)]
        DailyRingEngine.markActiveDay(&data)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(data.dailyWorkoutDates.contains(today))
        XCTAssertEqual(data.computeStreak(), 1)
        // The ring visual is still target-based — the goal isn't "closed" yet.
        XCTAssertFalse(DailyRingEngine.isClosed(on: Date(), data: data))
    }

    func test_markActiveDay_noPractice_doesNotMarkDay() {
        var data = ProgressData()
        DailyRingEngine.markActiveDay(&data)
        XCTAssertTrue(data.dailyWorkoutDates.isEmpty)
    }

    func test_markActiveDay_marksToday_andIsIdempotent() {
        var data = ProgressData()
        data.sessions = [session(total: 8)]
        DailyRingEngine.markActiveDay(&data)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(data.dailyWorkoutDates.contains(today))
        let countAfterFirst = data.dailyWorkoutDates.count
        DailyRingEngine.markActiveDay(&data)
        XCTAssertEqual(data.dailyWorkoutDates.count, countAfterFirst)
    }

    func test_lessonOnlyPractice_countsTowardStreak() {
        // The Phase 10 rule change: a user who never taps "Daily Workout"
        // but does a full lesson still gets their day.
        var data = ProgressData()
        data.sessions = [session(total: 7, lessonId: "net_pay_check")]
        DailyRingEngine.markActiveDay(&data)
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
        DailyRingEngine.markActiveDay(&data)

        XCTAssertEqual(data.computeStreak(), 6)   // 5 backfilled + today
    }

    func test_freezeAndRestDays_stillCount() {
        // Ring-closed two days ago, frozen yesterday, ring-closed today → 3.
        let calendar = Calendar.current
        var data = ProgressData()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        data.sessions = [session(daysAgo: 2, total: 8)]
        DailyRingEngine.markActiveDay(&data, now: twoDaysAgo)
        data.frozenDates.insert(calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: Date())!))
        data.sessions.append(session(total: 8))
        DailyRingEngine.markActiveDay(&data)
        XCTAssertEqual(data.computeStreak(), 3)
    }

    // MARK: - Store-level recording (audit fixes H2 + M3)

    private func dailyRec(daysAgo: Int, module: String = "smart_shopping", total: Int) -> SessionRecord {
        let d = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        // Synthetic lessonId (like the real Daily Workout) so no real-lesson
        // capability milestone outranks the streak/freeze milestone under test.
        return SessionRecord(id: UUID(), lessonId: "daily_challenge", moduleId: module,
                             date: d, correctCount: total, totalCount: total)
    }

    @MainActor
    func test_multiRecordBatch_preservesEarnedMilestone() {
        // A daily workout spanning multiple modules records several SessionRecords
        // at once. The milestone earned as the streak crosses a threshold must
        // survive — the old per-record loop recomputed (and nil'd) it on later
        // sub-records before the UI ever saw it (audit fix H2).
        let store = ProgressStore()
        store.reset()
        store.recordSession(dailyRec(daysAgo: 2, total: 8))
        store.recordSession(dailyRec(daysAgo: 1, total: 8))
        // Today, recorded as a 2-module batch (the bug path) — streak crosses to
        // 3, earning the first freeze.
        store.recordSessions([dailyRec(daysAgo: 0, module: "smart_shopping", total: 4),
                              dailyRec(daysAgo: 0, module: "salary", total: 4)])
        XCTAssertEqual(store.streak, 3)
        XCTAssertEqual(store.pendingMilestone?.id, "milestone_first_freeze")
        store.reset()
    }

    @MainActor
    func test_acceptStreakLoss_clearsBankedFreezes_noDoubleAward() {
        // Audit fix M3: accepting a loss resets BOTH the milestone counter and the
        // banked balance, so a new climb earns from scratch instead of stacking.
        let store = ProgressStore()
        store.reset()
        store.recordSession(dailyRec(daysAgo: 2, total: 8))
        store.recordSession(dailyRec(daysAgo: 1, total: 8))
        store.recordSession(dailyRec(daysAgo: 0, total: 8))   // streak 3 → 1 freeze
        XCTAssertEqual(store.availableFreezes, 1)
        store.acceptStreakLoss()
        XCTAssertEqual(store.availableFreezes, 0)
        store.reset()
    }
}
