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
struct OnboardingIconTile: View {
    let emoji: String
    var color: Color = Theme.Colors.primaryBlue
    var size: CGFloat = 38

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.52))
            .frame(width: size, height: size)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}
