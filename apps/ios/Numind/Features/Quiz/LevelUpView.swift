import SwiftUI

// MARK: - Data

struct LevelUpInfo: Identifiable {
    let id = UUID()
    let moduleName: String
    let moduleIcon: String
    let moduleColor: ModuleColor
    let newLevel: Int

    var levelName: String {
        switch newLevel {
        case 1:  return "Beginner"
        case 2:  return "Developing"
        case 3:  return "Skilled"
        case 4:  return "Advanced"
        default: return "Expert"
        }
    }
}

// MARK: - View

struct LevelUpView: View {
    let info: LevelUpInfo
    @Environment(\.dismiss) private var dismiss

    @State private var badgeScale:   CGFloat = 0.55
    @State private var badgeOpacity: Double  = 0
    @State private var showConfetti  = false

    private var accent:     Color { info.moduleColor.tintColor }
    private var accentTint: Color { info.moduleColor.tintBackground }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Colors.softBackground.ignoresSafeArea()

            if showConfetti {
                ConfettiView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                // Animated module badge
                ZStack {
                    Circle()
                        .fill(accentTint)
                        .frame(width: 128, height: 128)
                    VStack(spacing: 6) {
                        Image(systemName: info.moduleIcon)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(accent)
                        Text("Lv \(info.newLevel)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(accent)
                    }
                }
                .scaleEffect(badgeScale)
                .opacity(badgeOpacity)
                .padding(.bottom, 30)

                // Headline
                VStack(spacing: 10) {
                    Text("Level up!")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(info.moduleName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    Text(info.levelName.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(accent)
                        .kerning(1.0)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(accentTint)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 32)

                // Level pips — current pip is larger
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { i in
                        let isCurrent = i == info.newLevel
                        Circle()
                            .fill(i <= info.newLevel ? accent : Theme.Colors.mutedTint)
                            .frame(width: isCurrent ? 14 : 8, height: isCurrent ? 14 : 8)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.65).delay(0.5), value: badgeScale)
                .padding(.bottom, 52)

                Spacer()

                PillButton("Keep going") { dismiss() }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 36)
            }
        }
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.50, dampingFraction: 0.58).delay(0.12)) {
                badgeScale   = 1.0
                badgeOpacity = 1.0
            }
            showConfetti = true
        }
    }
}
