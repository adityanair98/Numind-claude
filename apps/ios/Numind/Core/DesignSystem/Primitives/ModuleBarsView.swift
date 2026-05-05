import SwiftUI

/// A vertical stack of horizontal score bars — one per module.
///
/// Used as a fallback when there are fewer than 3 modules to render a
/// meaningful radar chart. Each row shows the module icon, name, a filled
/// progress bar, and the numeric score.
struct ModuleBarsView: View {

    struct Bar {
        let icon: String        // SF Symbol
        let label: String
        let score: Int          // 0–100
        let color: Color
        let previousScore: Int? // optional 7-day-ago reference
    }

    let bars: [Bar]
    var showPrevious: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                barRow(bar)
            }
        }
    }

    // MARK: - Row

    private func barRow(_ bar: Bar) -> some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: bar.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(bar.color)
                .frame(width: 20)

            // Label
            Text(bar.label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.Colors.deepNavy)
                .frame(width: 68, alignment: .leading)

            // Bar track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule().fill(Theme.Colors.mutedTint)

                    // Previous score ghost (dashed outline effect via opacity)
                    if showPrevious, let prev = bar.previousScore {
                        Capsule()
                            .fill(bar.color.opacity(0.18))
                            .frame(width: geo.size.width * CGFloat(max(0, min(100, prev))) / 100)
                    }

                    // Current fill
                    Capsule()
                        .fill(bar.color.opacity(0.8))
                        .frame(width: geo.size.width * CGFloat(max(0, min(100, bar.score))) / 100)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: bar.score)
                }
            }
            .frame(height: 8)

            // Score label
            Text("\(bar.score)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .frame(width: 28, alignment: .trailing)
        }
        .frame(height: 20)
    }
}

// MARK: - Preview

#Preview {
    ModuleBarsView(bars: [
        .init(icon: "dollarsign.circle", label: "Tips",      score: 82, color: Theme.Colors.primaryBlue,   previousScore: 65),
        .init(icon: "tag",              label: "Discounts",  score: 54, color: Theme.Colors.mindTeal,       previousScore: 45),
        .init(icon: "percent",          label: "Tax",        score: 71, color: Theme.Colors.investIndigo,   previousScore: 71),
        .init(icon: "briefcase",        label: "Salary",     score: 38, color: Theme.Colors.warmOrange,     previousScore: 30),
        .init(icon: "chart.line.uptrend.xyaxis", label: "Investing", score: 60, color: Theme.Colors.growthGreen, previousScore: nil),
    ])
    .padding()
    .background(Theme.Colors.softBackground)
}
