import SwiftUI

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @ObservedObject var viewModel: QuizSessionViewModel
    let isPersonalBest: Bool
    let newBadgeIds: Set<String>
    /// Current overall Numind Score after this session was recorded.
    let numindScore: Int
    /// How the score changed this session (positive = improvement).
    let scoreDelta: Int
    let onContinue: () -> Void
    /// Called when the user wants to retry the quiz with fresh questions.
    /// Only shown when mastery threshold was not met.
    let onRetry: () -> Void

    @State private var xpAnimated: Int = 0
    @State private var showPersonalBest: Bool = false
    @State private var reviewVM: QuizSessionViewModel? = nil
    /// Results from the most recent review session (nil = no review done yet).
    /// Replaces the original wrong answers once the first review completes.
    @State private var reviewResults: [QuizSessionViewModel.QuizResult]? = nil

    private var accent: Color { viewModel.moduleColor.tintColor }
    private var accentTint: Color { viewModel.moduleColor.tintBackground }

    /// Wrong answers from whichever set the next review should target.
    /// After a review completes this switches to that review's results,
    /// giving a cascading "review the review" loop.
    private var wrongCount: Int {
        (reviewResults ?? viewModel.results).filter { !$0.isCorrect }.count
    }

    /// Whether the user hit the 75% mastery threshold this session.
    private var didMaster: Bool {
        viewModel.total > 0
            && Double(viewModel.correctCount) / Double(viewModel.total) >= 0.75
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            scrollContent
            footer
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
        }
        .onAppear {
            if didMaster {
                withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                    xpAnimated = viewModel.totalXP
                }
            } else {
                xpAnimated = viewModel.totalXP   // immediate, no fanfare on failure
            }
            if isPersonalBest && didMaster {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.62).delay(1.0)) {
                    showPersonalBest = true
                }
            }
            if !newBadgeIds.isEmpty {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        .fullScreenCover(item: $reviewVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    // Capture results before dismissing so the footer
                    // can offer another round on any remaining mistakes.
                    reviewResults = vm.results
                    reviewVM = nil
                }
            }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.sectionSpacing) {
                resultHeader
                statsCard
                if numindScore > 0 { scoreCard }
                masteryBanner
                if !newBadgeIds.isEmpty { newBadgesSection }
                recapSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 20)
            .padding(.bottom, Theme.Spacing.buttonHeight + 80)
        }
    }

    // MARK: - Result header

    @ViewBuilder
    private var resultHeader: some View {
        if didMaster {
            passHeader
        } else {
            failHeader
        }
    }

    private var passHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentTint)
                    .frame(width: 96, height: 96)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(accent)
            }

            VStack(spacing: 6) {
                Text("Session complete!")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("\(viewModel.total) questions · \(viewModel.elapsedTimeString)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            VStack(spacing: 8) {
                Text("+\(xpAnimated) XP")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.insightText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(Capsule())
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.7).delay(0.3), value: xpAnimated)

                if viewModel.bonusXP > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("+\(viewModel.bonusXP) XP speed bonus included")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Theme.Colors.insightText)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                if showPersonalBest {
                    HStack(spacing: 6) {
                        Text("🏆")
                            .font(.system(size: 14))
                        Text("New personal best!")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(accent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(accentTint)
                    .clipShape(Capsule())
                    .transition(.scale(scale: 0.75).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var failHeader: some View {
        let needed = Int(ceil(0.75 * Double(viewModel.total)))
        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.warmOrangeTint)
                    .frame(width: 96, height: 96)
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Theme.Colors.warmOrange)
            }

            VStack(spacing: 6) {
                Text("Almost there!")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("\(viewModel.total) questions · \(viewModel.elapsedTimeString)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            VStack(spacing: 8) {
                Text("+\(viewModel.totalXP) XP")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.insightText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(Capsule())

                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Colors.warmOrange)
                    Text("You got \(viewModel.correctCount)/\(viewModel.total) — need \(needed) to master")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.Colors.warmOrangeTint)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats card

    private var statsCard: some View {
        NumindCard {
            HStack {
                statCell(value: "\(viewModel.correctCount)/\(viewModel.total)",
                         label: "Correct",
                         color: accent)
                Divider()
                    .frame(width: 1, height: 32)
                    .background(Theme.Colors.hairline)
                statCell(value: progressStore.accuracy > 0 ? "\(Int(progressStore.accuracy * 100))%" : "—",
                         label: "Accuracy",
                         color: Theme.Colors.deepNavy)
                Divider()
                    .frame(width: 1, height: 32)
                    .background(Theme.Colors.hairline)
                statCell(value: progressStore.streak > 0 ? "\(progressStore.streak)🔥" : "—",
                         label: "Streak",
                         color: Theme.Colors.insightYellow)
            }
        }
    }

    private func statCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Score card

    private var scoreCard: some View {
        let tier = ScoreTier(score: numindScore)
        return NumindCard {
            HStack(spacing: 14) {
                NumindScoreRing(score: numindScore, size: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(tier.color)

                    if scoreDelta != 0 {
                        let isUp = scoreDelta > 0
                        HStack(spacing: 4) {
                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 11, weight: .bold))
                            Text("\(isUp ? "+" : "")\(scoreDelta) pts this session")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(isUp ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                    } else {
                        Text("Score unchanged")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
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

    // MARK: - Mastery banner (pass only)

    @ViewBuilder
    private var masteryBanner: some View {
        if didMaster {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lesson mastered!")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Next lesson unlocked")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(accentTint)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
    }

    // MARK: - Recap section

    private var recapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recap".uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.8)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.results.enumerated()), id: \.offset) { i, result in
                    recapRow(result: result, index: i)
                    if i < viewModel.results.count - 1 {
                        Divider()
                            .padding(.leading, 18 + 36 + 14)
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }

    private func recapRow(result: QuizSessionViewModel.QuizResult, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                    .fill(result.isCorrect ? accentTint : Theme.Colors.errorSoftRedTint)
                Image(systemName: result.isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(result.isCorrect ? accent : Theme.Colors.errorSoftRed)
            }
            .frame(width: 36, height: 36)

            Text(result.promptPreview)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.deepNavy)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !result.isCorrect {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.Colors.errorSoftRed)
                    .padding(6)
                    .background(Theme.Colors.errorSoftRedTint)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
    }

    // MARK: - Newly earned badges

    private var newBadgesSection: some View {
        let badges = newBadgeIds.compactMap { BadgeCatalog.badge(for: $0) }
            .sorted { $0.name < $1.name }
        return VStack(alignment: .leading, spacing: 12) {
            Text("Badges unlocked".uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.8)

            VStack(spacing: 0) {
                ForEach(Array(badges.enumerated()), id: \.element.id) { i, badge in
                    badgeUnlockRow(badge)
                    if i < badges.count - 1 {
                        Divider()
                            .padding(.leading, 18 + 44 + 14)
                            .background(Theme.Colors.hairline)
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }

    private func badgeUnlockRow(_ badge: Badge) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(badgeTierBackground(badge.tier))
                    .frame(width: 44, height: 44)
                Image(systemName: badge.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(badgeTierColor(badge.tier))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(badge.description)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18))
                .foregroundStyle(Theme.Colors.mindTeal)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
    }

    private func badgeTierColor(_ tier: BadgeTier) -> Color {
        switch tier {
        case .bronze: return Color(red: 0.78, green: 0.50, blue: 0.20)
        case .silver: return Theme.Colors.mindTeal
        case .gold:   return Theme.Colors.insightYellow
        }
    }

    private func badgeTierBackground(_ tier: BadgeTier) -> Color {
        badgeTierColor(tier).opacity(0.15)
    }

    // MARK: - Review mistakes

    private var reviewMistakesButton: some View {
        Button { startReview() } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("Review \(wrongCount) mistake\(wrongCount == 1 ? "" : "s")")
                    .font(Theme.Typography.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Spacing.buttonHeight)
            .background(Theme.Colors.errorSoftRed)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func startReview() {
        reviewVM = ReviewMistakesEngine.build(
            from: reviewResults ?? viewModel.results,
            moduleColor: viewModel.moduleColor,
            lessonShortcut: viewModel.lessonShortcut
        )
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

            VStack(spacing: 10) {
                if !didMaster {
                    // Not mastered: retry is the primary action
                    Button { onRetry() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Retry quiz")
                                .font(Theme.Typography.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Spacing.buttonHeight)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    PillButton("Skip for now", variant: .secondary) { onContinue() }

                } else {
                    // Mastered: review mistakes (if any), then continue
                    if wrongCount > 0 {
                        reviewMistakesButton
                    }
                    PillButton(wrongCount > 0 ? "Skip & continue" : "Continue learning") {
                        onContinue()
                    }
                }

                Button("Done for today") { dismiss() }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.Colors.primaryBlue)
                    .frame(height: 44)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 28)
            .background(Theme.Colors.softBackground)
        }
    }
}
