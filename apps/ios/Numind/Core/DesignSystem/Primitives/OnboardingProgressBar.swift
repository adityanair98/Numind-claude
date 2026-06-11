import SwiftUI

/// 5-phase progress bar for the onboarding funnel.
/// Thin capsule that fills 0...1. No numbers — just visual momentum.
struct OnboardingProgressBar: View {
    let value: Double
    var dark: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(dark ? Color.white.opacity(0.16) : Theme.Colors.mutedTint)

                Capsule()
                    .fill(dark ? Color.white : Theme.Colors.primaryBlue)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: 4)
        .animation(.easeOut(duration: 0.3), value: value)
    }

    // MARK: - Progress mapping

    /// Maps a 1-based screen index to a 0...1 progress value.
    /// Returns nil for screens that shouldn't show the bar (1, 26, 27).
    /// (Phase 12: paydayCapture inserted at 11 → 27 screens total.)
    static func progress(for screen: Int) -> Double? {
        // Screen 1 (welcome) and 26-27 (paywall/welcome) have no bar
        if screen == 1 || screen >= 26 { return nil }

        // Phase 1 (Problem Framing): screens 2–4
        if screen <= 4 {
            return 0.05 + Double(screen - 2) * 0.05
        }
        // Phase 2 (Personalization): screens 5–14 (10 screens)
        if screen <= 14 {
            return 0.20 + Double(screen - 4) * 0.027
        }
        // Phase 3 (Diagnostic): screens 15–17
        if screen <= 17 {
            return 0.50 + Double(screen - 14) * 0.04
        }
        // Phase 4 (Money Map): screen 18
        if screen == 18 {
            return 0.66
        }
        // Phase 5 (Plan + Priming + Payday): screens 19–25
        if screen <= 25 {
            return 0.70 + Double(screen - 18) * 0.035
        }

        return nil
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(value: 0.15)
        OnboardingProgressBar(value: 0.45)
        OnboardingProgressBar(value: 0.8)
        OnboardingProgressBar(value: 0.3, dark: true)
            .padding()
            .background(Theme.Colors.deepNavy)
    }
    .padding()
}
