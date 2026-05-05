import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    private static let defaultsKey      = "numind.progress.v1"
    private static let dailyChallengeKey = "numind.dailyChallenge.lastCompleted"
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    @Published private(set) var data: ProgressData
    @Published private(set) var dailyChallengeCompletedDate: String
    /// Badge IDs earned in the most-recent recordSession call. Cleared on the next call.
    @Published private(set) var newlyEarnedBadgeIds: Set<String> = []

    init() {
        if let raw = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: raw) {
            data = decoded
        } else {
            data = ProgressData()
        }
        dailyChallengeCompletedDate = UserDefaults.standard.string(forKey: Self.dailyChallengeKey) ?? ""
    }

    // MARK: - Write

    func recordSession(_ record: SessionRecord) {
        let previouslyEarned = data.earnedBadgeIds
        data.sessions.append(record)
        let current = data.computeStreak()
        if current > data.bestStreak {
            data.bestStreak = current
        }
        let nowEarned = BadgeEvaluator.earned(from: data)
        newlyEarnedBadgeIds = nowEarned.subtracting(previouslyEarned)
        data.earnedBadgeIds = nowEarned
        // Recompute Numind Score after every session so the radar + score ring
        // always reflect the latest performance without extra callsite boilerplate.
        let moduleIds = LocalContentRepository().allModules().map(\.id)
        recomputeAndStoreScore(moduleIds: moduleIds)
        // persist() is called inside recomputeAndStoreScore — no double write needed.
    }

    func reset() {
        data = ProgressData()
        UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
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

    // MARK: - Blitz personal best

    var blitzBest: Int { data.blitzBestScore }

    func updateBlitzBest(score: Int) {
        guard score > data.blitzBestScore else { return }
        data.updateBlitzBest(score: score)
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

    // MARK: - Numind Score

    /// Current overall Numind Score (0–100). 0 if no score has been computed yet.
    var numindScore: Int { data.scoreHistory.last?.overallScore ?? 0 }

    /// Latest score for a specific module (0–100). 0 if never computed.
    func numindScore(for moduleId: String) -> Int {
        data.scoreHistory.last?.moduleScores[moduleId] ?? 0
    }

    /// Module score from the nearest snapshot at or before `daysAgo` days ago.
    /// Returns nil if no snapshot exists that far back.
    func numindScoreHistory(for moduleId: String, daysAgo: Int) -> Int? {
        let cutoff = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return data.scoreHistory
            .filter { $0.date <= cutoff }
            .max { $0.date < $1.date }
            .flatMap { $0.moduleScores[moduleId] }
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
        let sessions = data.sessions
        var moduleScores: [String: Int] = [:]
        for id in moduleIds {
            moduleScores[id] = NumindScoreEngine.score(for: id, sessions: sessions)
        }
        let overall = moduleIds.isEmpty ? 0
            : moduleScores.values.reduce(0, +) / moduleIds.count

        let entry = ScoreEntry(date: Date(), overallScore: overall, moduleScores: moduleScores)
        data.scoreHistory.append(entry)

        // Prune entries older than 90 days to prevent unbounded growth.
        let horizon = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        data.scoreHistory.removeAll { $0.date < horizon }

        persist()
    }
}
