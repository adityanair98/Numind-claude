import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    private static let defaultsKey       = "numind.progress.v2"
    private static let legacyDefaultsKey = "numind.progress.v1"
    private static let dailyChallengeKey = "numind.dailyChallenge.lastCompleted"
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    @Published private(set) var data: ProgressData
    @Published private(set) var dailyChallengeCompletedDate: String
    /// Badge IDs earned in the most-recent recordSession call. Cleared on the next call.
    @Published private(set) var newlyEarnedBadgeIds: Set<String> = []
    /// Milestone triggered by the most-recent recordSession call. Nil if none.
    @Published private(set) var pendingMilestone: Milestone?
    /// FIFO queue of celebrations to show post-session. Multiple can stack
    /// (e.g. a lesson that simultaneously completes a focus pack AND a world
    /// queues both, with the pack first per the spec). UI pops one at a time.
    @Published private(set) var pendingCelebrations: [Celebration] = []

    init() {
        // v2 read path.
        if let raw = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: raw) {
            data = decoded
        } else if let legacyRaw = UserDefaults.standard.data(forKey: Self.legacyDefaultsKey),
                  var decoded = try? JSONDecoder().decode(ProgressData.self, from: legacyRaw) {
            // v1 → v2 migration: sessions/badges/freezes survive; scoreHistory
            // is dropped so it recomputes on next session under the new
            // axis-based engine. We don't yet have real users, so this is a
            // dev-data safety net (not a user-facing migration).
            decoded.scoreHistory = []
            data = decoded
        } else {
            data = ProgressData()
        }
        dailyChallengeCompletedDate = UserDefaults.standard.string(forKey: Self.dailyChallengeKey) ?? ""
    }

    // MARK: - Write

    func recordSession(_ record: SessionRecord) {
        let snapshotBefore = data
        let previouslyEarned = data.earnedBadgeIds
        // Snapshot pre-session mastery to detect first-time completions
        // (pack / world) AFTER the session is recorded.
        let masteredBefore = masteredLessonIds
        data.sessions.append(record)
        let current = data.computeStreak()
        if current > data.bestStreak {
            data.bestStreak = current
        }
        // Snapshot the streak so we can detect loss on next launch.
        data.lastKnownStreak = current

        // Award streak freezes for every 7-day milestone.
        let milestoneCount = current / 7
        if milestoneCount > data.freezeMilestonesAwarded {
            let newFreezes = milestoneCount - data.freezeMilestonesAwarded
            data.availableFreezes = min(3, data.availableFreezes + newFreezes)
            data.freezeMilestonesAwarded = milestoneCount
        }

        let nowEarned = BadgeEvaluator.earned(from: data)
        newlyEarnedBadgeIds = nowEarned.subtracting(previouslyEarned)
        data.earnedBadgeIds = nowEarned
        // Recompute Numind Score after every session so the radar + score ring
        // always reflect the latest performance without extra callsite boilerplate.
        let repo = LocalContentRepository()
        let moduleIds = repo.allModules().map(\.id)
        recomputeAndStoreScore(moduleIds: moduleIds)
        // persist() is called inside recomputeAndStoreScore — no double write needed.

        // Check for milestone celebrations.
        let allModules = repo.allModules()
        let moduleNames = Dictionary(uniqueKeysWithValues: allModules.map { ($0.id, $0.title) })
        let moduleLessonCounts = Dictionary(uniqueKeysWithValues: allModules.map { ($0.id, $0.lessonIds.count) })
        pendingMilestone = MilestoneEngine.check(
            before: snapshotBefore,
            after: data,
            shownIds: data.shownMilestoneIds,
            moduleNames: moduleNames,
            moduleLessonCounts: moduleLessonCounts
        )

        // Detect newly-completed packs and worlds for the celebration queue.
        // Pack celebration fires first when both a pack and a world complete
        // in the same session (per the spec).
        let masteredAfter = masteredLessonIds
        let newlyMastered = masteredAfter.subtracting(masteredBefore)
        if !newlyMastered.isEmpty {
            enqueueCompletionCelebrations(
                newlyMastered: newlyMastered,
                masteredAfter: masteredAfter,
                masteredBefore: masteredBefore
            )
        }
    }

    private func enqueueCompletionCelebrations(
        newlyMastered: Set<String>,
        masteredAfter: Set<String>,
        masteredBefore: Set<String>
    ) {
        let repo = LocalContentRepository()
        var newCelebrations: [Celebration] = []

        // Pack completion: any pack whose lesson set is fully covered by
        // masteredAfter, but wasn't before.
        for pack in repo.allPacks() {
            let lessons = Set(pack.lessonIds)
            let doneAfter = lessons.intersection(masteredAfter).count
            let doneBefore = lessons.intersection(masteredBefore).count
            if doneAfter == lessons.count && doneBefore < lessons.count {
                newCelebrations.append(.packCompleted(pack))
            }
        }

        // World completion: any module whose non-review lessons are all
        // mastered now, but weren't before. We check only lesson-mastery
        // (reviews are separate gates).
        for module in repo.allModules() {
            let lessons = Set(module.lessonIds)
            let doneAfter = lessons.intersection(masteredAfter).count
            let doneBefore = lessons.intersection(masteredBefore).count
            if doneAfter == lessons.count && doneBefore < lessons.count {
                newCelebrations.append(.worldCompleted(module))
            }
        }

        // Append all newly-detected celebrations to the queue (FIFO).
        // Pack-completed entries come first by construction (we iterate packs
        // before modules), matching the spec's sequential ordering rule.
        pendingCelebrations.append(contentsOf: newCelebrations)
    }

    /// Removes and returns the next celebration to show, or nil if empty.
    func popCelebration() -> Celebration? {
        guard !pendingCelebrations.isEmpty else { return nil }
        return pendingCelebrations.removeFirst()
    }

    func reset() {
        data = ProgressData()
        UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
        UserDefaults.standard.removeObject(forKey: Self.dailyChallengeKey)
        dailyChallengeCompletedDate = ""
    }

    // MARK: - Daily challenge

    var isDailyChallengeCompleted: Bool {
        dailyChallengeCompletedDate == Self.dateFormatter.string(from: Date())
    }

    func markDailyChallengeCompleted() {
        let today = Self.dateFormatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: Self.dailyChallengeKey)
        dailyChallengeCompletedDate = today
    }

    private func persist() {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: Self.defaultsKey)
    }

    // MARK: - Streak revival

    /// True when the user had a streak > 1 that has now dropped to 0,
    /// and the last session was recent enough to allow revival (≤ 2 days).
    var isStreakLost: Bool {
        let current = data.computeStreak()
        guard current == 0, data.lastKnownStreak > 1 else { return false }
        // Only allow revival if last session was within 2 days.
        guard let lastDate = data.lastSessionDate else { return false }
        let gap = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 999
        return gap <= 3
    }

    /// The streak the user had before it was lost.
    var lostStreakCount: Int { data.lastKnownStreak }

    /// The streak that existed before the current gap.
    var previousStreak: Int { data.computePreviousStreak() }

    /// Most recent session date.
    var lastSessionDate: Date? { data.lastSessionDate }

    /// Freeze the missed dates to revive the streak, then snapshot.
    func reviveStreak() {
        for date in data.missedDates() {
            data.freezeDate(date)
        }
        let current = data.computeStreak()
        if current > data.bestStreak {
            data.bestStreak = current
        }
        data.lastKnownStreak = current
        persist()
    }

    /// Accept the streak loss — reset lastKnownStreak so the loss screen
    /// doesn't re-trigger. Also resets freeze milestones so a new streak
    /// earns freezes from scratch.
    func acceptStreakLoss() {
        data.lastKnownStreak = 0
        data.freezeMilestonesAwarded = 0
        persist()
    }

    /// Attempts to auto-apply banked freezes for missed days, preserving the streak.
    /// Returns `true` if at least one freeze was used (streak saved).
    func autoApplyFreeze() -> Bool {
        let missed = data.missedDates()
        guard !missed.isEmpty, data.availableFreezes > 0 else { return false }

        for date in missed {
            guard data.availableFreezes > 0 else { break }
            data.freezeDate(date)
            data.availableFreezes -= 1
        }

        let current = data.computeStreak()
        if current > data.bestStreak { data.bestStreak = current }
        data.lastKnownStreak = current
        persist()
        return true
    }

    /// Number of streak freezes currently banked (max 3).
    var availableFreezes: Int { data.availableFreezes }

    // MARK: - Milestones

    /// Marks a milestone as shown so it won't fire again.
    func markMilestoneShown(_ milestone: Milestone) {
        data.shownMilestoneIds.insert(milestone.id)
        pendingMilestone = nil
        persist()
    }

    #if DEBUG
    /// Sets lastKnownStreak to a given value without any sessions,
    /// so the streak loss screen triggers on next check.
    func simulateStreakLoss(previousStreak: Int) {
        data.lastKnownStreak = previousStreak
        persist()
    }
    #endif

    // MARK: - Onboarding signals

    func saveOnboardingSignals(_ signals: OnboardingSignals) {
        data.onboardingSignals = signals
        persist()
    }

    // MARK: - Blitz personal best

    var blitzBest: Int { data.blitzBestScore }

    func updateBlitzBest(score: Int) {
        guard score > data.blitzBestScore else { return }
        data.updateBlitzBest(score: score)
        persist()
    }

    // MARK: - Streak mode personal best

    var streakModeBest: Int { data.streakModeBestScore }

    func updateStreakBest(score: Int) {
        guard score > data.streakModeBestScore else { return }
        data.updateStreakBest(score: score)
        persist()
    }

    // MARK: - Speed Drill personal best

    var speedDrillBest: Int { data.speedDrillBestScore }

    func updateSpeedDrillBest(score: Int) {
        guard score > data.speedDrillBestScore else { return }
        data.updateSpeedDrillBest(score: score)
        persist()
    }

    // MARK: - Recall personal best

    var recallBest: Int { data.recallBestScore }

    func updateRecallBest(score: Int) {
        guard score > data.recallBestScore else { return }
        data.updateRecallBest(score: score)
        persist()
    }

    // MARK: - Estimation personal best

    var estimationBest: Int { data.estimationBestScore }

    func updateEstimationBest(score: Int) {
        guard score > data.estimationBestScore else { return }
        data.updateEstimationBest(score: score)
        persist()
    }

    // MARK: - Comparison personal best

    var comparisonBest: Int { data.comparisonBestScore }

    func updateComparisonBest(score: Int) {
        guard score > data.comparisonBestScore else { return }
        data.updateComparisonBest(score: score)
        persist()
    }

    // MARK: - Computed (forwarded from ProgressData)

    var streak: Int               { data.computeStreak() }
    var bestStreak: Int           { data.bestStreak }
    var totalSessions: Int        { data.sessions.count }
    var totalXP: Int              { data.computeTotalXP() }
    var accuracy: Double          { data.computeAccuracy() }
    var weeklyCompletions: [Bool] { data.computeWeeklyCompletions() }
    var weeklyWorkouts: Int       { data.computeWeeklyWorkouts() }
    let weeklyGoal: Int = 5

    func moduleProgress(moduleId: String, totalLessons: Int) -> Double {
        data.moduleProgress(moduleId: moduleId, totalLessons: totalLessons)
    }

    func completedLessonCount(moduleId: String) -> Int {
        data.completedLessonCount(moduleId: moduleId)
    }

    func hasCompletedLesson(_ lessonId: String) -> Bool {
        data.hasCompletedLesson(lessonId)
    }

    func hasMasteredLesson(_ lessonId: String) -> Bool {
        data.hasMasteredLesson(lessonId)
    }

    func skillLevel(moduleId: String) -> Int {
        data.skillLevel(moduleId: moduleId)
    }

    func skillLevelProgress(moduleId: String) -> Double {
        data.skillLevelProgress(moduleId: moduleId)
    }

    /// Most-recent sessions, newest first.
    func recentSessions(limit: Int = 5) -> [SessionRecord] {
        Array(data.sessions.suffix(limit).reversed())
    }

    func weeklyXPHistory() -> [(label: String, xp: Int, isCurrent: Bool)] {
        data.weeklyXPHistory()
    }

    /// Best accuracy (0–1) across all attempts of a lesson, or nil if never attempted.
    func bestAccuracy(lessonId: String) -> Double? {
        let s = data.sessions.filter { $0.lessonId == lessonId }
        guard !s.isEmpty else { return nil }
        return s.map { Double($0.correctCount) / Double(max($0.totalCount, 1)) }.max()
    }

    // MARK: - Daily challenge stats

    /// Total correct answers across today's daily challenge sub-sessions.
    var todayDailyChallengeCorrectCount: Int {
        let cal = Calendar.current
        return data.sessions
            .filter { $0.lessonId == "daily_challenge" && cal.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.correctCount }
    }

    // MARK: - Focus Pack

    /// The user's current focus pack id, or nil if free-form.
    var focusPackId: String? { data.focusPackId }

    /// Resolve the current focus pack object (nil if unset or stale).
    var focusPack: Pack? {
        guard let id = data.focusPackId else { return nil }
        return LocalContentRepository().pack(id: id)
    }

    /// Set or replace the user's focus pack. Pass `nil` to clear.
    func setFocusPack(_ packId: String?) {
        data.focusPackId = packId
        persist()
    }

    /// Convenience: clear the focus pack.
    func clearFocusPack() { setFocusPack(nil) }

    /// Mastered-lesson IDs across all sessions. Derived; not stored.
    var masteredLessonIds: Set<String> {
        // A lesson is mastered iff any prior session for it scored >= 75%.
        var ids: Set<String> = []
        for session in data.sessions {
            guard session.totalCount > 0 else { continue }
            let acc = Double(session.correctCount) / Double(session.totalCount)
            if acc >= 0.75 { ids.insert(session.lessonId) }
        }
        return ids
    }

    /// Mastered/total for a specific pack id.
    func packProgress(packId: String) -> (done: Int, total: Int) {
        guard let pack = LocalContentRepository().pack(id: packId) else {
            return (0, 0)
        }
        return LocalContentRepository().packProgress(pack, masteredLessonIds: masteredLessonIds)
    }

    /// All packs the user has touched but not yet completed.
    var inProgressPacks: [Pack] {
        LocalContentRepository().inProgressPacks(masteredLessonIds: masteredLessonIds)
    }

    // MARK: - Numind Score

    /// Current overall Numind Score (0–100). 0 if no score has been computed yet.
    var numindScore: Int { data.scoreHistory.last?.overallScore ?? 0 }

    /// Latest score for a specific module (0–100). 0 if never computed.
    /// Compatibility shim: in the 7-axis world we average the lessons'
    /// primary-axis scores from the most recent snapshot.
    func numindScore(for moduleId: String) -> Int {
        guard let entry = data.scoreHistory.last else { return 0 }
        // Map module → primary axes of its lessons.
        let lessons = LocalContentRepository().lessons(for: moduleId)
        let primaryAxes = Set(lessons.compactMap { $0.primarySkill?.rawValue })
        let scores = primaryAxes.compactMap { entry.axisScores[$0] }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    /// Module score from the nearest snapshot at or before `daysAgo` days ago.
    /// Returns nil if no snapshot exists that far back.
    func numindScoreHistory(for moduleId: String, daysAgo: Int) -> Int? {
        let cutoff = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        guard let entry = data.scoreHistory
            .filter({ $0.date <= cutoff })
            .max(by: { $0.date < $1.date })
        else { return nil }
        let lessons = LocalContentRepository().lessons(for: moduleId)
        let primaryAxes = Set(lessons.compactMap { $0.primarySkill?.rawValue })
        let scores = primaryAxes.compactMap { entry.axisScores[$0] }
        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / scores.count
    }

    /// Latest score for a specific skill axis (0–100). 0 if never computed.
    func numindScore(forAxis axis: SkillAxis) -> Int {
        data.scoreHistory.last?.axisScores[axis.rawValue] ?? 0
    }

    /// Axis evidence level (Untested / Early Read / Developing / Reliable),
    /// recomputed lazily from current sessions (cheap; bounded by axis count).
    func numindEvidence(forAxis axis: SkillAxis) -> EvidenceLevel {
        let results = NumindScoreEngine.axisResults(
            sessions: sessionsWithDrillAttribution(),
            repository: LocalContentRepository()
        )
        return results.first { $0.axis == axis }?.evidence ?? .untested
    }

    /// Per-axis results across the whole user history. Used by Progress UI.
    var numindAxisResults: [NumindScoreEngine.AxisResult] {
        NumindScoreEngine.axisResults(
            sessions: sessionsWithDrillAttribution(),
            repository: LocalContentRepository()
        )
    }

    /// Dynamic subtitle string ("Solid money sense. Strongest: Debt. Focus
    /// next: Investing.") for the header below the score ring.
    var numindSubtitle: String {
        NumindScoreEngine.subtitle(numindAxisResults, composite: numindScore)
    }

    /// Pack recommended next, based on the user's weakest measured axis.
    /// Falls back to the first not-yet-completed pack if no clear weak axis.
    var numindRecommendedNextPack: Pack? {
        let mastered = masteredLessonIds
        let repo = LocalContentRepository()
        let unfinished = repo.allPacks().filter { p in
            // Skip already-completed packs
            let done = p.lessonIds.filter { mastered.contains($0) }.count
            return done < p.lessonIds.count
        }
        guard !unfinished.isEmpty else { return nil }

        // Find weakest measured axis (Early Read+)
        let results = numindAxisResults.filter { $0.evidence != .untested }
        if let weakest = results.min(by: { $0.score < $1.score }) {
            if let match = unfinished.first(where: { $0.primarySkillAxis == weakest.axis }) {
                return match
            }
            if let match = unfinished.first(where: { $0.secondarySkillAxes.contains(weakest.axis) }) {
                return match
            }
        }
        return unfinished.first
    }

    /// How much the overall score changed versus 7 days ago.
    /// Positive = improvement, negative = regression, 0 = no history.
    var numindScoreDelta: Int {
        guard let latest = data.scoreHistory.last else { return 0 }
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let prior = data.scoreHistory
            .filter { $0.date <= cutoff }
            .max { $0.date < $1.date }
        return latest.overallScore - (prior?.overallScore ?? 0)
    }

    /// Recomputes Numind Scores for all given modules and appends a `ScoreEntry`
    /// snapshot to `ProgressData`. Call this immediately after `recordSession`.
    ///
    /// - Parameter moduleIds: All known module IDs (from `ContentRepository.allModules()`).
    func recomputeAndStoreScore(moduleIds: [String]) {
        // Module IDs are accepted for legacy callers but ignored — the engine
        // now scores along the 7 SkillAxis cases regardless of module count.
        let scoringSessions = sessionsWithDrillAttribution()
        let repo = LocalContentRepository()
        let results = NumindScoreEngine.axisResults(sessions: scoringSessions, repository: repo)
        var axisScores: [String: Int] = [:]
        for r in results {
            axisScores[r.axis.rawValue] = r.score
        }
        let overall = NumindScoreEngine.composite(results)

        let entry = ScoreEntry(date: Date(), overallScore: overall, axisScores: axisScores)
        data.scoreHistory.append(entry)

        // Prune entries older than 90 days to prevent unbounded growth.
        let horizon = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        data.scoreHistory.removeAll { $0.date < horizon }

        persist()
    }

    // MARK: - Drill attribution

    /// Returns all sessions with "mixed" drill sessions split into per-module
    /// virtual sessions so the score engine can attribute questions to their
    /// source modules. Non-mixed sessions pass through unchanged.
    private func sessionsWithDrillAttribution() -> [SessionRecord] {
        let repo = LocalContentRepository()
        var result = data.sessions.filter { $0.moduleId != "mixed" }

        for session in data.sessions where session.moduleId == "mixed" {
            // Group question results by their source module.
            var moduleGroups: [String: [QuestionResult]] = [:]
            for qr in session.questionResults {
                if let mod = repo.module(forTemplateId: qr.templateId) {
                    moduleGroups[mod.id, default: []].append(qr)
                }
            }
            // Create one virtual session per module.
            for (modId, results) in moduleGroups {
                var sub = SessionRecord(
                    id: UUID(),
                    lessonId: session.lessonId,
                    moduleId: modId,
                    date: session.date,
                    correctCount: results.filter(\.isCorrect).count,
                    totalCount: results.count
                )
                sub.questionResults = results
                result.append(sub)
            }
        }
        return result
    }
}
