import Foundation

@MainActor
final class QuizSessionViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum SessionState: Equatable {
        case question
        case answered(UUID)      // user picked a choice
        case feedback(UUID)      // answer checked, showing result
        case complete            // all questions done
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

    /// Optional per-question time limit (seconds). Nil = standard untimed quiz.
    /// When set, a countdown timer runs each question; expiry = automatic wrong answer.
    let questionTimeLimit: TimeInterval?

    // MARK: - State

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var sessionState: SessionState = .question
    @Published private(set) var results: [QuizResult] = []
    @Published private(set) var hintRevealed: Bool = false
    @Published var freeEntryText: String = ""  // used when inputMode == .freeEntry

    // MARK: - Per-question countdown (Speed Drill)

    /// Remaining seconds for the current question. Zero when no time limit is set.
    @Published private(set) var questionTimeRemaining: TimeInterval = 0
    private var timerTask: Task<Void, Never>?

    // MARK: - Session timer

    private let sessionStartDate = Date()
    private var stoppedAt: Date? = nil

    /// Total time spent reading feedback screens — excluded from the displayed
    /// session clock in untimed sessions. Blitz keeps the clock running (intentional).
    private var totalFeedbackDuration: TimeInterval = 0
    /// Set when the session enters `.feedback` state; cleared in `advance()`.
    private var feedbackEnteredAt: Date? = nil

    // MARK: - Per-question timer

    /// Reset each time a new question becomes active.
    private var questionStartTime: Date = Date()
    /// Captured by checkAnswer(); consumed by advance() to build the QuizResult.
    private var lastQuestionTimeSpent: Double = 0

    var elapsedTimeString: String {
        let ref = stoppedAt ?? Date()
        var elapsed = ref.timeIntervalSince(sessionStartDate)
        // In untimed sessions, subtract feedback viewing time so the clock
        // only counts active answering time — not reading right/wrong screens.
        if questionTimeLimit == nil {
            elapsed -= totalFeedbackDuration
            if let entered = feedbackEnteredAt {
                elapsed -= ref.timeIntervalSince(entered)
            }
        }
        let secs = max(0, Int(elapsed))
        return String(format: "%02d:%02d", secs / 60, secs % 60)
    }

    // MARK: - Derived

    var currentQuestion: QuizQuestion { questions[currentIndex] }
    var total: Int { questions.count }

    // MARK: - XP

    /// Seconds thresholds and bonus amounts for speed XP.
    static let speedFastSeconds: Double = 5
    static let speedGoodSeconds: Double = 10
    static let speedFastBonus:   Int    = 5
    static let speedGoodBonus:   Int    = 2

    var correctCount: Int { results.filter(\.isCorrect).count }

    /// Base XP: 10 per correct answer.
    var xpEarned: Int { correctCount * 10 }

    /// Speed bonus XP for the question currently showing feedback.
    var currentSpeedBonus: Int {
        guard case .feedback = sessionState, isCorrectAnswer else { return 0 }
        return Self.speedBonus(for: lastQuestionTimeSpent)
    }

    /// Total speed bonus XP across all completed questions in this session.
    var bonusXP: Int {
        results.reduce(0) { acc, r in
            acc + (r.isCorrect ? Self.speedBonus(for: r.timeSpentSeconds) : 0)
        }
    }

    /// Total XP including speed bonuses — use this for display and storage.
    var totalXP: Int { xpEarned + bonusXP }

    private static func speedBonus(for seconds: Double) -> Int {
        if seconds < speedFastSeconds { return speedFastBonus }
        if seconds < speedGoodSeconds { return speedGoodBonus }
        return 0
    }

    /// Maps completed results to the Codable `QuestionResult` type for `SessionRecord`.
    var questionResults: [QuestionResult] {
        results.map {
            QuestionResult(
                templateId: $0.question.templateId,
                isCorrect: $0.isCorrect,
                timeSpentSeconds: $0.timeSpentSeconds,
                difficulty: $0.question.difficulty
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

    /// Number of questions generated per quiz session.
    static let targetQuestionCount = 8

    /// Initialiser for lesson-driven quiz sessions.
    init(
        lesson: Lesson,
        moduleColor: ModuleColor = .blue,
        sessions: [SessionRecord] = [],
        repository: ContentRepository = LocalContentRepository()
    ) {
        lessonTitle = lesson.title
        self.moduleColor = moduleColor
        self.lessonShortcut = lesson.shortcut
        self.questionTimeLimit = nil
        let ordered = sessions.isEmpty
            ? repository.templates(for: lesson.id)
            : SpacedRepetitionEngine.sortedTemplates(
                for: lesson.id,
                sessions: sessions,
                repository: repository
              )
        guard !ordered.isEmpty else {
            questions = []
            return
        }
        var built: [QuizQuestion] = []
        var usedFingerprints: Set<String> = []

        // Fingerprint = prompt + scenario combined. Many scenario-based templates
        // keep the prompt static and only vary variables in the scenario text,
        // so prompt-only dedup would treat every roll as a duplicate.
        func fingerprint(_ q: QuizQuestion) -> String {
            q.prompt + "|" + (q.scenario ?? "")
        }

        // First pass: one question per unique template — guarantees variety.
        for template in ordered {
            let q = QuizEngine.generate(from: template)
            usedFingerprints.insert(fingerprint(q))
            built.append(q)
        }

        // Second pass: fill remaining slots by reusing templates, re-rolling
        // variables up to 10× to avoid duplicate fingerprints in the same session.
        var reuseIdx = 0
        while built.count < Self.targetQuestionCount {
            let template = ordered[reuseIdx % ordered.count]
            var q = QuizEngine.generate(from: template)
            var attempts = 1
            while usedFingerprints.contains(fingerprint(q)) && attempts < 10 {
                q = QuizEngine.generate(from: template)
                attempts += 1
            }
            usedFingerprints.insert(fingerprint(q))
            built.append(q)
            reuseIdx += 1
        }
        built.shuffle()
        questions = built
    }

    /// Initialiser for pre-generated question sets (daily challenge, game modes).
    ///
    /// - Parameters:
    ///   - questions: Pre-built question array.
    ///   - title: Display title shown in the quiz header.
    ///   - shortcut: Hint/shortcut text shown in the hint section.
    ///   - moduleColor: Accent color for the quiz UI.
    ///   - questionTimeLimit: Optional per-question countdown in seconds (Speed Drill = 15s).
    init(
        questions: [QuizQuestion],
        title: String,
        shortcut: String,
        moduleColor: ModuleColor = .blue,
        questionTimeLimit: TimeInterval? = nil
    ) {
        lessonTitle = title
        self.moduleColor = moduleColor
        self.lessonShortcut = shortcut
        self.questions = questions
        self.questionTimeLimit = questionTimeLimit
        // Start countdown for first question if a time limit is set.
        if questionTimeLimit != nil {
            questionTimeRemaining = questionTimeLimit!
        }
    }

    // MARK: - Per-question timer management

    /// Starts (or restarts) the per-question countdown. No-op if no time limit is set.
    private func startQuestionTimer() {
        guard let limit = questionTimeLimit else { return }
        questionTimeRemaining = limit
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled && self.questionTimeRemaining > 0 {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                self.questionTimeRemaining = max(0, self.questionTimeRemaining - 0.1)
            }
            guard !Task.isCancelled else { return }
            self.handleTimeout()
        }
    }

    /// Cancels the current countdown (called when user answers before time runs out).
    private func cancelQuestionTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    /// Called when the countdown hits zero. Marks the question as wrong and shows feedback.
    private func handleTimeout() {
        switch sessionState {
        case .question, .answered:
            // Time's up — always wrong, regardless of any selection made.
            lastQuestionTimeSpent = questionTimeLimit ?? 0
            sessionState = .feedback(UUID())  // UUID won't match correctChoiceId → wrong
        default:
            break
        }
    }

    func revealHint() {
        guard !hintRevealed else { return }
        hintRevealed = true
    }

    // MARK: - Actions

    func select(_ choiceId: UUID) {
        switch sessionState {
        case .question, .answered:
            sessionState = .answered(choiceId)
        default:
            return
        }
    }

    func checkAnswer() {
        cancelQuestionTimer()
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
        // Start tracking feedback viewing time (untimed sessions only).
        if questionTimeLimit == nil {
            feedbackEnteredAt = Date()
        }
    }

    func appendDigit(_ digit: String) {
        guard freeEntryText.count < 10 else { return }
        if digit == "." {
            guard !freeEntryText.contains(".") else { return }
            freeEntryText += freeEntryText.isEmpty ? "0." : "."
        } else {
            if freeEntryText == "0" { freeEntryText = "" }
            freeEntryText += digit
        }
    }

    func deleteDigit() {
        guard !freeEntryText.isEmpty else { return }
        freeEntryText.removeLast()
    }

    func advance() {
        guard case .feedback(let id) = sessionState else { return }
        // Accumulate how long the user spent on this feedback screen.
        if questionTimeLimit == nil, let entered = feedbackEnteredAt {
            totalFeedbackDuration += Date().timeIntervalSince(entered)
            feedbackEnteredAt = nil
        }
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
            questionStartTime = Date()
            startQuestionTimer()
        } else {
            stoppedAt = Date()
            sessionState = .complete
        }
    }

    // MARK: - Lifecycle

    func startSession() {
        // Called after the view appears — starts the first question's timer.
        startQuestionTimer()
    }
}
