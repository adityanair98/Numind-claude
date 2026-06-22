import SwiftUI

/// Screen 6 — Motivation ("What brings you to Numind?")
/// Multi-select, pick up to 3.
struct MotivationPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    // One accent for every card — selection feedback should read as
    // "selected", not as seven competing theme colors. Labels come from
    // Motivation.displayText so later screens can echo them verbatim.
    // Personal, second-person sublines (varied in shape) — the old set was
    // mostly "noun, noun, noun" lists that all read the same.
    private let options: [(motivation: Motivation, sub: String, symbol: String)] = [
        (.fillTheGapSchoolLeft, "No one ever sat you down and explained it", "graduationcap.fill"),
        (.decideWithConfidence, "Walk in already knowing the move", "checkmark.seal.fill"),
        (.stopLeavingMoney, "Claim the raises and matches you\u{2019}re owed", "briefcase.fill"),
        (.stopGettingTaken, "Never get played by a fee or a closer", "shield.fill"),
        (.understandPaycheck, "Finally see what\u{2019}s eating your check", "doc.text.fill"),
        (.getAheadOfDebt, "Get out from under it for good", "creditcard.fill"),
        (.growMoney, "Put it to work instead of just sitting", "chart.line.uptrend.xyaxis"),
        (.staySharp, "Stay quick \u{2014} don\u{2019}t let it fade", "bolt.fill"),
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
                            .padding(.top, 24)

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
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        viewModel.toggleMotivation(opt.motivation)
                                    }
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

                if let reflection = MirroringCopy.reflection(forMotivations: viewModel.signals.motivations) {
                    Text(reflection)
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
