import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    private static let defaultsKey = "numind.progress.v1"

    @Published private(set) var data: ProgressData

    init() {
        if let raw = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: raw) {
            data = decoded
        } else {
            data = ProgressData()
        }
    }

    // MARK: - Write

    func recordSession(_ record: SessionRecord) {
        data.sessions.append(record)
        let current = data.computeStreak()
        if current > data.bestStreak {
            data.bestStreak = current
        }
        persist()
    }

    func reset() {
        data = ProgressData()
        UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
    }

    private func persist() {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: Self.defaultsKey)
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

    func skillLevel(moduleId: String) -> Int {
        data.skillLevel(moduleId: moduleId)
    }

    func skillLevelProgress(moduleId: String) -> Double {
        data.skillLevelProgress(moduleId: moduleId)
    }
}
