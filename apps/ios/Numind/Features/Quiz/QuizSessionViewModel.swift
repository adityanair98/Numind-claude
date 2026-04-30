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
        /// Seconds from question appearing to the user tapping "Check answer".
        let timeSpentSeconds: Double
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
    @Published var freeEntryText: String = ""  // used when inputMode == .freeEntry

    // MARK: - Session timer

    private let sessionStartDate = Date()
    private var stoppedAt: Date? = nil

    // MARK: - Per-question timer

    /// Reset each time a new question becomes active.
    private var questionStartTime: Date = Date()
    /// Captured by checkAnswer(); consumed by advance() to build the QuizResult.
    private var lastQuestionTimeSpent: Double = 0

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

    /// Maps completed results to the Codable `QuestionResult` type for `SessionRecord`.
    var questionResults: [QuestionResult] {
        results.map {
            QuestionResult(
                templateId: $0.question.templateId,
                isCorrect: $0.isCorrect,
                timeSpentSeconds: $0.timeSpentSeconds
            )
        }
    }

    /// True when the player has made a selection (MCQ) or typed something (free-entry).
    var isReadyToCheck: Bool {
        switch sessionState {
        case .answered: return true
        case .question: return currentQuestion.inputMode == .freeEntry && !freeEntryText.isEmpty
        default:        return false
        }
    }

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

    /// Initialiser for lesson-driven quiz sessions.
    /// When `sessions` is non-empty the template order is determined by the
    /// Spaced Repetition engine (most-due / most-struggled templates first).
    init(
        lesson: Lesson,
        moduleColor: ModuleColor = .blue,
        sessions: [SessionRecord] = [],
        repository: ContentRepository = LocalContentRepository()
    ) {
        lessonTitle = lesson.title
        self.moduleColor = moduleColor
        self.lessonShortcut = lesson.shortcut
        let templates = sessions.isEmpty
            ? repository.templates(for: lesson.id)
            : SpacedRepetitionEngine.sortedTemplates(
                for: lesson.id,
                sessions: sessions,
                repository: repository
              )
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
        // Capture how long the user spent on this question before revealing feedback.
        lastQuestionTimeSpent = Date().timeIntervalSince(questionStartTime)
        switch currentQuestion.inputMode {
        case .multipleChoice:
            guard case .answered(let id) = sessionState else { return }
            sessionState = .feedback(id)
        case .freeEntry:
            guard let entered = Double(freeEntryText) else { return }
            let tolerance: Double = 0.05
            let isCorrect = abs(entered - currentQuestion.correctValue) <= tolerance
            sessionState = .feedback(isCorrect ? currentQuestion.correctChoiceId : UUID())
        }
    }

    func appendDigit(_ digit: String) {
        guard freeEntryText.count < 10 else { return }
        if digit == "." {
            guard !freeEntryText.contains(".") else { return }
            freeEntryText += freeEntryText.isEmpty ? "0." : "."
        } else {
            if freeEntryText == "0" { freeEntryText = "" } // replace leading zero
            freeEntryText += digit
        }
    }

    func deleteDigit() {
        guard !freeEntryText.isEmpty else { return }
        freeEntryText.removeLast()
    }

    func advance() {
        guard case .feedback(let id) = sessionState else { return }
        results.append(QuizResult(
            question: currentQuestion,
            selectedChoiceId: id,
            timeSpentSeconds: lastQuestionTimeSpent
        ))
        let next = currentIndex + 1
        if next < questions.count {
            currentIndex = next
            sessionState = .question
            hintRevealed = false
            freeEntryText = ""
            questionStartTime = Date()  // reset timer for next question
        } else {
            stoppedAt = Date()
            sessionState = .complete
        }
    }
}
