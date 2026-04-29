import SwiftUI

struct NumindCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private let background: Color
    private let content: () -> Content

    init(background: Color = Theme.Colors.cardBackground, @ViewBuilder content: @escaping () -> Content) {
        self.background = background
        self.content = content
    }

    var body: some View {
        content()
            .padding(Theme.Spacing.cardPadding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            // Light mode: drop shadow for depth. Dark mode: hairline border instead.
            .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.06), radius: 12, x: 0, y: 4)
            .overlay {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.hairline, lineWidth: 0.5)
                }
            }
    }
}

#Preview {
    NumindCard {
        VStack(alignment: .leading, spacing: 6) {
            Text("Card Title").font(Theme.Typography.headline)
            Text("Supporting content inside a NumindCard.").font(Theme.Typography.body)
        }
        .foregroundStyle(Theme.Colors.deepNavy)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
