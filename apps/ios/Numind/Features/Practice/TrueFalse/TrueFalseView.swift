import SwiftUI

/// True/False Snap: rapid-fire binary decisions.
/// "Is this correct? 15% tip on $80 = $12." Tap true or false.
struct TrueFalseView: View {
    @ObservedObject var viewModel: TrueFalseViewModel
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
                    .padding(.bottom, 24)

                Spacer()

                if let item = viewModel.currentItem {
                    statementCard(item)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)

                    Spacer()

                    answerButtons
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 48)
                }
            }

            // Flash overlay
            if case .flashing(let correct) = viewModel.state {
                flashOverlay(correct: correct)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: viewModel.state)
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

            // Score
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                Text("\(viewModel.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(Theme.Colors.mindTeal)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Theme.Colors.mindTeal.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    // MARK: - Statement Card

    private func statementCard(_ item: TrueFalseItem) -> some View {
        VStack(spacing: 16) {
            Text("Is this correct?")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)
                .textCase(.uppercase)
                .kerning(0.8)

            if let scenario = item.scenario {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text(scenario)
                        .font(.system(size: 13, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(Theme.Colors.primaryBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Theme.Colors.primaryBlueTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Text(item.statement)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity)
        }
        .padding(28)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
        .id(item.id)
    }

    // MARK: - Answer Buttons

    private var answerButtons: some View {
        let isFlashing = { if case .flashing = viewModel.state { return true }; return false }()

        return HStack(spacing: 16) {
            Button { viewModel.answer(isTrue: false) } label: {
                VStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 28, weight: .bold))
                    Text("False")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Theme.Colors.errorSoftRed)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Theme.Colors.errorSoftRed.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(isFlashing)

            Button { viewModel.answer(isTrue: true) } label: {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                    Text("True")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Theme.Colors.mindTeal)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Theme.Colors.mindTeal.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(isFlashing)
        }
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
                                .fill(Theme.Colors.primaryBlueTint)
                                .frame(width: 72, height: 72)
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Theme.Colors.primaryBlue)
                        }

                        Text("Snap complete!")
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
            lessonId: "true_false",
            moduleId: "mixed",
            date: Date(),
            correctCount: viewModel.score,
            totalCount: viewModel.totalAnswered
        )
        record.questionResults = viewModel.results
        progressStore.recordSession(record)
        progressStore.updateTrueFalseBest(score: viewModel.score)

        numindScore = progressStore.numindScore
        scoreDelta = progressStore.numindScore - scoreBefore
    }
}
