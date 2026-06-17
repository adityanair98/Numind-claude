import SwiftUI

/// Screen 26 — Welcome to Numind (final, celebratory milestone)
/// Warm hero tint, confetti, success badge, first session CTA.
struct WelcomeConfirmView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("numind.userName") private var userName = "You"
    let onStartFirstSession: () -> Void
    let onExploreFirst: () -> Void

    private var minutesPerDay: Int { viewModel.signals.dailyMinutes ?? 10 }
    private var packShortName: String {
        viewModel.focusPack?.title ?? "Your path"
    }
    private var streakDays: String {
        if let goal = viewModel.signals.streakGoal { return "\(goal)d" }
        return "7d"
    }

    var body: some View {
        ZStack {
            // Warm celebratory hero tint fading into the page background.
            LinearGradient(
                colors: [Theme.Colors.emberTint, Theme.Colors.softBackground],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti (milestone celebration screen — completion of onboarding)
            ConfettiBurst()

            VStack(spacing: 0) {
                Spacer()

                // Success badge
                SuccessBadge()
                    .padding(.bottom, 30)

                Text("You\u{2019}re all set")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.insightText)

                Text("Welcome to Numind,\n\(userName)")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)

                Text("\(packShortName) is your focus. Let\u{2019}s close your first ring.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)
                    .padding(.horizontal, 28)

                // Stats row
                HStack(spacing: 0) {
                    statPill(value: "\(minutesPerDay)", label: "min/day")
                    statDivider
                    statPill(value: "\(viewModel.signals.dailyChallengeCount)", label: "ring target")
                    statDivider
                    statPill(value: streakDays, label: "ring streak")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                )
                .padding(.top, 30)
                .padding(.horizontal, 40)

                Spacer()
                Spacer()

                // CTAs
                VStack(spacing: 6) {
                    Button(action: onStartFirstSession) {
                        Text("Start today\u{2019}s workout \u{2192}")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.ctaLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(Theme.Colors.ctaFill)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: onExploreFirst) {
                        Text("Explore first")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .frame(height: 36)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 44)
            }
        }
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(minWidth: 64)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Theme.Colors.hairline)
            .frame(width: 1, height: 30)
            .padding(.horizontal, 2)
    }
}

// MARK: - Success Badge

private struct SuccessBadge: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Glow
            RadialGradient(
                colors: [Theme.Colors.mindTeal.opacity(0.30), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 80
            )
            .frame(width: 190, height: 190)

            // Bead ring
            ForEach(0..<16, id: \.self) { i in
                let angle = Double(i) / 16.0 * .pi * 2 - .pi / 2
                let r: CGFloat = 60
                Circle()
                    .fill(i % 4 == 0 ? Theme.Colors.mindTeal : Theme.Colors.mutedText.opacity(0.35))
                    .frame(width: 6, height: 6)
                    .offset(x: r * cos(angle), y: r * sin(angle))
            }

            // Center disk
            Circle()
                .fill(Theme.Colors.mindTeal)
                .frame(width: 94, height: 94)
                .shadow(color: Theme.Colors.mindTeal.opacity(0.45), radius: 18, x: 0, y: 8)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .frame(width: 130, height: 130)
        .scaleEffect(appeared ? 1 : 0.5)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
        .onAppear { appeared = true }
    }
}

#Preview {
    WelcomeConfirmView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onStartFirstSession: {},
        onExploreFirst: {}
    )
}
