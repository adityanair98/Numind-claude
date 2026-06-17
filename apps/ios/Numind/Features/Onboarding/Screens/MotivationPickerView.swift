import SwiftUI

/// Screen 6 — Motivation ("What brings you to Numind?")
/// Multi-select, pick up to 3.
struct MotivationPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    // One accent for every card — selection feedback should read as
    // "selected", not as seven competing theme colors. Labels come from
    // Motivation.displayText so later screens can echo them verbatim.
    private let options: [(motivation: Motivation, sub: String, symbol: String)] = [
        (.stopLeavingMoney, "Negotiation, benefits, the match", "briefcase.fill"),
        (.stopGettingTaken, "Scams, fees, dealer tactics", "shield.fill"),
        (.decideWithConfidence, "Know your numbers before the moment", "checkmark.seal.fill"),
        (.understandPaycheck, "Deductions, benefits, taxes", "doc.text.fill"),
        (.getAheadOfDebt, "Interest, payoff, the real cost", "creditcard.fill"),
        (.growMoney, "Match, accounts, compounding", "chart.line.uptrend.xyaxis"),
        (.staySharp, "Daily reps, no fading skills", "bolt.fill"),
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
                                .foregroundStyle(Theme.Colors.mindTeal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.mindTealTint)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        VStack(spacing: 8) {
                            ForEach(options, id: \.motivation) { opt in
                                OnboardingMultiCard(
                                    label: opt.motivation.displayText,
                                    subtitle: opt.sub,
                                    selected: viewModel.signals.motivations.contains(opt.motivation),
                                    accentColor: Theme.Colors.mindTeal
                                ) {
                                    viewModel.toggleMotivation(opt.motivation)
                                } icon: {
                                    IconTile(systemName: opt.symbol, tintColor: Theme.Colors.mindTeal, size: 36)
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
