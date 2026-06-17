import SwiftUI
import UserNotifications

/// Screen 20 — Notification Permission
/// Mock notifications + enable/skip CTA.
struct NotificationPermissionView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Stay on track with smart reminders")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("We\u{2019}ll remind you at the right time \u{2014} and celebrate your streaks.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        // Mock notifications
                        VStack(spacing: 10) {
                            notificationBanner(
                                symbol: "flame.fill",
                                bg: Theme.Colors.ember,
                                body: "Your ring\u{2019}s still open \u{2014} 6 minutes closes it."
                            )
                            notificationBanner(
                                symbol: "arrow.triangle.2.circlepath",
                                bg: Theme.Colors.mindTeal,
                                body: "2 skills are fading \u{2014} 3 minutes brings them back.",
                                scale: 0.96
                            )
                            notificationBanner(
                                symbol: "calendar",
                                bg: Theme.Colors.insightText,
                                body: "Open enrollment is in 3 weeks \u{2014} you\u{2019}re 2 skills from Ready.",
                                scale: 0.96,
                                opacity: 0.5
                            )
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 4)

                        // Smart timing hint
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                            Text("Smart timing \u{2014} we won\u{2019}t bug you when you\u{2019}re busy.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Colors.deepNavy)
                        }
                        .padding(14)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    VStack(spacing: 6) {
                        PillButton("Enable reminders") {
                            requestNotifications()
                        }
                        Button {
                            onContinue()
                        } label: {
                            Text("Maybe later")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.Colors.mutedText)
                                .frame(height: 44)
                        }
                    }
                }
            }
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async {
                onContinue()
            }
        }
    }

    private func notificationBanner(symbol: String, bg: Color, body: String, scale: CGFloat = 1.0, opacity: Double = 1.0) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("NUMIND")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .tracking(0.4)
                    Spacer()
                    Text("now")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Text(body)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Theme.Colors.deepNavy.opacity(0.08), radius: 6, x: 0, y: 2)
        .scaleEffect(scale)
        .opacity(opacity)
    }
}

#Preview {
    NotificationPermissionView(onContinue: {})
}
