import SwiftUI

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @ObservedObject var viewModel: QuizSessionViewModel
    let isPersonalBest: Bool
    let newBadgeIds: Set<String>
    let onContinue: () -> Void

    @State private var xpAnimated: Int = 0
    @State private var showPersonalBest: Bool = false
    @State private var reviewVM: QuizSessionViewModel? = nil

    private var accent: Color { viewModel.moduleColor.tintColor }
    private var accentTint: Color { viewModel.moduleColor.tintBackground }

    private var wrongCount: Int { viewModel.results.filter { !$0.isCorrect }.count }

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
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                xpAnimated = viewModel.totalXP
            }
            if isPersonalBest {
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
                    reviewVM = nil   // dismiss back to this summary when review ends
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
                if !newBadgeIds.isEmpty { newBadgesSection }
                recapSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 20)
            .padding(.bottom, Theme.Spacing.buttonHeight + 80)
        }
    }

    // MARK: - Result header

    private var resultHeader: some View {
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
            from: viewModel.results,
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
                if wrongCount > 0 {
                    reviewMistakesButton
                }
                PillButton(wrongCount > 0 ? "Skip & continue" : "Continue learning") {
                    onContinue()
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
