import SwiftUI

/// Screen 23 — Improvement Projection (DARK)
/// "In [streak goal] days, here's what you'll unlock"
struct ImprovementProjectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private var streakDays: Int { viewModel.signals.streakGoal ?? 7 }
    private var minutesPerDay: Int { viewModel.signals.dailyMinutes ?? 10 }
    private var challengeCount: Int { viewModel.signals.dailyChallengeCount }
    private var packTitle: String { viewModel.focusPack?.title ?? "your moment" }

    private var skillsEstimate: Int { max(2, min(streakDays / 2, viewModel.moneyMapRows.count)) }
    private var questionsEstimate: Int { streakDays * challengeCount }
    private var readyDateText: String {
        MomentCalendar.readyEstimate(coreSkillCount: max(viewModel.moneyMapRows.count, 3))
            .formatted(.dateTime.month(.wide).day())
    }

    var body: some View {
        ZStack {
            Theme.Colors.deepNavy.ignoresSafeArea()

            // Halo
            RadialGradient(
                colors: [Theme.Colors.insightYellow.opacity(0.16), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 160
            )
            .offset(y: -40)

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("In \(streakDays) days")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.top, 4)

                        Text("Here\u{2019}s what you\u{2019}ll unlock:")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineSpacing(2)
                            .padding(.top, 10)

                        VStack(spacing: 12) {
                            unlockRow(
                                glyph: "\u{2705}",
                                color: Theme.Colors.mindTeal,
                                title: "\(skillsEstimate) core skills at solid",
                                sub: "From \(packTitle)"
                            )
                            unlockRow(
                                glyph: "\u{1F3AF}",
                                color: Theme.Colors.primaryBlue,
                                title: "~\(questionsEstimate) real questions practiced",
                                sub: "Tuned to where your diagnostic placed you"
                            )
                            unlockRow(
                                glyph: "\u{1F9ED}",
                                color: Theme.Colors.insightYellow,
                                title: "On track to Ready by \(readyDateText)",
                                sub: "Earned, not granted \u{2014} that\u{2019}s the point"
                            )
                            unlockRow(
                                glyph: "\u{1F504}",
                                color: Theme.Colors.warmOrange,
                                title: "Your first refresh",
                                sub: "The moment a skill tries to fade \u{2014} and you catch it"
                            )
                        }
                        .padding(.top, 22)

                        Text("Start with a free trial and see the improvement for yourself.")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 22)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: true) {
                    Button(action: onContinue) {
                        Text("Let me try")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func unlockRow(glyph: String, color: Color, title: String, sub: String) -> some View {
        HStack(spacing: 14) {
            Text(glyph)
                .font(.system(size: 22))
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(sub)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

#Preview {
    ImprovementProjectionView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
