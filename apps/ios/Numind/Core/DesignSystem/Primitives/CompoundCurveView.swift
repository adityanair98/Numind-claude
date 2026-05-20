import SwiftUI

/// Exponential 1.01^365 curve for the Kaizen screen (Screen 11).
/// Insightful yellow stroke with gradient fill fading to transparent.
/// Animates stroke from left to right over 1.2s.
struct CompoundCurveView: View {
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let maxVal: CGFloat = 37.78  // 1.01^365

            // Grid lines
            for frac in [0.25, 0.5, 0.75] as [CGFloat] {
                var gridPath = Path()
                gridPath.move(to: CGPoint(x: 0, y: h * frac))
                gridPath.addLine(to: CGPoint(x: w, y: h * frac))
                context.stroke(gridPath, with: .color(.white.opacity(0.06)), lineWidth: 1)
            }

            // Build curve points
            let steps = 50
            var curvePoints: [CGPoint] = []
            for i in 0...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let x = t * w
                let days = t * 365
                let value = pow(1.01, days) / maxVal
                let y = h - value * h
                curvePoints.append(CGPoint(x: x, y: max(2, y)))
            }

            // Fill path (gradient under curve)
            var fillPath = Path()
            fillPath.addLines(curvePoints)
            fillPath.addLine(to: CGPoint(x: w, y: h))
            fillPath.addLine(to: CGPoint(x: 0, y: h))
            fillPath.closeSubpath()

            let gradient = Gradient(stops: [
                .init(color: Theme.Colors.insightYellow.opacity(0.5), location: 0),
                .init(color: Theme.Colors.insightYellow.opacity(0), location: 1),
            ])
            context.fill(fillPath, with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: 0, y: h)))

            // Stroke path (animated)
            var strokePath = Path()
            strokePath.addLines(curvePoints)
            context.stroke(
                strokePath.trimmedPath(from: 0, to: animationProgress),
                with: .color(Theme.Colors.insightYellow),
                lineWidth: 2.4
            )

            // End dot (only when fully animated)
            if animationProgress >= 0.98, let last = curvePoints.last {
                let dotRect = CGRect(x: last.x - 5, y: last.y - 5, width: 10, height: 10)
                context.fill(Ellipse().path(in: dotRect.insetBy(dx: -5, dy: -5)), with: .color(Theme.Colors.insightYellow.opacity(0.25)))
                context.fill(Ellipse().path(in: dotRect), with: .color(Theme.Colors.insightYellow))
            }
        }
        .frame(height: 84)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animationProgress = 1
            }
        }
    }
}

#Preview {
    CompoundCurveView()
        .padding()
        .background(Theme.Colors.deepNavy)
}
