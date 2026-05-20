import SwiftUI

/// Full-screen "oh no" overlay shown when the user's streak has broken.
///
/// Offers two paths:
/// 1. **Revive** — complete a quick 5-question quiz to freeze the missed day(s)
/// 2. **Start fresh** — accept the loss and begin a new streak
struct StreakLossView: View {
    let lostStreak: Int
    let onRevive: () -> Void
    let onDismiss: () -> Void

    @State private var showRevivalQuiz = false

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Broken flame illustration
                brokenFlameIcon
                    .padding(.bottom, 24)

                Text("Oh no!")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)

                Text("You lost your \(lostStreak)-day streak")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .padding(.top, 8)

                // Motivational nudge
                NumindCard {
                    VStack(spacing: 8) {
                        Text("Don\u{2019}t worry \u{2014} it happens to everyone.")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("Complete a quick challenge to pick up right where you left off.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 32)

                Spacer()

                // CTAs
                VStack(spacing: 12) {
                    PillButton("Revive your streak") {
                        showRevivalQuiz = true
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Start fresh")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showRevivalQuiz) {
            StreakRevivalQuizView(
                onSuccess: { onRevive() },
                onFailure: { onDismiss() }
            )
        }
    }

    // MARK: - Broken flame

    private var brokenFlameIcon: some View {
        ZStack {
            // Outer ring — faded
            Circle()
                .fill(Theme.Colors.errorSoftRed.opacity(0.1))
                .frame(width: 120, height: 120)

            // Inner ring
            Circle()
                .fill(Theme.Colors.errorSoftRed.opacity(0.15))
                .frame(width: 88, height: 88)

            // Flame with X
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.Colors.errorSoftRed.opacity(0.6))

                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .offset(y: -2)
            }
        }
    }
}

#Preview {
    StreakLossView(lostStreak: 12, onRevive: {}, onDismiss: {})
}
