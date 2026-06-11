import SwiftUI

/// Single-select option card for onboarding screens.
/// Icon + label + optional subtitle + RadioDot indicator.
/// Optionally tappable via `action`.
struct OnboardingSelectCard<Icon: View>: View {
    let label: String
    var subtitle: String? = nil
    let selected: Bool
    var accentColor: Color = Theme.Colors.primaryBlue
    var dark: Bool = false
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
                    .foregroundStyle(dark ? .white : Theme.Colors.deepNavy)

                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(dark ? Color.white.opacity(0.65) : Theme.Colors.mutedText)
                }
            }

            Spacer()

            RadioDot(selected: selected, color: accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(borderColor, lineWidth: selected ? 1.5 : 1)
        )
        .shadow(
            color: selected
                ? accentColor.opacity(dark ? 0 : 0.15)
                : .black.opacity(dark ? 0 : 0.04),
            radius: selected ? 10 : 6, x: 0, y: 2
        )
        .animation(.easeOut(duration: 0.18), value: selected)
    }

    private var cardBackground: Color {
        if dark {
            return selected
                ? Color.white.opacity(0.10)
                : Color.white.opacity(0.04)
        }
        return Theme.Colors.cardBackground
    }

    private var borderColor: Color {
        if selected { return accentColor }
        return dark ? Color.white.opacity(0.10) : Theme.Colors.hairline
    }
}

/// Convenience initializer without icon.
extension OnboardingSelectCard where Icon == EmptyView {
    init(
        label: String,
        subtitle: String? = nil,
        selected: Bool,
        accentColor: Color = Theme.Colors.primaryBlue,
        dark: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.label = label
        self.subtitle = subtitle
        self.selected = selected
        self.accentColor = accentColor
        self.dark = dark
        self.action = action
        self.icon = { EmptyView() }
    }
}

/// Convenience initializer with action and icon.
extension OnboardingSelectCard {
    init(
        label: String,
        subtitle: String? = nil,
        selected: Bool,
        accentColor: Color = Theme.Colors.primaryBlue,
        dark: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.label = label
        self.subtitle = subtitle
        self.selected = selected
        self.accentColor = accentColor
        self.dark = dark
        self.action = action
        self.icon = icon
    }
}

#Preview {
    VStack(spacing: 10) {
        OnboardingSelectCard(label: "I freeze", subtitle: "I just go with whatever they offer", selected: false) {
            Text("\u{1F630}")
                .font(.system(size: 20))
                .frame(width: 38, height: 38)
                .background(Theme.Colors.errorSoftRed.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        OnboardingSelectCard(label: "I get by", subtitle: "I manage, but it's slow", selected: true, accentColor: Theme.Colors.warmOrange) {
            Text("\u{1F642}")
                .font(.system(size: 20))
                .frame(width: 38, height: 38)
                .background(Theme.Colors.warmOrange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
