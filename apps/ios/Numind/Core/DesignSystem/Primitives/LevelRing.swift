import SwiftUI

/// A compact ring showing the user's current **Level** and progress toward the
/// next (Phase 9). Replaces `NumindScoreRing` as the headline chip — Level is
/// an effort signal (XP), not a 0–100 competence verdict, so there are no tier
/// names or verdict colors.
struct LevelRing: View {
    let level: Int
    /// 0–1 progress through the current level toward the next.
    var progress: Double = 0
    var size: CGFloat = 52

    private var ringWidth: CGFloat { max(5, size * 0.12) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    LinearGradient(
                        colors: [Theme.Colors.primaryBlue, Theme.Colors.mindTeal],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            VStack(spacing: 0) {
                if size >= 64 {
                    Text("LEVEL")
                        .font(.system(size: max(6, size * 0.11), weight: .heavy))
                        .foregroundStyle(Theme.Colors.mutedText)
                        .kerning(0.5)
                }
                Text("\(level)")
                    .font(.system(size: size * 0.40, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        LevelRing(level: 3, progress: 0.4, size: 52)
        LevelRing(level: 7, progress: 0.7, size: 88)
        LevelRing(level: 12, progress: 0.25, size: 120)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
