import Foundation

// Pure Codable value — all computation lives here so it's testable without the store.
struct ProgressData: Codable {
    var sessions: [SessionRecord] = []

    // MARK: - Streak

    func computeStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })

        // Start from today if completed today, otherwise from yesterday
        var checkDay = sessionDays.contains(today)
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today)!

        var streak = 0
        while sessionDays.contains(checkDay) {
            streak += 1
            checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
        }
        return streak
    }

    // MARK: - Accuracy

    func computeAccuracy() -> Double {
        let totalCorrect   = sessions.reduce(0) { $0 + $1.correctCount }
        let totalQuestions = sessions.reduce(0) { $0 + $1.totalCount }
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestions)
    }

    // MARK: - Module progress

    func completedLessonCount(moduleId: String) -> Int {
        Set(sessions.filter { $0.moduleId == moduleId }.map { $0.lessonId }).count
    }

    func moduleProgress(moduleId: String, totalLessons: Int) -> Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessonCount(moduleId: moduleId)) / Double(totalLessons)
    }

    func hasCompletedLesson(_ lessonId: String) -> Bool {
        sessions.contains { $0.lessonId == lessonId }
    }

    // MARK: - Weekly

    // Returns 7 Bool values: index 0 = Monday of the current week.
    func computeWeeklyCompletions() -> [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })

        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2 // Monday
        let monday = calendar.date(from: comps) ?? today

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: monday) ?? today
            return sessionDays.contains(day)
        }
    }

    // Unique days with at least one session in the current calendar week.
    func computeWeeklyWorkouts() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let thisWeek = sessions.filter {
            calendar.isDate($0.date, equalTo: today, toGranularity: .weekOfYear)
        }
        return Set(thisWeek.map { calendar.startOfDay(for: $0.date) }).count
    }
}
