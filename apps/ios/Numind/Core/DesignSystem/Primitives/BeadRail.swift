import SwiftUI

// Placeholder geometry — bead size, spacing, and rail shape will be
// refined after Claude Design wireframes are approved.
struct BeadRail: View {
    let progress: Int
    let total: Int

    private let beadSize: CGFloat = 10
    private let beadSpacing: CGFloat = 8

    var body: some View {
        HStack(spacing: beadSpacing) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .frame(width: beadSize, height: beadSize)
                    .foregroundStyle(
                        index < progress
                            ? Theme.Colors.insightYellow
                            : Theme.Colors.mutedText.opacity(0.25)
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        BeadRail(progress: 3, total: 5)
        BeadRail(progress: 0, total: 5)
        BeadRail(progress: 5, total: 5)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
