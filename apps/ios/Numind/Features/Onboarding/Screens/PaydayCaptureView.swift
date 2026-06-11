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
    @State private var secondPaydayDay = 31   // semimonthly: "Last day" default

    /// Day-of-month options for the second semimonthly payday (31 = last day).
    private static let secondDayOptions = [1, 5, 10, 15, 20, 25, 31]

    private static func secondDayLabel(_ day: Int) -> String {
        day == 31 ? "Last day" : "The \(day)\(ordinalSuffix(day))"
    }

    private static func ordinalSuffix(_ day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22:     return "nd"
        case 3, 23:     return "rd"
        default:        return "th"
        }
    }

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

                            // Twice a month = two known days; one anchor can't
                            // tell us the other, so ask.
                            if cadence == .semimonthly {
                                HStack(spacing: 14) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Theme.Colors.growthGreen)
                                        .frame(width: 36, height: 36)
                                        .background(Theme.Colors.growthGreen.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    Text("Your other payday")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.Colors.deepNavy)
                                    Spacer()
                                    Picker("", selection: $secondPaydayDay) {
                                        ForEach(Self.secondDayOptions, id: \.self) { day in
                                            Text(Self.secondDayLabel(day)).tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Theme.Colors.deepNavy)
                                    .onChange(of: secondPaydayDay) { _, _ in save() }
                                }
                                .padding(14)
                                .background(Theme.Colors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                                )
                                .padding(.top, 10)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
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
                if let second = saved.secondPaydayDay { secondPaydayDay = second }
            }
        }
    }

    private func save() {
        guard let cadence else { return }
        viewModel.setPaycheck(cadence: cadence, anchorDate: anchorDate,
                              secondPaydayDay: secondPaydayDay)
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
