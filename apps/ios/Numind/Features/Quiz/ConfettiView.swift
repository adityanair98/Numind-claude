import SwiftUI

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { ConfettiPiece(index: $0) }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let index: Int
    @State private var animate = false

    // Upper-semicircle burst: angles 0°→175° so all pieces go upward or sideways
    private var angle: Double     { Double(index * 5) }
    private var distance: CGFloat { CGFloat(80 + (index % 5) * 30) }
    private var rotDelta: Double  { Double((index % 5 + 1) * 72) }
    private var size: CGFloat     { CGFloat(6 + index % 4 * 2) }
    private var isRound: Bool     { index % 3 == 0 }
    private var delay: Double     { Double(index % 5) * 0.03 }

    private var color: Color {
        let palette: [Color] = [
            Theme.Colors.primaryBlue,
            Theme.Colors.mindTeal,
            Theme.Colors.insightYellow,
            .pink, .orange
        ]
        return palette[index % palette.count]
    }

    private var dx: CGFloat { distance * CGFloat(cos(angle * .pi / 180)) }
    private var dy: CGFloat { -distance * CGFloat(sin(angle * .pi / 180)) }

    var body: some View {
        RoundedRectangle(cornerRadius: isRound ? size / 2 : 2)
            .fill(color)
            .frame(width: size, height: isRound ? size : size * 1.6)
            .rotationEffect(.degrees(animate ? rotDelta : 0))
            .offset(x: animate ? dx : 0, y: animate ? dy : 0)
            .opacity(animate ? 0 : 0.95)
            .onAppear {
                withAnimation(.easeOut(duration: 0.85).delay(delay)) {
                    animate = true
                }
            }
    }
}
