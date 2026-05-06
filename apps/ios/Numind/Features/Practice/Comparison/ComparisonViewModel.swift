import Foundation
import UIKit

/// A pair of questions shown side-by-side — the user taps the one with the larger answer.
struct ComparisonPair: Identifiable {
    let id = UUID()
    let templateIdA: String
    let templateIdB: String
    let promptA: String
    let promptB: String
    let valueA: Double
    let valueB: Double
    /// Index of the correct side: 0 = left (A), 1 = right (B).
    var correctSide: Int { valueA >= valueB ? 0 : 1 }
}

/// State and logic for a Comparison Snap session.
///
/// Two problems side by side — tap the bigger one. 15 questions, 8s per question.
@MainActor
final class ComparisonViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum CompState: Equatable {
        case playing
        case flashing(Bool)    // brief flash (true = user was correct)
        case timeout           // ran out of time on this question
        case complete
    }

    // MARK: - Config

    let questionTimeLimit: TimeInterval = 8

    // MARK: - Published

    @Published private(set) var state: CompState = .playing
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var totalAnswered: Int = 0
    @Published private(set) var timeRemaining: TimeInterval = 8

    // MARK: - Data

    let pairs: [ComparisonPair]
    private(set) var results: [QuestionResult] = []
    private var questionStartTime: Date = Date()
    private var flashTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?

    var currentPair: ComparisonPair? {
        currentIndex < pairs.count ? pairs[currentIndex] : nil
    }

    let previousBest: Int

    var total: Int { pairs.count }
    var accuracy: Double { totalAnswered > 0 ? Double(score) / Double(totalAnswered) : 0 }
    var xpEarned: Int { score * 10 }
    var isNewBest: Bool { score > previousBest && score > 0 }

    // MARK: - Init

    init(pairs: [ComparisonPair], previousBest: Int = 0) {
        self.pairs = pairs
        self.previousBest = previousBest
    }

    /// Build comparison pairs from templates. Each pair uses two different templates.
    static func generatePairs(
        from templates: [QuizTemplate],
        count: Int = 15
    ) -> [ComparisonPair] {
        let shuffled = templates.shuffled()
        guard shuffled.count >= 2 else { return [] }

        var pairs: [ComparisonPair] = []
        var usedFingerprints: Set<String> = []
        var idx = 0

        while pairs.count < count && idx + 1 < shuffled.count {
            // Re-roll each side up to 10× to avoid duplicate prompt+scenario combos.
            var qA = QuizEngine.generate(from: shuffled[idx])
            var fpA = qA.prompt + "|" + (qA.scenario ?? "")
            var attA = 1
            while usedFingerprints.contains(fpA) && attA < 10 {
                qA = QuizEngine.generate(from: shuffled[idx])
                fpA = qA.prompt + "|" + (qA.scenario ?? "")
                attA += 1
            }

            var qB = QuizEngine.generate(from: shuffled[idx + 1])
            var fpB = qB.prompt + "|" + (qB.scenario ?? "")
            var attB = 1
            while usedFingerprints.contains(fpB) && attB < 10 {
                qB = QuizEngine.generate(from: shuffled[idx + 1])
                fpB = qB.prompt + "|" + (qB.scenario ?? "")
                attB += 1
            }

            // Skip if both values are equal — there's no "bigger" answer.
            if qA.correctValue != qB.correctValue {
                usedFingerprints.insert(fpA)
                usedFingerprints.insert(fpB)
                pairs.append(ComparisonPair(
                    templateIdA: shuffled[idx].id,
                    templateIdB: shuffled[idx + 1].id,
                    promptA: qA.prompt,
                    promptB: qB.prompt,
                    valueA: qA.correctValue,
                    valueB: qB.correctValue
                ))
            }
            idx += 2

            // Wrap around if needed
            if idx >= shuffled.count { idx = 0 }
            if pairs.count > 0 && idx == 0 { break } // prevent infinite loop
        }

        return pairs
    }

    // MARK: - Lifecycle

    func start() {
        questionStartTime = Date()
        startTimer()
    }

    // MARK: - Actions

    /// User picks side 0 (left/A) or 1 (right/B).
    func selectSide(_ side: Int) {
        guard case .playing = state, let pair = currentPair else { return }
        cancelTimer()

        let isCorrect = side == pair.correctSide
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        if isCorrect { score += 1 }
        totalAnswered += 1

        // Record under the template of whichever side the user picked
        results.append(QuestionResult(
            templateId: side == 0 ? pair.templateIdA : pair.templateIdB,
            isCorrect: isCorrect,
            timeSpentSeconds: timeSpent
        ))

        state = .flashing(isCorrect)
        UIImpactFeedbackGenerator(style: isCorrect ? .medium : .rigid).impactOccurred()

        flashTask?.cancel()
        flashTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            self.advance()
        }
    }

    // MARK: - Private

    private func advance() {
        let next = currentIndex + 1
        if next < pairs.count {
            currentIndex = next
            questionStartTime = Date()
            state = .playing
            startTimer()
        } else {
            state = .complete
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func startTimer() {
        timeRemaining = questionTimeLimit
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled && self.timeRemaining > 0 {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                self.timeRemaining = max(0, self.timeRemaining - 0.1)
            }
            guard !Task.isCancelled else { return }
            self.handleTimeout()
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func handleTimeout() {
        guard case .playing = state, let pair = currentPair else { return }

        totalAnswered += 1
        results.append(QuestionResult(
            templateId: pair.templateIdA,
            isCorrect: false,
            timeSpentSeconds: questionTimeLimit
        ))

        state = .timeout
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        flashTask?.cancel()
        flashTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            self.advance()
        }
    }
}
