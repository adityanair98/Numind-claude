import SwiftUI

/// Confetti particle burst for celebrating new personal bests.
///
/// Drop as an overlay on any view — fires automatically on appear.
/// Uses Canvas + TimelineView for smooth 60fps rendering.
///
///     .overlay(ConfettiBurst())
///
struct ConfettiBurst: View {
    @State private var particles: [Particle] = []
    @State private var startDate: Date?

    private let count: Int
    private let duration: Double = 3.0

    init(count: Int = 60) {
        self.count = count
    }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: startDate == nil)) { timeline in
                Canvas { context, size in
                    guard let start = startDate else { return }
                    let elapsed = timeline.date.timeIntervalSince(start)
                    guard elapsed < duration + 1.5 else { return }

                    for p in particles {
                        drawParticle(p, elapsed: elapsed, context: &context, size: size)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            particles = Self.makeParticles(count: count)
            // Small delay so the view is settled before confetti fires
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startDate = Date()
            }
        }
    }

    // MARK: - Drawing

    private func drawParticle(
        _ p: Particle,
        elapsed: Double,
        context: inout GraphicsContext,
        size: CGSize
    ) {
        let t = elapsed - p.delay
        guard t > 0 else { return }

        let gravity: CGFloat = 320
        let drag: CGFloat = 0.97 // slight air resistance
        let adjustedT = CGFloat(t)

        // Physics: upward burst + gravity pull + horizontal drift
        let x = size.width * p.startXFraction + p.horizontalVelocity * adjustedT * pow(drag, adjustedT * 30)
        let y = -p.initialUpVelocity * adjustedT + 0.5 * gravity * adjustedT * adjustedT

        // Fade out in last third of duration
        let fadeStart = duration * 0.6
        let opacity: Double = t < fadeStart ? 1.0 : max(0, 1.0 - (t - fadeStart) / (duration - fadeStart))

        guard opacity > 0, y < size.height + 50 else { return }

        context.drawLayer { ctx in
            ctx.opacity = opacity
            ctx.translateBy(x: x, y: y)
            ctx.rotate(by: .degrees(p.rotationSpeed * t))

            let w = p.isWide ? p.size * 1.6 : p.size * 0.5
            let h = p.size
            let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)

            if p.isCircle {
                ctx.fill(Path(ellipseIn: rect), with: .color(p.color))
            } else {
                ctx.fill(
                    Path(roundedRect: rect, cornerRadius: 1.5),
                    with: .color(p.color)
                )
            }
        }
    }

    // MARK: - Particle generation

    private static func makeParticles(count: Int) -> [Particle] {
        let colors: [Color] = [
            Color(red: 1.00, green: 0.84, blue: 0.04), // gold
            Color(red: 0.22, green: 0.78, blue: 0.72), // teal
            Color(red: 0.27, green: 0.42, blue: 0.87), // blue
            Color(red: 1.00, green: 0.56, blue: 0.33), // orange
            Color(red: 0.90, green: 0.30, blue: 0.25), // red
            Color(red: 0.65, green: 0.35, blue: 0.80), // purple
            .white,
        ]

        return (0..<count).map { i in
            Particle(
                color: colors[i % colors.count],
                startXFraction: CGFloat.random(in: 0.15...0.85),
                horizontalVelocity: CGFloat.random(in: -90...90),
                initialUpVelocity: CGFloat.random(in: 120...340),
                rotationSpeed: Double.random(in: -400...400),
                size: CGFloat.random(in: 5...10),
                delay: Double.random(in: 0...0.5),
                isCircle: i % 3 == 0,
                isWide: i % 4 == 0
            )
        }
    }
}

// MARK: - Particle model

extension ConfettiBurst {
    struct Particle {
        let color: Color
        let startXFraction: CGFloat     // 0…1 horizontal start position
        let horizontalVelocity: CGFloat // pixels/second drift
        let initialUpVelocity: CGFloat  // upward burst speed
        let rotationSpeed: Double       // degrees/second
        let size: CGFloat               // base size in points
        let delay: Double               // staggered start
        let isCircle: Bool              // shape variant
        let isWide: Bool                // wide rectangle variant
    }
}

// MARK: - Reusable "New Personal Best" badge

/// Golden trophy badge shown when the user beats their personal best.
struct NewBestBadge: View {
    @State private var scale: CGFloat = 0.5

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 13, weight: .bold))
            Text("New personal best!")
                .font(.system(size: 13, weight: .bold))
        }
        .foregroundStyle(Theme.Colors.insightText)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Theme.Colors.insightYellowTint)
        .clipShape(Capsule())
        .shadow(color: Theme.Colors.insightYellow.opacity(0.3), radius: 8, y: 3)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                scale = 1.0
            }
        }
    }
}

#Preview("Confetti") {
    ZStack {
        Theme.Colors.softBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Celebration!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            NewBestBadge()
        }
    }
    .overlay(ConfettiBurst())
}
