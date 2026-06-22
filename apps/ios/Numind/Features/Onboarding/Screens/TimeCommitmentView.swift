import SwiftUI

/// Screen 10 — Time Commitment ("How much time can you dedicate daily?")
struct TimeCommitmentView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    // Short by design — Numind's loop is decision-sized daily reps, not long
    // study blocks. Offering 15/20 over-promised time the session won't fill.
    private let options: [(minutes: Int, label: String, sub: String, color: Color)] = [
        (3, "3 minutes", "A quick daily rep", Theme.Colors.mindTeal),
        (5, "5 minutes", "The sweet spot", Theme.Colors.topicPaycheck),
        (10, "10 minutes", "Go a little deeper", Theme.Colors.warmOrange),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("How much time can you dedicate daily?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("Pick what you\u{2019}ll actually do \u{2014} not aspirational.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(options, id: \.minutes) { opt in
                                let minuteLabel = opt.label.components(separatedBy: " ").first ?? ""
                                OnboardingSelectCard(
                                    label: opt.label,
                                    subtitle: opt.sub,
                                    selected: viewModel.signals.dailyMinutes == opt.minutes,
                                    accentColor: opt.color
                                ) {
                                    viewModel.setDailyMinutes(opt.minutes)
                                } icon: {
                                    Text(minuteLabel)
                                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                                        .foregroundStyle(opt.color)
                                        .frame(width: 44, height: 44)
                                        .background(opt.color.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        }
                        .padding(.top, 22)

                        // Hint
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Colors.mindTeal)
                            Text("You can always do more with practice modes beyond your daily goal.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Colors.deepNavy)
                        }
                        .padding(14)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(viewModel.signals.dailyMinutes != nil ? 1 : 0.5)
                .allowsHitTesting(viewModel.signals.dailyMinutes != nil)
            }
        }
    }
}

#Preview {
    TimeCommitmentView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
