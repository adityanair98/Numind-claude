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
            Theme.Colors.softBackground.ignoresSafeArea()

            // Halo
            RadialGradient(
                colors: [Theme.Colors.insightYellow.opacity(0.28), .clear],
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
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 4)

                        Text("\(minutesPerDay) minutes a day equals")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 20)

                        Text("\(hoursPerYear) hours")
                            .font(.system(size: 64, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Theme.Colors.insightText)
                            .padding(.top, 6)

                        Text("this year")
                            .font(Theme.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 4)

                        // Compound chart card
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("A few minutes daily")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Colors.mutedText)
                                Spacer()
                                Text("every moment")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.mindTeal)
                            }

                            Text("this year, met prepared \u{2014} raises, renewals, bills, plans")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)
                                .padding(.top, 2)

                            CompoundCurveView()
                                .padding(.top, 16)

                            HStack {
                                Text("Day 1")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.Colors.mutedText)
                                Spacer()
                                Text("Day 365")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.Colors.mutedText)
                            }
                            .padding(.top, 6)
                        }
                        .padding(18)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                        )
                        .padding(.top, 28)

                        Text(viewModel.isHabitBuyer
                             ? "Week one, tips stop needing your phone. Month one, you read a paycheck like a native. Month three, a dealer can\u{2019}t number you."
                             : "Short sessions. Real scenarios. No fluff \u{2014} a few minutes a day keeps your instincts sharp for whichever decision is next.")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(4)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("I\u{2019}m in") { onContinue() }
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
