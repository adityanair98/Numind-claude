import SwiftUI

/// Reusable footer with gradient fade for onboarding screens.
/// Pins content to the bottom with a fade-to-background gradient above.
func onboardingFooter<Content: View>(dark: Bool, @ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 0) {
        LinearGradient(
            colors: [
                (dark ? Theme.Colors.deepNavy : Theme.Colors.softBackground).opacity(0),
                dark ? Theme.Colors.deepNavy : Theme.Colors.softBackground,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 24)
        .allowsHitTesting(false)

        VStack(spacing: 6) {
            content()
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, 44)
        .background(dark ? Theme.Colors.deepNavy : Theme.Colors.softBackground)
    }
}

/// Icon tile used in onboarding option cards.
///
/// Prefer the `systemImage:` initializer (SF Symbol in a token color). The
/// legacy `emoji:` initializer is retained for screens still passing emoji
/// glyphs; new usage should pass an SF Symbol name.
struct OnboardingIconTile: View {
    enum Glyph {
        case emoji(String)
        case symbol(String)
    }

    let glyph: Glyph
    var color: Color = Theme.Colors.primaryBlue
    var size: CGFloat = 38

    init(emoji: String, color: Color = Theme.Colors.primaryBlue, size: CGFloat = 38) {
        self.glyph = .emoji(emoji)
        self.color = color
        self.size = size
    }

    init(systemImage: String, color: Color = Theme.Colors.primaryBlue, size: CGFloat = 38) {
        self.glyph = .symbol(systemImage)
        self.color = color
        self.size = size
    }

    var body: some View {
        Group {
            switch glyph {
            case .emoji(let value):
                Text(value)
                    .font(.system(size: size * 0.52))
            case .symbol(let name):
                Image(systemName: name)
                    .font(.system(size: size * 0.46, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}
