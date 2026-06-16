import SwiftUI

/// Screen 3 — "It's not knowledge, it's timing."
/// Money decisions arrive as MOMENTS — the frame the whole funnel runs on.
struct DailyMicroView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Clock illustration
                HStack {
                    Spacer()
                    ClockIllustration()
                    Spacer()
                }
                .padding(.top, 28)

                Text("You don\u{2019}t need a finance course. You need to be ready on the day it happens.")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30)

                (Text("Money decisions arrive as ")
                    + Text("moments")
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.deepNavy)
                    + Text(" \u{2014} a job offer every few years, open enrollment every fall, a lease every year. Five minutes a day keeps your money instincts sharp for whichever one is next."))
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            // Footer
            VStack {
                Spacer()
                onboardingFooter(dark: false) {
                    PillButton("That\u{2019}s me") { onContinue() }
                }
            }
        }
    }
}

// MARK: - Clock Illustration

private struct ClockIllustration: View {
    var body: some View {
        ZStack {
            // Glow
            RadialGradient(
                colors: [Theme.Colors.primaryBlue.opacity(0.10), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 120
            )
            .frame(width: 240, height: 240)

            // Outer ring
            Circle()
                .fill(.white)
                .frame(width: 200, height: 200)
                .shadow(color: Theme.Colors.deepNavy.opacity(0.10), radius: 20, x: 0, y: 10)
                .overlay(
                    Circle()
                        .strokeBorder(Theme.Colors.primaryBlue.opacity(0.10), lineWidth: 2)
                )

            // 12 tick marks
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) * 30 - 90
                let rad = angle * .pi / 180
                let r: CGFloat = 84
                let cx = r * cos(rad)
                let cy = r * sin(rad)
                let accent = i == 0 || i == 1

                Circle()
                    .fill(accent ? Theme.Colors.insightYellow : Theme.Colors.mutedTint)
                    .frame(width: 6, height: 6)
                    .offset(x: cx, y: cy)
            }

            // Yellow arc for "5 min" section
            Circle()
                .trim(from: 0, to: 1.0 / 12.0)
                .rotation(.degrees(-90))
                .stroke(Theme.Colors.insightYellow, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 168, height: 168)

            // Center label
            VStack(spacing: 2) {
                Text("5")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("minutes / day")
                    .font(.system(size: 10, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .frame(width: 200, height: 200)
    }
}

#Preview {
    DailyMicroView(onContinue: {})
}
