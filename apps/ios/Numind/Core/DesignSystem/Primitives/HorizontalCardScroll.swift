import SwiftUI

/// A minimal horizontal-scroll carousel that snaps to a fixed card width.
/// Use it anywhere we need to show a horizontally-scrollable list of
/// equal-width cards (e.g. Home's "Also in progress" packs row).
///
/// Intentionally generic — takes a list of items + a card-builder closure.
/// Don't fork it; pass card-styling via the trailing builder instead.
struct HorizontalCardScroll<Item: Identifiable, Card: View>: View {
    let items: [Item]
    let cardWidth: CGFloat
    let spacing: CGFloat
    let card: (Item) -> Card

    init(
        items: [Item],
        cardWidth: CGFloat = 240,
        spacing: CGFloat = 12,
        @ViewBuilder card: @escaping (Item) -> Card
    ) {
        self.items = items
        self.cardWidth = cardWidth
        self.spacing = spacing
        self.card = card
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(items) { item in
                    card(item)
                        .frame(width: cardWidth, alignment: .leading)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
        // Cancel the screen-horizontal padding the parent will likely add,
        // so the leading card sits flush with the rest of the column.
        .padding(.horizontal, -Theme.Spacing.screenHorizontal)
    }
}
