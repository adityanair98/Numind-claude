import Foundation
import UIKit

/// State and logic for a Blitz mode session.
///
/// Blitz: 60-second sprint where the player answers as many MCQ questions as possible.
/// Each answer is auto-submitted on tap (no "Check answer" step). A brief 0.5s
/// flash shows correct (green) / wrong (red) before the next question loads.
@MainActor
final class BlitzViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum BlitzState: Equatable {
        case ready              // before tapping Start
        case playing            // timer running, question visible
        case flashing(Bool)    // 0.5s result flash (true = correct)
        case complete           // timer reached zero
    }

    // MARK: - Input / config

    let totalTime: TimeInterval = 60
    let previousBest: Int

    // MARK: - Published state

    @Published private(set) var state: BlitzState = .ready
    @Published private(set) var timeRemaining: TimeInterval = 60
    @Published private(set) var score: Int = 0          // correct answers
    @Published private(set) var totalAnswered: Int = 0
    @Published private(set) var currentQuestion: QuizQuestion?

    // MARK: - Private

    private var questions: [QuizQuestion]
    private var queueIndex: Int = 0
    private var countdownTask: Task<Void, Never>?
    private var flashTask: Task<Void, Never>?
    private(set) var results: [QuestionResult] = []
    private var questionStartTime: Date = Date()

    // MARK: - Computed

    var accuracy: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(score) / Double(totalAnswered)
    }

    var xpEarned: Int { score * 10 }

    var isNewBest: Bool { score > previousBest }

    // MARK: - Init

    init(questions: [QuizQuestion], previousBest: Int = 0) {
        self.questions = questions
        self.previousBest = previousBest
        self.currentQuestion = questions.first
    }

    // MARK: - Public API

    /// Begin the 60-second countdown and show the first question.
    func start() {
        guard case .ready = state else { return }
        state = .playing
        questionStartTime = Date()
        startCountdown()
    }

    /// Called when the user taps an MCQ option. Immediately evaluates the answer,
    /// records the result, then flashes for 0.5s before advancing.
    func select(_ choiceId: UUID) {
        guard case .playing = state, let question = currentQuestion else { return }
        guard timeRemaining > 0 else { return }

        let isCorrect = choiceId == question.correctChoiceId
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        if isCorrect { score += 1 }
        totalAnswered += 1

        results.append(QuestionResult(
            templateId: question.templateId,
            isCorrect: isCorrect,
            timeSpentSeconds: timeSpent
        ))

        state = .flashing(isCorrect)
        UIImpactFeedbackGenerator(style: isCorrect ? .medium : .rigid).impactOccurred()

        flashTask?.cancel()
        flashTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self.advanceToNext()
        }
    }

    /// Reset for "Play again" — uses a newly generated question queue.
    func reset(questions: [QuizQuestion]) {
        countdownTask?.cancel()
        flashTask?.cancel()
        self.questions = questions
        queueIndex = 0
        score = 0
        totalAnswered = 0
        results = []
        timeRemaining = totalTime
        state = .ready
        currentQuestion = questions.first
    }

    // MARK: - Private

    private func advanceToNext() {
        guard case .flashing = state else { return }

        if timeRemaining <= 0 {
            endGame()
            return
        }

        queueIndex += 1
        guard queueIndex < questions.count else {
            // Ran out of pre-generated questions — shouldn't happen with queueSize = 45.
            endGame()
            return
        }

        currentQuestion = questions[queueIndex]
        questionStartTime = Date()
        state = .playing
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while !Task.isCancelled && self.timeRemaining > 0 {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                self.timeRemaining = max(0, self.timeRemaining - 0.1)
            }
            guard !Task.isCancelled else { return }
            self.endGame()
        }
    }

    private func endGame() {
        flashTask?.cancel()
        countdownTask?.cancel()
        timeRemaining = 0
        state = .complete
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
