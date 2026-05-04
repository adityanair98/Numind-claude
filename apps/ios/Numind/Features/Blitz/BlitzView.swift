import SwiftUI

/// The main Blitz mode container.
///
/// Manages two phases:
///   - Playing phase: 60-second countdown game
///   - Summary phase: score display + play again / done
struct BlitzView: View {
    @ObservedObject var viewModel: BlitzViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    // Closure called by the parent to re-generate questions for "Play again"
    let generateQuestions: () -> [QuizQuestion]

    @State private var showSummary = false

    var body: some View {
        Group {
            if showSummary {
                BlitzSummaryView(
                    viewModel: viewModel,
                    onPlayAgain: {
                        let newQuestions = generateQuestions()
                        viewModel.reset(questions: newQuestions)
                        showSummary = false
                    },
                    onDone: {
                        recordSession()
                        dismiss()
                    }
                )
                .environmentObject(progressStore)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.92).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                blitzPlayingView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSummary)
        .onChange(of: viewModel.state) { _, newState in
            if case .complete = newState {
                showSummary = true
            }
        }
        .onAppear {
            viewModel.start()
        }
    }

    // MARK: - Playing View

    private var blitzPlayingView: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: close + timer + score
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                if let question = viewModel.currentQuestion {
                    ScrollView {
                        VStack(spacing: 16) {
                            promptCard(for: question)
                            optionsGrid(for: question)
                        }
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 32)
                    }
                }

                Spacer(minLength: 0)
            }

            // Flash overlay (correct/wrong)
            if case .flashing(let correct) = viewModel.state {
                flashOverlay(correct: correct)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: viewModel.state)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 16) {
            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.mutedTint)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            // Countdown timer (center)
            blitzTimer

            Spacer()

            // Score counter
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                Text("\(viewModel.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(scoreColor)
            .clipShape(Capsule())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.score)
        }
    }

    private var blitzTimer: some View {
        let remaining = viewModel.timeRemaining
        let progress = viewModel.totalTime > 0 ? remaining / viewModel.totalTime : 0

        return ZStack {
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: 5)
                .frame(width: 72, height: 72)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .animation(.linear(duration: 0.1), value: remaining)
            VStack(spacing: 0) {
                Text("\(max(0, Int(ceil(remaining))))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(timerColor)
                    .animation(.none, value: remaining)
                    .contentTransition(.numericText())
                Text("sec")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .scaleEffect(remaining <= 10 && viewModel.state == .playing ? 1.05 : 1.0)
        .animation(
            remaining <= 10
                ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                : .default,
            value: remaining
        )
    }

    private var timerColor: Color {
        let r = viewModel.timeRemaining
        if r > 20 { return Theme.Colors.mindTeal }
        if r > 10 { return Theme.Colors.warmOrange }
        return Theme.Colors.errorSoftRed
    }

    private var scoreColor: Color {
        viewModel.score > 0 ? Theme.Colors.mindTeal : Theme.Colors.mutedText.opacity(0.6)
    }

    // MARK: - Prompt card

    private func promptCard(for question: QuizQuestion) -> some View {
        NumindCard {
            VStack(spacing: 0) {
                // Scenario / context block — shown when template has a scenarioTemplate.
                if let scenario = question.scenario {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.Colors.primaryBlue)
                            Text("CONTEXT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.Colors.primaryBlue)
                                .kerning(0.5)
                        }
                        Text(scenario)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Theme.Colors.primaryBlueTint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.bottom, 12)
                }

                // Main question prompt
                Text(question.prompt)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, question.scenario == nil ? 8 : 0)
            }
        }
    }

    // MARK: - Options grid (2×2)

    private func optionsGrid(for question: QuizQuestion) -> some View {
        let choices = question.choices
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(choices) { choice in
                blitzOptionButton(choice: choice, question: question)
            }
        }
    }

    private func blitzOptionButton(choice: QuizQuestion.Choice, question: QuizQuestion) -> some View {
        let isFlashing = {
            if case .flashing = viewModel.state { return true }
            return false
        }()

        return Button {
            viewModel.select(choice.id)
        } label: {
            Text(choice.text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 72)
                .padding(12)
                .background(Theme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.hairline, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isFlashing)
        .animation(.none, value: isFlashing)
    }

    // MARK: - Flash overlay

    private func flashOverlay(correct: Bool) -> some View {
        ZStack {
            (correct ? Color.green : Color.red)
                .opacity(0.15)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(correct ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                        .frame(width: 72, height: 72)
                    Image(systemName: correct ? "checkmark" : "xmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: correct)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Session recording

    private func recordSession() {
        guard viewModel.totalAnswered > 0 else { return }
        var record = SessionRecord(
            id: UUID(),
            lessonId: "blitz_session",
            moduleId: "mixed",
            date: Date(),
            correctCount: viewModel.score,
            totalCount: viewModel.totalAnswered
        )
        record.questionResults = viewModel.results
        progressStore.recordSession(record)
        progressStore.updateBlitzBest(score: viewModel.score)
    }
}
