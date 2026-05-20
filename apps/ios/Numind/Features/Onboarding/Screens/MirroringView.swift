import SwiftUI

/// Screen 8 — Mirroring / Reinforcement
/// NLP mirroring: reflects motivation + aspiration back with benefit framing.
struct MirroringView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            // Soft halo
            RadialGradient(
                colors: [Theme.Colors.primaryBlue.opacity(0.10), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 160
            )
            .frame(width: 320, height: 320)
            .offset(y: -40)

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Based on your goals")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.primaryBlue)
                            .padding(.top, 4)

                        Text(MirroringCopy.headline(for: viewModel.signals.aspiration))
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(2)
                            .padding(.top, 10)

                        // Bullet card
                        NumindCard {
                            VStack(spacing: 0) {
                                let bullets = MirroringCopy.bullets(for: viewModel.signals.motivations)
                                ForEach(Array(bullets.enumerated()), id: \.offset) { index, bullet in
                                    if index > 0 {
                                        Divider()
                                            .padding(.vertical, 12)
                                    }
                                    mirrorRow(bullet)
                                }
                            }
                        }
                        .padding(.top, 22)

                        Text("We built Numind for exactly this.")
                            .font(Theme.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 22)

                        Text("Your plan will reflect what you told us.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("That\u{2019}s what I need") { onContinue() }
                }
            }
        }
    }

    private func mirrorRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.Colors.mindTeal)
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineSpacing(4)
        }
    }
}

#Preview {
    MirroringView(
        viewModel: {
            let vm = OnboardingViewModel(
                progressStore: ProgressStore(),
                repository: LocalContentRepository()
            )
            vm.setAspiration(.confidentWithMoney)
            vm.toggleMotivation(.careerGrowth)
            vm.toggleMotivation(.buildConfidence)
            return vm
        }(),
        onContinue: {}
    )
}
