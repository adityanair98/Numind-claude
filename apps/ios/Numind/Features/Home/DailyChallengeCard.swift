import SwiftUI

/// Hero card for the daily workout (Phase 13 — "Warm-Premium Money Tool").
/// The one accent block on Home: a calm white card with a teal eyebrow, sans
/// title, ink "Start" pill, and the teal daily-goal ring (mono center) on the
/// right. No bead rail, gradient, emoji, or glow.
struct DailyChallengeCard: View {
    let isDone: Bool
    let progress: Int
    /// Number of questions the user answered correctly (used in done state).
    let correctCount: Int
    let timeUntilReset: String
    /// True when the user has completed at least one session (not brand new).
    let hasHistory: Bool
    let onStart: () -> Void
    let onBonusRound: () -> Void

    /// Per-user workout size (onboarding-driven); defaults for previews.
    var total: Int = DailyChallengeEngine.defaultQuestionCount

    /// The user's chosen daily commitment (3/5/10) — shown honestly in the
    /// eyebrow instead of a count-derived estimate.
    var dailyMinutes: Int = 5

    // Daily goal ring (Phase 13 — moved into the hero card from the header).
    var ringProgress: Double = 0
    var ringCenter: String = "0"
    var isRingClosed: Bool = false
    var onRingTap: (() -> Void)? = nil

    var body: some View {
        NumindCard {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    eyebrow
                    Text(title)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                    Spacer(minLength: 14)
                    if isDone {
                        Button(action: onBonusRound) {
                            Text("More practice")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                        }
                        .buttonStyle(.plain)
                    } else {
                        startPill
                    }
                }
                Spacer(minLength: 0)
                ringColumn
            }
        }
    }

    // MARK: - Pieces

    private var eyebrow: some View {
        Text(isDone ? "TODAY · DONE" : "TODAY · \(dailyMinutes) MIN")
            .font(Theme.Typography.overline)
            .textCase(.uppercase)
            .kerning(0.6)
            .foregroundStyle(Theme.Colors.mindTeal)
    }

    private var title: String {
        if isDone { return "Ring closed for today" }
        return hasHistory ? "Your overdue skills, picked" : "A fresh set to start you"
    }

    private var startPill: some View {
        Button(action: onStart) {
            Text(progress > 0 ? "Continue" : "Start")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.Colors.ctaLabel)
                .padding(.horizontal, 26)
                .frame(height: 44)
                .background(Theme.Colors.ctaFill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var ringColumn: some View {
        Button { onRingTap?() } label: {
            VStack(spacing: 4) {
                GoalRing(progress: ringProgress, isClosed: isRingClosed,
                         centerText: ringCenter, size: 72)
                Text(isDone ? "done" : "today")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .buttonStyle(.plain)
        .disabled(onRingTap == nil)
    }
}

#Preview("Returning user") {
    DailyChallengeCard(isDone: false, progress: 0, correctCount: 0, timeUntilReset: "7h",
                       hasHistory: true, onStart: {}, onBonusRound: {},
                       ringProgress: 0.5, ringCenter: "1/2")
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("Done") {
    DailyChallengeCard(isDone: true, progress: 8, correctCount: 7, timeUntilReset: "",
                       hasHistory: true, onStart: {}, onBonusRound: {},
                       ringProgress: 1, ringCenter: "2/2", isRingClosed: true)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}
