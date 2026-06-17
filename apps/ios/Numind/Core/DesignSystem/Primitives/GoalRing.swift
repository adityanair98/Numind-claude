import SwiftUI

/// The daily goal ring (Phase 10) — the app's one glanceable daily signal,
/// replacing the retired LevelRing in the same slots. Fill = today's practice
/// against the ring target; closed = a checkmark and the day counts toward
/// the streak. Fueled invisibly by the XP engine; no points are shown.
struct GoalRing: View {
    let progress: Double      // 0–1 ring fill
    let isClosed: Bool
    var centerText: String? = nil
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.track, lineWidth: size * 0.11)
            Circle()
                .trim(from: 0, to: max(0.02, min(1, progress)))
                .stroke(
                    Theme.Colors.mindTeal,   // teal = ready/positive (Phase 13)
                    style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
            if isClosed {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.34, weight: .bold))
                    .foregroundStyle(Theme.Colors.mindTeal)
            } else if let centerText {
                Text(centerText)
                    .font(.system(size: size * 0.26, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .minimumScaleFactor(0.6)
            }
        }
        .frame(width: size, height: size)
    }
}
