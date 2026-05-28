import Foundation

@MainActor
final class QuizSessionViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum SessionState: Equatable {
        case question
        case answered(UUID)      // user picked a choice
        case feedback(UUID)      // answer checked, showing result
        case motivator(MotivatorCheckpoint)  // mid-session checkpoint
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
    /// Money-moment sentence for this lesson (Phase 6c). Nil for review/blitz
    /// sessions that aren't tied to a single lesson.
    let lessonRealWorldHint: String?
    /// Calculator slug for this lesson (Phase 7a), nil for review/blitz sessions.
    let lessonRelatedCalculatorSlug: String?
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

    // MARK: - Motivator state

    /// Question indices where full-screen motivators were shown.
    private(set) var motivatorsShownAt: [Int] = []
    /// Question indices where inline encouragement was shown.
    private(set) var inlineShownAt: [Int] = []
    /// Inline encouragement to display over the feedback screen (nil = none).
    @Published private(set) var inlineEncouragement: InlineEncouragement? = nil
    /// Content repository for looking up lesson shortcuts (coaching tips).
    private let repository: ContentRepository

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

    /// Default question count for non-lesson contexts (Speed Drill, etc.).
    static let defaultQuestionCount = 8

    /// Question count for a lesson session. First attempt = 5 (gentler intro).
    /// Subsequent attempts = 8 (full session).
    static func lessonQuestionCount(
        lessonId: String,
        moduleId: String,
        sessions: [SessionRecord],
        signals: OnboardingSignals?
    ) -> Int {
        let hasAttempted = sessions.contains { $0.lessonId == lessonId }
        if !hasAttempted {
            // First attempt — check diagnostic calibration
            if let difficulty = signals?.startingDifficulties[moduleId] {
                switch difficulty {
                case .intermediate: return 5  // Strong — shorter session
                case .foundation:   return 6  // Decent — slightly shorter
                case .beginner:     return 8  // Needs work — full session
                }
            }
            return 5 // No diagnostic data — gentle first session
        }
        return 8 // Subsequent attempts — full session
    }

    /// Initialiser for lesson-driven quiz sessions.
    init(
        lesson: Lesson,
        moduleColor: ModuleColor = .blue,
        sessions: [SessionRecord] = [],
        signals: OnboardingSignals? = nil,
        repository: ContentRepository = LocalContentRepository()
    ) {
        lessonTitle = lesson.title
        self.moduleColor = moduleColor
        self.lessonShortcut = lesson.shortcut
        self.lessonRealWorldHint = lesson.realWorldHint
        self.lessonRelatedCalculatorSlug = lesson.relatedCalculatorSlug
        self.questionTimeLimit = nil
        self.repository = repository
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

        let targetCount = Self.lessonQuestionCount(
            lessonId: lesson.id,
            moduleId: lesson.moduleId,
            sessions: sessions,
            signals: signals
        )

        var built: [QuizQuestion] = []
        var usedFingerprints: Set<String> = []

        // Fingerprint = prompt + scenario combined. Many scenario-based templates
        // keep the prompt static and only vary variables in the scenario text,
        // so prompt-only dedup would treat every roll as a duplicate.
        func fingerprint(_ q: QuizQuestion) -> String {
            q.prompt + "|" + (q.scenario ?? "")
        }

        // First pass: one question per unique template — guarantees variety.
        // Use diagnostic-calibrated difficulty for first encounters.
        for template in ordered.prefix(targetCount) {
            let diff = AdaptiveDifficultyEngine.targetDifficulty(
                for: template.id,
                moduleId: lesson.moduleId,
                in: sessions,
                signals: signals
            )
            let q = QuizEngine.generate(from: template, targetDifficulty: diff)
            usedFingerprints.insert(fingerprint(q))
            built.append(q)
        }

        // Second pass: fill remaining slots by reusing templates, re-rolling
        // variables up to 10× to avoid duplicate fingerprints in the same session.
        var reuseIdx = 0
        while built.count < targetCount {
            let template = ordered[reuseIdx % ordered.count]
            let diff = AdaptiveDifficultyEngine.targetDifficulty(
                for: template.id,
                moduleId: lesson.moduleId,
                in: sessions,
                signals: signals
            )
            var q = QuizEngine.generate(from: template, targetDifficulty: diff)
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
    ///   - repository: Content repository for coaching tip lookups.
    init(
        questions: [QuizQuestion],
        title: String,
        shortcut: String,
        moduleColor: ModuleColor = .blue,
        questionTimeLimit: TimeInterval? = nil,
        repository: ContentRepository = LocalContentRepository()
    ) {
        lessonTitle = title
        self.moduleColor = moduleColor
        self.lessonShortcut = shortcut
        self.lessonRealWorldHint = nil
        self.lessonRelatedCalculatorSlug = nil
        self.questions = questions
        self.questionTimeLimit = questionTimeLimit
        self.repository = repository
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

        // Evaluate inline encouragement for correct answers.
        if isCorrectAnswer {
            evaluateInlineEncouragement()
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
        // ── Dismissing a motivator → proceed to next question ──
        if case .motivator = sessionState {
            let next = currentIndex + 1
            currentIndex = next
            sessionState = .question
            hintRevealed = false
            freeEntryText = ""
            questionStartTime = Date()
            startQuestionTimer()
            return
        }

        guard case .feedback(let id) = sessionState else { return }

        // Accumulate how long the user spent on this feedback screen.
        if questionTimeLimit == nil, let entered = feedbackEnteredAt {
            totalFeedbackDuration += Date().timeIntervalSince(entered)
            feedbackEnteredAt = nil
        }

        // Clear inline encouragement
        inlineEncouragement = nil

        results.append(QuizResult(
            question: currentQuestion,
            selectedChoiceId: id,
            timeSpentSeconds: lastQuestionTimeSpent
        ))

        let next = currentIndex + 1

        // ── HARD CONSTRAINT: never show motivator after the last question ──
        guard next < questions.count else {
            stoppedAt = Date()
            sessionState = .complete
            return
        }

        // ── Evaluate motivator checkpoint ──
        let correctFlags = results.map(\.isCorrect)
        if let type = MotivatorEngine.evaluate(
            correctFlags: correctFlags,
            totalQuestions: questions.count,
            justAnsweredIndex: currentIndex,
            motivatorsShownAt: motivatorsShownAt,
            isSpeedDrill: questionTimeLimit != nil
        ) {
            let checkpoint = buildCheckpoint(type: type)
            motivatorsShownAt.append(currentIndex)
            sessionState = .motivator(checkpoint)
            return
        }

        // Normal advance
        currentIndex = next
        sessionState = .question
        hintRevealed = false
        freeEntryText = ""
        questionStartTime = Date()
        startQuestionTimer()
    }

    // MARK: - Motivator checkpoint builder

    /// Builds a fully populated `MotivatorCheckpoint` for the given type,
    /// resolving copy, stats, and coaching tips from the current session state.
    private func buildCheckpoint(type: MotivatorType) -> MotivatorCheckpoint {
        var cp = MotivatorCheckpoint(type: type)
        let answeredCount = results.count
        let correctCount = results.filter(\.isCorrect).count
        cp.accuracy = answeredCount > 0 ? Double(correctCount) / Double(answeredCount) : 0
        cp.total = questions.count
        cp.completed = answeredCount

        switch type {
        case .momentum:
            let streak = consecutiveCorrectFromEnd()
            cp.streak = streak
            let lastN = results.suffix(streak)
            let avgLast = lastN.map(\.timeSpentSeconds).reduce(0, +) / Double(lastN.count)
            cp.avgTimeLastN = avgLast
            let sessionAvg = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
            cp.paceImproving = avgLast < sessionAvg
            let copy = MotivatorCopy.momentum(streak: streak)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta
            cp.secondaryLabel = "See progress"

        case .coaching:
            // Find most recent wrong answer's template → look up lesson for tip
            if let wrongResult = results.last(where: { !$0.isCorrect }),
               let lesson = repository.lesson(forTemplateId: wrongResult.question.templateId) {
                cp.tipTitle = lesson.shortcut
                cp.example = lesson.example
            } else {
                cp.tipTitle = lessonShortcut
            }
            let copy = MotivatorCopy.coaching()
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.ctaLabel = "Keep going"

        case .progress:
            let copy = MotivatorCopy.progress(completed: answeredCount, total: questions.count)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta
            cp.avgTime = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
            cp.secondaryLabel = "View progress"

        case .nearFinish:
            let remaining = questions.count - answeredCount
            let copy = MotivatorCopy.nearFinish(remaining: remaining)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta
            cp.secondaryLabel = "See today's progress"
            // dailyStreak is set by the view from ProgressStore
        }

        return cp
    }

    /// Count of consecutive correct answers from the end of results.
    private func consecutiveCorrectFromEnd() -> Int {
        var count = 0
        for result in results.reversed() {
            if result.isCorrect { count += 1 } else { break }
        }
        return count
    }

    /// Evaluate and set inline encouragement after a correct answer.
    /// Called from `checkAnswer()` when the answer is correct.
    private func evaluateInlineEncouragement() {
        let streak = consecutiveCorrectFromEnd() + 1 // +1 because current result not yet in results
        if MotivatorEngine.evaluateInline(
            isCorrect: true,
            timeSpent: lastQuestionTimeSpent,
            hintWasRevealed: hintRevealed,
            consecutiveCorrect: streak,
            inlineShownAt: inlineShownAt,
            currentIndex: currentIndex
        ) {
            let copy = MotivatorCopy.inlineEncouragement()
            inlineEncouragement = InlineEncouragement(headline: copy.headline, subtitle: copy.subtitle)
            inlineShownAt.append(currentIndex)
        }
    }

    // MARK: - Lifecycle

    func startSession() {
        // Called after the view appears — starts the first question's timer.
        startQuestionTimer()
    }
}
