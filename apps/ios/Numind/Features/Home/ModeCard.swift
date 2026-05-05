import SwiftUI

/// Gradient game-mode card for Speed Drill / Blitz.
/// Unlocked shows a vibrant gradient with decorative orbs; locked shows a muted white card.
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let shadowColor: Color
    let bestLabel: String?
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if locked {
                lockedContent
            } else {
                unlockedContent
            }
        }
        .buttonStyle(.plain)
        .disabled(locked)
    }

    // MARK: - Unlocked

    private var unlockedContent: some View {
        ZStack(alignment: .topLeading) {
            // Decorative orbs
            decorativeOrbs

            VStack(alignment: .leading, spacing: 10) {
                iconView(frosted: true, iconName: icon, color: .white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(Theme.Typography.small)
                        .foregroundStyle(.white.opacity(0.85))
                }
                bestChip
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 138)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: UnitPoint(x: 0.15, y: 0),
                endPoint: UnitPoint(x: 0.85, y: 1)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: shadowColor.opacity(0.35), radius: 14, x: 0, y: 14)
    }

    // MARK: - Locked

    private var lockedContent: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 10) {
                iconView(frosted: false, iconName: "lock.fill", color: Theme.Colors.mutedText)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(subtitle)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Text("Master a lesson")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.5)
                    .textCase(.uppercase)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.Colors.mutedTint)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 138)
    }

    // MARK: - Icon

    private func iconView(frosted: Bool, iconName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(frosted ? .white.opacity(0.22) : Theme.Colors.mutedTint)
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(width: 38, height: 38)
    }

    // MARK: - Best stat capsule

    @ViewBuilder
    private var bestChip: some View {
        if let best = bestLabel {
            Text(best)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .kerning(0.5)
                .textCase(.uppercase)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.22))
                .clipShape(Capsule())
        } else {
            Text("No sessions yet")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
                .kerning(0.5)
                .textCase(.uppercase)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    // MARK: - Decorative orbs

    private var decorativeOrbs: some View {
        GeometryReader { geo in
            // Large circle bottom-right
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 100, height: 100)
                .offset(x: geo.size.width - 78, y: geo.size.height - 78)

            // Small circle top-left
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 55, height: 55)
                .offset(x: -15, y: -15)
        }
    }
}

// MARK: - Convenience constructors

extension ModeCard {
    /// Pre-configured Speed Drill card.
    static func speedDrill(bestLabel: String?, locked: Bool, action: @escaping () -> Void) -> ModeCard {
        ModeCard(
            icon: "bolt.fill",
            title: "Speed Drill",
            subtitle: "8 questions \u{00B7} 15s each",
            gradientColors: [Theme.Colors.mindTeal, Color(red: 31 / 255, green: 175 / 255, blue: 160 / 255)],
            shadowColor: Theme.Colors.mindTeal,
            bestLabel: bestLabel,
            locked: locked,
            action: action
        )
    }

    /// Pre-configured Blitz card.
    static func blitz(bestLabel: String?, locked: Bool, action: @escaping () -> Void) -> ModeCard {
        ModeCard(
            icon: "flame.fill",
            title: "Blitz",
            subtitle: "60 seconds \u{00B7} go fast",
            gradientColors: [Color(red: 255 / 255, green: 144 / 255, blue: 84 / 255), Theme.Colors.warmOrange],
            shadowColor: Theme.Colors.warmOrange,
            bestLabel: bestLabel,
            locked: locked,
            action: action
        )
    }
}

#Preview("Unlocked") {
    HStack(spacing: 12) {
        ModeCard.speedDrill(bestLabel: "42 sec best", locked: false) {}
        ModeCard.blitz(bestLabel: "28 correct", locked: false) {}
    }
    .padding(.horizontal, Theme.Spacing.screenHorizontal)
    .background(Theme.Colors.softBackground)
}

#Preview("Locked") {
    HStack(spacing: 12) {
        ModeCard.speedDrill(bestLabel: nil, locked: true) {}
        ModeCard.blitz(bestLabel: nil, locked: true) {}
    }
    .padding(.horizontal, Theme.Spacing.screenHorizontal)
    .background(Theme.Colors.softBackground)
}
