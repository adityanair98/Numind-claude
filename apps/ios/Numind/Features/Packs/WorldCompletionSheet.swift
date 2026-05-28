import SwiftUI

/// Transient celebration sheet shown when the user masters the last
/// remaining lesson in a world (module). Sister to PackCompletionSheet;
/// shown after pack celebrations when both fire in the same session.
struct WorldCompletionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let module: Module
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.sectionSpacing) {
            Spacer()
            VStack(spacing: 16) {
                Text("👑")
                    .font(.system(size: 72))
                Text("World conquered")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                Text(module.title)
                    .font(Theme.Typography.title)
                    .foregroundStyle(module.color.tintColor)
                    .multilineTextAlignment(.center)
                Text("Every lesson in \(module.title) is at 75% or better. You've nailed the fundamentals here.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.cardPadding)
            }
            Spacer()
            Button(action: dismissNow) {
                Text("Onward")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Spacing.buttonHeight)
                    .background(Theme.Colors.deepNavy)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
    }

    private func dismissNow() {
        onDismiss?()
        dismiss()
    }
}
