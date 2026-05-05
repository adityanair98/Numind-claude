import SwiftUI

/// A spider/radar chart — one axis per module, values normalised 0–1.
///
/// - `axes`: ordered (label, value) pairs. Value is clamped to 0–1.
/// - `previousAxes`: optional historical snapshot (drawn as dashed outline).
///
/// Renders a filled polygon for current scores, an optional dashed polygon
/// for the 7-day-ago comparison, concentric grid levels, and axis labels.
///
/// Usage:
/// ```swift
/// RadarChartView(
///     axes: modules.map { (label: $0.shortName, value: score($0) / 100.0) },
///     previousAxes: oldSnapshot,
///     size: 220
/// )
/// ```
struct RadarChartView: View {

    struct Axis {
        let label: String
        let value: Double   // 0–1
    }

    let axes: [Axis]
    var previousAxes: [Axis]? = nil
    var size: CGFloat = 220

    // MARK: - Style

    private let fillColor   = Theme.Colors.primaryBlue
    private let strokeColor = Theme.Colors.primaryBlue
    private let histColor   = Color.gray
    private let gridLevels: [Double] = [0.25, 0.5, 0.75, 1.0]

    // MARK: - Body

    var body: some View {
        Canvas { ctx, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2 - labelPadding

            // Grid polygons
            for level in gridLevels {
                let gridPath = polygon(values: Array(repeating: level, count: axes.count),
                                       center: center, radius: radius)
                ctx.stroke(gridPath,
                           with: .color(Theme.Colors.mutedTint),
                           lineWidth: level == 1.0 ? 1 : 0.5)
            }

            // Axis spokes
            for i in 0..<axes.count {
                let angle = axisAngle(index: i, total: axes.count)
                let tip   = point(fraction: 1.0, angle: angle, center: center, radius: radius)
                var spoke = Path()
                spoke.move(to: center)
                spoke.addLine(to: tip)
                ctx.stroke(spoke, with: .color(Theme.Colors.mutedTint), lineWidth: 0.5)
            }

            // Historical polygon (dashed)
            if let prev = previousAxes, prev.count == axes.count {
                let prevPath = polygon(values: prev.map(\.value), center: center, radius: radius)
                ctx.stroke(prevPath,
                           with: .color(histColor.opacity(0.35)),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }

            // Current polygon — fill then stroke
            let currentPath = polygon(values: axes.map(\.value), center: center, radius: radius)
            ctx.fill(currentPath, with: .color(fillColor.opacity(0.15)))
            ctx.stroke(currentPath, with: .color(strokeColor), lineWidth: 2)

        } symbols: {
            // Axis labels rendered as SwiftUI text overlays (supports scaling / dark mode)
            ForEach(Array(axes.enumerated()), id: \.offset) { i, axis in
                Text(axis.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .tag(i)
            }
        }
        .frame(width: size, height: size)
        .overlay(labelsOverlay)
    }

    // MARK: - Labels overlay

    @ViewBuilder
    private var labelsOverlay: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - labelPadding
            let labelRadius = radius + 14

            ForEach(Array(axes.enumerated()), id: \.offset) { i, axis in
                let angle = axisAngle(index: i, total: axes.count)
                let pos   = point(fraction: 1.0, angle: angle, center: center, radius: labelRadius)

                Text(axis.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize()
                    .position(pos)
            }
        }
    }

    // MARK: - Geometry helpers

    private let labelPadding: CGFloat = 26

    private func axisAngle(index: Int, total: Int) -> Double {
        // Distribute evenly starting from the top (-90°).
        Double(index) * 360.0 / Double(total) - 90
    }

    private func point(fraction: Double, angle: Double, center: CGPoint, radius: CGFloat) -> CGPoint {
        let r = angle * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(fraction) * CGFloat(cos(r)),
            y: center.y + radius * CGFloat(fraction) * CGFloat(sin(r))
        )
    }

    private func polygon(values: [Double], center: CGPoint, radius: CGFloat) -> Path {
        guard !values.isEmpty else { return Path() }
        let total = values.count
        return Path { path in
            for (i, value) in values.enumerated() {
                let angle = axisAngle(index: i, total: total)
                let pt    = point(fraction: max(0, min(1, value)),
                                  angle: angle, center: center, radius: radius)
                i == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview("Radar — 6 modules") {
    let current: [RadarChartView.Axis] = [
        .init(label: "Tips",      value: 0.80),
        .init(label: "Discount",  value: 0.55),
        .init(label: "Tax",       value: 0.70),
        .init(label: "Salary",    value: 0.40),
        .init(label: "Investing", value: 0.60),
        .init(label: "Loans",     value: 0.30),
    ]
    let previous: [RadarChartView.Axis] = [
        .init(label: "Tips",      value: 0.60),
        .init(label: "Discount",  value: 0.45),
        .init(label: "Tax",       value: 0.65),
        .init(label: "Salary",    value: 0.30),
        .init(label: "Investing", value: 0.50),
        .init(label: "Loans",     value: 0.20),
    ]
    RadarChartView(axes: current, previousAxes: previous, size: 260)
        .padding(32)
        .background(Theme.Colors.softBackground)
}

#Preview("Radar — 3 modules") {
    let axes: [RadarChartView.Axis] = [
        .init(label: "Tips",   value: 0.90),
        .init(label: "Tax",    value: 0.50),
        .init(label: "Money",  value: 0.70),
    ]
    RadarChartView(axes: axes, size: 220)
        .padding(32)
        .background(Theme.Colors.softBackground)
}
