import Foundation

@MainActor
final class ModuleDetailViewModel: ObservableObject {
    let module: Module
    let moduleIndex: Int
    let totalModules: Int
    @Published private(set) var lessons: [Lesson] = []

    init(module: Module, moduleIndex: Int, totalModules: Int,
         repository: ContentRepository = LocalContentRepository()) {
        self.module = module
        self.moduleIndex = moduleIndex
        self.totalModules = totalModules
        self.lessons = repository.lessons(for: module.id)
    }

    var moduleLabel: String { "Module \(moduleIndex + 1) of \(totalModules)" }
}
