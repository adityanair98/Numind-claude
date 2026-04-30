import Foundation

// Pure Codable value — all computation lives here so it's testable without the store.
struct ProgressData: Codable {
    var sessions: [SessionRecord] = []
    var bestStreak: Int = 0

    // MARK: - Streak

    func computeStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })

        // Start from today if practiced, otherwise from yesterday.
        var checkDay = sessionDays.contains(today)
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today)!

        // Allow one grace day (1-day gap) per streak chain.
        var streak = 0
        var graceUsed = false
        while true {
            if sessionDays.contains(checkDay) {
                streak += 1
                checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
            } else if !graceUsed {
                // Skip the missed day once — grace day
                graceUsed = true
                checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
            } else {
                break
            }
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

    // MARK: - XP

    func computeTotalXP() -> Int {
        sessions.reduce(0) { $0 + $1.correctCount * 10 + $1.bonusXP }
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

    // MARK: - Skill mastery (1–5 levels based on session count per module)

    // Thresholds: sessions needed to reach each level boundary
    private static let levelThresholds = [0, 1, 3, 6, 10, 15]

    func skillLevel(moduleId: String) -> Int {
        let count = sessions.filter { $0.moduleId == moduleId }.count
        let thresholds = Self.levelThresholds
        for level in stride(from: thresholds.count - 1, through: 0, by: -1) {
            if count >= thresholds[level] { return level }
        }
        return 0
    }

    // Progress (0–1) within the current level toward the next.
    func skillLevelProgress(moduleId: String) -> Double {
        let count = sessions.filter { $0.moduleId == moduleId }.count
        let level = skillLevel(moduleId: moduleId)
        let thresholds = Self.levelThresholds
        if level >= thresholds.count - 1 { return 1.0 }
        let lower = thresholds[level]
        let upper = thresholds[level + 1]
        guard upper > lower else { return 1.0 }
        return Double(count - lower) / Double(upper - lower)
    }

    // MARK: - Personal best

    /// Best (correctCount, totalXP) across all prior sessions for a lesson.
    /// Returns nil if the lesson has never been attempted.
    func bestResult(for lessonId: String) -> (correctCount: Int, totalXP: Int)? {
        let prior = sessions.filter { $0.lessonId == lessonId }
        guard !prior.isEmpty else { return nil }
        let best = prior.max { a, b in
            let xpA = a.correctCount * 10 + a.bonusXP
            let xpB = b.correctCount * 10 + b.bonusXP
            return a.correctCount < b.correctCount
                || (a.correctCount == b.correctCount && xpA < xpB)
        }!
        return (best.correctCount, best.correctCount * 10 + best.bonusXP)
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
