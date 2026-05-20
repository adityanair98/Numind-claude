import SwiftUI

/// Screen 6 — Motivation ("What brings you to Numind?")
/// Multi-select, pick up to 3.
struct MotivationPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(motivation: Motivation, label: String, sub: String, emoji: String, color: Color)] = [
        (.financialDecisions, "Better financial decisions", "Tips, budgets, investments", "\u{1F4B0}", Theme.Colors.primaryBlue),
        (.buildConfidence, "Build confidence", "Stop second-guessing math", "\u{1F4AA}", Theme.Colors.mindTeal),
        (.careerGrowth, "Career growth", "Salary, business math", "\u{1F4C8}", Theme.Colors.warmOrange),
        (.staySharp, "Stay mentally sharp", "Keep my mind active", "\u{1F9E0}", Theme.Colors.investIndigo),
        (.supportEducation, "Support my education", "School, exams, coursework", "\u{1F4DA}", Theme.Colors.growthGreen),
        (.appearSharper, "Appear sharper socially", "Impress friends, split bills", "\u{2728}", Theme.Colors.insightYellow),
        (.boostFocus, "Boost focus & analysis", "Train my brain", "\u{1F3AF}", Theme.Colors.debtCoral),
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
