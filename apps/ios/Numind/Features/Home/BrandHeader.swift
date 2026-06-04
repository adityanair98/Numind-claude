import SwiftUI

/// Top brand row replacing the standard navigation title.
/// Shows wordmark + bell button, then avatar circle + greeting.
struct BrandHeader: View {
    let name: String
    let isDailyChallengeCompleted: Bool
    /// Current Level (Phase 9 — an effort signal, not a 0–100 verdict). 0 hides
    /// the ring until the user has sessions.
    var level: Int = 0
    /// 0–1 progress through the current level toward the next.
    var levelProgress: Double = 0
    /// Called when the user taps the level ring.
    var onScoreTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Bell hidden until notifications ship (Phase 8 Group G); `bellButton`
            // retained below so wiring it back up is a one-line change.
            greetingRow
        }
    }

    // MARK: - Top row (bell) — currently unused; see note in `body`.

    private var topRow: some View {
        HStack {
            Spacer()
            bellButton
        }
    }

    private var bellButton: some View {
        Button(action: {}) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: 38, height: 38)
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                Image(systemName: "bell.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .frame(width: 38, height: 38)
                if !isDailyChallengeCompleted {
                    Circle()
                        .fill(Theme.Colors.warmOrange)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Theme.Colors.cardBackground, lineWidth: 2)
                        )
                        .offset(x: -1, y: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Greeting row (avatar + text)

    private var greetingRow: some View {
        HStack(alignment: .bottom, spacing: 14) {
            avatarCircle
            VStack(alignment: .leading, spacing: 2) {
                Text("\(greetingPrefix),")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                HStack(spacing: 4) {
                    Text(displayName)
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }
            }
            Spacer()
            // Small level ring — only shown after first session
            if level > 0 {
                Button {
                    onScoreTap?()
                } label: {
                    LevelRing(level: level, progress: levelProgress, size: 52)
                        .padding(.bottom, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.mindTeal, Theme.Colors.primaryBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(String((name.isEmpty ? "A" : name).prefix(1)).uppercased())
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 52, height: 52)
        .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 6)
    }

    // MARK: - Helpers

    private var displayName: String {
        name.isEmpty ? "there" : name
    }

    private var greetingPrefix: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }
}

#Preview {
    VStack {
        BrandHeader(name: "Aditya", isDailyChallengeCompleted: false)
        Spacer()
    }
    .padding(.horizontal, Theme.Spacing.screenHorizontal)
    .background(Theme.Colors.softBackground)
}
