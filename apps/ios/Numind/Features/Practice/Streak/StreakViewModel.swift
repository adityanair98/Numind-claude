import Foundation
import UIKit

/// State and logic for a Streak mode session.
///
/// One wrong answer ends the game. Score = consecutive correct answers.
/// No timer — the player can take as long as they want, but can't miss.
@MainActor
final class StreakViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum StreakState: Equatable {
        case playing
        case flashing(Bool)    // 0.5s result flash (true = correct)
        case gameOver          // one wrong answer or out of questions
    }

    // MARK: - Config

    let previousBest: Int

    // MARK: - Published

    @Published private(set) var state: StreakState = .playing
    @Published private(set) var streakCount: Int = 0
    @Published private(set) var currentQuestion: QuizQuestion?

    // MARK: - Private

    private var questions: [QuizQuestion]
    private var queueIndex: Int = 0
    private var flashTask: Task<Void, Never>?
    private(set) var results: [QuestionResult] = []
    private var questionStartTime: Date = Date()

    // MARK: - Computed

    var isNewBest: Bool { streakCount > previousBest }
    var xpEarned: Int { streakCount * 10 }

    // MARK: - Init

    init(questions: [QuizQuestion], previousBest: Int = 0) {
        self.questions = questions
        self.previousBest = previousBest
        self.currentQuestion = questions.first
    }

    // MARK: - Public API

    /// Called when the user taps an MCQ option.
    func select(_ choiceId: UUID) {
        guard case .playing = state, let question = currentQuestion else { return }

        let isCorrect = choiceId == question.correctChoiceId
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        results.append(QuestionResult(
            templateId: question.templateId,
            isCorrect: isCorrect,
            timeSpentSeconds: timeSpent
        ))

        if isCorrect {
            streakCount += 1
            state = .flashing(true)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            flashTask?.cancel()
            flashTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                self.advanceToNext()
            }
        } else {
            state = .flashing(false)
            UINotificationFeedbackGenerator().notificationOccurred(.error)

            flashTask?.cancel()
            flashTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(800))
                guard !Task.isCancelled else { return }
                self.state = .gameOver
            }
        }
    }

    /// Reset for "Try again" — uses a newly generated question queue.
    func reset(questions: [QuizQuestion]) {
        flashTask?.cancel()
        self.questions = questions
        queueIndex = 0
        streakCount = 0
        results = []
        state = .playing
        currentQuestion = questions.first
        questionStartTime = Date()
    }

    // MARK: - Private

    private func advanceToNext() {
        queueIndex += 1
        guard queueIndex < questions.count else {
            // Ran out of questions — impressive!
            state = .gameOver
            return
        }
        currentQuestion = questions[queueIndex]
        questionStartTime = Date()
        state = .playing
    }
}
