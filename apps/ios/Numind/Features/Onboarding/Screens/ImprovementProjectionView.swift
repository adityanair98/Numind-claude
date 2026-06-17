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
        MomentsRegistry.readyEstimate(coreSkillCount: max(viewModel.moneyMapRows.count, 3))
            .formatted(.dateTime.month(.wide).day())
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            // Warm insight halo fading into the background
            RadialGradient(
                colors: [Theme.Colors.insightYellowTint, .clear],
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
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .padding(.top, 4)

                        Text("Here\u{2019}s what you\u{2019}ll unlock:")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(2)
                            .padding(.top, 10)

                        VStack(spacing: 12) {
                            unlockRow(
                                icon: "checkmark.seal.fill",
                                color: Theme.Colors.mindTeal,
                                title: "\(skillsEstimate) core skills at solid",
                                sub: "From \(packTitle)"
                            )
                            unlockRow(
                                icon: "target",
                                color: Theme.Colors.deepNavy,
                                title: "~\(questionsEstimate) real questions practiced",
                                sub: "Tuned to where your diagnostic placed you"
                            )
                            if viewModel.isHabitBuyer {
                                unlockRow(
                                    icon: "bolt.fill",
                                    color: Theme.Colors.insightText,
                                    title: "Answers that arrive before you reach for your phone",
                                    sub: "Second nature \u{2014} that\u{2019}s the whole point"
                                )
                            } else {
                                unlockRow(
                                    icon: "signpost.right.fill",
                                    color: Theme.Colors.insightText,
                                    title: "On track to Ready by \(readyDateText)",
                                    sub: "Earned, not granted \u{2014} that\u{2019}s the point"
                                )
                            }
                            unlockRow(
                                icon: "arrow.triangle.2.circlepath",
                                color: Theme.Colors.ember,
                                title: "Your first refresh",
                                sub: "The moment a skill tries to fade \u{2014} and you catch it"
                            )
                        }
                        .padding(.top, 22)

                        Text("Start with a free trial and see the improvement for yourself.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 22)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Let me try") { onContinue() }
                }
            }
        }
    }

    private func unlockRow(icon: String, color: Color, title: String, sub: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(sub)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
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
