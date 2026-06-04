import Foundation

/// A milestone achievement that can trigger a celebration overlay.
enum Milestone: Identifiable {
    case firstSession
    case fiveSessions
    case tenSessions
    case firstWeekStreak
    case twoWeekStreak
    case accuracyJump(percent: Int)
    case levelUp(level: Int)
    case moduleCompleted(name: String)
    case firstFreeze

    var id: String {
        switch self {
        case .firstSession:              return "milestone_first_session"
        case .fiveSessions:              return "milestone_5_sessions"
        case .tenSessions:               return "milestone_10_sessions"
        case .firstWeekStreak:           return "milestone_7_day_streak"
        case .twoWeekStreak:             return "milestone_14_day_streak"
        case .accuracyJump(let p):       return "milestone_accuracy_\(p)"
        case .levelUp(let l):            return "milestone_level_\(l)"
        case .moduleCompleted(let n):    return "milestone_module_\(n)"
        case .firstFreeze:               return "milestone_first_freeze"
        }
    }

    var icon: String {
        switch self {
        case .firstSession:         return "star.fill"
        case .fiveSessions:         return "flame.fill"
        case .tenSessions:          return "medal.fill"
        case .firstWeekStreak:      return "bolt.fill"
        case .twoWeekStreak:        return "bolt.shield.fill"
        case .accuracyJump:         return "arrow.up.right"
        case .levelUp:              return "chevron.up.circle.fill"
        case .moduleCompleted:      return "checkmark.seal.fill"
        case .firstFreeze:          return "snowflake"
        }
    }

    var headline: String {
        switch self {
        case .firstSession:              return "First Session Complete!"
        case .fiveSessions:              return "5 Sessions Down!"
        case .tenSessions:               return "10 Sessions Strong!"
        case .firstWeekStreak:           return "7-Day Streak!"
        case .twoWeekStreak:             return "14-Day Streak!"
        case .accuracyJump(let p):       return "Accuracy Up \(p)%!"
        case .levelUp(let l):            return "Level \(l) Reached!"
        case .moduleCompleted(let name): return "\(name) Complete!"
        case .firstFreeze:               return "Streak Freeze Earned!"
        }
    }

    var subtext: String {
        switch self {
        case .firstSession:
            return "You've taken the first step. Every expert started here."
        case .fiveSessions:
            return "You're building real momentum. Keep going!"
        case .tenSessions:
            return "Double digits! Your money sense is growing fast."
        case .firstWeekStreak:
            return "A full week of daily practice \u{2014} you've earned a streak freeze!"
        case .twoWeekStreak:
            return "Two weeks straight. You're in the top tier of learners."
        case .accuracyJump:
            return "Your answers are getting sharper. The practice is paying off."
        case .levelUp(let l):
            if l >= 12 { return "Elite territory. Your money sense is seriously sharp." }
            if l >= 8 { return "Real fluency is forming \u{2014} and the depth is showing." }
            return "Your reps are adding up. Keep the momentum going."
        case .moduleCompleted:
            return "Every lesson finished! You've mastered this topic."
        case .firstFreeze:
            return "Miss a day? This freeze will keep your streak alive."
        }
    }
}

/// Compares two ProgressData snapshots to detect new milestones.
enum MilestoneEngine {

    /// Returns the highest-priority unshown milestone, or nil.
    ///
    /// `moduleLessonCounts` maps module ID to its total non-review lesson count;
    /// required for accurate module-completion detection. If a module is missing,
    /// completion will never fire for it.
    static func check(
        before: ProgressData,
        after: ProgressData,
        shownIds: Set<String>,
        moduleNames: [String: String] = [:],
        moduleLessonCounts: [String: Int] = [:],
        beforeLevel: Int = 0,
        afterLevel: Int = 0
    ) -> Milestone? {
        let candidates = allTriggered(
            before: before,
            after: after,
            moduleNames: moduleNames,
            moduleLessonCounts: moduleLessonCounts,
            beforeLevel: beforeLevel,
            afterLevel: afterLevel
        )
        return candidates.first { !shownIds.contains($0.id) }
    }

    /// Levels that trigger a celebration overlay (Phase 9 — replaced the
    /// composite 25/50/75 thresholds). Front-loaded then sparser so the
    /// celebration stays meaningful as XP scales.
    static let celebratedLevels = [3, 5, 8, 10, 12, 15]

    // MARK: - Internal

    /// All milestones that fire given the before/after transition, priority-ordered.
    private static func allTriggered(
        before: ProgressData,
        after: ProgressData,
        moduleNames: [String: String],
        moduleLessonCounts: [String: Int],
        beforeLevel: Int,
        afterLevel: Int
    ) -> [Milestone] {
        var results: [Milestone] = []

        let beforeCount = before.sessions.count
        let afterCount = after.sessions.count

        // Session count milestones
        if beforeCount < 1 && afterCount >= 1 {
            results.append(.firstSession)
        }
        if beforeCount < 5 && afterCount >= 5 {
            results.append(.fiveSessions)
        }
        if beforeCount < 10 && afterCount >= 10 {
            results.append(.tenSessions)
        }

        // Streak milestones
        let beforeStreak = before.computeStreak()
        let afterStreak = after.computeStreak()
        if beforeStreak < 7 && afterStreak >= 7 {
            results.append(.firstWeekStreak)
        }
        if beforeStreak < 14 && afterStreak >= 14 {
            results.append(.twoWeekStreak)
        }

        // Streak freeze earned
        if before.availableFreezes == 0 && after.availableFreezes > 0 {
            results.append(.firstFreeze)
        }

        // Level-up milestones (Phase 9 — replaced composite score thresholds).
        for milestoneLevel in celebratedLevels {
            if beforeLevel < milestoneLevel && afterLevel >= milestoneLevel {
                results.append(.levelUp(level: milestoneLevel))
            }
        }

        // Accuracy improvement (10%+ jump, comparing last-20 sessions)
        let beforeAcc = recentAccuracy(before.sessions, window: 20)
        let afterAcc = recentAccuracy(after.sessions, window: 20)
        if let ba = beforeAcc, let aa = afterAcc {
            let delta = Int((aa - ba) * 100)
            if delta >= 10 {
                results.append(.accuracyJump(percent: delta))
            }
        }

        // Module completion — fires only when the user completes the FINAL lesson of a module.
        // Requires moduleLessonCounts to be supplied; without it, completion can never trigger.
        let allModuleIds = Set(after.sessions.map(\.moduleId))
        for moduleId in allModuleIds {
            guard let totalLessons = moduleLessonCounts[moduleId], totalLessons > 0 else { continue }
            let beforeLessons = Set(before.sessions.filter { $0.moduleId == moduleId && !$0.isReviewSession }.map(\.lessonId))
            let afterLessons = Set(after.sessions.filter { $0.moduleId == moduleId && !$0.isReviewSession }.map(\.lessonId))
            // Fire exactly once: the transition from < totalLessons to == totalLessons.
            let crossedThreshold = beforeLessons.count < totalLessons && afterLessons.count >= totalLessons
            if crossedThreshold {
                let name = moduleNames[moduleId] ?? moduleId
                results.append(.moduleCompleted(name: name))
            }
        }

        return results
    }

    private static func recentAccuracy(_ sessions: [SessionRecord], window: Int) -> Double? {
        let recent = sessions.suffix(window)
        let total = recent.reduce(0) { $0 + $1.totalCount }
        guard total > 0 else { return nil }
        let correct = recent.reduce(0) { $0 + $1.correctCount }
        return Double(correct) / Double(total)
    }
}
