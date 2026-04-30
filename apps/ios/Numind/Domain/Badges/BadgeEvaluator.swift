import Foundation

/// Pure evaluation — computes which badges are earned given a ProgressData snapshot.
/// Every criterion is derivable from the existing SessionRecord / QuestionResult data;
/// no new persistence is required.
enum BadgeEvaluator {

    static func earned(from data: ProgressData) -> Set<String> {
        var ids = Set<String>()
        let sessions      = data.sessions
        let sessionCount  = sessions.count
        let totalQs       = sessions.reduce(0) { $0 + $1.totalCount }
        let accuracy      = data.computeAccuracy()
        let xp            = data.computeTotalXP()
        let streak        = data.computeStreak()
        let uniqueLessons = Set(sessions.map(\.lessonId)).count
        let uniqueModules = Set(sessions.map(\.moduleId)).count

        // MARK: Starter
        if sessionCount >= 1 { ids.insert("first_session") }

        let perfectSessions = sessions.filter {
            $0.correctCount == $0.totalCount && $0.totalCount >= 3
        }
        if !perfectSessions.isEmpty { ids.insert("first_perfect") }
        if perfectSessions.count >= 3 { ids.insert("triple_perfect") }

        let speedSessions = sessions.filter { $0.bonusXP > 0 }
        if !speedSessions.isEmpty { ids.insert("first_speed_bonus") }
        if speedSessions.count >= 5 { ids.insert("speed_5_sessions") }

        // Flash Five: 5+ correct answers each under 5 s, within a single session
        let hasFastFive = sessions.contains { session in
            session.questionResults.filter {
                $0.isCorrect && $0.timeSpentSeconds < 5
            }.count >= 5
        }
        if hasFastFive { ids.insert("fast_five") }

        // MARK: Streak
        if streak >= 3  { ids.insert("streak_3") }
        if streak >= 7  { ids.insert("streak_7") }
        if streak >= 14 { ids.insert("streak_14") }

        // MARK: Accuracy (meaningful only with ≥ 20 questions answered)
        if totalQs >= 20 && accuracy >= 0.80 { ids.insert("accuracy_80") }
        if totalQs >= 20 && accuracy >= 0.90 { ids.insert("accuracy_90") }

        // MARK: Volume
        if totalQs >= 100    { ids.insert("questions_100") }
        if totalQs >= 500    { ids.insert("questions_500") }
        if sessionCount >= 10 { ids.insert("sessions_10") }
        if sessionCount >= 25 { ids.insert("sessions_25") }

        // MARK: XP
        if xp >= 100  { ids.insert("xp_100") }
        if xp >= 500  { ids.insert("xp_500") }
        if xp >= 1000 { ids.insert("xp_1000") }

        // MARK: Breadth
        if uniqueLessons >= 5 { ids.insert("lessons_5") }
        if uniqueModules >= 3 { ids.insert("multi_module") }

        return ids
    }
}
