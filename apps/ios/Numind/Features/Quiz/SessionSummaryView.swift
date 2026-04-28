import SwiftUI

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuizSessionViewModel
    let onContinue: () -> Void

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
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.sectionSpacing) {
                trophyHeader
                statsCard
                recapSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 20)
            .padding(.bottom, Theme.Spacing.buttonHeight + 80)
        }
    }

    // MARK: - Trophy header

    private var trophyHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.insightYellowTint)
                    .frame(width: 88, height: 88)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.insightYellow)
            }
            Text("Workout complete!")
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.deepNavy)
            Text("\(viewModel.total) questions")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats card

    private var statsCard: some View {
        NumindCard {
            HStack {
                statCell(value: "\(viewModel.correctCount)/\(viewModel.total)",
                         label: "Correct",
                         color: Theme.Colors.mindTeal)
                Divider()
                    .frame(width: 1, height: 32)
                    .background(Theme.Colors.hairline)
                statCell(value: "+\(viewModel.xpEarned)",
                         label: "XP Earned",
                         color: Theme.Colors.deepNavy)
                Divider()
                    .frame(width: 1, height: 32)
                    .background(Theme.Colors.hairline)
                statCell(value: "—",
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
                    .fill(result.isCorrect ? Theme.Colors.mindTealTint : Theme.Colors.errorSoftRedTint)
                Image(systemName: result.isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(result.isCorrect ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
            }
            .frame(width: 36, height: 36)

            Text(result.promptPreview)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.deepNavy)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !result.isCorrect {
                Text("Review")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.primaryBlue)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
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
                PillButton("Continue learning") { onContinue() }
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
