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

    /// True when the user has mastered at least one lesson — unlocks game modes.
    @Published private(set) var modesUnlocked: Bool = false

    private let repo: ContentRepository

    init(repository: ContentRepository = LocalContentRepository()) {
        repo = repository
    }

    func refresh(using store: ProgressStore) {
        var incompleteCards: [LessonCard] = []
        var partialModuleCard: LessonCard? = nil

        for module in repo.allModules() {
            let lessons = repo.lessons(for: module.id)
            let completedCount = store.completedLessonCount(moduleId: module.id)

            // A module with partial progress surfaces a "Continue" card
            if completedCount > 0 && completedCount < lessons.count, partialModuleCard == nil {
                if let next = lessons.enumerated().first(where: { !store.hasCompletedLesson($0.element.id) }) {
                    partialModuleCard = LessonCard(
                        id: next.element.id,
                        lesson: next.element,
                        module: module,
                        lessonIndex: next.offset,
                        totalLessons: lessons.count
                    )
                }
            }

            for (i, lesson) in lessons.enumerated() where !store.hasCompletedLesson(lesson.id) {
                incompleteCards.append(LessonCard(
                    id: lesson.id,
                    lesson: lesson,
                    module: module,
                    lessonIndex: i,
                    totalLessons: lessons.count
                ))
            }
        }

        todayCard    = incompleteCards.first
        continueCard = partialModuleCard
        upNextCards  = Array(incompleteCards.dropFirst().prefix(2))
        modesUnlocked = MasteredTemplatePool.hasUnlockedModes(progressData: store.data)
    }
}
