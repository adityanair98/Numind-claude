import SwiftUI

/// Full-screen overlay shown when a milestone is achieved.
struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void

    @State private var iconScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var confettiVisible = false

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            // Confetti particles
            if confettiVisible {
                ConfettiOverlay()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(iconGradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: accentColor.opacity(0.4), radius: 20, y: 8)

                    Image(systemName: milestone.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(iconScale)
                .padding(.bottom, 32)

                // Headline
                Text(milestone.headline)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)

                Text(milestone.subtext)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    .opacity(textOpacity)

                Spacer()

                // CTA
                PillButton("Keep going") { onDismiss() }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .opacity(buttonOpacity)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                buttonOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.15)) {
                confettiVisible = true
            }
        }
    }

    private var accentColor: Color {
        switch milestone {
        case .firstSession, .fiveSessions, .tenSessions:
            return Theme.Colors.primaryBlue
        case .firstWeekStreak, .twoWeekStreak:
            return Theme.Colors.warmOrange
        case .accuracyJump:
            return Theme.Colors.mindTeal
        case .levelUp:
            return Theme.Colors.growthGreen
        case .moduleCompleted:
            return Theme.Colors.primaryBlue
        case .firstFreeze:
            return Theme.Colors.mindTeal
        }
    }

    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Confetti overlay

/// Lightweight confetti animation using phase-driven circles.
private struct ConfettiOverlay: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(
                            x: animating ? p.endX : p.startX,
                            y: animating ? geo.size.height + 20 : p.startY
                        )
                        .opacity(animating ? 0 : 1)
                }
            }
            .onAppear {
                particles = (0..<30).map { _ in
                    ConfettiParticle(bounds: geo.size)
                }
                withAnimation(.easeOut(duration: 2.0)) {
                    animating = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let size: CGFloat
    let color: Color

    init(bounds: CGSize) {
        startX = CGFloat.random(in: 0...bounds.width)
        startY = CGFloat.random(in: -40...bounds.height * 0.3)
        endX = startX + CGFloat.random(in: -60...60)
        size = CGFloat.random(in: 5...10)
        color = [
            Theme.Colors.primaryBlue,
            Theme.Colors.mindTeal,
            Theme.Colors.warmOrange,
            Theme.Colors.insightYellow,
            Theme.Colors.growthGreen
        ].randomElement()!
    }
}

#Preview {
    MilestoneCelebrationView(milestone: .firstSession) {}
}
