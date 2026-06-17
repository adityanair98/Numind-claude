import SwiftUI

/// Top brand row (Phase 13). Warm date + sans greeting on the left; the streak
/// as an ember flame chip (flame glyph + mono count) on the right — the ring
/// now lives in the daily hero card.
struct BrandHeader: View {
    let name: String
    var streak: Int = 0

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text(dateLine)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                Text("\(greetingPrefix), \(displayName)")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.deepNavy)
            }
            Spacer()
            if streak > 0 { streakChip }
        }
    }

    private var streakChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.ember)
            Text("\(streak)")
                .font(Theme.Typography.monoSmall)
                .foregroundStyle(Theme.Colors.deepNavy)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(Theme.Colors.emberTint)
        .clipShape(Capsule())
    }

    private var displayName: String { name.isEmpty ? "there" : name }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
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
        BrandHeader(name: "Aditya", streak: 12)
        Spacer()
    }
    .padding(.horizontal, Theme.Spacing.screenHorizontal)
    .background(Theme.Colors.softBackground)
}
