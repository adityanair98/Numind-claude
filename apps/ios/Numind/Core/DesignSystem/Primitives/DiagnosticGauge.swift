import SwiftUI

/// Arc gauge illustration for Screen 15 (Diagnostic Intro).
/// Red → yellow → teal gradient arc with a needle indicator.
/// Static illustration — not data-driven.
struct DiagnosticGauge: View {
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.Colors.primaryBlue.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 110
                    )
                )
                .frame(width: 240, height: 240)

            // Gauge arc
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.65)
                let radius: CGFloat = 80
                let startAngle: CGFloat = .pi * 1.15  // slightly past left
                let endAngle: CGFloat = .pi * -0.15   // slightly past right

                // Background arc
                var bgPath = Path()
                bgPath.addArc(center: center, radius: radius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)
                context.stroke(bgPath, with: .color(Theme.Colors.mutedTint), style: StrokeStyle(lineWidth: 14, lineCap: .round))

                // Gradient fill arc (partial — about 60%)
                let fillEndAngle = startAngle + (endAngle - startAngle + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi) * 0.6
                var fillPath = Path()
                fillPath.addArc(center: center, radius: radius, startAngle: .radians(startAngle), endAngle: .radians(fillEndAngle), clockwise: false)

                let gradient = Gradient(colors: [
                    Theme.Colors.errorSoftRed,
                    Theme.Colors.insightYellow,
                    Theme.Colors.mindTeal,
                ])
                context.stroke(
                    fillPath,
                    with: .linearGradient(gradient, startPoint: CGPoint(x: center.x - radius, y: center.y), endPoint: CGPoint(x: center.x + radius, y: center.y)),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )

                // Needle
                let needleAngle = fillEndAngle - 0.1
                let needleEnd = CGPoint(
                    x: center.x + (radius - 10) * cos(needleAngle),
                    y: center.y + (radius - 10) * sin(needleAngle)
                )
                var needlePath = Path()
                needlePath.move(to: center)
                needlePath.addLine(to: needleEnd)
                context.stroke(needlePath, with: .color(Theme.Colors.deepNavy), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                // Center dot
                let outerDot = CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)
                let innerDot = CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)
                context.fill(Circle().path(in: outerDot), with: .color(Theme.Colors.deepNavy))
                context.fill(Circle().path(in: innerDot), with: .color(Theme.Colors.insightYellow))
            }
            .frame(width: 220, height: 160)

            // Tick labels
            VStack {
                Spacer()
                HStack {
                    Text("start")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                    Text("sharp")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(.horizontal, 20)
            }
            .frame(width: 220, height: 160)
        }
        .frame(width: 220, height: 160)
    }
}

#Preview {
    DiagnosticGauge()
        .padding()
        .background(Theme.Colors.softBackground)
}
