import SwiftUI

/// Screen 11 — Kaizen / Compounding (DARK)
/// Shows yearly time projection + 1.01^365 compound curve.
struct KaizenView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private var minutesPerDay: Int {
        viewModel.signals.dailyMinutes ?? 10
    }

    private var hoursPerYear: Int {
        Int(round(Double(minutesPerDay) / 60.0 * 365.0))
    }

    var body: some View {
        ZStack {
            Theme.Colors.deepNavy.ignoresSafeArea()

            // Halo
            RadialGradient(
                colors: [Theme.Colors.insightYellow.opacity(0.16), .clear],
                center: .init(x: 0.8, y: 0.0),
                startRadius: 0,
                endRadius: 160
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("The kaizen principle")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.top, 4)

                        Text("\(minutesPerDay) minutes a day equals")
                            .font(Theme.Typography.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.top, 20)

                        Text("\(hoursPerYear) hours")
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Colors.insightYellow)
                            .padding(.top, 6)

                        Text("this year")
                            .font(Theme.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.top, 4)

                        // Compound chart card
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("A few minutes daily")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Text("every moment")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.Colors.mindTeal)
                            }

                            Text("this year, met prepared \u{2014} raises, renewals, bills, plans")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.white.opacity(0.55))
                                .padding(.top, 2)

                            CompoundCurveView()
                                .padding(.top, 16)

                            HStack {
                                Text("Day 1")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.5))
                                Spacer()
                                Text("Day 365")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.top, 6)
                        }
                        .padding(18)
                        .background(.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                        )
                        .padding(.top, 28)

                        Text("Short sessions. Real scenarios. No fluff \u{2014} a few minutes a day keeps the math sharp for whichever decision is next.")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineSpacing(4)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: true) {
                    Button(action: onContinue) {
                        Text("I\u{2019}m in")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    KaizenView(
        viewModel: {
            let vm = OnboardingViewModel(
                progressStore: ProgressStore(),
                repository: LocalContentRepository()
            )
            vm.setDailyMinutes(10)
            return vm
        }(),
        onContinue: {}
    )
}
