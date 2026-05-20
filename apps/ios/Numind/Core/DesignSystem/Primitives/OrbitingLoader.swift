import SwiftUI

/// Screen 17's "Preparing your results" loading animation.
/// 3 concentric pulsing rings + 4 orbiting dots + center brain badge.
struct OrbitingLoader: View {
    @State private var rotating = false

    var body: some View {
        ZStack {
            // Pulsing concentric rings
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .strokeBorder(
                        Theme.Colors.primaryBlue.opacity(0.18 + Double(ring) * 0.18),
                        lineWidth: 1.5
                    )
                    .frame(width: 180 - CGFloat(ring) * 28, height: 180 - CGFloat(ring) * 28)
                    .scaleEffect(rotating ? 1.0 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(ring) * 0.2),
                        value: rotating
                    )
            }

            // Inner frosted circle
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.18))
                .frame(width: 80, height: 80)

            // Center badge
            Circle()
                .fill(Theme.Colors.primaryBlue)
                .frame(width: 60, height: 60)
                .shadow(color: Theme.Colors.primaryBlue.opacity(0.6), radius: 20)
                .overlay(
                    Text("🧠")
                        .font(.system(size: 30))
                )

            // Orbiting dots (4 at 90° intervals)
            ForEach(0..<4, id: \.self) { index in
                let isEven = index % 2 == 0
                Circle()
                    .fill(isEven ? Theme.Colors.insightYellow : Theme.Colors.mindTeal)
                    .frame(width: 8, height: 8)
                    .shadow(color: (isEven ? Theme.Colors.insightYellow : Theme.Colors.mindTeal).opacity(0.6), radius: 6)
                    .offset(y: -76)
                    .rotationEffect(.degrees(Double(index) * 90 + (rotating ? 360 : 0)))
                    .animation(
                        .linear(duration: 4)
                            .repeatForever(autoreverses: false),
                        value: rotating
                    )
            }
        }
        .frame(width: 180, height: 180)
        .onAppear { rotating = true }
    }
}

#Preview {
    OrbitingLoader()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.deepNavy)
}
