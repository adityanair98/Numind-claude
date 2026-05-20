import SwiftUI

/// Multi-select indicator: 22pt circle with checkmark when selected.
struct CheckBadge: View {
    let selected: Bool
    var color: Color = Theme.Colors.primaryBlue
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            if selected {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)

                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.45, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Circle()
                    .strokeBorder(Theme.Colors.mutedText.opacity(0.28), lineWidth: 1.5)
                    .frame(width: size, height: size)
            }
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}

#Preview {
    HStack(spacing: 20) {
        CheckBadge(selected: false)
        CheckBadge(selected: true)
        CheckBadge(selected: true, color: Theme.Colors.mindTeal)
    }
    .padding()
}
