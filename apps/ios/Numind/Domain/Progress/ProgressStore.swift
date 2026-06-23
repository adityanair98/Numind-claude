import Foundation

/// Per-axis lesson coverage (Phase 9): how many lessons whose *primary* skill is
/// this axis the user has mastered, out of the total. The honest replacement for
/// the old 0–100 per-axis composite — it answers "how much have you locked in
/// here," not "how good are you" (a verdict the app can't validate).
struct AxisCoverage: Identifiable {
    var id: String { axis.rawValue }
    let axis: SkillAxis
    let mastered: Int
    let total: Int
    var fraction: Double { total > 0 ? Double(mastered) / Double(total) : 0 }
}

@MainActor
final class ProgressStore: ObservableObject {
    private static let defaultsKey       = "numind.progress.v3"
    private static let legacyDefaultsKey = "numind.progress.v2"
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
                  let decoded = try? JSONDecoder().decode(ProgressData.self, from: legacyRaw) {
            // Legacy → current migration: sessions/badges/freezes survive.
            // The retired composite `scoreHistory`/`pinnedAxes` keys simply drop
            // out (JSONDecoder ignores unknown keys). XP/Level/Readiness all
            // recompute from the session log. We don't yet have real users, so
            // this is a dev-data safety net (not a user-facing migration).
            data = decoded
        } else {
            data = ProgressData()
        }
        dailyChallengeCompletedDate = UserDefaults.standard.string(forKey: Self.dailyChallengeKey) ?? ""
    }

    // MARK: - Write

    func recordSession(_ record: SessionRecord) {
        recordSessions([record])
    }

    /// Records one or more SessionRecords as a SINGLE logical event. The Daily
    /// Workout / Refresh / Bonus flows split one workout into per-module records;
    /// recording them as a batch means the streak, freezes, badges, the pending
    /// milestone, and completion celebrations are computed ONCE against the
    /// before→after snapshot. Recording them one-at-a-time (the old loop) made
    /// each later sub-record recompute `pendingMilestone` — clobbering a
    /// capability/streak/freeze milestone earned on an earlier sub-record before
    /// the UI ever saw it (audit fix H2), and ran the streak/freeze/badge
    /// recompute N times for one workout.
    func recordSessions(_ records: [SessionRecord]) {
        guard !records.isEmpty else { return }
        let snapshotBefore = data
        let previouslyEarned = data.earnedBadgeIds
        // Snapshot pre-session mastery to detect first-time completions
        // (pack / world) AFTER the session is recorded.
        let masteredBefore = masteredLessonIds
        data.sessions.append(contentsOf: records)
        // Phase 10 / audit fix H3: any real practice marks the day for the
        // streak (must run before computeStreak). The ring's own target governs
        // only the visual goal, not whether the day counts.
        let latest = records.map(\.date).max() ?? Date()
        DailyRingEngine.markActiveDay(&data, now: latest)
        // `.ringClosed` keeps its literal meaning — the daily volume target was
        // actually hit — so it fires on the target transition, not on first
        // practice of the day.
        if !DailyRingEngine.isClosed(on: latest, data: snapshotBefore),
           DailyRingEngine.isClosed(on: latest, data: data) {
            AnalyticsService.capture(.ringClosed)
        }
        let current = data.computeStreak()
        if current > data.bestStreak {
            data.bestStreak = current
        }
        // Snapshot the streak so we can detect loss on next launch.
        data.lastKnownStreak = current

        // Award streak freezes. Phase 6a — gentler ramp:
        //   • First freeze at day 3 (was 7) — adults need safety before commitment
        //   • Subsequent freezes every 7 days
        //   • Cap raised to 5 (was 3)
        let milestoneCount: Int = {
            if current < 3 { return 0 }
            // Day 3 → 1 milestone; day 10 → 2; day 17 → 3; etc.
            return 1 + max(0, (current - 3) / 7)
        }()
        if milestoneCount > data.freezeMilestonesAwarded {
            let newFreezes = milestoneCount - data.freezeMilestonesAwarded
            data.availableFreezes = min(5, data.availableFreezes + newFreezes)
            data.freezeMilestonesAwarded = milestoneCount
        }

        let nowEarned = BadgeEvaluator.earned(from: data)
        newlyEarnedBadgeIds = nowEarned.subtracting(previouslyEarned)
        data.earnedBadgeIds = nowEarned
        // Phase 9: XP/Level/Readiness are pure functions over the session log —
        // nothing to recompute or persist beyond the session itself.
        persist()

        // Check for milestone celebrations (Phase 10 — capability triggers;
        // pack/world COMPLETION celebrations stay in the Celebration queue).
        let repo = LocalContentRepository()
        let packs = repo.allPacks()
        func readyIds(_ d: ProgressData) -> Set<String> {
            Set(packs.filter { pack in
                switch ReadinessEngine.state(for: pack, data: d, repository: repo) {
                case .ready, .sharp: return true
                default: return false
                }
            }.map(\.id))
        }
        func masteredReal(_ d: ProgressData) -> Set<String> {
            masteredRealLessonIds(in: d)
        }
        func staleCount(_ d: ProgressData) -> Int {
            FreshnessEngine.staleCount(
                masteredLessonIds: masteredReal(d), sessions: d.sessions, repository: repo
            )
        }
        let lessonNames = Dictionary(
            uniqueKeysWithValues: repo.allModules()
                .flatMap { repo.lessons(for: $0.id) }
                .map { ($0.id, $0.title) }
        )
        let beforeReadyIds = readyIds(snapshotBefore)
        let afterReadyIds = readyIds(data)
        pendingMilestone = MilestoneEngine.check(
            before: snapshotBefore,
            after: data,
            shownIds: data.shownMilestoneIds,
            beforeMastered: masteredReal(snapshotBefore),
            afterMastered: masteredReal(data),
            beforeReadyPackIds: beforeReadyIds,
            afterReadyPackIds: afterReadyIds,
            packNames: Dictionary(uniqueKeysWithValues: packs.map { ($0.id, $0.title) }),
            lessonNames: lessonNames,
            beforeStaleCount: staleCount(snapshotBefore),
            afterStaleCount: staleCount(data),
            lastSessionLessonId: records.last?.lessonId ?? ""
        )
        for packId in afterReadyIds.subtracting(beforeReadyIds) {
            AnalyticsService.capture(.packStateChanged,
                                     properties: ["pack_id": packId, "state": "ready"])
        }

        // Detect newly-completed packs and worlds for the celebration queue.
        // Pack celebration fires first when both a pack and a world complete
        // in the same session (per the spec).
        let masteredAfter = masteredLessonIds
        let newlyMastered = masteredAfter.subtracting(masteredBefore)
        for lessonId in newlyMastered where !lessonId.hasPrefix("review_") {
            AnalyticsService.capture(.lessonMastered, properties: ["lesson_id": lessonId])
        }
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

    /// Marks today as a completed Daily Workout. Persists the date string
    /// for the legacy "completed-today" check AND inserts today (start-of-
    /// day) into `dailyWorkoutDates` so the Phase 5f streak rule sees it.
    func markDailyChallengeCompleted() {
        let now = Date()
        let today = Self.dateFormatter.string(from: now)
        UserDefaults.standard.set(today, forKey: Self.dailyChallengeKey)
        dailyChallengeCompletedDate = today
        // Phase 10: the day itself is marked by the streak-active rule inside
        // recordSessions (DailyRingEngine.markActiveDay) — this method now
        // only maintains the legacy "workout done today" card state.
        // Recompute streak so the rest of the app immediately reflects it.
        let current = data.computeStreak()
        if current > data.bestStreak { data.bestStreak = current }
        data.lastKnownStreak = current
        persist()
    }

    /// Convenience: same semantics as `markDailyChallengeCompleted` but
    /// reads clearer at the new "Daily Workout" call sites.
    func markDailyWorkoutCompleted() {
        markDailyChallengeCompleted()
    }

    // MARK: - Daily ring (Phase 10)

    var ringTarget: Int { DailyRingEngine.target(for: data) }
    var todayQuestionCount: Int { DailyRingEngine.questionCount(on: Date(), sessions: data.sessions) }
    var ringProgress: Double { DailyRingEngine.progress(on: Date(), data: data) }
    var isRingClosedToday: Bool { DailyRingEngine.isClosed(on: Date(), data: data) }

    private func persist() {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: Self.defaultsKey)
        WidgetSnapshotWriter.write(from: data)
    }

    // MARK: - Streak revival

    /// True when the user had a streak > 1 that has now dropped to 0,
    /// and the last session was recent enough to allow revival (≤ 3 days).
    var isStreakLost: Bool {
        let current = data.computeStreak()
        guard current == 0, data.lastKnownStreak > 1 else { return false }
        // Only allow revival if last session was within 3 days.
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
    /// doesn't re-trigger. The freeze safety net resets with the streak it
    /// protected: both the awarded-milestone counter AND the banked balance go
    /// to zero so a new streak earns freezes truly from scratch. (Audit fix M3:
    /// previously only `freezeMilestonesAwarded` reset, so the next climb
    /// re-earned freezes the user had already banked — a double-award leak.)
    func acceptStreakLoss() {
        data.lastKnownStreak = 0
        data.freezeMilestonesAwarded = 0
        data.availableFreezes = 0
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
            AnalyticsService.capture(.streakFreezeUsed)
        }

        let current = data.computeStreak()
        if current > data.bestStreak { data.bestStreak = current }
        data.lastKnownStreak = current
        persist()
        return true
    }

    /// Number of streak freezes currently banked (max 5 after Phase 6a).
    var availableFreezes: Int { data.availableFreezes }

    // MARK: - Rest days (Phase 6a)

    /// True if the user is eligible to take a rest day right now —
    /// at most one rest day every 14 days. UI surfaces a "take a rest"
    /// pill on the Daily Workout card when this is true AND the streak
    /// is ≥3 days.
    func canTakeRestDay(on date: Date = Date()) -> Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)
        // Strict `>` so a rest day exactly 14 days ago no longer blocks — true
        // 1-per-14-days cadence (audit fix #16; `>=` made it 1-per-15).
        let window = cal.date(byAdding: .day, value: -14, to: today) ?? today
        return !data.restDaysUsed.contains(where: { $0 > window })
    }

    /// Use today as a rest day. Inserts today into `restDaysUsed`, which
    /// counts as an active day in `computeStreak()` without burning a
    /// freeze. No-op if the user has already taken a rest day in the
    /// trailing 14 days.
    func takeRestDay() {
        guard canTakeRestDay() else { return }
        let today = Calendar.current.startOfDay(for: Date())
        data.restDaysUsed.insert(today)
        let current = data.computeStreak()
        if current > data.bestStreak { data.bestStreak = current }
        data.lastKnownStreak = current
        persist()
    }

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

    /// In-place mutation of saved signals (Profile edits: payday, lease month).
    func updateSignals(_ mutate: (inout OnboardingSignals) -> Void) {
        var signals = data.onboardingSignals ?? OnboardingSignals()
        mutate(&signals)
        data.onboardingSignals = signals
        persist()
    }

    // MARK: - Sharpness check + real-world saves (Phase 12)

    var sharpnessChecks: [SharpnessCheckRecord] { data.sharpnessChecks ?? [] }
    var realWorldSaves: [RealWorldSave] { data.realWorldSaves ?? [] }

    /// Due 28+ days after the last check (or the day-1 diagnostic / first
    /// session when no check exists yet).
    var isSharpnessCheckDue: Bool {
        let anchor = data.onboardingSignals?.diagnosticDate
            ?? data.sessions.map(\.date).min()
        return SharpnessCheckGate.isCheckDue(
            lastCheck: sharpnessChecks.map(\.date).max(),
            anchor: anchor
        )
    }

    func recordSharpnessCheck(_ record: SharpnessCheckRecord) {
        data.sharpnessChecks = sharpnessChecks + [record]
        persist()
    }

    var isSavePromptDue: Bool {
        SharpnessCheckGate.isSavePromptDue(
            lastPrompt: data.lastSavePromptDate,
            sessionCount: data.sessions.count
        )
    }

    /// Marks the prompt shown (regardless of answer) and stores a save
    /// when the user picked one.
    func recordSavePrompt(label: String?) {
        data.lastSavePromptDate = Date()
        if let label {
            data.realWorldSaves = realWorldSaves + [
                RealWorldSave(id: UUID(), date: Date(), label: label)
            ]
        }
        persist()
    }

    // MARK: - Computed (forwarded from ProgressData)

    var streak: Int               { data.computeStreak() }
    var bestStreak: Int           { data.bestStreak }
    var totalSessions: Int        { data.sessions.count }
    var totalXP: Int              { xp }
    var accuracy: Double          { data.computeAccuracy() }
    var weeklyCompletions: [Bool] { data.computeWeeklyCompletions() }
    var weeklyWorkouts: Int       { data.computeWeeklyWorkouts() }
    let weeklyGoal: Int = 5

    // MARK: - Momentum (XP + Level, Phase 9)

    /// Real lesson IDs mastered in a given snapshot (excludes daily/bonus/recall
    /// pseudo-lessons, which share the `lessonId` field but aren't curriculum).
    private func masteredRealLessonIds(in d: ProgressData) -> Set<String> {
        let repo = LocalContentRepository()
        let real = Set(repo.allModules().flatMap { repo.lessons(for: $0.id).map(\.id) })
        let mastered = Set(d.sessions.map(\.lessonId)).filter { d.hasMasteredLesson($0) }
        return mastered.intersection(real)
    }

    /// Lifetime XP for a snapshot — the effort currency. Monotonic; pure.
    func xp(of d: ProgressData) -> Int {
        MomentumEngine.totalXP(
            sessions: d.sessions,
            masteredLessonCount: masteredRealLessonIds(in: d).count,
            readyPackCount: ReadinessEngine.readyPackCount(data: d)
        )
    }

    /// Effective level for a snapshot — XP ladder, depth-gated above L8.
    func level(of d: ProgressData) -> Int {
        let deep = masteredRealLessonIds(in: d).filter { d.masteredWithHard($0) }.count
        return MomentumEngine.level(xp: xp(of: d), deepMasteryCount: deep)
    }

    /// Lifetime XP — the effort currency. Monotonic; pure over the session log.
    var xp: Int { xp(of: data) }

    /// Effective level — XP ladder, depth-gated above L8.
    var level: Int { level(of: data) }

    var xpToNextLevel: Int? { MomentumEngine.xpToNextLevel(xp) }
    var levelProgress: Double { MomentumEngine.levelProgress(xp) }

    /// True when the user has the XP for the next level but is held back by the
    /// depth gate (needs another deep mastery — a lesson mastered with a hard
    /// question, or a pack reaching Ready). Drives honest "earn a deep mastery"
    /// copy instead of an "X XP to go" bar that would never move.
    var isDepthGated: Bool {
        let deep = masteredRealLessonIds(in: data).filter { data.masteredWithHard($0) }.count
        return MomentumEngine.isDepthGated(xp: xp, deepMasteryCount: deep)
    }

    // MARK: - Readiness + Freshness (Phase 9)

    /// Readiness state for a pack (the decision-scoped competence signal).
    func readiness(for pack: Pack) -> ReadinessEngine.State {
        ReadinessEngine.state(for: pack, data: data)
    }

    /// Number of packs the user is Ready/Sharp on — the Home competence headline.
    var readyPackCount: Int { ReadinessEngine.readyPackCount(data: data) }

    /// Per-axis lesson coverage (mastered / total) by primary skill axis.
    /// Drives the coverage radar + rows on Home and Progress.
    var axisCoverage: [AxisCoverage] {
        let repo = LocalContentRepository()
        let mastered = masteredLessonIds
        var counts: [SkillAxis: (m: Int, t: Int)] = [:]
        for axis in SkillAxis.allCases { counts[axis] = (0, 0) }
        for module in repo.allModules() {
            for lesson in repo.lessons(for: module.id) {
                guard let axis = lesson.primarySkill else { continue }
                var e = counts[axis] ?? (0, 0)
                e.t += 1
                if mastered.contains(lesson.id) { e.m += 1 }
                counts[axis] = e
            }
        }
        return SkillAxis.allCases.map {
            AxisCoverage(axis: $0, mastered: counts[$0]?.m ?? 0, total: counts[$0]?.t ?? 0)
        }
    }

    /// Mastered skills that have gone stale (overdue) — surfaced as refresh opportunities.
    var staleSkillCount: Int {
        FreshnessEngine.staleCount(masteredLessonIds: masteredLessonIds, sessions: data.sessions)
    }

    func moduleProgress(moduleId: String, totalLessons: Int) -> Double {
        data.moduleProgress(moduleId: moduleId, totalLessons: totalLessons)
    }

    func completedLessonCount(moduleId: String) -> Int {
        data.completedLessonCount(moduleId: moduleId)
    }

    func hasCompletedLesson(_ lessonId: String) -> Bool {
        data.hasCompletedLesson(lessonId)
    }

    /// "Was this lesson ever mastered" — does NOT consider mastery decay.
    /// Most UI surfaces want `hasMasteredLessonNow` instead.
    func hasMasteredLesson(_ lessonId: String) -> Bool {
        data.hasMasteredLesson(lessonId)
    }

    /// "Is this lesson *currently* mastered." Phase 9: mastery no longer
    /// decays — once earned, the star stays (the headline never goes down).
    /// Skill staleness is carried by Freshness (FreshnessEngine), not by
    /// revoking the star. Kept as a distinct method so call sites (gold
    /// checkmark, world-conquered crown, pack progress, resume target) read
    /// clearly and we can reintroduce a decay policy here if ever needed.
    func hasMasteredLessonNow(_ lessonId: String) -> Bool {
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

    /// Real curriculum lesson IDs the user has ever mastered. Mastery does NOT
    /// decay (Phase 9) — once earned it stays; staleness is carried separately
    /// by Freshness. Routed through `masteredRealLessonIds(in:)` (see below) so
    /// synthetic ids can't leak in.
    var masteredLessonIds: Set<String> {
        // Only REAL curriculum lessons. The daily/bonus/refresh sessions reuse
        // the lessonId field for synthetic ids ("daily_challenge" etc.); a
        // single ≥85% daily sub-session would otherwise flip "daily_challenge"
        // to mastered and show a phantom "1 mastered" on Progress.
        masteredRealLessonIds(in: data)
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

    // MARK: - Skill axes (private diagnostic, Phase 9)
    //
    // The 7-axis model survives only as an internal diagnostic — it feeds the
    // coverage radar, the "focus next" recommendation, and the Daily Insight
    // session radar. There is no longer a 0–100 composite, subtitle, delta, or
    // score history; competence is expressed via per-pack Readiness.

    /// Axis evidence level (Untested / Early Read / Developing / Reliable),
    /// recomputed lazily from current sessions (cheap; bounded by axis count).
    func numindEvidence(forAxis axis: SkillAxis) -> EvidenceLevel {
        let results = NumindScoreEngine.axisResults(
            sessions: sessionsWithDrillAttribution(),
            repository: LocalContentRepository()
        )
        return results.first { $0.axis == axis }?.evidence ?? .notStarted
    }

    /// Per-axis results across the whole user history. Used by Progress UI.
    var numindAxisResults: [NumindScoreEngine.AxisResult] {
        NumindScoreEngine.axisResults(
            sessions: sessionsWithDrillAttribution(),
            repository: LocalContentRepository()
        )
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
        let results = numindAxisResults.filter { $0.evidence != .notStarted }
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
