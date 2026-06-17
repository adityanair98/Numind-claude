import SwiftUI

/// Compact streak card with flame tile, streak count, 7-day dot strip, and freeze bank.
struct StreakStripCard: View {
    let streak: Int
    let completions: [Bool]
    var availableFreezes: Int = 0

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NumindCard {
            HStack(alignment: .center, spacing: 14) {
                flameTile
                streakInfo
                Spacer(minLength: 0)
                weekDots
            }
        }
    }

    // MARK: - Flame tile

    private var flameTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.Colors.emberTint)
                .shadow(color: Theme.Colors.ember.opacity(0.25), radius: 7, x: 0, y: 6)
            Image(systemName: "flame.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.Colors.ember)
        }
        .frame(width: 46, height: 46)
    }

    // MARK: - Streak info

    private var streakInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(streak)")
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("day streak")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            HStack(spacing: 8) {
                Text(tierMessage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.Colors.ember)

                if availableFreezes > 0 {
                    freezeBadge
                }
            }
        }
    }

    // MARK: - Freeze badge

    private var freezeBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "snowflake")
                .font(.system(size: 10, weight: .bold))
            Text("\u{00D7}\(availableFreezes)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(Theme.Colors.mindTeal)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Theme.Colors.mindTeal.opacity(0.1))
        .clipShape(Capsule())
    }

    private var tierMessage: String {
        if streak >= 7 { return "You're on fire" }
        if streak >= 3 { return "Nice rhythm" }
        return "Building momentum"
    }

    // MARK: - Week dots

    private var weekDots: some View {
        let todayIdx = todayWeekdayIndex

        return HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { i in
                let done = i < completions.count && completions[i]
                let isToday = i == todayIdx

                VStack(spacing: 4) {
                    ZStack {
                        if done {
                            Circle()
                                .fill(Theme.Colors.mindTeal)
                                .shadow(color: Theme.Colors.mindTeal.opacity(0.4), radius: 3, x: 0, y: 2)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isToday {
                            Circle()
                                .fill(Theme.Colors.cardBackground)
                                .overlay(
                                    Circle()
                                        .stroke(Theme.Colors.mindTeal, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                                )
                        } else {
                            Circle()
                                .fill(Theme.Colors.mutedTint)
                        }
                    }
                    .frame(width: 20, height: 20)

                    Text(dayLabels[i])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(isToday ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
                        .kerning(0.4)
                }
            }
        }
    }

    /// Index 0 = Monday ... 6 = Sunday matching the dayLabels array.
    private var todayWeekdayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar.weekday: 1=Sun 2=Mon ... 7=Sat
        // dayLabels: 0=Mon ... 6=Sun
        return (weekday + 5) % 7
    }
}

#Preview("Active streak + freezes") {
    StreakStripCard(streak: 12, completions: [true, true, true, true, false, false, false], availableFreezes: 2)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("Active streak, no freezes") {
    StreakStripCard(streak: 12, completions: [true, true, true, true, false, false, false])
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}

#Preview("No streak") {
    StreakStripCard(streak: 0, completions: [false, false, false, false, false, false, false])
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground)
}
