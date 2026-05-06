import Foundation
import UIKit

/// A single true/false question: a completed equation that is either correct or uses a distractor.
struct TrueFalseItem: Identifiable {
    let id = UUID()
    let templateId: String
    /// Optional real-world context shown above the statement (e.g. "Your bill is $80").
    let scenario: String?
    /// The equation statement, e.g. "20% tip = $16.00"
    let statement: String
    /// Whether the displayed answer is correct.
    let isTrue: Bool
    /// The actual correct value (used for explanation).
    let correctValue: Double
    /// The answer format for display.
    let answerFormat: AnswerFormat
}

/// State and logic for a True/False Snap session.
///
/// 20 rapid-fire statements. The player taps true or false.
/// Half are correct, half use a distractor value.
@MainActor
final class TrueFalseViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum TFState: Equatable {
        case playing
        case flashing(Bool)    // brief flash showing if the user was right
        case complete
    }

    // MARK: - Published

    @Published private(set) var state: TFState = .playing
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var totalAnswered: Int = 0

    // MARK: - Data

    let items: [TrueFalseItem]
    private(set) var results: [QuestionResult] = []
    private var questionStartTime: Date = Date()
    private var flashTask: Task<Void, Never>?

    var currentItem: TrueFalseItem? {
        currentIndex < items.count ? items[currentIndex] : nil
    }

    let previousBest: Int

    var total: Int { items.count }
    var accuracy: Double { totalAnswered > 0 ? Double(score) / Double(totalAnswered) : 0 }
    var xpEarned: Int { score * 10 }
    var isNewBest: Bool { score > previousBest && score > 0 }

    // MARK: - Init

    init(items: [TrueFalseItem], previousBest: Int = 0) {
        self.items = items
        self.previousBest = previousBest
    }

    /// Build true/false items from quiz templates.
    /// Half show the correct answer, half show a distractor.
    static func generateItems(
        from templates: [QuizTemplate],
        count: Int = 20
    ) -> [TrueFalseItem] {
        let picked = Array(templates.shuffled().prefix(count))
        var items: [TrueFalseItem] = []
        var usedFingerprints: Set<String> = []

        for (i, template) in picked.enumerated() {
            // Re-roll up to 10× to avoid duplicate prompt+scenario combos.
            var question = QuizEngine.generate(from: template)
            var fp = question.prompt + "|" + (question.scenario ?? "")
            var attempts = 1
            while usedFingerprints.contains(fp) && attempts < 10 {
                question = QuizEngine.generate(from: template)
                fp = question.prompt + "|" + (question.scenario ?? "")
                attempts += 1
            }
            usedFingerprints.insert(fp)

            let showCorrect = i % 2 == 0  // alternate true/false

            if showCorrect {
                let displayValue = QuizEngine.format(question.correctValue, as: template.answerFormat)
                items.append(TrueFalseItem(
                    templateId: template.id,
                    scenario: question.scenario,
                    statement: "\(question.prompt) = \(displayValue)",
                    isTrue: true,
                    correctValue: question.correctValue,
                    answerFormat: template.answerFormat
                ))
            } else {
                // Pick a distractor from the choices
                let distractor = question.choices.first { $0.id != question.correctChoiceId }
                let displayValue = distractor?.text
                    ?? QuizEngine.format(question.correctValue * 1.1, as: template.answerFormat)
                items.append(TrueFalseItem(
                    templateId: template.id,
                    scenario: question.scenario,
                    statement: "\(question.prompt) = \(displayValue)",
                    isTrue: false,
                    correctValue: question.correctValue,
                    answerFormat: template.answerFormat
                ))
            }
        }

        return items.shuffled()
    }

    // MARK: - Actions

    func answer(isTrue userSaysTrue: Bool) {
        guard case .playing = state, let item = currentItem else { return }

        let isCorrect = (userSaysTrue == item.isTrue)
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        if isCorrect { score += 1 }
        totalAnswered += 1

        results.append(QuestionResult(
            templateId: item.templateId,
            isCorrect: isCorrect,
            timeSpentSeconds: timeSpent
        ))

        state = .flashing(isCorrect)
        UIImpactFeedbackGenerator(style: isCorrect ? .medium : .rigid).impactOccurred()

        flashTask?.cancel()
        flashTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self.advance()
        }
    }

    private func advance() {
        let next = currentIndex + 1
        if next < items.count {
            currentIndex = next
            questionStartTime = Date()
            state = .playing
        } else {
            state = .complete
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
