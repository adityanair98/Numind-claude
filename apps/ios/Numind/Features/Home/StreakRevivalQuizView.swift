import SwiftUI

/// Quick 5-question MCQ quiz to revive a broken streak.
///
/// Pass threshold: ≥ 3 out of 5 correct.
/// Uses the same template → question pipeline as all other quiz modes.
struct StreakRevivalQuizView: View {
    let onSuccess: () -> Void
    let onFailure: () -> Void

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var flash: FlashState? = nil
    @State private var phase: Phase = .quiz

    private let totalQuestions = 5
    private let passThreshold = 3

    private enum Phase { case quiz, passed, failed }
    private enum FlashState { case correct, wrong }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            switch phase {
            case .quiz:
                if questions.isEmpty {
                    ProgressView()
                        .tint(Theme.Colors.primaryBlue)
                } else if currentIndex < questions.count {
                    quizContent
                }

            case .passed:
                resultView(
                    icon: "checkmark.circle.fill",
                    iconColor: Theme.Colors.mindTeal,
                    title: "Streak revived!",
                    message: "You got \(correctCount) out of \(totalQuestions) right. Your streak is back!",
                    ctaLabel: "Continue",
                    action: onSuccess
                )

            case .failed:
                resultView(
                    icon: "xmark.circle.fill",
                    iconColor: Theme.Colors.errorSoftRed,
                    title: "Not quite",
                    message: "You needed \(passThreshold) correct but got \(correctCount). Your streak will reset.",
                    ctaLabel: "OK",
                    action: onFailure
                )
            }

            // Flash overlay
            if let flash {
                flashOverlay(flash)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.2), value: self.flash == nil)
            }
        }
        .onAppear { generateQuestions() }
    }

    // MARK: - Quiz content

    private var quizContent: some View {
        let question = questions[currentIndex]

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Question \(currentIndex + 1) of \(totalQuestions)")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.mutedText)
                Spacer()
                DotProgress(current: currentIndex + 1, total: totalQuestions)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Question card
                    questionCard(question)
                        .padding(.top, 22)

                    // Choice grid
                    choiceGrid(question)
                        .padding(.top, 16)

                    Text("Get \(passThreshold) right to revive your streak")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Question card

    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Streak Revival")
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Colors.warmOrange)

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

    // MARK: - Choice grid

    private func choiceGrid(_ question: QuizQuestion) -> some View {
        let letters = ["A", "B", "C", "D"]
        let choices = Array(question.choices.prefix(4))

        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 12) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, choice in
                Button {
                    answerTapped(choiceId: choice.id, question: question)
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
                .disabled(flash != nil)
            }
        }
    }

    // MARK: - Flash overlay

    private func flashOverlay(_ state: FlashState) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                state == .correct
                    ? Theme.Colors.mindTeal.opacity(0.12)
                    : Theme.Colors.errorSoftRed.opacity(0.12)
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    // MARK: - Result view

    private func resultView(
        icon: String,
        iconColor: Color,
        title: String,
        message: String,
        ctaLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(iconColor)
                .padding(.bottom, 20)

            Text(title)
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.deepNavy)

            Text(message)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)

            Spacer()

            PillButton(ctaLabel) { action() }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Logic

    private func generateQuestions() {
        let repo = LocalContentRepository()
        let allTemplates = repo.allTemplates()
        guard !allTemplates.isEmpty else { return }

        let picked = Array(allTemplates.shuffled().prefix(totalQuestions))
        questions = picked.map { QuizEngine.generate(from: $0) }
    }

    private func answerTapped(choiceId: UUID, question: QuizQuestion) {
        guard flash == nil else { return }

        let isCorrect = question.correctChoiceId == choiceId
        if isCorrect { correctCount += 1 }

        flash = isCorrect ? .correct : .wrong

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            flash = nil

            if currentIndex + 1 < questions.count {
                currentIndex += 1
            } else {
                // Quiz complete
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = correctCount >= passThreshold ? .passed : .failed
                }
            }
        }
    }
}

#Preview {
    StreakRevivalQuizView(onSuccess: {}, onFailure: {})
}
