import SwiftUI

/// Transient celebration sheet shown when the user completes the last
/// remaining lesson in a pack. Renders inline from `LessonView`'s
/// `onSessionComplete` flow before the lesson summary so the user lands
/// on a "win" page first. Tapping "Awesome" dismisses and clears the
/// focus (since the path is done).
struct PackCompletionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    let pack: Pack
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.sectionSpacing) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.Colors.mindTeal)
                Text("Path complete")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                Text(pack.title)
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.mindTeal)
                    .multilineTextAlignment(.center)
                Text("You finished all \(pack.lessonIds.count) lessons. The next time this life event comes up — you'll know exactly what to do.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.cardPadding)
            }
            Spacer()
            PillButton("Awesome", action: dismissNow)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
    }

    private func dismissNow() {
        // If the completed pack is the user's focus, clear it so the next
        // session picks up a fresh path (or no pack at all).
        if progressStore.focusPackId == pack.id {
            progressStore.clearFocusPack()
        }
        onDismiss?()
        dismiss()
    }
}
