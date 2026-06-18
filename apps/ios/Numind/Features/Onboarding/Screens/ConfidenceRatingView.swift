import SwiftUI

/// Screen 5 — Confidence Self-Rating
/// "How would you rate your everyday mental math?"
struct ConfidenceRatingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(level: ConfidenceLevel, label: String, sub: String, symbol: String, color: Color)] = [
        (.struggle, "I freeze", "I just go with whatever they offer", "exclamationmark.triangle.fill", Theme.Colors.warmOrange),
        (.getBy, "I muddle through", "And hope it works out", "tortoise.fill", Theme.Colors.ember),
        (.decent, "I\u{2019}m okay", "But I second-guess myself after", "hand.thumbsup.fill", Theme.Colors.mindTeal),
        (.quick, "I\u{2019}m sharp", "Just want to stay that way", "bolt.fill", Theme.Colors.mindTeal),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When a money decision lands on you, how does it feel?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("No wrong answer. This one\u{2019}s just for us.")
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
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        viewModel.setConfidence(opt.level)
                                    }
                                } icon: {
                                    IconTile(systemName: opt.symbol, tintColor: opt.color, size: 38)
                                }
                            }
                        }
                        .padding(.top, 22)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                if let level = viewModel.signals.confidenceLevel {
                    Text(MirroringCopy.reflection(forConfidence: level))
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 10)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
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
