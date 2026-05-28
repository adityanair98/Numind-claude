import Foundation

/// A point-in-time snapshot of the user's Numind Score, recorded after each session.
struct ScoreEntry: Codable {
    let date: Date
    let overallScore: Int
    /// Per-module scores at this point in time. Keyed by module ID.
    let moduleScores: [String: Int]
}

// Pure Codable value — all computation lives here so it's testable without the store.
struct ProgressData: Codable {
    var sessions: [SessionRecord] = []
    var bestStreak: Int = 0
    /// Stable set of earned badge IDs. Default empty for backward compat.
    var earnedBadgeIds: Set<String> = []
    /// Personal best for Blitz mode: highest number of correct answers in a 60-second session.
    var blitzBestScore: Int = 0
    /// Personal best for Streak mode: longest correct-answer streak in a single session.
    var streakModeBestScore: Int = 0
    /// Personal best for Speed Drill: highest correct count in a timed session.
    var speedDrillBestScore: Int = 0
    /// Personal best for Recall mode: highest correct count reviewing past misses.
    var recallBestScore: Int = 0
    /// Personal best for Estimation mode: highest correct count (2+ stars) in a session.
    var estimationBestScore: Int = 0
    /// Personal best for Comparison mode: highest score out of 15.
    var comparisonBestScore: Int = 0
    /// Timestamped Numind Score snapshots — one appended after each session.
    /// Retained for 90 days; older entries are pruned automatically.
    var scoreHistory: [ScoreEntry] = []

    /// Signals collected during the onboarding funnel.
    /// Nil for users who completed the old 3-page onboarding.
    /// Diagnostic results live here but are explicitly excluded from `sessions`.
    var onboardingSignals: OnboardingSignals?

    /// Dates where a streak freeze was applied (start-of-day normalized).
    /// These count as "active" days in streak computation.
    var frozenDates: Set<Date> = []

    /// The streak value recorded after the most recent session.
    /// Used to detect streak loss on next app launch.
    var lastKnownStreak: Int = 0

    /// Number of streak freezes currently banked (max 3).
    var availableFreezes: Int = 0

    /// How many 7-day streak milestones have been rewarded with a freeze.
    /// Prevents double-awarding when streak stays above 7.
    var freezeMilestonesAwarded: Int = 0

    /// IDs of milestones already shown to the user. Prevents repeats.
    var shownMilestoneIds: Set<String> = []

    /// The single currently-focused Life-Event Pack. Drives the Home
    /// "Continue your path" card + the pack-aware Daily Workout slot
    /// selection. Nil means the user is free-form (no path focus). Users
    /// can only have one focus at a time, but any number of packs can
    /// be "in progress" (derived from session history, not stored).
    var focusPackId: String?

    // MARK: - Streak

    /// Active days = session days ∪ frozen dates. Used by streak + helpers.
    private var activeDays: Set<Date> {
        let calendar = Calendar.current
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        return sessionDays.union(frozenDates)
    }

    func computeStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = activeDays

        // Start from today if active, otherwise from yesterday.
        var checkDay = days.contains(today)
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today)!

        // Strict consecutive days — no grace period.
        guard days.contains(checkDay) else { return 0 }

        var streak = 0
        while days.contains(checkDay) {
            streak += 1
            checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
        }
        return streak
    }

    /// The streak that existed before the current gap (if any).
    /// Walks backward past the missed days to find the last active run.
    func computePreviousStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = activeDays

        // Skip today, walk back to find the first active day past the gap.
        var day = calendar.date(byAdding: .day, value: -1, to: today)!
        var gapDays = 0
        while !days.contains(day) {
            gapDays += 1
            // Don't scan more than 7 days back.
            guard gapDays <= 7 else { return 0 }
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        // Count the streak from this active day backward.
        var streak = 0
        while days.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    /// The missed dates between the last active day and today.
    /// Only returns dates within the last 3 days (revival window).
    func missedDates() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = activeDays

        var missed: [Date] = []
        var day = calendar.date(byAdding: .day, value: -1, to: today)!
        while !days.contains(day) && today.timeIntervalSince(day) <= 3 * 86400 {
            missed.append(day)
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return missed
    }

    /// Most recent session date.
    var lastSessionDate: Date? {
        sessions.map(\.date).max()
    }

    mutating func freezeDate(_ date: Date) {
        frozenDates.insert(Calendar.current.startOfDay(for: date))
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
        // Exclude review/checkpoint sessions — they share moduleId but aren't lessons.
        Set(sessions.filter { $0.moduleId == moduleId && !$0.isReviewSession }
            .map { $0.lessonId }).count
    }

    func moduleProgress(moduleId: String, totalLessons: Int) -> Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessonCount(moduleId: moduleId)) / Double(totalLessons)
    }

    func hasCompletedLesson(_ lessonId: String) -> Bool {
        sessions.contains { $0.lessonId == lessonId }
    }

    /// Returns true if the user has ever scored ≥ 75% on this lesson.
    /// 75% = the mastery threshold (6/8 correct).
    func hasMasteredLesson(_ lessonId: String) -> Bool {
        sessions.contains {
            $0.lessonId == lessonId
                && $0.totalCount > 0
                && Double($0.correctCount) / Double($0.totalCount) >= 0.75
        }
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

    // MARK: - Blitz best score

    /// Updates blitzBestScore if the new score exceeds the current record.
    mutating func updateBlitzBest(score: Int) {
        if score > blitzBestScore { blitzBestScore = score }
    }

    /// Updates streakModeBestScore if the new streak exceeds the current record.
    mutating func updateStreakBest(score: Int) {
        if score > streakModeBestScore { streakModeBestScore = score }
    }

    mutating func updateSpeedDrillBest(score: Int) {
        if score > speedDrillBestScore { speedDrillBestScore = score }
    }

    mutating func updateRecallBest(score: Int) {
        if score > recallBestScore { recallBestScore = score }
    }

    mutating func updateEstimationBest(score: Int) {
        if score > estimationBestScore { estimationBestScore = score }
    }

    mutating func updateComparisonBest(score: Int) {
        if score > comparisonBestScore { comparisonBestScore = score }
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

    // MARK: - Weekly XP history (last 4 weeks, oldest → newest)

    /// Returns 4 entries ordered oldest → newest. isCurrent = true for the live week.
    func weeklyXPHistory() -> [(label: String, xp: Int, isCurrent: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        // Anchor to Monday of the current week (matches computeWeeklyCompletions)
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2 // Monday
        let currentMonday = calendar.date(from: comps) ?? today

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        // weekOffset: 3 = oldest, 0 = current — reversed() gives [3,2,1,0] → chronological
        return (0..<4).reversed().map { weekOffset in
            let weekStart = calendar.date(
                byAdding: .weekOfYear, value: -weekOffset, to: currentMonday
            ) ?? currentMonday
            let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? weekStart
            let xp = sessions
                .filter { $0.date >= weekStart && $0.date < weekEnd }
                .reduce(0) { $0 + $1.correctCount * 10 + $1.bonusXP }
            return (
                label: weekOffset == 0 ? "This week" : formatter.string(from: weekStart),
                xp: xp,
                isCurrent: weekOffset == 0
            )
        }
    }
}
