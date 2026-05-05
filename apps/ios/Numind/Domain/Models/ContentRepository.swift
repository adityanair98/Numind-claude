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
}
