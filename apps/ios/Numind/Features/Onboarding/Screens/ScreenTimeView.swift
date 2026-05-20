import SwiftUI

/// Screen 4 — Screen Time (question + reveal sub-states)
/// Asks social media time, then reveals yearly extrapolation.
struct ScreenTimeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let options: [(label: String, minutes: Int)] = [
        ("30 minutes", 30),
        ("1 hour", 60),
        ("2 hours", 120),
        ("3+ hours", 180),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            if viewModel.screenTimeRevealed {
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.screenTimeRevealed)
    }

    // MARK: - Question State

    private var questionState: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("How much time do you spend on social media daily?")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .padding(.top, 8)

                    Text("Average estimate is fine \u{2014} we\u{2019}re not judging.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(options, id: \.minutes) { opt in
                            OnboardingSelectCard(
                                label: opt.label,
                                selected: viewModel.signals.socialMediaMinutes == opt.minutes
                            ) {
                                viewModel.setSocialMediaMinutes(opt.minutes)
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
            .opacity(viewModel.signals.socialMediaMinutes != nil ? 1 : 0.5)
            .allowsHitTesting(viewModel.signals.socialMediaMinutes != nil)
        }
    }

    // MARK: - Reveal State

    private var revealState: some View {
        let minutes = viewModel.signals.socialMediaMinutes ?? 120
        let hoursPerYear = Int(Double(minutes) / 60.0 * 365.0)
        let label: String = {
            switch minutes {
            case 30:  return "30 min"
            case 60:  return "1 hour"
            case 120: return "2 hours"
            default:  return "3+ hours"
            }
        }()

        return VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("You said \(label)/day. That\u{2019}s\u{2026}")
                        .font(Theme.Typography.small)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 4)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(hoursPerYear)")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("hrs/yr")
                            .font(Theme.Typography.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    .padding(.top, 12)

                    Text("on social media alone")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 6)

                    // VS divider
                    HStack(spacing: 12) {
                        VStack { Divider() }
                        Text("VS")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .tracking(2)
                        VStack { Divider() }
                    }
                    .padding(.vertical, 28)

                    // Numind comparison card
                    HStack(alignment: .top, spacing: 12) {
                        Text("\u{1F9E0}")
                            .font(.system(size: 26))
                            .frame(width: 48, height: 48)
                            .background(Theme.Colors.mindTealTint)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Just 10 minutes on Numind")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)
                            Text("61 hours/year")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.Colors.mindTeal)
                            Text("\u{2014} enough to build a real skill.")
                                .font(Theme.Typography.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .padding(.top, 4)
                        }
                    }
                    .padding(18)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Theme.Colors.mindTeal, lineWidth: 1.5)
                    )
                    .shadow(color: Theme.Colors.mindTeal.opacity(0.18), radius: 14, x: 0, y: 6)

                    Text("Structured practice \u{2014} even in short daily sessions \u{2014} produces measurable skill improvement.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .lineSpacing(3)
                        .padding(.top, 18)

                    Text("Source: Ericsson et al., 1993")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                        .padding(.top, 8)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 120)
            }

            onboardingFooter(dark: false) {
                PillButton("That\u{2019}s eye-opening") { onContinue() }
            }
        }
    }
}

#Preview {
    ScreenTimeView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
