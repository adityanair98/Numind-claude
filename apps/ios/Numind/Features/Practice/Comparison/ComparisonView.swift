import SwiftUI

/// Comparison Snap: two problems side by side — tap the one with the bigger answer.
/// 15 questions, 8 seconds per question.
struct ComparisonView: View {
    @ObservedObject var viewModel: ComparisonViewModel
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
            } else {
                playingView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSummary)
        .onAppear { viewModel.start() }
        .onChange(of: viewModel.state) { _, newState in
            if case .complete = newState {
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

                Text("Which is more?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .padding(.bottom, 20)

                if let pair = viewModel.currentPair {
                    comparisonCards(pair)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                }

                Spacer()
            }

            // Flash / timeout overlay
            switch viewModel.state {
            case .flashing(let correct):
                flashOverlay(correct: correct)
                    .transition(.opacity)
            case .timeout:
                timeoutOverlay
                    .transition(.opacity)
            default:
                EmptyView()
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

            // Timer ring
            timerRing

            Spacer()

            // Score
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                Text("\(viewModel.score)/\(viewModel.currentIndex + 1)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(Theme.Colors.mindTeal)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Theme.Colors.mindTeal.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    private var timerRing: some View {
        let progress = viewModel.timeRemaining / viewModel.questionTimeLimit
        let color: Color = viewModel.timeRemaining > 3 ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed

        return ZStack {
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: 4)
                .frame(width: 48, height: 48)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 48, height: 48)
                .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
            Text("\(max(0, Int(ceil(viewModel.timeRemaining))))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
    }

    // MARK: - Comparison Cards

    private func comparisonCards(_ pair: ComparisonPair) -> some View {
        let isFlashing = {
            switch viewModel.state {
            case .flashing, .timeout: return true
            default: return false
            }
        }()

        return HStack(spacing: 12) {
            sideCard(prompt: pair.promptA, side: 0, disabled: isFlashing)
            Text("vs")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Theme.Colors.mutedText)
            sideCard(prompt: pair.promptB, side: 1, disabled: isFlashing)
        }
        .id(pair.id)
    }

    private func sideCard(prompt: String, side: Int, disabled: Bool) -> some View {
        Button {
            viewModel.selectSide(side)
        } label: {
            VStack(spacing: 12) {
                Text(prompt)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(Theme.Colors.hairline, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    // MARK: - Overlays

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

    private var timeoutOverlay: some View {
        ZStack {
            Color.orange.opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.warmOrange)
                        .frame(width: 72, height: 72)
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text("Time's up!")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.warmOrange)
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
                                .fill(Theme.Colors.mindTeal.opacity(0.15))
                                .frame(width: 72, height: 72)
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                        }

                        Text("Comparison complete!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)

                        Text("\(viewModel.score)/\(viewModel.total) correct")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mutedText)

                        Text("+\(viewModel.xpEarned) XP")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.insightText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
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
        guard viewModel.totalAnswered > 0 else { return }
        let scoreBefore = progressStore.numindScore

        var record = SessionRecord(
            id: UUID(),
            lessonId: "comparison",
            moduleId: "mixed",
            date: Date(),
            correctCount: viewModel.score,
            totalCount: viewModel.totalAnswered
        )
        record.questionResults = viewModel.results
        progressStore.recordSession(record)
        progressStore.updateComparisonBest(score: viewModel.score)

        numindScore = progressStore.numindScore
        scoreDelta = progressStore.numindScore - scoreBefore
    }
}
