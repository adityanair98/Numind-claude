import SwiftUI

/// Screen 21 — Paywall Priming (coffee comparison + the cost of guessing)
struct PaywallPrimingView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Less than a coffee a month")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("One unprepared money decision costs more than a year of Numind. Usually a lot more.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(3)
                            .padding(.top, 8)

                        // Comparison cards
                        HStack(spacing: 12) {
                            comparisonCard(
                                symbol: "cup.and.saucer.fill",
                                label: "One coffee",
                                price: "$5.50",
                                sub: "20 minutes of caffeine",
                                tint: Theme.Colors.warmOrangeTint,
                                color: Theme.Colors.warmOrange,
                                featured: false
                            )
                            comparisonCard(
                                symbol: "brain.head.profile",
                                label: "Numind / week",
                                price: "$3.99",
                                sub: "Every money decision, prepared",
                                tint: Theme.Colors.mindTealTint,
                                color: Theme.Colors.mindTeal,
                                featured: true
                            )
                        }
                        .padding(.top, 26)

                        // Quick math card — verified real-mistake costs
                        NumindCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What unprepared costs")
                                    .font(Theme.Typography.small)
                                    .textCase(.uppercase)
                                    .tracking(1)
                                    .foregroundStyle(Theme.Colors.mutedText)

                                mathLine(left: "Cashing out a 401(k) at a job change", right: "\u{2212}$2,000+", muted: true)
                                mathLine(left: "A year of unclaimed employer match", right: "\u{2212}$1,000+", muted: true)
                                mathLine(left: "Forfeited FSA money (use it or lose it)", right: "\u{2212}$400+", muted: true)
                                Divider().padding(.vertical, 4)
                                mathLine(left: "Numind, for a whole year (annual plan)", right: "$29.99", highlight: true)
                            }
                        }
                        .padding(.top, 22)

                        Text("One prepared decision pays for a decade of it.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Sounds fair") { onContinue() }
                }
            }
        }
    }

    private func comparisonCard(
        symbol: String, label: String, price: String, sub: String,
        tint: Color, color: Color, featured: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 56, height: 56)
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.Colors.mutedText)

            Text(price)
                .font(.system(size: 24, weight: .heavy, design: .monospaced))
                .foregroundStyle(Theme.Colors.deepNavy)

            Text(sub)
                .font(.system(size: 12))
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(minHeight: 180)
        .background(
            featured
                ? LinearGradient(colors: [Theme.Colors.cardBackground, tint], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [Theme.Colors.cardBackground, Theme.Colors.cardBackground], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(featured ? color : Theme.Colors.hairline, lineWidth: featured ? 1.5 : 1)
        )
        .overlay(alignment: .topTrailing) {
            if featured {
                Text("BETTER")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(0.5)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(color)
                    .clipShape(Capsule())
                    .padding(12)
            }
        }
        .shadow(
            color: featured ? color.opacity(0.14) : .black.opacity(0.04),
            radius: featured ? 14 : 3, x: 0, y: featured ? 6 : 1
        )
    }

    private func mathLine(left: String, right: String, muted: Bool = false, highlight: Bool = false) -> some View {
        HStack {
            Text(left)
                .font(.system(size: 14))
                .foregroundStyle(muted ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
            Spacer()
            Text(right)
                .font(.system(size: 14, weight: highlight ? .heavy : .semibold, design: .monospaced))
                .foregroundStyle(
                    highlight ? Theme.Colors.mindTeal :
                    muted ? Theme.Colors.mutedText : Theme.Colors.deepNavy
                )
        }
    }
}

#Preview {
    PaywallPrimingView(onContinue: {})
}
