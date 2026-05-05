import SwiftUI

/// Hero card for the daily challenge. Uses HeroCard with navy/teal variants.
struct DailyChallengeCard: View {
    let isDone: Bool
    let progress: Int
    let timeUntilReset: String
    /// True when the user has completed at least one session (not brand new).
    let hasHistory: Bool
    let onStart: () -> Void
    let onBonusRound: () -> Void

    private let total = DailyChallengeEngine.questionCount

    var body: some View {
        if isDone {
            doneState
        } else {
            notDoneState
        }
    }

    // MARK: - Not-done state

    private var notDoneState: some View {
        HeroCard(variant: .navy) {
            VStack(alignment: .leading, spacing: 0) {
                headerChips
                titleBlock
                    .padding(.top, 14)
                progressBlock
                    .padding(.top, 18)
                ctaButton
                    .padding(.top, 18)
            }
        }
    }

    // MARK: - Done state

    private var doneState: some View {
        HeroCard(variant: .teal) {
            VStack(alignment: .leading, spacing: 0) {
                dailyChip
                Text("Nailed it \u{2728}")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 14)
                Text("\(total)/\(total) today. Streak +1. Come back tomorrow for a fresh set.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 6)
                bonusButton
                    .padding(.top, 16)
            }
        }
    }

    // MARK: - Shared chip

    private var dailyChip: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.Colors.insightYellow)
                .frame(width: 6, height: 6)
                .shadow(color: Theme.Colors.insightYellow, radius: 4)
            Text("DAILY CHALLENGE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow)
                .kerning(0.6)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
        .background(Theme.Colors.insightYellow.opacity(0.18))
        .overlay(
            Capsule().stroke(Theme.Colors.insightYellow.opacity(0.35), lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    // MARK: - Header chips row

    private var headerChips: some View {
        HStack {
            dailyChip
            Spacer()
            Text("Resets in \(timeUntilReset)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hasHistory
                 ? "\(total) questions\npicked for you"
                 : "\(total) questions\ntest your mental math")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineSpacing(1)
            Text(hasHistory
                 ? "Your most overdue skills \u{00B7} ~3 min"
                 : "Across all topics \u{00B7} ~3 min")
                .font(Theme.Typography.caption)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    // MARK: - Progress rail + labels

    private var progressBlock: some View {
        VStack(spacing: 10) {
            BeadRail(
                progress: progress,
                total: total,
                variant: .chunky,
                filledColor: Theme.Colors.mindTeal,
                trackColor: .white.opacity(0.14)
            )
            HStack {
                Text(progress > 0 ? "\(progress) / \(total) answered" : "Fresh set ready")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                xpChip
            }
        }
    }

    private var xpChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
            Text("+\(total * 10) XP max")
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(Theme.Colors.insightYellow)
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(Theme.Colors.insightYellow.opacity(0.18))
        .clipShape(Capsule())
    }

    // MARK: - CTA button (teal gradient)

    private var ctaButton: some View {
        Button(action: onStart) {
            HStack(spacing: 8) {
                Text(progress > 0 ? "Continue challenge" : "Start challenge")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [
                        Theme.Colors.mindTeal,
                        Color(red: 31 / 255, green: 175 / 255, blue: 160 / 255),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Theme.Colors.mindTeal.opacity(0.45), radius: 12, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bonus round button (frosted glass)

    private var bonusButton: some View {
        Button(action: onBonusRound) {
            Text("Try a bonus round \u{2192}")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.ultraThinMaterial.opacity(0.6))
                .background(.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("New user") {
    DailyChallengeCard(isDone: false, progress: 0, timeUntilReset: "7h 23m", hasHistory: false, onStart: {}, onBonusRound: {})
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("Returning user") {
    DailyChallengeCard(isDone: false, progress: 0, timeUntilReset: "7h 23m", hasHistory: true, onStart: {}, onBonusRound: {})
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("In Progress") {
    DailyChallengeCard(isDone: false, progress: 4, timeUntilReset: "5h 10m", hasHistory: true, onStart: {}, onBonusRound: {})
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("Done") {
    DailyChallengeCard(isDone: true, progress: DailyChallengeEngine.questionCount, timeUntilReset: "", hasHistory: true, onStart: {}, onBonusRound: {})
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}
