import SwiftUI

/// A circular donut ring displaying a 0–100 Numind Score.
///
/// The arc fills clockwise from the top, coloured with the brand blue→teal
/// gradient. An optional delta badge floats below the ring.
///
/// Usage:
/// ```swift
/// NumindScoreRing(score: 72, delta: +8, size: 120)
/// NumindScoreRing(score: 45)          // compact, no delta
/// ```
struct NumindScoreRing: View {
    let score: Int
    /// Change vs. 7 days ago. Nil hides the badge; 0 shows a neutral badge.
    var delta: Int? = nil
    /// Overall diameter of the ring.
    var size: CGFloat = 88

    private var progress: Double { Double(max(0, min(100, score))) / 100 }
    private var ringWidth: CGFloat { max(6, size * 0.13) }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: ringWidth)

            // Filled arc — blue → teal gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Theme.Colors.primaryBlue, Theme.Colors.mindTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: score)

            // Center label
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .contentTransition(.numericText())
                Text("SCORE")
                    .font(.system(size: max(7, size * 0.10), weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.6)
            }

            // Delta badge — positioned just below the ring
            if let delta {
                deltaBadge(delta)
                    .offset(y: size * 0.44)
            }
        }
        .frame(width: size, height: size + (delta != nil ? size * 0.22 : 0))
    }

    @ViewBuilder
    private func deltaBadge(_ delta: Int) -> some View {
        let isPositive = delta > 0
        let isNeutral  = delta == 0
        let label      = isNeutral ? "—" : (isPositive ? "+\(delta)" : "\(delta)")
        let color: Color = isNeutral ? Theme.Colors.mutedText
                         : isPositive ? Theme.Colors.mindTeal
                         : Theme.Colors.errorSoftRed

        Text(label)
            .font(.system(size: max(9, size * 0.13), weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Previews

#Preview("Score ring variants") {
    VStack(spacing: 24) {
        HStack(spacing: 32) {
            NumindScoreRing(score: 0,   delta: nil)
            NumindScoreRing(score: 45,  delta: 0)
            NumindScoreRing(score: 72,  delta: 8)
            NumindScoreRing(score: 100, delta: -3)
        }
        NumindScoreRing(score: 78, delta: 12, size: 140)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
