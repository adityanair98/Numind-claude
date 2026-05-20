import SwiftUI

/// Screen 15 — Diagnostic Intro
/// "Let's see where you're starting" with gauge illustration.
struct DiagnosticIntroView: View {
    @AppStorage("numind.userName") private var userName = "You"
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Gauge illustration
                        HStack {
                            Spacer()
                            DiagnosticGauge()
                            Spacer()
                        }
                        .padding(.top, 20)

                        Text("Let\u{2019}s see where you\u{2019}re starting")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 28)

                        Text("8 quick questions \u{2014} no pressure, just calibration.")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(3)
                            .padding(.top, 12)

                        Text(userName == "You"
                            ? "This helps us build your personal plan."
                            : "\(userName), this helps us build your personal plan.")
                            .font(Theme.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 16)

                        // Info chips
                        HStack(spacing: 10) {
                            diagnosticChip(glyph: "\u{23F1}", label: "~3 min")
                            diagnosticChip(glyph: "\u{1F3AF}", label: "No score")
                            diagnosticChip(glyph: "\u{2728}", label: "Calibrate")
                        }
                        .padding(.top, 22)

                        Text("Won\u{2019}t affect anything in your profile.")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Let\u{2019}s go") { onStart() }
                }
            }
        }
    }

    private func diagnosticChip(glyph: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(glyph)
                .font(.system(size: 22))
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    DiagnosticIntroView(onStart: {})
}
