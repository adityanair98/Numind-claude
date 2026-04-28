import SwiftUI

struct PillButton: View {
    enum Variant { case primary, secondary }

    private let title: String
    private let variant: Variant
    private let action: () -> Void

    init(_ title: String, variant: Variant = .primary, action: @escaping () -> Void) {
        self.title   = title
        self.variant = variant
        self.action  = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundStyle(labelColor)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Spacing.buttonHeight)
                .background(fillColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var fillColor: Color {
        switch variant {
        case .primary:   Theme.Colors.primaryBlue
        case .secondary: Theme.Colors.softBackground
        }
    }

    private var labelColor: Color {
        switch variant {
        case .primary:   .white
        case .secondary: Theme.Colors.primaryBlue
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PillButton("Start today's workout") { }
        PillButton("View all modules", variant: .secondary) { }
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
