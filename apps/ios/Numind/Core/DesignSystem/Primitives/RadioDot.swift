import SwiftUI

/// Single-select radio indicator: 22pt circle, empty or filled.
struct RadioDot: View {
    let selected: Bool
    var color: Color = Theme.Colors.primaryBlue
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    selected ? color : Theme.Colors.mutedText.opacity(0.32),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            if selected {
                Circle()
                    .fill(color)
                    .frame(width: size - 10, height: size - 10)
            }
        }
        .animation(.easeOut(duration: 0.12), value: selected)
    }
}

#Preview {
    HStack(spacing: 20) {
        RadioDot(selected: false)
        RadioDot(selected: true)
        RadioDot(selected: true, color: Theme.Colors.mindTeal)
    }
    .padding()
}
