import SwiftUI

/// Non-blocking overlay card shown on the feedback screen when the user
/// demonstrates good pattern recognition (fast answer, used hint, streak).
///
/// Appears as a centered card over the feedback content. Auto-dismisses
/// after 2.5 seconds, or the user can tap "Continue" to advance immediately.
struct InlineEncouragementView: View {
    let encouragement: InlineEncouragement
    let onContinue: () -> Void

    @State private var appeared = false
    @State private var autoDismissTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture { onContinue() }

            // Card
            VStack(spacing: 16) {
                // Star icon
                ZStack {
                    Circle()
                        .fill(Theme.Colors.insightYellowTint)
                        .frame(width: 72, height: 72)
                    Image(systemName: "star.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }

                Text(encouragement.headline)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)

                Text(encouragement.subtitle)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)

                Button {
                    autoDismissTask?.cancel()
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mindTeal)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .frame(maxWidth: 300)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                appeared = true
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            // Auto-dismiss after 2.5 seconds
            autoDismissTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.5))
                guard !Task.isCancelled else { return }
                onContinue()
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }
}
