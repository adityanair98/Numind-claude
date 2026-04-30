import SwiftUI

/// Themed illustration banner shown above the quiz question prompt card.
///
/// Each ``QuestionTheme`` renders a distinct colour + icon composition:
/// - A tinted background using the theme's module colour
/// - Two decorative ghost circles adding depth (bottom-right corner bleed)
/// - A large ghost accent symbol representing the scene (far right)
/// - An icon circle (primary symbol) + label pair on the left
///
/// Designed to be placed directly above a ``NumindCard`` with 8 pt spacing
/// so the two elements read as a visual unit.
struct QuizGraphicBanner: View {
    let theme: QuestionTheme

    private var tint: Color { theme.moduleColor.tintColor }
    private var tintBg: Color { theme.moduleColor.tintBackground }

    var body: some View {
        ZStack(alignment: .leading) {

            // ── Background ───────────────────────────────────────────────────────
            tintBg

            // ── Decorative geometry (depth / atmosphere) ─────────────────────────
            // Large ghost circle — bleeds off the bottom-right corner
            Circle()
                .fill(tint.opacity(0.07))
                .frame(width: 100, height: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 32, y: 32)

            // Medium ghost circle — floats top-right, inset
            Circle()
                .fill(tint.opacity(0.09))
                .frame(width: 52, height: 52)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: -22, y: -18)

            // ── Large accent symbol (ghost, far right) ───────────────────────────
            // Anchored to the trailing edge and partially clipped — creates the
            // "scene" feeling without overpowering the readable content on the left.
            HStack(spacing: 0) {
                Spacer()
                Image(systemName: theme.accentSymbol)
                    .font(.system(size: 62, weight: .thin))
                    .foregroundStyle(tint.opacity(0.13))
                    .offset(x: 12)
            }

            // ── Main content: icon circle + labels ───────────────────────────────
            HStack(spacing: 14) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))
                        .frame(width: 56, height: 56)
                    Image(systemName: theme.symbolName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(tint)
                }

                // Labels
                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.label)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(tint)
                    Text(theme.sublabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(tint.opacity(0.70))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Preview

#Preview("All themes") {
    ScrollView {
        VStack(spacing: 10) {
            QuizGraphicBanner(theme: .dining)
            QuizGraphicBanner(theme: .shopping)
            QuizGraphicBanner(theme: .everydaySpend)
            QuizGraphicBanner(theme: .budget)
            QuizGraphicBanner(theme: .paycheck)
            QuizGraphicBanner(theme: .investing)
            QuizGraphicBanner(theme: .quickMath)
            QuizGraphicBanner(theme: .estimation)
        }
        .padding()
    }
    .background(Theme.Colors.softBackground)
}
