import SwiftUI

/// Streak mode: one wrong answer and you're out.
/// The score is your consecutive correct answers. Tracks personal best.
struct StreakView: View {
    @ObservedObject var viewModel: StreakViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    let generateQuestions: () -> [QuizQuestion]

    @State private var showSummary = false
    @State private var numindScore: Int = 0
    @State private var scoreDelta: Int = 0

    var body: some View {
        Group {
            if showSummary {
                summaryView
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                playingView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSummary)
        .onChange(of: viewModel.state) { _, newState in
            if case .gameOver = newState {
                recordSession()
                showSummary = true
            }
        }
    }

    // MARK: - Playing View

    private var playingView: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
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

            // Flash overlay
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

            // Streak counter
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("\(viewModel.streakCount)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(streakColor)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.streakCount)

            Spacer()

            // Best badge
            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("\(viewModel.previousBest)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundStyle(Theme.Colors.insightText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.Colors.insightYellowTint)
            .clipShape(Capsule())
        }
    }

    private var streakColor: Color {
        if viewModel.streakCount >= 10 { return Theme.Colors.growthGreen }
        if viewModel.streakCount >= 5  { return Theme.Colors.warmOrange }
        return Theme.Colors.mindTeal
    }

    // MARK: - Question UI

    private func promptCard(for question: QuizQuestion) -> some View {
        NumindCard {
            VStack(spacing: 0) {
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

                Text(question.prompt)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, question.scenario == nil ? 8 : 0)
            }
        }
    }

    private func optionsGrid(for question: QuizQuestion) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(question.choices) { choice in
                optionButton(choice: choice)
            }
        }
    }

    private func optionButton(choice: QuizQuestion.Choice) -> some View {
        let isFlashing = { if case .flashing = viewModel.state { return true }; return false }()

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
    }

    // MARK: - Flash overlay

    private func flashOverlay(correct: Bool) -> some View {
        ZStack {
            (correct ? Color.green : Color.red)
                .opacity(0.15)
                .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(correct ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                    .frame(width: 72, height: 72)
                Image(systemName: correct ? "checkmark" : "xmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Summary

    private var summaryView: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.sectionSpacing) {
                    // Hero
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.warmOrangeTint)
                                .frame(width: 72, height: 72)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Theme.Colors.warmOrange)
                        }

                        VStack(spacing: 8) {
                            Text("Streak over!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Colors.deepNavy)

                            Text("\(viewModel.streakCount)")
                                .font(.system(size: 72, weight: .black, design: .rounded))
                                .foregroundStyle(streakColor)

                            Text("correct in a row")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }

                        if viewModel.isNewBest {
                            NewBestBadge()
                        } else if viewModel.previousBest > 0 {
                            Text("Personal best: \(viewModel.previousBest)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                    }

                    // Stats
                    NumindCard {
                        VStack(spacing: 0) {
                            statRow(icon: "flame.fill", iconColor: Theme.Colors.warmOrange,
                                    label: "Streak", value: "\(viewModel.streakCount)")
                            Divider().background(Theme.Colors.hairline)
                            statRow(icon: "star.fill", iconColor: Theme.Colors.insightYellow,
                                    label: "XP earned", value: "+\(viewModel.xpEarned) XP")
                        }
                    }

                    // Score card
                    if numindScore > 0 {
                        NumindCard {
                            HStack(spacing: 14) {
                                NumindScoreRing(score: numindScore, size: 52)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ScoreTier(score: numindScore).name)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(ScoreTier(score: numindScore).color)
                                    if scoreDelta != 0 {
                                        let isUp = scoreDelta > 0
                                        HStack(spacing: 4) {
                                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("\(isUp ? "+" : "")\(scoreDelta) pts")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundStyle(isUp ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                                    }
                                }

                                Spacer()

                                Text("NUMIND\nSCORE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(Theme.Colors.mutedText)
                                    .tracking(0.5)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }

                    // Buttons
                    VStack(spacing: 12) {
                        PillButton("Try again", variant: .primary) {
                            let newQuestions = generateQuestions()
                            viewModel.reset(questions: newQuestions)
                            showSummary = false
                        }
                        PillButton("Done", variant: .secondary) {
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 48)
                .padding(.bottom, 40)
            }

            if viewModel.isNewBest {
                ConfettiBurst()
            }
        }
    }

    private func statRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(label)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.deepNavy)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
        .padding(.vertical, 14)
    }

    // MARK: - Session recording

    private func recordSession() {
        guard viewModel.streakCount > 0 else { return }
        let scoreBefore = progressStore.numindScore

        var record = SessionRecord(
            id: UUID(),
            lessonId: "streak_mode",
            moduleId: "mixed",
            date: Date(),
            correctCount: viewModel.streakCount,
            totalCount: viewModel.results.count
        )
        record.questionResults = viewModel.results
        progressStore.recordSession(record)
        progressStore.updateStreakBest(score: viewModel.streakCount)

        numindScore = progressStore.numindScore
        scoreDelta = progressStore.numindScore - scoreBefore
    }
}
