import SwiftUI

/// Screen 12 — ADHD Screen with conditional reveal card.
struct ADHDScreenView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Do you have ADD or ADHD?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("We use this only to tune your sessions \u{2014} never as a diagnosis.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        VStack(spacing: 8) {
                            ForEach(ADHDStatus.allCases, id: \.self) { status in
                                OnboardingSelectCard(
                                    label: status.displayText,
                                    selected: viewModel.signals.adhdStatus == status
                                ) {
                                    viewModel.setADHDStatus(status)
                                }
                            }
                        }
                        .padding(.top, 18)

                        // Conditional reveal card
                        if let status = viewModel.signals.adhdStatus, status.showsReveal {
                            revealCard
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }
                .animation(.easeOut(duration: 0.3), value: viewModel.signals.adhdStatus)

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(viewModel.signals.adhdStatus != nil ? 1 : 0.5)
                .allowsHitTesting(viewModel.signals.adhdStatus != nil)
            }
        }
    }

    private var revealCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\u{1F331}")
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text("Numind is built for short attention windows")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)

                (Text("An FDA-cleared game-based tool showed significant attention improvement in adults with ADHD \u{2014} ")
                    + Text("72.5% reported quality-of-life gains")
                        .fontWeight(.bold)
                    + Text("."))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)

                Text("Numind\u{2019}s short, decision-sized sessions are designed to work with your attention \u{2014} not against it.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
                    .padding(.top, 2)

                Text("EndeavorOTC / STARS-ADHD-Adult, Akili Interactive, 2023")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Theme.Colors.mindTealTint)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.mindTeal.opacity(0.20), lineWidth: 1)
        )
        .padding(.top, 18)
    }
}

#Preview {
    ADHDScreenView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
