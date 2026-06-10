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
        // Exclude review sessions from lesson/module uniqueness counts so badges
        // reflect actual lesson breadth, not review repetition.
        let realSessions  = sessions.filter { !$0.isReviewSession }
        let uniqueLessons = Set(realSessions.map(\.lessonId)).count
        let uniqueModules = Set(realSessions.map(\.moduleId)).count

        // MARK: Starter
        if sessionCount >= 1 { ids.insert("first_session") }

        let perfectSessions = sessions.filter {
            $0.correctCount == $0.totalCount && $0.totalCount >= 3
        }
        if !perfectSessions.isEmpty { ids.insert("first_perfect") }
        if perfectSessions.count >= 3 { ids.insert("triple_perfect") }

        // A "speed" session = one with ≥1 fast correct answer (<10s), measured
        // directly from question results so these badges survive the Phase 9
        // removal of speed-bonus XP (which previously fed `bonusXP`).
        let speedSessions = sessions.filter { session in
            session.questionResults.contains { $0.isCorrect && $0.timeSpentSeconds < 10 }
        }
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

        // MARK: Volume (Phase 6a — retired questions_500, xp_500, xp_1000
        // as redundant cumulative-grind badges)
        if totalQs >= 100    { ids.insert("questions_100") }
        if sessionCount >= 10 { ids.insert("sessions_10") }
        if sessionCount >= 25 { ids.insert("sessions_25") }

        // MARK: Early momentum (Phase 10 — question-count trigger replaces the
        // retired visible-XP framing; id kept for earned-set compatibility)
        if totalQs >= 10 { ids.insert("xp_100") }

        // MARK: Breadth
        if uniqueLessons >= 5 { ids.insert("lessons_5") }
        if uniqueModules >= 3 { ids.insert("multi_module") }

        // MARK: Retention (Phase 6a — rewards the actual product promise:
        // do you remember this when the gap re-tests you?)
        if rememberedTemplateCount(in: sessions) >= 5 { ids.insert("remembered_5") }

        // MARK: Real-world (Phase 6a — rewards accuracy on scenario-eligible
        // questions, the closest proxy for "would handle this in real life")
        if scenarioAccuracy(in: sessions).qualifies { ids.insert("real_world") }

        return ids
    }

    /// Count of distinct templates where the user got the question right
    /// after a ≥14-day gap since the prior attempt. The user demonstrably
    /// remembered the math, not just memorized it in the moment.
    private static func rememberedTemplateCount(in sessions: [SessionRecord]) -> Int {
        // Group attempts by template, in chronological order.
        var perTemplate: [String: [(date: Date, isCorrect: Bool)]] = [:]
        for session in sessions.sorted(by: { $0.date < $1.date }) {
            for qr in session.questionResults {
                perTemplate[qr.templateId, default: []].append(
                    (date: session.date, isCorrect: qr.isCorrect)
                )
            }
        }
        var count = 0
        for (_, attempts) in perTemplate where attempts.count >= 2 {
            // Look for ANY adjacent pair separated by ≥14 days where the
            // later attempt is correct.
            var earned = false
            for i in 1..<attempts.count {
                let gap = attempts[i].date.timeIntervalSince(attempts[i - 1].date) / 86_400
                if gap >= 14 && attempts[i].isCorrect {
                    earned = true
                    break
                }
            }
            if earned { count += 1 }
        }
        return count
    }

    /// Accuracy across scenario-eligible question results, plus the count.
    /// "Real-world" badge requires ≥10 attempts at ≥80% accuracy.
    private static func scenarioAccuracy(
        in sessions: [SessionRecord]
    ) -> (qualifies: Bool, count: Int, accuracy: Double) {
        let repo = LocalContentRepository()
        var total = 0
        var correct = 0
        for session in sessions {
            for qr in session.questionResults {
                guard let lesson = repo.lesson(forTemplateId: qr.templateId),
                      lesson.isScenarioEligible else { continue }
                total += 1
                if qr.isCorrect { correct += 1 }
            }
        }
        guard total > 0 else { return (false, 0, 0) }
        let acc = Double(correct) / Double(total)
        return (qualifies: total >= 10 && acc >= 0.80, count: total, accuracy: acc)
    }
}
