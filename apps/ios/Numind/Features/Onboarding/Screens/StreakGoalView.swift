import SwiftUI

/// Screen 22 — Streak Goal (3, 7, or 14 days)
struct StreakGoalView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(days: Int, label: String, sub: String, glyph: String, color: Color, recommended: Bool)] = [
        (3, "3 days", "Build your first habit loop", "\u{1F525}", Theme.Colors.warmOrange, false),
        (7, "7 days", "Complete your first module", "\u{1F3C6}", Theme.Colors.insightYellow, true),
        (14, "14 days", "Measurable speed improvement", "\u{26A1}", Theme.Colors.primaryBlue, false),
    ]

    private var ctaLabel: String {
        if let goal = viewModel.signals.streakGoal {
            return "I\u{2019}m going for \(goal) days"
        }
        return "Continue"
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Set your first streak goal")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("Don\u{2019}t worry \u{2014} you can extend it anytime.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        VStack(spacing: 12) {
                            ForEach(options, id: \.days) { opt in
                                let selected = viewModel.signals.streakGoal == opt.days
                                Button {
                                    viewModel.setStreakGoal(opt.days)
                                } label: {
                                    HStack(spacing: 14) {
                                        Text(opt.glyph)
                                            .font(.system(size: 28))
                                            .frame(width: 56, height: 56)
                                            .background(opt.color.opacity(0.14))
                                            .clipShape(RoundedRectangle(cornerRadius: 16))

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                Text(opt.label)
                                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                                    .foregroundStyle(Theme.Colors.deepNavy)

                                                if opt.recommended {
                                                    Text("RECOMMENDED")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundStyle(Theme.Colors.deepNavy)
                                                        .tracking(0.4)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 2)
                                                        .background(Theme.Colors.insightYellow)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                            Text(opt.sub)
                                                .font(.system(size: 13))
                                                .foregroundStyle(Theme.Colors.mutedText)
                                        }

                                        Spacer()
                                        RadioDot(selected: selected, color: opt.color)
                                    }
                                    .padding(18)
                                    .background(selected ? opt.color.opacity(0.06) : Theme.Colors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(
                                                selected ? opt.color : Theme.Colors.hairline,
                                                lineWidth: selected ? 1.5 : 1
                                            )
                                    )
                                    .shadow(
                                        color: selected ? opt.color.opacity(0.14) : .black.opacity(0.04),
                                        radius: selected ? 11 : 3, x: 0, y: selected ? 4 : 1
                                    )
                                }
                                .buttonStyle(.plain)
                                .animation(.easeOut(duration: 0.18), value: selected)
                            }
                        }
                        .padding(.top, 22)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton(ctaLabel) { onContinue() }
                }
                .opacity(viewModel.signals.streakGoal != nil ? 1 : 0.5)
                .allowsHitTesting(viewModel.signals.streakGoal != nil)
            }
        }
    }
}

#Preview {
    StreakGoalView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
