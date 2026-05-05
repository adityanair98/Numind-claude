import SwiftUI

/// A marquee surface with a deep-navy (or teal) gradient background
/// and decorative floating orbs. Used as the hero card for Daily
/// Challenge (Home), Mixed Mode (Practice), and Streak Ring (Progress).
///
/// Usage mirrors `NumindCard` — pass any content via a `@ViewBuilder`:
///
///     HeroCard {
///         Text("Daily Challenge")
///             .foregroundStyle(.white)
///     }
///
struct HeroCard<Content: View>: View {

    enum Variant {
        /// Deep navy gradient with teal/yellow/blue orbs.
        case navy
        /// Solid teal gradient (completion / success state).
        case teal
    }

    private let variant: Variant
    private let content: () -> Content

    // Non-adaptive navy — always dark regardless of color scheme.
    private static var heroNavy: Color {
        Color(red: 16 / 255, green: 34 / 255, blue: 74 / 255)
    }
    private static var heroNavyMid: Color {
        Color(red: 26 / 255, green: 45 / 255, blue: 94 / 255)
    }
    private static var heroNavyDeep: Color {
        Color(red: 10 / 255, green: 24 / 255, blue: 56 / 255)
    }

    init(variant: Variant = .navy, @ViewBuilder content: @escaping () -> Content) {
        self.variant = variant
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background gradient
            background
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            // Decorative orbs (navy variant only)
            if variant == .navy {
                decorativeOrbs
            }

            // Content slot
            content()
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: shadowColor.opacity(shadowOpacity), radius: 18, x: 0, y: 18)
    }

    // MARK: - Background

    @ViewBuilder
    private var background: some View {
        switch variant {
        case .navy:
            LinearGradient(
                stops: [
                    .init(color: Self.heroNavy, location: 0),
                    .init(color: Self.heroNavyMid, location: 0.6),
                    .init(color: Self.heroNavyDeep, location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .teal:
            LinearGradient(
                colors: [
                    Theme.Colors.mindTeal,
                    Color(red: 31 / 255, green: 175 / 255, blue: 160 / 255),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Orbs

    private var decorativeOrbs: some View {
        ZStack(alignment: .topTrailing) {
            // Large radial teal glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.Colors.mindTeal.opacity(0.33), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .offset(x: 30, y: -30)

            // Small teal dot
            Circle()
                .fill(Theme.Colors.mindTeal)
                .frame(width: 14, height: 14)
                .shadow(color: Theme.Colors.mindTeal, radius: 9)
                .offset(x: -30, y: 24)

            // Small yellow dot
            Circle()
                .fill(Theme.Colors.insightYellow)
                .frame(width: 11, height: 11)
                .shadow(color: Theme.Colors.insightYellow, radius: 7)
                .offset(x: -60, y: 58)

            // Small blue dot
            Circle()
                .fill(Theme.Colors.primaryBlue)
                .frame(width: 9, height: 9)
                .shadow(color: Theme.Colors.primaryBlue, radius: 6)
                .offset(x: -96, y: 90)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Shadow

    private var shadowColor: Color {
        switch variant {
        case .navy: return Self.heroNavy
        case .teal: return Theme.Colors.mindTeal
        }
    }

    private var shadowOpacity: Double {
        switch variant {
        case .navy: return 0.32
        case .teal: return 0.35
        }
    }
}

// MARK: - Preview

#Preview("Navy variant") {
    HeroCard(variant: .navy) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Challenge")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("10 questions across your modules")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.65))
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 40)
    .background(Theme.Colors.softBackground)
}

#Preview("Teal variant") {
    HeroCard(variant: .teal) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nailed it ✨")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("10/10 today. Streak +1.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.85))
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 40)
    .background(Theme.Colors.softBackground)
}
