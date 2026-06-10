import Foundation

/// Phase 10 — the daily goal ring.
///
/// One honest daily metric: questions answered today against a small fixed
/// target. Closing the ring is what marks the day for the streak — "the ring
/// closes from any real practice" (Daily Workout, a lesson, a refresh round,
/// or pack practice all count). The workout is simply the one-tap way to
/// close it.
///
/// Pure over the session log, like the other Phase 9/10 engines. The XP
/// engine keeps fueling difficulty weighting invisibly; the ring is the only
/// per-day number the user sees.
enum DailyRingEngine {

    /// Daily target: sized to the user's workout, capped at 8 so a single
    /// full lesson always closes the ring, floored at 5 so the day is never
    /// trivial. (Cap rationale: users on 10–12-question workouts shouldn't
    /// need more than one real session for the day to count.)
    static func target(for data: ProgressData?) -> Int {
        let workout = DailyChallengeEngine.questionCount(for: data)
        return min(max(workout, 5), 8)
    }

    /// Total questions answered on `day` across ALL sessions. The Daily
    /// Workout records one SessionRecord per module touched, so this sums
    /// across records rather than looking for a single one.
    static func questionCount(on day: Date, sessions: [SessionRecord]) -> Int {
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: day)
        return sessions
            .filter { calendar.startOfDay(for: $0.date) == target }
            .reduce(0) { $0 + $1.totalCount }
    }

    static func isClosed(on day: Date, data: ProgressData) -> Bool {
        questionCount(on: day, sessions: data.sessions) >= target(for: data)
    }

    /// Ring fill 0–1 for `day`.
    static func progress(on day: Date, data: ProgressData) -> Double {
        let t = target(for: data)
        guard t > 0 else { return 0 }
        return min(1, Double(questionCount(on: day, sessions: data.sessions)) / Double(t))
    }

    /// Marks `now`'s day in `dailyWorkoutDates` once the ring target is
    /// reached (idempotent; no-op while the ring is open).
    ///
    /// Phase 10 widens that field's semantics from "completed the Daily
    /// Workout" to "closed the daily ring" — the persisted shape is
    /// unchanged, so no migration.
    ///
    /// Backfill hazard: `ProgressData.activeDays` anchors the streak on
    /// `dailyWorkoutDates` EXCLUSIVELY once the set is non-empty, falling
    /// back to session days only while it's empty. A legacy lesson-only user
    /// (empty set, streak anchored on session days) would have that streak
    /// collapse to 1 on their first ring closure — so the first write also
    /// backfills all historical session days.
    static func markIfClosed(_ data: inout ProgressData, now: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        guard !data.dailyWorkoutDates.contains(today),
              isClosed(on: now, data: data) else { return }
        if data.dailyWorkoutDates.isEmpty {
            for day in Set(data.sessions.map { calendar.startOfDay(for: $0.date) }) {
                data.dailyWorkoutDates.insert(day)
            }
        }
        data.dailyWorkoutDates.insert(today)
    }
}
