import Foundation

protocol ContentRepository {
    func allModules() -> [Module]
    func module(id: String) -> Module?
    func lessons(for moduleId: String) -> [Lesson]
    func lesson(id: String) -> Lesson?
    func allTemplates() -> [QuizTemplate]
    func templates(for lessonId: String) -> [QuizTemplate]
    func template(id: String) -> QuizTemplate?
    /// Returns the lesson whose `quizTemplateIds` contains `templateId`, or nil.
    func lesson(forTemplateId: String) -> Lesson?
    /// Returns the module that owns the lesson containing `templateId`, or nil.
    func module(forTemplateId: String) -> Module?

    // MARK: - Packs (life-event sequences)
    /// All packs in display order (matches packs.json file order).
    func allPacks() -> [Pack]
    /// Look up a pack by id (e.g. "first_paycheck").
    func pack(id: String) -> Pack?
    /// All packs that include the given lesson — useful for showing
    /// "this lesson appears in N paths" cross-links.
    func packs(containingLesson lessonId: String) -> [Pack]
}
