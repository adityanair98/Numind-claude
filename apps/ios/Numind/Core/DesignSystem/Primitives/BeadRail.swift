import SwiftUI

struct BeadRail: View {
    enum Variant { case dot, chunky }

    let progress: Int
    let total: Int
    var variant: Variant = .dot

    var body: some View {
        HStack(spacing: variant == .chunky ? 6 : 8) {
            ForEach(0..<total, id: \.self) { index in
                beadView(at: index)
            }
        }
    }

    @ViewBuilder
    private func beadView(at index: Int) -> some View {
        switch variant {
        case .chunky:
            Capsule()
                .frame(width: 28, height: 6)
                .foregroundStyle(
                    index < progress
                        ? Theme.Colors.primaryBlue
                        : Theme.Colors.mutedTint
                )
        case .dot:
            let isDone    = index < progress
            let isCurrent = index == progress
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(
                    isDone    ? Theme.Colors.insightYellow :
                    isCurrent ? Theme.Colors.primaryBlue   :
                                Theme.Colors.mutedTint
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
