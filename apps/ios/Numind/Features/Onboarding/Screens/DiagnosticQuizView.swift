import SwiftUI

/// Screen 16 — Diagnostic-as-demo (8 questions, choice cards).
///
/// The diagnostic carries the end-of-funnel paywall, so it has to demo the
/// product, not feel like a test:
/// - the GOAL RING fills live at the top (one segment per question — the
///   daily habit mechanic, experienced before we ask for commitment)
/// - after an answer it is HONEST: the correct choice always lights teal, a
///   wrong pick is flagged amber (never red), and a result strip names the
///   answer — warmth comes from the copy, not from hiding the result
/// - then the shortcut/move reveal shows the thing the subscription buys
/// - capability placement language, never points or grades
struct DiagnosticQuizView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private var currentItem: DiagnosticQuestionBuilder.TaggedQuestion? {
        guard viewModel.diagnosticIndex < viewModel.diagnosticItems.count else { return nil }
        return viewModel.diagnosticItems[viewModel.diagnosticIndex]
    }

    private var questionNumber: Int { viewModel.diagnosticIndex + 1 }
    private var totalQuestions: Int { viewModel.diagnosticItems.count }

    /// Ring fills per ANSWERED question — practice counts, not correctness,
    /// exactly like the real daily ring.
    private var ringProgress: Double {
        guard totalQuestions > 0 else { return 0 }
        let answered = viewModel.diagnosticIndex + (viewModel.diagnosticReveal != nil ? 1 : 0)
        return Double(answered) / Double(totalQuestions)
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            if let item = currentItem {
                VStack(alignment: .leading, spacing: 0) {
                    header(item)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            questionCard(item)
                                .padding(.top, 18)

                            choices(item)
                                .padding(.top, 16)

                            if viewModel.diagnosticReveal == nil {
                                Text("Tap your best guess \u{2014} we\u{2019}ll show you the move either way.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 18)
                            } else if let reveal = viewModel.diagnosticReveal {
                                resultStrip(reveal)
                                    .padding(.top, 16)
                                moveCard(reveal)
                                    .padding(.top, 12)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 40)
                    }

                    if viewModel.diagnosticReveal != nil {
                        onboardingFooter(dark: false) {
                            PillButton(questionNumber == totalQuestions ? "Finish" : "Next") {
                                viewModel.advanceDiagnostic()
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.26), value: viewModel.diagnosticReveal)
    }

    // MARK: - Header

    private func header(_ item: DiagnosticQuestionBuilder.TaggedQuestion) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Question \(questionNumber) of \(totalQuestions)")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.mutedText)
                if item.isApplication {
                    Text("What would you do?")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.Colors.warmOrange)
                }
            }
            Spacer()
            GoalRing(progress: ringProgress, isClosed: ringProgress >= 1.0, size: 40)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 4)
    }

    // MARK: - Question Card

    private func questionCard(_ item: DiagnosticQuestionBuilder.TaggedQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.lessonTitle)
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Colors.mindTeal)

            Text(item.question.prompt)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
                .lineSpacing(3)
                .padding(.top, 4)

            if let scenario = item.question.scenario {
                Text(scenario)
                    .font(.system(size: 17, weight: .bold))
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

    // MARK: - Choices

    /// How a choice should render once an answer is locked in.
    fileprivate enum ChoiceMark { case interactive, correct, wrongPick, dimmed }

    private func mark(for choice: QuizQuestion.Choice) -> ChoiceMark {
        guard let reveal = viewModel.diagnosticReveal else { return .interactive }
        if choice.id == reveal.correctChoiceId { return .correct }
        if choice.id == reveal.selectedChoiceId { return .wrongPick }
        return .dimmed
    }

    /// Decision items get a single readable column; numerical items keep the
    /// compact 2×2 money grid.
    @ViewBuilder
    private func choices(_ item: DiagnosticQuestionBuilder.TaggedQuestion) -> some View {
        let letters = ["A", "B", "C", "D"]
        let list = Array(item.question.choices.prefix(4))

        if item.isApplication {
            VStack(spacing: 10) {
                ForEach(Array(list.enumerated()), id: \.element.id) { _, choice in
                    decisionCell(choice)
                }
            }
        } else {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12) {
                ForEach(Array(list.enumerated()), id: \.element.id) { index, choice in
                    numericCell(index < letters.count ? letters[index] : "", choice)
                }
            }
        }
    }

    private func numericCell(_ letter: String, _ choice: QuizQuestion.Choice) -> some View {
        let state = mark(for: choice)
        return Button {
            viewModel.answerDiagnostic(choiceId: choice.id)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(letter)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(state == .correct ? Theme.Colors.growthGreen : Theme.Colors.mindTeal)
                        .frame(width: 28, height: 28)
                        .background(state == .correct ? Theme.Colors.mindTeal.opacity(0.18) : Theme.Colors.mindTealTint)
                        .clipShape(Circle())
                    Spacer()
                    markBadge(state)
                }
                Spacer(minLength: 8)
                Text(choice.text)
                    .font(.system(size: choice.text.count > 24 ? 14 : 22,
                                  weight: .bold, design: .monospaced))
                    .foregroundStyle(state == .correct ? Theme.Colors.growthGreen : Theme.Colors.deepNavy)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .frame(minHeight: 88)
            .modifier(ChoiceChrome(state: state))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.diagnosticReveal != nil)
    }

    private func decisionCell(_ choice: QuizQuestion.Choice) -> some View {
        let state = mark(for: choice)
        return Button {
            viewModel.answerDiagnostic(choiceId: choice.id)
        } label: {
            HStack(spacing: 12) {
                Text(choice.text)
                    .font(.system(size: 14, weight: state == .correct ? .semibold : .regular))
                    .foregroundStyle(state == .correct ? Theme.Colors.growthGreen : Theme.Colors.deepNavy)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                markBadge(state)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(ChoiceChrome(state: state))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.diagnosticReveal != nil)
    }

    @ViewBuilder
    private func markBadge(_ state: ChoiceMark) -> some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Theme.Colors.growthGreen)
                .clipShape(Circle())
        case .wrongPick:
            Text("YOUR PICK")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.Colors.warmOrange)
                .fixedSize()
        default:
            EmptyView()
        }
    }

    // MARK: - Result strip + reveal

    private func resultStrip(_ reveal: DiagnosticReveal) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: reveal.correct ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(reveal.correct ? Theme.Colors.growthGreen : Theme.Colors.warmOrange)
            Text(resultText(reveal))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(reveal.correct ? Theme.Colors.growthGreen : Theme.Colors.warmOrange)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(reveal.correct ? Theme.Colors.mindTealTint : Theme.Colors.warmOrangeTint)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func resultText(_ reveal: DiagnosticReveal) -> String {
        if reveal.correct {
            return reveal.isApplication ? "Nailed it \u{2014} that\u{2019}s the move." : "Nailed it \u{2014} that\u{2019}s the number."
        }
        let label = reveal.isApplication ? "the move is" : "the answer is"
        return "Not quite \u{2014} \(label) \(reveal.correctChoiceText). This is exactly one we\u{2019}ll build with you."
    }

    private func moveCard(_ reveal: DiagnosticReveal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Numerical items have a shortcut; decision items have a move.
            // Both are readiness, neither is a speed claim.
            Text(reveal.isApplication ? "THE MOVE" : "THE SHORTCUT")
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(Theme.Colors.insightText)
            Text(reveal.shortcut)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.Colors.insightYellowTint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Shared card chrome for a diagnostic choice in each marked state.
private struct ChoiceChrome: ViewModifier {
    let state: DiagnosticQuizView.ChoiceMark

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(stroke, lineWidth: strokeWidth)
            )
            .opacity(state == .dimmed ? 0.5 : 1)
            .shadow(color: .black.opacity(state == .interactive ? 0.04 : 0), radius: 3, x: 0, y: 1)
    }

    private var fill: Color {
        switch state {
        case .correct:   return Theme.Colors.mindTealTint
        case .wrongPick: return Theme.Colors.warmOrangeTint
        default:         return Theme.Colors.cardBackground
        }
    }
    private var stroke: Color {
        switch state {
        case .correct:   return Theme.Colors.mindTeal
        case .wrongPick: return Theme.Colors.warmOrange
        default:         return Theme.Colors.hairline
        }
    }
    private var strokeWidth: CGFloat {
        (state == .correct || state == .wrongPick) ? 1.5 : 1
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
