import SwiftUI

/// Screen 16 — Diagnostic-as-demo (8 questions, 2x2 choice grid).
///
/// The diagnostic carries the end-of-funnel paywall, so it has to demo the
/// product, not feel like a test:
/// - the GOAL RING fills live at the top (one segment per question — the
///   daily habit mechanic, experienced before we ask for commitment)
/// - after EVERY answer a shortcut reveal card shows the mental-math move
///   behind the question (the thing the subscription buys)
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
                    // Header: counter + live goal ring
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
                        GoalRing(
                            progress: ringProgress,
                            isClosed: ringProgress >= 1.0,
                            size: 40
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, 4)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            questionCard(item)
                                .padding(.top, 18)

                            choiceGrid(item.question)
                                .padding(.top, 16)

                            Text("Tap your best guess \u{2014} we\u{2019}ll show you the shortcut either way.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.top, 18)
                        }
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 60)
                    }
                }

                // Shortcut reveal — the demo beat
                if let reveal = viewModel.diagnosticReveal {
                    revealOverlay(reveal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeOut(duration: 0.28), value: viewModel.diagnosticReveal)
    }

    // MARK: - Question Card

    private func questionCard(_ item: DiagnosticQuestionBuilder.TaggedQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.lessonTitle)
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Colors.primaryBlue)

            Text(item.question.prompt)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
                .lineSpacing(3)
                .padding(.top, 4)

            if let scenario = item.question.scenario {
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
                            .font(.system(size: choice.text.count > 24 ? 14 : 22,
                                          weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .multilineTextAlignment(.leading)
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
                .disabled(viewModel.diagnosticReveal != nil)
            }
        }
    }

    // MARK: - Shortcut Reveal

    private func revealOverlay(_ reveal: DiagnosticReveal) -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: reveal.correct ? "checkmark.circle.fill" : "lightbulb.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(reveal.correct ? Theme.Colors.growthGreen : Theme.Colors.warmOrange)
                    Text(reveal.correct
                         ? "\(reveal.lessonTitle) \u{2014} solid start"
                         : "\(reveal.lessonTitle) \u{2014} we\u{2019}ll build this one")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("THE SHORTCUT")
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
                .padding(14)
                .background(Theme.Colors.insightYellowTint)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                PillButton(questionNumber == totalQuestions ? "Finish" : "Next") {
                    viewModel.advanceDiagnostic()
                }
            }
            .padding(20)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: -4)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { } // swallow taps behind the card
        )
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
