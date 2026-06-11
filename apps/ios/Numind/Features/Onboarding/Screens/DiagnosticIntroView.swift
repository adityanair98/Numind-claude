import SwiftUI

/// Screen 15 — Diagnostic Intro
/// "Let's see where you stand on [moment]" with gauge illustration.
struct DiagnosticIntroView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("numind.userName") private var userName = "You"
    let onStart: () -> Void

    private var packTitle: String { viewModel.focusPack?.title ?? "your money moments" }

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

                        Text("Let\u{2019}s see where you stand on \(packTitle)")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 28)

                        Text("8 quick questions \u{2014} no grades, just an honest starting picture.")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(3)
                            .padding(.top, 12)

                        Text(userName == "You"
                            ? "This builds your Money Map and your plan."
                            : "\(userName), this builds your Money Map and your plan.")
                            .font(Theme.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 16)

                        // Info chips
                        HStack(spacing: 10) {
                            diagnosticChip(glyph: "\u{23F1}", label: "~3 min")
                            diagnosticChip(glyph: "\u{1F3AF}", label: "No grades")
                            diagnosticChip(glyph: "\u{1F4A1}", label: "Shortcuts")
                        }
                        .padding(.top, 22)

                        Text("We\u{2019}ll show you the shortcut behind every question \u{2014} that\u{2019}s the product.")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.Colors.mutedText.opacity(0.8))
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
    DiagnosticIntroView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onStart: {}
    )
}
