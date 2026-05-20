import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    struct LessonCard: Identifiable {
        let id: String          // lesson.id
        let lesson: Lesson
        let module: Module
        let lessonIndex: Int    // 0-based within the module
        let totalLessons: Int

        var questionCount: Int { lesson.quizTemplateIds.count }
        var xpReward: Int { questionCount * 10 }
    }

    @Published private(set) var todayCard: LessonCard?
    @Published private(set) var continueCard: LessonCard?
    @Published private(set) var upNextCards: [LessonCard] = []

    /// All ordered recommendations — used by the view to show reason chips.
    @Published private(set) var recommendations: [LessonRecommendation] = []

    /// True when the user has completed at least one lesson — unlocks game modes.
    @Published private(set) var modesUnlocked: Bool = false

    private let repo: ContentRepository

    init(repository: ContentRepository = LocalContentRepository()) {
        repo = repository
    }

    // MARK: - Daily reset countdown

    /// Human-readable time until midnight, e.g. "7h 23m".
    var timeUntilDailyReset: String {
        let cal = Calendar.current
        let now = Date()
        guard let midnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) else {
            return ""
        }
        let diff = cal.dateComponents([.hour, .minute], from: now, to: midnight)
        let h = diff.hour ?? 0
        let m = diff.minute ?? 0
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    /// Builds a `LessonCard` for a given lesson so the insight view can launch it.
    func card(for lesson: Lesson, using repository: ContentRepository) -> LessonCard? {
        guard let module = repository.module(id: lesson.moduleId) else { return nil }
        let lessons = repository.lessons(for: module.id)
        guard let idx = lessons.firstIndex(where: { $0.id == lesson.id }) else { return nil }
        return LessonCard(
            id: lesson.id,
            lesson: lesson,
            module: module,
            lessonIndex: idx,
            totalLessons: lessons.count
        )
    }

    func refresh(using store: ProgressStore) {
        // Use the recommendation engine to rank incomplete lessons by weakness.
        let recs = LessonRecommendationEngine.recommendations(
            repository: repo,
            sessions: store.data.sessions,
            onboardingSignals: store.data.onboardingSignals,
            limit: 10
        )

        // Convert recommendations to LessonCards preserving urgency order.
        let cards: [LessonCard] = recs.compactMap { rec in
            let lessons = repo.lessons(for: rec.module.id)
            guard let idx = lessons.firstIndex(where: { $0.id == rec.lesson.id }) else { return nil }
            return LessonCard(
                id: rec.lesson.id,
                lesson: rec.lesson,
                module: rec.module,
                lessonIndex: idx,
                totalLessons: lessons.count
            )
        }

        // "Continue" = a partially-started module (in-progress recommendation).
        let continueRec = recs.first {
            if case .inProgress = $0.reason { return true }
            return false
        }
        continueCard = continueRec.flatMap { rec in
            let lessons = repo.lessons(for: rec.module.id)
            guard let idx = lessons.firstIndex(where: { $0.id == rec.lesson.id }) else { return nil }
            return LessonCard(id: rec.lesson.id, lesson: rec.lesson, module: rec.module,
                              lessonIndex: idx, totalLessons: lessons.count)
        }

        recommendations = recs
        todayCard       = cards.first
        upNextCards     = Array(cards.dropFirst().prefix(2))
        modesUnlocked   = MasteredTemplatePool.hasUnlockedModes(progressData: store.data)
    }
}
