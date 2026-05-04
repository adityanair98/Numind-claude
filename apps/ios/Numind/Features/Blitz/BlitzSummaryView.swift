import SwiftUI

/// Summary screen shown after a Blitz session ends.
///
/// Displays the final score, personal best comparison, stats, and
/// offers "Play again" or "Done" actions.
struct BlitzSummaryView: View {
    @ObservedObject var viewModel: BlitzViewModel
    @EnvironmentObject private var progressStore: ProgressStore

    let onPlayAgain: () -> Void
    let onDone: () -> Void

    @State private var scoreScale: CGFloat = 0.6
    @State private var scoreOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.sectionSpacing) {
                    heroSection
                    statsCard
                    footerButtons
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 48)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                scoreScale = 1.0
                scoreOpacity = 1.0
            }
        }
    }

    // MARK: - Hero section

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Blitz icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.warmOrangeTint)
                    .frame(width: 72, height: 72)
                Image(systemName: "flame.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.Colors.warmOrange)
            }

            VStack(spacing: 8) {
                Text("Blitz complete!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)

                // Animated score
                Text("\(viewModel.score)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.Colors.warmOrange)
                    .scaleEffect(scoreScale)
                    .opacity(scoreOpacity)
                    .contentTransition(.numericText())

                Text("questions correct")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            // Personal best badge
            if viewModel.isNewBest {
                personalBestBadge
            } else if viewModel.previousBest > 0 {
                previousBestLabel
            }
        }
    }

    private var personalBestBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 13, weight: .bold))
            Text("New personal best!")
                .font(.system(size: 13, weight: .bold))
        }
        .foregroundStyle(Theme.Colors.insightText)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Theme.Colors.insightYellowTint)
        .clipShape(Capsule())
        .shadow(color: Theme.Colors.insightYellow.opacity(0.3), radius: 8, y: 3)
    }

    private var previousBestLabel: some View {
        Text("Personal best: \(viewModel.previousBest)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.Colors.mutedText)
    }

    // MARK: - Stats card

    private var statsCard: some View {
        NumindCard {
            VStack(spacing: 0) {
                statRow(
                    icon: "checkmark.circle.fill",
                    iconColor: Theme.Colors.mindTeal,
                    label: "Correct",
                    value: "\(viewModel.score) / \(viewModel.totalAnswered)"
                )
                Divider().background(Theme.Colors.hairline)
                statRow(
                    icon: "target",
                    iconColor: Theme.Colors.primaryBlue,
                    label: "Accuracy",
                    value: "\(Int(viewModel.accuracy * 100))%"
                )
                Divider().background(Theme.Colors.hairline)
                statRow(
                    icon: "star.fill",
                    iconColor: Theme.Colors.insightYellow,
                    label: "XP earned",
                    value: "+\(viewModel.xpEarned) XP"
                )
                if viewModel.totalAnswered > 0 {
                    Divider().background(Theme.Colors.hairline)
                    statRow(
                        icon: "bolt.fill",
                        iconColor: Theme.Colors.warmOrange,
                        label: "Avg time/question",
                        value: avgTimeString
                    )
                }
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

    private var avgTimeString: String {
        guard viewModel.totalAnswered > 0 else { return "—" }
        let avg = viewModel.totalTime / Double(max(viewModel.totalAnswered, 1))
        return String(format: "%.1fs", avg)
    }

    // MARK: - Footer

    private var footerButtons: some View {
        VStack(spacing: 12) {
            PillButton("Play again", variant: .primary) {
                onPlayAgain()
            }
            PillButton("Done", variant: .secondary) {
                onDone()
            }
        }
    }
}
