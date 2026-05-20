import SwiftUI

/// Screen 16 — Diagnostic Quiz (8 questions, 2x2 choice grid)
/// Lightweight diagnostic mode — no XP, no motivators, no feedback phase.
struct DiagnosticQuizView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private var currentQuestion: QuizQuestion? {
        guard viewModel.diagnosticIndex < viewModel.diagnosticQuestions.count else { return nil }
        return viewModel.diagnosticQuestions[viewModel.diagnosticIndex]
    }

    private var questionNumber: Int {
        viewModel.diagnosticIndex + 1
    }

    private var totalQuestions: Int {
        viewModel.diagnosticQuestions.count
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            if let question = currentQuestion {
                VStack(alignment: .leading, spacing: 0) {
                    // Header: counter + dots
                    HStack {
                        Text("Question \(questionNumber) of \(totalQuestions)")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundStyle(Theme.Colors.mutedText)
                        Spacer()
                        DotProgress(current: questionNumber, total: totalQuestions)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, 4)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Question card
                            questionCard(question)
                                .padding(.top, 22)

                            // 2x2 choice grid
                            choiceGrid(question)
                                .padding(.top, 16)

                            Text("Tap your best guess \u{2014} no scoring, no explanation.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.top, 18)
                        }
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 60)
                    }
                }

                // Flash overlay
                if let flash = viewModel.diagnosticFlash {
                    flashOverlay(correct: flash.correct)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.2), value: viewModel.diagnosticFlash)
                }
            }
        }
    }

    // MARK: - Question Card

    private var currentModuleId: String? {
        guard viewModel.diagnosticIndex < viewModel.diagnosticModuleIds.count else { return nil }
        return viewModel.diagnosticModuleIds[viewModel.diagnosticIndex]
    }

    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let moduleId = currentModuleId {
                Text(moduleId.capitalized)
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.primaryBlue)
            }

            Text(question.prompt)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
                .lineSpacing(3)
                .padding(.top, 4)

            if let scenario = question.scenario {
                Text(scenario)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Choice Grid

    private func choiceGrid(_ question: QuizQuestion) -> some View {
        let letters = ["A", "B", "C", "D"]
        let choices = Array(question.choices.prefix(4))

        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 12) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, choice in
                Button {
                    viewModel.answerDiagnostic(choiceId: choice.id)
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(index < letters.count ? letters[index] : "")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                            .frame(width: 28, height: 28)
                            .background(Theme.Colors.primaryBlueTint)
                            .clipShape(Circle())

                        Spacer()

                        Text(choice.text)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .frame(minHeight: 88)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.diagnosticFlash != nil)
            }
        }
    }

    // MARK: - Flash Overlay

    private func flashOverlay(correct: Bool) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                correct
                    ? Theme.Colors.mindTeal.opacity(0.12)
                    : Theme.Colors.errorSoftRed.opacity(0.12)
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

#Preview {
    DiagnosticQuizView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        )
    )
}
