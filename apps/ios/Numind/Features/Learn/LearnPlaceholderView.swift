import SwiftUI

struct LearnPlaceholderView: View {
    private let modules = [
        ("percent.ar", Theme.Colors.primaryBlue,  "Tips, Tax & Bill Split",       "Everyday restaurant and shopping math."),
        ("tag.fill",   Theme.Colors.mindTeal,      "Discounts & Shopping",         "Sales, markdowns, and deal math."),
        ("dollarsign", Theme.Colors.insightYellow, "Everyday Money Math",          "Budgeting, splitting, and estimating."),
        ("eye.fill",   Theme.Colors.mutedText,     "Estimation & Number Sense",    "Gut-check and ballpark skills."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                sectionLabel("Modules")

                VStack(spacing: 12) {
                    ForEach(modules, id: \.2) { icon, tint, title, subtitle in
                        moduleRow(icon: icon, tint: tint, title: title, subtitle: subtitle)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
    }

    private func moduleRow(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        NumindCard {
            HStack(spacing: 14) {
                IconTile(systemName: icon, tintColor: tint)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

#Preview {
    NavigationStack {
        LearnPlaceholderView()
    }
}
