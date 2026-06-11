import SwiftUI

/// Screen 4 — Insecurity Mirror (question + reveal sub-states).
///
/// "Which of these have happened to you?" — the user names the moments
/// they felt unprepared for, then the reveal shows the verified cost of
/// exactly those moments and that each has a 5-minute version of the math.
/// Replaces the old screen-time/opportunity-cost device with one that is
/// specific to money decisions.
struct InsecurityMirrorView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            if viewModel.mirrorRevealed {
                revealState
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                questionState
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.mirrorRevealed)
    }

    // MARK: - Question State

    private var questionState: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Which of these have happened to you?")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .padding(.top, 8)

                    Text("Pick any that ring true \u{2014} most people have at least one.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(FeltMoment.allCases, id: \.self) { moment in
                            OnboardingSelectCard(
                                label: moment.displayText,
                                selected: viewModel.signals.feltMoments.contains(moment)
                            ) {
                                viewModel.toggleFeltMoment(moment)
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
            .opacity(viewModel.signals.feltMoments.isEmpty ? 0.5 : 1)
            .allowsHitTesting(!viewModel.signals.feltMoments.isEmpty)
        }
    }

    // MARK: - Reveal State

    private var hasRealMoment: Bool {
        !viewModel.signals.feltMoments.subtracting([.noneYet]).isEmpty
    }

    private var revealState: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(hasRealMoment ? "You\u{2019}re in good company" : "You\u{2019}re ahead of most")
                        .font(Theme.Typography.small)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 4)

                    Text(hasRealMoment
                         ? "Every one of these has a 5-minute fix."
                         : "These moments are coming \u{2014} and each has a 5-minute fix.")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(2)
                        .padding(.top, 12)

                    // Verified cost stats
                    VStack(spacing: 10) {
                        costRow(stat: "41%", text: "of people cash out their 401(k) when changing jobs \u{2014} paying tax plus a 10% penalty",
                                source: "UBC Sauder / HBR")
                        costRow(stat: "$24B", text: "in employer 401(k) match goes unclaimed every year",
                                source: "Financial Engines")
                        costRow(stat: "$4.5B", text: "in FSA money is forfeited annually \u{2014} use it or lose it",
                                source: "EBRI")
                    }
                    .padding(.top, 22)

                    Text("Not because people are careless \u{2014} because nobody showed them what to look for before the moment arrived.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .lineSpacing(3)
                        .padding(.top, 18)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 120)
            }

            onboardingFooter(dark: false) {
                PillButton("Show me how") { onContinue() }
            }
        }
    }

    private func costRow(stat: String, text: String, source: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(stat)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Colors.warmOrange)
                .frame(width: 72, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
                Text(source)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    InsecurityMirrorView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
