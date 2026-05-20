import SwiftUI

/// Screen 1 — Welcome / Hook
/// Deep navy gradient background, hero illustration, value props, CTA.
struct WelcomeHookView: View {
    let onGetStarted: () -> Void
    let onAlreadyHaveAccount: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Theme.Colors.deepNavy, Color(red: 0.08, green: 0.28, blue: 0.72)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 32)

                // Hero illustration (reuse existing pattern)
                HeroIllustration()
                    .padding(.bottom, 36)

                // Headline
                VStack(alignment: .leading, spacing: 6) {
                    Text("Real math.")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Real life.")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Colors.insightYellow)

                    Text("Build everyday math skills that help you make smarter decisions — every day.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineSpacing(3)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

                // Value props
                VStack(spacing: 12) {
                    valueRow(emoji: "\u{26A1}", tint: Theme.Colors.primaryBlueTint, title: "Short, focused workouts", sub: "5\u{2013}10 minutes to build momentum")
                    valueRow(emoji: "\u{1F6D2}", tint: Theme.Colors.mindTealTint, title: "Practical & relevant", sub: "Learn skills you can use today")
                    valueRow(emoji: "\u{1F4CA}", tint: Theme.Colors.insightYellowTint, title: "Track progress, build habits", sub: "Streaks, goals, and rewards")
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 18)

                Spacer(minLength: 24)

                // CTAs
                VStack(spacing: 6) {
                    Button(action: onGetStarted) {
                        Text("Get started")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: onAlreadyHaveAccount) {
                        Text("I already have an account")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.72))
                            .frame(height: 44)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 44)
            }
        }
    }

    private func valueRow(emoji: String, tint: Color, title: String, sub: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 18))
                .frame(width: 38, height: 38)
                .background(tint)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(sub)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
    }
}

// MARK: - Hero Illustration

private struct HeroIllustration: View {
    @State private var floatA = false
    @State private var floatB = false
    @State private var floatC = false

    var body: some View {
        ZStack {
            // Glow blobs
            Circle()
                .fill(Theme.Colors.insightYellow.opacity(0.35))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: 70, y: -30)

            Circle()
                .fill(Theme.Colors.mindTeal.opacity(0.30))
                .frame(width: 200, height: 200)
                .blur(radius: 35)
                .offset(x: -60, y: 20)

            // Receipt card
            ReceiptCard()
                .rotationEffect(.degrees(-7))
                .offset(x: -10, y: floatA ? -4 : 4)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: floatA)

            // % coin
            ZStack {
                Circle()
                    .fill(Theme.Colors.insightYellow)
                    .frame(width: 78, height: 78)
                    .shadow(color: Theme.Colors.insightYellow.opacity(0.45), radius: 16, x: 0, y: 8)
                Text("%")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
            }
            .rotationEffect(.degrees(8))
            .offset(x: 100, y: floatB ? -48 : -40)
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatB)

            // Cart badge
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.Colors.mindTeal)
                    .frame(width: 64, height: 64)
                    .shadow(color: Theme.Colors.mindTeal.opacity(0.45), radius: 14, x: 0, y: 6)
                Text("\u{1F6D2}")
                    .font(.system(size: 30))
            }
            .rotationEffect(.degrees(-6))
            .offset(x: -95, y: floatC ? 55 : 62)
            .animation(.easeInOut(duration: 2.9).repeatForever(autoreverses: true), value: floatC)

            // Dollar pill
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                Text("$")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
            }
            .offset(x: 20, y: -80)

            // Decorative dots
            Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6).offset(x: 80, y: 55)
            Circle().fill(Color.white.opacity(0.3)).frame(width: 6, height: 6).offset(x: 95, y: 55)
            Circle().fill(Theme.Colors.insightYellow.opacity(0.5)).frame(width: 5, height: 5).offset(x: -80, y: -50)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .onAppear {
            floatA = true
            floatB = true
            floatC = true
        }
    }
}

// MARK: - Receipt Card

private struct ReceiptCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Receipt")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)
                .textCase(.uppercase)
                .tracking(1)

            Text("Coffee Bar \u{2014} Mon")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.Colors.deepNavy)

            Divider()

            receiptLine("Latte", "$5.20")
            receiptLine("Croissant", "$4.80")
            receiptLine("Berry tea", "$3.50")

            Divider()

            receiptLine("Subtotal", "$13.50", muted: true)
            receiptLine("Tax 8.5%", "$1.15", muted: true)

            HStack {
                Text("Tip 18%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                Text("$2.43")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.primaryBlue)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(width: 200)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 15)
    }

    private func receiptLine(_ label: String, _ value: String, muted: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(muted ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(muted ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
        }
    }
}

#Preview {
    WelcomeHookView(onGetStarted: {}, onAlreadyHaveAccount: {})
}
