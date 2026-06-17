import SwiftUI

/// Screen 24 — Trial End Notification ("When should we remind you?")
struct TrialReminderView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(days: Int?, label: String, sub: String, symbol: String, color: Color)] = [
        (1, "1 day before", "We\u{2019}ll ping on day 4 of your trial", "alarm.fill", Theme.Colors.mindTeal),
        (2, "2 days before", "We\u{2019}ll ping on day 3 of your trial", "calendar", Theme.Colors.mindTeal),
        (nil, "Don\u{2019}t remind me", "I\u{2019}ve got my own calendar", "bell.slash.fill", Theme.Colors.mutedText),
    ]

    // Track explicit selection since nil could mean "don't remind" or "not yet selected"
    @State private var hasSelected = false

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When should we remind you before your trial ends?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("We\u{2019}ll never surprise you with a charge.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        // Trust badge
                        HStack(spacing: 10) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                            Text("Always 24h notice. Always one tap to cancel.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Colors.deepNavy)
                        }
                        .padding(14)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.top, 18)

                        VStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { index, opt in
                                let isSelected = hasSelected && viewModel.signals.trialReminderDays == opt.days
                                OnboardingSelectCard(
                                    label: opt.label,
                                    subtitle: opt.sub,
                                    selected: isSelected,
                                    accentColor: opt.color
                                ) {
                                    viewModel.setTrialReminder(opt.days)
                                    hasSelected = true
                                } icon: {
                                    OnboardingIconTile(systemImage: opt.symbol, color: opt.color)
                                }
                            }
                        }
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(hasSelected ? 1 : 0.5)
                .allowsHitTesting(hasSelected)
            }
        }
    }
}

#Preview {
    TrialReminderView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
