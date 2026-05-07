import SwiftUI

/// Estimation mode: drag a slider to your best guess.
/// Scored on proximity — within 5% = 3 stars, within 15% = 2 stars, within 30% = 1 star.
struct EstimationView: View {
    @ObservedObject var viewModel: EstimationViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

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
            } else if case .motivator(let checkpoint) = viewModel.state {
                motivatorScreen(checkpoint: checkpoint)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                playingView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSummary)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.state)
        .onAppear { viewModel.startTimer() }
        .onChange(of: viewModel.state) { _, newState in
            if case .complete = newState {
                recordSession()
                showSummary = true
            }
        }
    }

    // MARK: - Motivator

    private func motivatorScreen(checkpoint: MotivatorCheckpoint) -> some View {
        var cp = checkpoint
        if checkpoint.type == .nearFinish {
            cp.dailyStreak = progressStore.streak
        }
        return MotivatorView(checkpoint: cp) {
            viewModel.advance()
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
                    .padding(.bottom, 8)

                // Countdown timer bar
                timerBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                if let item = viewModel.currentItem {
                    ScrollView {
                        promptCard(item)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    }

                    Spacer(minLength: 0)

                    // Feedback banner
                    if case .feedback(let grade) = viewModel.state {
                        feedbackBanner(grade: grade, item: item)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Slider area
                    sliderSection(item)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 32)
                }
            }
        }
    }

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

            // Progress
            Text("\(viewModel.currentIndex + 1)/\(viewModel.total)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)

            Spacer()

            // Stars
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .bold))
                Text("\(viewModel.totalStars)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(Theme.Colors.insightYellow)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Theme.Colors.insightYellowTint)
            .clipShape(Capsule())
        }
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        let isPlaying = viewModel.state == .playing
        let fraction = viewModel.timeFraction
        let timerColor: Color = fraction > 0.3
            ? Theme.Colors.mindTeal
            : (fraction > 0.15 ? Theme.Colors.warmOrange : Theme.Colors.errorSoftRed)

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.Colors.mutedTint)

                Capsule()
                    .fill(timerColor)
                    .frame(width: geo.size.width * max(0, fraction))
                    .animation(.linear(duration: 0.05), value: fraction)
            }
        }
        .frame(height: 5)
        .opacity(isPlaying ? 1 : 0)
    }

    // MARK: - Prompt Card

    private func promptCard(_ item: EstimationItem) -> some View {
        VStack(spacing: 10) {
            if let scenario = item.scenario {
                Text(scenario)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            Text(item.prompt)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .padding(20)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .id(item.id)
    }

    // MARK: - Slider Section

    private func sliderSection(_ item: EstimationItem) -> some View {
        let isFeedback: Bool = {
            if case .feedback = viewModel.state { return true }
            return false
        }()

        let feedbackGrade: EstimationGrade? = {
            if case .feedback(let g) = viewModel.state { return g }
            return nil
        }()

        return VStack(spacing: 20) {
            // Large current value display
            Text(viewModel.formattedSliderValue)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.hasDragged ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: viewModel.sliderValue)

            if !viewModel.hasDragged && !isFeedback {
                Text("Drag to estimate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .transition(.opacity)
            }

            // Slider
            EstimationSlider(
                value: $viewModel.sliderValue,
                config: item.sliderConfig,
                answerFormat: item.answerFormat,
                correctValue: isFeedback ? item.correctValue : nil,
                grade: feedbackGrade,
                isDisabled: isFeedback,
                onDragStarted: { viewModel.markDragged() }
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.currentIndex)

            // Submit / Next button
            if isFeedback {
                Button { viewModel.advance() } label: {
                    Text("Next")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Theme.Colors.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Button { viewModel.submit() } label: {
                    Text("Lock it in")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.hasDragged
                            ? Theme.Colors.mindTeal
                            : Theme.Colors.mutedText)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.hasDragged)
            }
        }
    }

    // MARK: - Feedback Banner

    private func feedbackBanner(grade: EstimationGrade, item: EstimationItem) -> some View {
        let gradeColor: Color = {
            switch grade {
            case .perfect: return Theme.Colors.mindTeal
            case .good:    return Theme.Colors.primaryBlue
            case .okay:    return Theme.Colors.warmOrange
            case .miss:    return Theme.Colors.errorSoftRed
            }
        }()

        return HStack(spacing: 12) {
            // Stars
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < grade.stars ? "star.fill" : "star")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(i < grade.stars ? Theme.Colors.insightYellow : Theme.Colors.mutedTint)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(grade.label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(gradeColor)
                Text("Answer: \(QuizEngine.format(item.correctValue, as: item.answerFormat))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            Spacer()
        }
        .padding(14)
        .background(gradeColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                                .fill(Theme.Colors.insightYellowTint)
                                .frame(width: 72, height: 72)
                            Image(systemName: "scope")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Theme.Colors.insightYellow)
                        }

                        Text("Estimation complete!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)

                        // Stars display
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("\(viewModel.totalStars)/\(viewModel.maxStars)")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(Theme.Colors.insightYellow)

                        Text("+\(viewModel.xpEarned) XP")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.insightText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Theme.Colors.insightYellowTint)
                            .clipShape(Capsule())

                        if viewModel.isNewBest {
                            NewBestBadge()
                        } else if viewModel.previousBest > 0 {
                            Text("Personal best: \(viewModel.previousBest)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mutedText)
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
                        PillButton("Done", variant: .primary) {
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

    // MARK: - Session recording

    private func recordSession() {
        let scoreBefore = progressStore.numindScore

        var record = SessionRecord(
            id: UUID(),
            lessonId: "estimation",
            moduleId: "mixed",
            date: Date(),
            correctCount: viewModel.correctCount,
            totalCount: viewModel.total
        )
        record.questionResults = viewModel.results
        progressStore.recordSession(record)
        progressStore.updateEstimationBest(score: viewModel.totalStars)

        numindScore = progressStore.numindScore
        scoreDelta = progressStore.numindScore - scoreBefore
    }
}
