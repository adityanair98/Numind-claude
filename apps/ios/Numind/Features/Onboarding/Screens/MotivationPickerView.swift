import SwiftUI

/// Screen 6 — Motivation ("What brings you to Numind?")
/// Multi-select, pick up to 3.
struct MotivationPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(motivation: Motivation, label: String, sub: String, emoji: String, color: Color)] = [
        (.stopLeavingMoney, "Stop leaving money on the table", "Negotiation, benefits, the match", "\u{1F4BC}", Theme.Colors.warmOrange),
        (.stopGettingTaken, "Stop getting taken advantage of", "Scams, fees, dealer tactics", "\u{1F6E1}", Theme.Colors.debtCoral),
        (.decideWithConfidence, "Decide with confidence, not anxiety", "Know your numbers before the moment", "\u{1F4AA}", Theme.Colors.mindTeal),
        (.understandPaycheck, "Actually understand my paycheck", "Deductions, benefits, taxes", "\u{1F9FE}", Theme.Colors.taxSlate),
        (.getAheadOfDebt, "Get ahead of my debt", "Interest, payoff, the real cost", "\u{1F4B3}", Theme.Colors.primaryBlue),
        (.growMoney, "Make my money grow", "Match, accounts, compounding", "\u{1F4C8}", Theme.Colors.investIndigo),
        (.staySharp, "Keep my money instincts sharp", "Daily reps, no fading skills", "\u{26A1}", Theme.Colors.growthGreen),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What brings you to Numind?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        HStack(spacing: 8) {
                            Text("Pick up to 3")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)

                            Text("\(viewModel.signals.motivations.count) of 3 selected")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.primaryBlueTint)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        VStack(spacing: 8) {
                            ForEach(options, id: \.motivation) { opt in
                                OnboardingMultiCard(
                                    label: opt.label,
                                    subtitle: opt.sub,
                                    selected: viewModel.signals.motivations.contains(opt.motivation),
                                    accentColor: opt.color
                                ) {
                                    viewModel.toggleMotivation(opt.motivation)
                                } icon: {
                                    OnboardingIconTile(emoji: opt.emoji, color: opt.color, size: 36)
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
                .opacity(viewModel.signals.motivations.isEmpty ? 0.5 : 1)
                .allowsHitTesting(!viewModel.signals.motivations.isEmpty)
            }
        }
    }
}

#Preview {
    MotivationPickerView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
