import SwiftUI

private let choiceKeys = ["A", "B", "C", "D"]

struct QuizSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuizSessionViewModel
    let onComplete: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            scrollContent
            footer
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.lessonTitle)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(viewModel.currentIndex + 1) / \(viewModel.total)")
                    .font(Theme.Typography.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .onChange(of: viewModel.sessionState) { _, newState in
            if case .complete = newState { onComplete() }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.sectionSpacing) {
                beadRail
                switch viewModel.sessionState {
                case .question, .answered:
                    questionContent
                case .feedback:
                    feedbackContent
                case .complete:
                    EmptyView()
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 8)
            .padding(.bottom, Theme.Spacing.buttonHeight + 52)
        }
    }

    // MARK: - Bead rail

    private var beadRail: some View {
        BeadRail(
            progress: viewModel.currentIndex + 1,
            total: viewModel.total,
            variant: .chunky
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Question content

    private var questionContent: some View {
        let q = viewModel.currentQuestion
        return VStack(spacing: Theme.Spacing.sectionSpacing) {
            // Question card
            NumindCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Question \(viewModel.currentIndex + 1)")
                        .font(Theme.Typography.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.primaryBlue)
                        .textCase(.uppercase)
                        .kerning(0.6)
                    Text(q.prompt)
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }

            // Options
            VStack(spacing: 10) {
                ForEach(Array(q.choices.enumerated()), id: \.element.id) { i, choice in
                    OptionCard(
                        key: choiceKeys[safe: i] ?? "?",
                        text: choice.text,
                        state: questionCardState(for: choice),
                        action: { viewModel.select(choice.id) }
                    )
                }
            }
        }
    }

    private func questionCardState(for choice: QuizQuestion.Choice) -> OptionCardState {
        guard let selectedId = viewModel.selectedChoiceId else { return .normal }
        return choice.id == selectedId ? .selected : .normal
    }

    // MARK: - Feedback content

    private var feedbackContent: some View {
        let q = viewModel.currentQuestion
        let isCorrect = viewModel.isCorrectAnswer
        return VStack(spacing: Theme.Spacing.sectionSpacing) {
            // Result hero
            resultHeroCard(isCorrect: isCorrect)

            // Options recap
            VStack(spacing: 10) {
                ForEach(Array(q.choices.enumerated()), id: \.element.id) { i, choice in
                    OptionCard(
                        key: choiceKeys[safe: i] ?? "?",
                        text: choice.text,
                        state: feedbackCardState(for: choice),
                        action: {}
                    )
                    .opacity(isHighlighted(choice) ? 1 : 0.45)
                }
            }

            // Explanation
            NumindCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Why")
                        .font(Theme.Typography.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.primaryBlue)
                        .textCase(.uppercase)
                        .kerning(0.6)
                    Text(q.explanation)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
        }
    }

    private func resultHeroCard(isCorrect: Bool) -> some View {
        NumindCard(background: isCorrect ? Theme.Colors.mindTealTint : Theme.Colors.errorSoftRedTint) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCorrect ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                        .frame(width: 64, height: 64)
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text(isCorrect ? "Nice — that's right." : "Not quite.")
                    .font(Theme.Typography.title)
                    .foregroundStyle(isCorrect ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                Text(isCorrect ? "+10 XP" : "Keep going")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(isCorrect ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func feedbackCardState(for choice: QuizQuestion.Choice) -> OptionCardState {
        let correctId = viewModel.currentQuestion.correctChoiceId
        let selectedId = viewModel.selectedChoiceId
        if choice.id == correctId { return .correct }
        if choice.id == selectedId { return .wrong }
        return .normal
    }

    private func isHighlighted(_ choice: QuizQuestion.Choice) -> Bool {
        let correctId = viewModel.currentQuestion.correctChoiceId
        let selectedId = viewModel.selectedChoiceId
        return choice.id == correctId || choice.id == selectedId
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            footerButton
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
                .background(Theme.Colors.softBackground)
        }
    }

    @ViewBuilder
    private var footerButton: some View {
        switch viewModel.sessionState {
        case .question:
            checkAnswerButtonView(enabled: false)
        case .answered:
            checkAnswerButtonView(enabled: true)
        case .feedback:
            PillButton("Continue") { viewModel.advance() }
        case .complete:
            EmptyView()
        }
    }

    private func checkAnswerButtonView(enabled: Bool) -> some View {
        Button { viewModel.checkAnswer() } label: {
            Text("Check answer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(enabled ? .white : Theme.Colors.mutedText)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Spacing.buttonHeight)
                .background(enabled ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// Safe subscript for the keys array
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
