import Foundation

final class LocalContentRepository: ContentRepository {
    private let modules: [Module]
    private let lessons: [Lesson]
    private let templates: [QuizTemplate]
    private let packs: [Pack]

    init(bundle: Bundle = .main) {
        modules   = bundle.decodeJSON([Module].self,       from: "modules")
        lessons   = bundle.decodeJSON([Lesson].self,       from: "lessons")
        templates = bundle.decodeJSON([QuizTemplate].self, from: "quiz_templates")
        packs     = bundle.decodeJSON([Pack].self,         from: "packs")
    }

    func allModules() -> [Module] { modules }
    func allTemplates() -> [QuizTemplate] { templates }

    func module(id: String) -> Module? {
        modules.first { $0.id == id }
    }

    func lessons(for moduleId: String) -> [Lesson] {
        lessons.filter { $0.moduleId == moduleId }
    }

    func lesson(id: String) -> Lesson? {
        lessons.first { $0.id == id }
    }

    // Returns templates in the order the lesson declares them.
    func templates(for lessonId: String) -> [QuizTemplate] {
        guard let lesson = lesson(id: lessonId) else { return [] }
        return lesson.quizTemplateIds.compactMap { tid in
            templates.first { $0.id == tid }
        }
    }

    func template(id: String) -> QuizTemplate? {
        templates.first { $0.id == id }
    }

    func lesson(forTemplateId templateId: String) -> Lesson? {
        lessons.first { $0.quizTemplateIds.contains(templateId) }
    }

    func module(forTemplateId templateId: String) -> Module? {
        guard let lesson = lesson(forTemplateId: templateId) else { return nil }
        return module(id: lesson.moduleId)
    }

    // MARK: - Packs

    func allPacks() -> [Pack] { packs }

    func pack(id: String) -> Pack? {
        packs.first { $0.id == id }
    }

    func packs(containingLesson lessonId: String) -> [Pack] {
        packs.filter { $0.lessonIds.contains(lessonId) }
    }

    func inProgressPacks(masteredLessonIds: Set<String>) -> [Pack] {
        packs.filter { pack in
            let lessons = Set(pack.lessonIds)
            let mastered = lessons.intersection(masteredLessonIds)
            // Touched at least once, but not yet fully completed.
            return !mastered.isEmpty && mastered.count < lessons.count
        }
    }

    func packProgress(_ pack: Pack, masteredLessonIds: Set<String>) -> (done: Int, total: Int) {
        let done = pack.lessonIds.filter { masteredLessonIds.contains($0) }.count
        return (done, pack.lessonIds.count)
    }
}

// MARK: - Bundle helper

private extension Bundle {
    // Loads and decodes a JSON resource file. Crashes on missing or malformed
    // content — local fixtures are a developer asset, not a runtime input.
    func decodeJSON<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let url = self.url(forResource: filename, withExtension: "json") else {
            fatalError("[ContentRepository] \(filename).json not found in bundle '\(bundleIdentifier ?? "?")'")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            fatalError("[ContentRepository] Failed to decode \(filename).json: \(error)")
        }
    }
}
