import Foundation

@MainActor
final class LearnViewModel: ObservableObject {
    @Published private(set) var modules: [Module] = []

    init(repository: ContentRepository = LocalContentRepository()) {
        modules = repository.allModules()
    }
}
