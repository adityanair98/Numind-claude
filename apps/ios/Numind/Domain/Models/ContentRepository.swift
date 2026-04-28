import Foundation

protocol ContentRepository {
    func allModules() -> [Module]
    func module(id: String) -> Module?
    func lessons(for moduleId: String) -> [Lesson]
    func lesson(id: String) -> Lesson?
    func templates(for lessonId: String) -> [QuizTemplate]
    func template(id: String) -> QuizTemplate?
}
