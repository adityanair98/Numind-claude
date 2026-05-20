import SwiftUI

/// Screen 7 — Aspiration ("Where do you want to be in 30 days?")
struct AspirationPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(aspiration: Aspiration, label: String, emoji: String)] = [
        (.tipInstantly, "Tip in my head instantly", "\u{26A1}"),
        (.confidentWithMoney, "Feel confident with money", "\u{1F4AA}"),
        (.spotGoodDeals, "Know if a deal is actually good", "\u{1F3AF}"),
        (.fasterThanPhone, "Do mental math faster than my phone", "\u{1F680}"),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Where do you want to be in 30 days?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("We\u{2019}ll keep this in front of you.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(options, id: \.aspiration) { opt in
                                OnboardingSelectCard(
                                    label: opt.label,
                                    selected: viewModel.signals.aspiration == opt.aspiration,
                                    accentColor: Theme.Colors.primaryBlue
                                ) {
                                    viewModel.setAspiration(opt.aspiration)
                                } icon: {
                                    OnboardingIconTile(emoji: opt.emoji, color: Theme.Colors.primaryBlue)
                                }
                            }
                        }
                        .padding(.top, 22)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(viewModel.signals.aspiration != nil ? 1 : 0.5)
                .allowsHitTesting(viewModel.signals.aspiration != nil)
            }
        }
    }
}

#Preview {
    AspirationPickerView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
