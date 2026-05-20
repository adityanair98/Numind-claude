import SwiftUI

/// Multi-select option card for onboarding screens.
/// Icon + label + optional subtitle + CheckBadge indicator.
/// Tinted background on selection. Optionally tappable via `action`.
struct OnboardingMultiCard<Icon: View>: View {
    let label: String
    var subtitle: String? = nil
    let selected: Bool
    var accentColor: Color = Theme.Colors.primaryBlue
    var action: (() -> Void)? = nil
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        let content = cardContent

        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var cardContent: some View {
        HStack(spacing: 14) {
            icon()

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)

                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }

            Spacer()

            CheckBadge(selected: selected, color: accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(selected ? accentColor.opacity(0.06) : Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(
                    selected ? accentColor : Theme.Colors.hairline,
                    lineWidth: selected ? 1.5 : 1
                )
        )
        .shadow(
            color: selected ? accentColor.opacity(0.14) : .black.opacity(0.04),
            radius: selected ? 10 : 6, x: 0, y: 2
        )
        .animation(.easeOut(duration: 0.18), value: selected)
    }
}

/// Convenience initializer with action and icon.
extension OnboardingMultiCard {
    init(
        label: String,
        subtitle: String? = nil,
        selected: Bool,
        accentColor: Color = Theme.Colors.primaryBlue,
        action: @escaping () -> Void,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.label = label
        self.subtitle = subtitle
        self.selected = selected
        self.accentColor = accentColor
        self.action = action
        self.icon = icon
    }
}

#Preview {
    VStack(spacing: 8) {
        OnboardingMultiCard(
            label: "Better financial decisions",
            subtitle: "Tips, budgets, investments",
            selected: true,
            accentColor: Theme.Colors.primaryBlue
        ) {
            Text("\u{1F4B0}")
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(Theme.Colors.primaryBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        OnboardingMultiCard(
            label: "Build confidence",
            subtitle: "Stop second-guessing math",
            selected: false,
            accentColor: Theme.Colors.mindTeal
        ) {
            Text("\u{1F4AA}")
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(Theme.Colors.mindTeal.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
