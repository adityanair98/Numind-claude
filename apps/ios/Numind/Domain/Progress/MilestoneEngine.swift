import Foundation

/// A milestone achievement that can trigger a celebration overlay.
///
/// Phase 10: milestones celebrate CAPABILITY, never volume. The session-count
/// and level-up cases are retired; pack/world *completion* celebrations live
/// exclusively in the `Celebration` queue (PackCompletionSheet /
/// WorldCompletionSheet), so nothing double-fires.
enum Milestone: Identifiable {
    case firstSkillMastered(name: String)
    case firstPackReady(name: String)
    case threePacksReady
    case firstRefreshSave
    case firstWeekStreak
    case twoWeekStreak
    case accuracyJump(percent: Int)
    case firstFreeze

    var id: String {
        switch self {
        case .firstSkillMastered:        return "milestone_first_skill"
        case .firstPackReady:            return "milestone_first_pack_ready"
        case .threePacksReady:           return "milestone_3_packs_ready"
        case .firstRefreshSave:          return "milestone_first_refresh"
        case .firstWeekStreak:           return "milestone_7_day_streak"
        case .twoWeekStreak:             return "milestone_14_day_streak"
        case .accuracyJump(let p):       return "milestone_accuracy_\(p)"
        case .firstFreeze:               return "milestone_first_freeze"
        }
    }

    var icon: String {
        switch self {
        case .firstSkillMastered:   return "checkmark.seal.fill"
        case .firstPackReady:       return "flag.checkered"
        case .threePacksReady:      return "trophy.fill"
        case .firstRefreshSave:     return "arrow.counterclockwise.circle.fill"
        case .firstWeekStreak:      return "bolt.fill"
        case .twoWeekStreak:        return "bolt.shield.fill"
        case .accuracyJump:         return "arrow.up.right"
        case .firstFreeze:          return "snowflake"
        }
    }

    var headline: String {
        switch self {
        case .firstSkillMastered(let name): return "\(name) — Mastered!"
        case .firstPackReady(let name):     return "Ready: \(name)!"
        case .threePacksReady:              return "3 Decisions Ready!"
        case .firstRefreshSave:             return "Skill Refreshed!"
        case .firstWeekStreak:              return "7-Day Streak!"
        case .twoWeekStreak:                return "14-Day Streak!"
        case .accuracyJump(let p):          return "Accuracy Up \(p)%!"
        case .firstFreeze:                  return "Streak Freeze Earned!"
        }
    }

    var subtext: String {
        switch self {
        case .firstSkillMastered:
            return "Your first mastered money skill — the ledger starts here."
        case .firstPackReady:
            return "You've put in the reps, proven the hard ones, and held it over time. This decision is yours now."
        case .threePacksReady:
            return "Three real money decisions you can walk into prepared."
        case .firstRefreshSave:
            return "A fading skill, brought back sharp. That's how it sticks for good."
        case .firstWeekStreak:
            return "A full week of daily practice \u{2014} you've earned a streak freeze!"
        case .twoWeekStreak:
            return "Two weeks straight. You're in the top tier of learners."
        case .accuracyJump:
            return "Your answers are getting sharper. The practice is paying off."
        case .firstFreeze:
            return "Miss a day? This freeze will keep your streak alive."
        }
    }
}

/// Compares two ProgressData snapshots (plus capability inputs computed by
/// the caller) to detect new milestones. Pure — the store supplies snapshots.
enum MilestoneEngine {

    /// Returns the highest-priority unshown milestone, or nil.
    static func check(
        before: ProgressData,
        after: ProgressData,
        shownIds: Set<String>,
        beforeMastered: Set<String> = [],
        afterMastered: Set<String> = [],
        beforeReadyPackIds: Set<String> = [],
        afterReadyPackIds: Set<String> = [],
        packNames: [String: String] = [:],
        lessonNames: [String: String] = [:],
        beforeStaleCount: Int = 0,
        afterStaleCount: Int = 0,
        lastSessionLessonId: String = ""
    ) -> Milestone? {
        let candidates = allTriggered(
            before: before, after: after,
            beforeMastered: beforeMastered, afterMastered: afterMastered,
            beforeReadyPackIds: beforeReadyPackIds, afterReadyPackIds: afterReadyPackIds,
            packNames: packNames, lessonNames: lessonNames,
            beforeStaleCount: beforeStaleCount, afterStaleCount: afterStaleCount,
            lastSessionLessonId: lastSessionLessonId
        )
        return candidates.first { !shownIds.contains($0.id) }
    }

    // MARK: - Internal

    /// All milestones that fire given the transition, priority-ordered
    /// (capability first, then streak/consistency).
    private static func allTriggered(
        before: ProgressData,
        after: ProgressData,
        beforeMastered: Set<String>,
        afterMastered: Set<String>,
        beforeReadyPackIds: Set<String>,
        afterReadyPackIds: Set<String>,
        packNames: [String: String],
        lessonNames: [String: String],
        beforeStaleCount: Int,
        afterStaleCount: Int,
        lastSessionLessonId: String
    ) -> [Milestone] {
        var results: [Milestone] = []

        // First pack Ready — the activation moment.
        if beforeReadyPackIds.isEmpty, let newId = afterReadyPackIds.subtracting(beforeReadyPackIds).first {
            results.append(.firstPackReady(name: packNames[newId] ?? newId))
        }

        // Three packs Ready.
        if beforeReadyPackIds.count < 3 && afterReadyPackIds.count >= 3 {
            results.append(.threePacksReady)
        }

        // First skill mastered.
        if beforeMastered.isEmpty, let newId = afterMastered.subtracting(beforeMastered).first {
            results.append(.firstSkillMastered(name: lessonNames[newId] ?? newId))
        }

        // First refresh that actually restored a fading skill.
        if lastSessionLessonId == "refresh_review" && afterStaleCount < beforeStaleCount {
            results.append(.firstRefreshSave)
        }

        // Streak milestones.
        let beforeStreak = before.computeStreak()
        let afterStreak = after.computeStreak()
        if beforeStreak < 7 && afterStreak >= 7 {
            results.append(.firstWeekStreak)
        }
        if beforeStreak < 14 && afterStreak >= 14 {
            results.append(.twoWeekStreak)
        }

        // Streak freeze earned.
        if before.availableFreezes == 0 && after.availableFreezes > 0 {
            results.append(.firstFreeze)
        }

        // Accuracy improvement (10%+ jump, comparing last-20 sessions).
        let beforeAcc = recentAccuracy(before.sessions, window: 20)
        let afterAcc = recentAccuracy(after.sessions, window: 20)
        if let ba = beforeAcc, let aa = afterAcc {
            let delta = Int((aa - ba) * 100)
            if delta >= 10 {
                results.append(.accuracyJump(percent: delta))
            }
        }

        return results
    }

    /// Minimum questions in the trailing window before an accuracy-jump
    /// milestone can fire — guards against tiny-denominator spikes on a user's
    /// first few sessions (audit fix #28).
    private static let accuracyMinSample = 20

    private static func recentAccuracy(_ sessions: [SessionRecord], window: Int) -> Double? {
        let recent = sessions.suffix(window)
        let total = recent.reduce(0) { $0 + $1.totalCount }
        guard total >= accuracyMinSample else { return nil }
        let correct = recent.reduce(0) { $0 + $1.correctCount }
        return Double(correct) / Double(total)
    }
}
