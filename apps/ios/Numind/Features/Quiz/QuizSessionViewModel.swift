import Foundation

@MainActor
final class QuizSessionViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum SessionState: Equatable {
        case question
        case answered(UUID)
        case feedback(UUID)
        case complete
    }

    struct QuizResult {
        let question: QuizQuestion
        let selectedChoiceId: UUID
        var isCorrect: Bool { selectedChoiceId == question.correctChoiceId }
        var promptPreview: String {
            question.prompt.count > 38
                ? String(question.prompt.prefix(38)) + "…"
                : question.prompt
        }
    }

    // MARK: - Input

    let lessonTitle: String
    let moduleColor: ModuleColor
    let lessonShortcut: String
    let questions: [QuizQuestion]

    // MARK: - State

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var sessionState: SessionState = .question
    @Published private(set) var results: [QuizResult] = []
    @Published private(set) var hintRevealed: Bool = false

    // MARK: - Timer

    private let sessionStartDate = Date()
    private var stoppedAt: Date? = nil

    var elapsedTimeString: String {
        let ref = stoppedAt ?? Date()
        let elapsed = Int(ref.timeIntervalSince(sessionStartDate))
        return String(format: "%02d:%02d", elapsed / 60, elapsed % 60)
    }

    // MARK: - Derived

    var currentQuestion: QuizQuestion { questions[currentIndex] }
    var total: Int { questions.count }
    var correctCount: Int { results.filter(\.isCorrect).count }
    var xpEarned: Int { correctCount * 10 }

    var isAnswered: Bool {
        if case .answered = sessionState { return true }
        return false
    }

    var isCorrectAnswer: Bool {
        guard case .feedback(let id) = sessionState else { return false }
        return id == currentQuestion.correctChoiceId
    }

    var selectedChoiceId: UUID? {
        switch sessionState {
        case .answered(let id), .feedback(let id): return id
        default: return nil
        }
    }

    // MARK: - Init

    init(lesson: Lesson, moduleColor: ModuleColor = .blue, repository: ContentRepository = LocalContentRepository()) {
        lessonTitle = lesson.title
        self.moduleColor = moduleColor
        self.lessonShortcut = lesson.shortcut
        let templates = repository.templates(for: lesson.id)
        questions = templates.map { QuizEngine.generate(from: $0) }
    }

    /// Initialiser for pre-generated question sets (e.g. daily challenge).
    init(questions: [QuizQuestion], title: String, shortcut: String, moduleColor: ModuleColor = .blue) {
        lessonTitle = title
        self.moduleColor = moduleColor
        self.lessonShortcut = shortcut
        self.questions = questions
    }

    func revealHint() {
        guard !hintRevealed else { return }
        hintRevealed = true
    }

    // MARK: - Actions

    func select(_ choiceId: UUID) {
        // Allow re-selection while in .answered — user can change their mind before tapping Check.
        switch sessionState {
        case .question, .answered:
            sessionState = .answered(choiceId)
        default:
            return
        }
    }

    func checkAnswer() {
        guard case .answered(let id) = sessionState else { return }
        sessionState = .feedback(id)
    }

    func advance() {
        guard case .feedback(let id) = sessionState else { return }
        results.append(QuizResult(question: currentQuestion, selectedChoiceId: id))
        let next = currentIndex + 1
        if next < questions.count {
            currentIndex = next
            sessionState = .question
            hintRevealed = false  // reset per-question
        } else {
            stoppedAt = Date()
            sessionState = .complete
        }
    }
}
