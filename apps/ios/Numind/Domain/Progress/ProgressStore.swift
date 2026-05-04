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
        persist()
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
}
