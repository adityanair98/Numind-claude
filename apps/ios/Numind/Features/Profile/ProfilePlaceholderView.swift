import SwiftUI

struct ProfilePlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                placeholderCard(
                    icon: "person.circle.fill",
                    tint: Theme.Colors.primaryBlue,
                    title: "Account",
                    description: "User info, goals, and preferences — set during onboarding (not built yet)."
                )

                placeholderCard(
                    icon: "arrow.counterclockwise",
                    tint: Theme.Colors.errorSoftRed,
                    title: "Reset progress",
                    description: "Clear all local lesson and quiz history."
                )
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Profile")
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
        ProfilePlaceholderView()
    }
}
