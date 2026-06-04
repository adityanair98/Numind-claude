import Foundation

/// Pure functions that derive user-friendly improvement stats from ProgressData.
/// All comparisons are current-week vs 2-weeks-ago to smooth noise.
enum ImprovementCalculator {

    struct Stats {
        /// Average response time this week (seconds), nil if no sessions.
        let avgSpeedThisWeek: Double?
        /// Average response time 2 weeks ago (seconds), nil if no sessions.
        let avgSpeedPrior: Double?
        /// Accuracy this week (0–1), nil if no sessions.
        let accuracyThisWeek: Double?
        /// Accuracy 2 weeks ago (0–1), nil if no sessions.
        let accuracyPrior: Double?
        /// Number of unique templates where lifetime accuracy ≥ 80%.
        let skillsMastered: Int
        /// XP earned this week (Phase 9 — replaced the legacy Numind-Score delta).
        let xpThisWeek: Int
        /// Total sessions this week.
        let sessionsThisWeek: Int
        /// Total sessions 2 weeks ago.
        let sessionsPrior: Int
    }

    // MARK: - Public

    static func compute(from data: ProgressData, xpThisWeek: Int) -> Stats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Week boundaries (Mon–Sun)
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2 // Monday
        let thisMonday = calendar.date(from: comps) ?? today
        let lastMonday = calendar.date(byAdding: .weekOfYear, value: -1, to: thisMonday)!
        let twoWeeksAgoMonday = calendar.date(byAdding: .weekOfYear, value: -2, to: thisMonday)!

        let thisWeek = data.sessions.filter { $0.date >= thisMonday }
        let priorWeek = data.sessions.filter { $0.date >= twoWeeksAgoMonday && $0.date < lastMonday }

        return Stats(
            avgSpeedThisWeek: avgSpeed(thisWeek),
            avgSpeedPrior: avgSpeed(priorWeek),
            accuracyThisWeek: accuracy(thisWeek),
            accuracyPrior: accuracy(priorWeek),
            skillsMastered: countMasteredTemplates(data.sessions),
            xpThisWeek: xpThisWeek,
            sessionsThisWeek: thisWeek.count,
            sessionsPrior: priorWeek.count
        )
    }

    // MARK: - Trend helpers

    /// Speed improvement as a positive percentage (e.g. 12 means "12% faster"),
    /// or nil if either period has no data.
    static func speedImprovement(_ stats: Stats) -> Int? {
        guard let current = stats.avgSpeedThisWeek,
              let prior = stats.avgSpeedPrior,
              prior > 0 else { return nil }
        let pct = Int(((prior - current) / prior) * 100)
        return pct > 0 ? pct : nil // Only surface positive trends
    }

    /// Accuracy improvement as a positive percentage-point jump (e.g. 8 means "+8%"),
    /// or nil if either period has no data.
    static func accuracyImprovement(_ stats: Stats) -> Int? {
        guard let current = stats.accuracyThisWeek,
              let prior = stats.accuracyPrior else { return nil }
        let delta = Int((current - prior) * 100)
        return delta > 0 ? delta : nil
    }

    // MARK: - Internal

    private static func avgSpeed(_ sessions: [SessionRecord]) -> Double? {
        let results = sessions.flatMap(\.questionResults)
        guard !results.isEmpty else { return nil }
        return results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
    }

    private static func accuracy(_ sessions: [SessionRecord]) -> Double? {
        let total = sessions.reduce(0) { $0 + $1.totalCount }
        guard total > 0 else { return nil }
        let correct = sessions.reduce(0) { $0 + $1.correctCount }
        return Double(correct) / Double(total)
    }

    /// Count unique template IDs where the user has ≥ 80% accuracy (lifetime).
    private static func countMasteredTemplates(_ sessions: [SessionRecord]) -> Int {
        var templateStats: [String: (correct: Int, total: Int)] = [:]
        for session in sessions {
            for qr in session.questionResults {
                var entry = templateStats[qr.templateId, default: (0, 0)]
                entry.total += 1
                if qr.isCorrect { entry.correct += 1 }
                templateStats[qr.templateId] = entry
            }
        }
        return templateStats.values.filter { $0.total >= 3 && Double($0.correct) / Double($0.total) >= 0.8 }.count
    }
}
