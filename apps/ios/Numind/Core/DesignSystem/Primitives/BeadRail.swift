import SwiftUI

struct BeadRail: View {
    enum Variant { case dot, chunky }

    let progress: Int
    let total: Int
    var variant: Variant = .dot

    /// Override the filled-bead color (default: primaryBlue for chunky, insightYellow for dot).
    var filledColor: Color? = nil
    /// Override the track / unfilled color (default: mutedTint).
    var trackColor: Color = Theme.Colors.mutedTint

    // Chunky rail is bounded — beads SHRINK to fit a large pack instead of
    // overflowing the row. A 12-lesson pack at a fixed 28pt/bead is ~400pt of
    // rail, which stretched the whole Home VStack past the screen (everything
    // shifted/clipped, read as "zoomed in"). ≤5 beads keep the full 28pt pill.
    private static let chunkySpacing: CGFloat = 6
    private static let chunkyMaxRailWidth: CGFloat = 170

    private var chunkyBeadWidth: CGFloat {
        guard total > 1 else { return 28 }
        let avail = Self.chunkyMaxRailWidth - Self.chunkySpacing * CGFloat(total - 1)
        return max(4, min(28, avail / CGFloat(total)))
    }

    var body: some View {
        HStack(spacing: variant == .chunky ? Self.chunkySpacing : 8) {
            ForEach(0..<total, id: \.self) { index in
                beadView(at: index)
            }
        }
    }

    @ViewBuilder
    private func beadView(at index: Int) -> some View {
        switch variant {
        case .chunky:
            let filled = filledColor ?? Theme.Colors.primaryBlue
            Capsule()
                .frame(width: chunkyBeadWidth, height: 6)
                .foregroundStyle(index < progress ? filled : trackColor)
                .shadow(color: index < progress ? filled.opacity(0.35) : .clear, radius: 3, y: 0)
        case .dot:
            let isDone    = index < progress
            let isCurrent = index == progress
            let doneFill = filledColor ?? Theme.Colors.insightYellow
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(
                    isDone    ? doneFill :
                    isCurrent ? Theme.Colors.primaryBlue :
                                trackColor
                )
                .scaleEffect(isCurrent ? 1.3 : 1)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        Text("Dot variant").font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
        BeadRail(progress: 3, total: 5, variant: .dot)
        BeadRail(progress: 0, total: 5, variant: .dot)
        BeadRail(progress: 5, total: 5, variant: .dot)

        Divider()

        Text("Chunky variant").font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
        BeadRail(progress: 2, total: 5, variant: .chunky)
        BeadRail(progress: 0, total: 5, variant: .chunky)
        BeadRail(progress: 5, total: 5, variant: .chunky)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
