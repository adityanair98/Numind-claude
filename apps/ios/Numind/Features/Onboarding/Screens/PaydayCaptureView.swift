import SwiftUI

/// Screen 11 — Payday Capture (Phase 12).
///
/// "When do you get paid?" — the strongest natural recurring trigger finance
/// has. Cadence cards + a "most recent payday" date, with a prominent skip.
/// Feeds the payday moment chip and payday-anchored reminders.
struct PaydayCaptureView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @State private var cadence: PaycheckSchedule.Cadence? = nil
    @State private var anchorDate = Date()

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you get paid?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("We\u{2019}ll time your sessions to your money \u{2014} payday is the best 2 minutes you\u{2019}ll spend on each check.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(2)
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(PaycheckSchedule.Cadence.allCases, id: \.self) { option in
                                OnboardingSelectCard(
                                    label: option.displayText,
                                    selected: cadence == option
                                ) {
                                    cadence = option
                                    save()
                                }
                            }
                        }
                        .padding(.top, 22)

                        if cadence != nil {
                            HStack(spacing: 14) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.growthGreen)
                                    .frame(width: 36, height: 36)
                                    .background(Theme.Colors.growthGreen.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Text("Most recent payday")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.deepNavy)
                                Spacer()
                                DatePicker("", selection: $anchorDate,
                                           in: ...Date(),
                                           displayedComponents: .date)
                                    .labelsHidden()
                                    .onChange(of: anchorDate) { _, _ in save() }
                            }
                            .padding(14)
                            .background(Theme.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                            )
                            .padding(.top, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 140)
                }
                .animation(.easeOut(duration: 0.22), value: cadence)

                onboardingFooter(dark: false) {
                    VStack(spacing: 6) {
                        PillButton("Continue") { onContinue() }
                            .opacity(cadence != nil ? 1 : 0.5)
                            .allowsHitTesting(cadence != nil)
                        Button {
                            viewModel.clearPaycheck()
                            onContinue()
                        } label: {
                            Text("Skip \u{2014} I\u{2019}ll add this later")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.Colors.mutedText)
                                .frame(height: 40)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let saved = viewModel.signals.paycheck {
                cadence = saved.cadence
                anchorDate = saved.anchorDate
            }
        }
    }

    private func save() {
        guard let cadence else { return }
        viewModel.setPaycheck(cadence: cadence, anchorDate: anchorDate)
    }
}

#Preview {
    PaydayCaptureView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
