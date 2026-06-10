import SwiftUI

/// Full-screen in-session teach moment (Phase 10).
///
/// New material enters the Daily Workout through exactly this door: the
/// lesson's concept + shortcut, shown once, right before its first practice
/// rep. Mirrors `MotivatorView`'s full-screen interstitial structure.
struct TeachCardView: View {
    let card: TeachCard
    let accent: Color
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 36)

                    Text("NEW SKILL")
                        .font(Theme.Typography.overline)
                        .tracking(1.4)
                        .foregroundStyle(accent)

                    Text(card.lessonTitle)
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(card.concept)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    // The shortcut is the take-away — insight-yellow idiom.
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Shortcut", systemImage: "bolt.fill")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.insightText)
                        Text(card.shortcut)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    if let example = card.example {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Worked example")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.mutedText)
                            Text(example)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Spacer().frame(height: Theme.Spacing.buttonHeight + 60)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 24)
                .allowsHitTesting(false)

                PillButton("Got it — try one") { onContinue() }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 12)
                    .background(Theme.Colors.softBackground)
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.35).delay(0.1)) { appeared = true }
        }
    }
}
