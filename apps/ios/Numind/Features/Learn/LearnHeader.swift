import SwiftUI

/// Custom header for the Learn tab, replacing the standard navigation title.
/// Shows wordmark + mastery pill, then "Your quest" display title.
struct LearnHeader: View {
    let totalMastered: Int
    let totalLessons: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            topRow
            VStack(alignment: .leading, spacing: 4) {
                Text("Your quest")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("\(totalMastered) lessons mastered \u{00B7} \(totalLessons - totalMastered) to go")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Top row (wordmark + mastery pill)

    private var topRow: some View {
        HStack {
            Image("NumindWordmark")
                .resizable()
                .scaledToFit()
                .frame(height: 22)
            Spacer()
            masteryPill
        }
    }

    private var masteryPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow)
            HStack(spacing: 0) {
                Text("\(totalMastered)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("/\(totalLessons)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.Colors.cardBackground)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        LearnHeader(totalMastered: 8, totalLessons: 24)
        Spacer()
    }
    .background(Theme.Colors.softBackground)
}
