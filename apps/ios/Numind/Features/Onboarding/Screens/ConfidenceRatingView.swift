import SwiftUI

/// Screen 5 — Confidence Self-Rating
/// "How would you rate your everyday mental math?"
struct ConfidenceRatingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(level: ConfidenceLevel, label: String, sub: String, emoji: String, color: Color)] = [
        (.struggle, "I freeze", "I just go with whatever they offer", "\u{1F630}", Theme.Colors.errorSoftRed),
        (.getBy, "I muddle through", "And hope it works out", "\u{1F642}", Theme.Colors.warmOrange),
        (.decent, "I\u{2019}m okay", "But I second-guess myself after", "\u{1F44D}", Theme.Colors.primaryBlue),
        (.quick, "I\u{2019}m sharp", "Just want to stay that way", "\u{26A1}", Theme.Colors.mindTeal),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When a money decision lands on you, how do you handle it?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("No wrong answer \u{2014} just helps us calibrate.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(options, id: \.level) { opt in
                                OnboardingSelectCard(
                                    label: opt.label,
                                    subtitle: opt.sub,
                                    selected: viewModel.signals.confidenceLevel == opt.level,
                                    accentColor: opt.color
                                ) {
                                    viewModel.setConfidence(opt.level)
                                } icon: {
                                    OnboardingIconTile(emoji: opt.emoji, color: opt.color)
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
                .opacity(viewModel.signals.confidenceLevel != nil ? 1 : 0.5)
                .allowsHitTesting(viewModel.signals.confidenceLevel != nil)
            }
        }
    }
}

#Preview {
    ConfidenceRatingView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
