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

                // Mascot coin on a teal radial glow, with a teal check badge —
                // the celebratory artifact (mascots allowed on milestones only).
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.Colors.mindTeal.opacity(0.28), .clear],
                                center: .center, startRadius: 0, endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)

                    Circle()
                        .fill(iconGradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: accentColor.opacity(0.4), radius: 20, y: 8)

                    Image(systemName: milestone.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(glyphColor)

                    // Teal check badge, bottom-trailing.
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Theme.Colors.mindTeal)
                        .background(Circle().fill(Theme.Colors.softBackground).padding(3))
                        .offset(x: 42, y: 42)
                }
                .scaleEffect(iconScale)
                .padding(.bottom, 24)

                // Eyebrow — names the milestone kind in caps.
                Text(eyebrow)
                    .font(.system(size: 12, weight: .heavy))
                    .kerning(1.2)
                    .foregroundStyle(accentColor == Theme.Colors.insightYellow
                                     ? Theme.Colors.insightText : accentColor)
                    .opacity(textOpacity)
                    .padding(.bottom, 8)

                // Headline (sans — celebration screens never use serif).
                Text(milestone.headline)
                    .font(Theme.Typography.largeDisplay)
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

                // CTA — ink pill + secondary link.
                VStack(spacing: 10) {
                    PillButton("Keep going") { onDismiss() }
                    Button("Back to lessons") { onDismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                        .frame(height: 40)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .opacity(buttonOpacity)
                .padding(.bottom, 44)
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
        case .firstSkillMastered:
            return Theme.Colors.insightYellow          // gold coin
        case .firstPackReady, .threePacksReady:
            return Theme.Colors.mindTeal
        case .firstRefreshSave:
            return Theme.Colors.mindTeal
        case .firstWeekStreak, .twoWeekStreak:
            return Theme.Colors.ember                   // warm flame
        case .accuracyJump:
            return Theme.Colors.mindTeal
        case .firstFreeze:
            return Theme.Colors.mindTeal
        }
    }

    /// Glyph reads dark on the gold coin, light on the saturated accents.
    private var glyphColor: Color {
        accentColor == Theme.Colors.insightYellow ? Theme.Colors.deepNavy : .white
    }

    private var eyebrow: String {
        switch milestone {
        case .firstSkillMastered: return "SKILL MASTERED"
        case .firstPackReady:     return "PACK READY"
        case .threePacksReady:    return "THREE PACKS READY"
        case .firstRefreshSave:   return "BACK TO SHARP"
        case .firstWeekStreak:    return "7-DAY STREAK"
        case .twoWeekStreak:      return "14-DAY STREAK"
        case .accuracyJump:       return "SHARPER"
        case .firstFreeze:        return "STREAK PROTECTED"
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

/// Restrained confetti (Phase 13): 8 gold/teal/ember dots + squares that
/// drift only through the top zone, then fade. Celebration, not a toy storm.
private struct ConfettiOverlay: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Group {
                        if p.isSquare {
                            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(p.color)
                        } else {
                            Circle().fill(p.color)
                        }
                    }
                    .frame(width: p.size, height: p.size)
                    .rotationEffect(.degrees(animating ? p.rotation : 0))
                    .position(
                        x: animating ? p.endX : p.startX,
                        y: animating ? p.endY : p.startY
                    )
                    .opacity(animating ? 0 : 1)
                }
            }
            .onAppear {
                particles = (0..<8).map { _ in ConfettiParticle(bounds: geo.size) }
                withAnimation(.easeOut(duration: 1.6)) { animating = true }
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
    let endY: CGFloat
    let size: CGFloat
    let rotation: CGFloat
    let color: Color
    let isSquare: Bool

    init(bounds: CGSize) {
        startX = CGFloat.random(in: bounds.width * 0.15...bounds.width * 0.85)
        startY = CGFloat.random(in: -20...bounds.height * 0.12)
        endX = startX + CGFloat.random(in: -50...50)
        endY = startY + CGFloat.random(in: bounds.height * 0.18...bounds.height * 0.32)  // top zone only
        size = CGFloat.random(in: 7...12)
        rotation = CGFloat.random(in: -180...180)
        color = [
            Theme.Colors.insightYellow,
            Theme.Colors.mindTeal,
            Theme.Colors.ember
        ].randomElement()!
        isSquare = Bool.random()
    }
}

#Preview {
    MilestoneCelebrationView(milestone: .firstPackReady(name: "First Paycheck")) {}
}
