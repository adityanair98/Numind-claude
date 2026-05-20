import SwiftUI

/// Horizontal dot indicator for the diagnostic quiz.
/// Current question's dot is wider (capsule), completed dots are teal,
/// remaining dots are small circles in muted tint.
struct DotProgress: View {
    let current: Int    // 1-based
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                let oneBasedIndex = index + 1
                if oneBasedIndex < current {
                    // Completed
                    Capsule()
                        .fill(Theme.Colors.mindTeal)
                        .frame(width: 16, height: 6)
                } else if oneBasedIndex == current {
                    // Current
                    Capsule()
                        .fill(Theme.Colors.primaryBlue)
                        .frame(width: 16, height: 6)
                } else {
                    // Remaining
                    Circle()
                        .fill(Theme.Colors.mutedTint)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: current)
    }
}

#Preview {
    VStack(spacing: 16) {
        DotProgress(current: 1, total: 8)
        DotProgress(current: 3, total: 8)
        DotProgress(current: 7, total: 8)
    }
    .padding()
}
