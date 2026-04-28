import SwiftUI

struct HomePlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                placeholderCard(
                    icon: "bolt.fill",
                    tint: Theme.Colors.primaryBlue,
                    title: "Daily workout",
                    description: "Streak badge, session type picker, and primary Start CTA."
                )

                placeholderCard(
                    icon: "arrow.right.circle.fill",
                    tint: Theme.Colors.mindTeal,
                    title: "Continue learning",
                    description: "Resume card showing the last incomplete lesson and progress."
                )
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
    }
}

private func placeholderCard(
    icon: String,
    tint: Color,
    title: String,
    description: String
) -> some View {
    NumindCard {
        HStack(alignment: .top, spacing: 14) {
            IconTile(systemName: icon, tintColor: tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                Text("Placeholder — wireframes pending")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.insightYellow)
                    .padding(.top, 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomePlaceholderView()
    }
}
