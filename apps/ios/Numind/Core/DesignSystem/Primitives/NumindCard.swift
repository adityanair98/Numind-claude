import SwiftUI

struct NumindCard<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Theme.Spacing.cardPadding)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
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
