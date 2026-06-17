import SwiftUI

/// Screen 7 — Life-Moment Picker (the structural keystone of funnel v2).
///
/// "What's coming up in your life?" — the 12 Life-Event Packs wearing their
/// real-life names. The FIRST selection becomes the focus pack (badged
/// "YOUR FOCUS"); up to 2 more become secondary moments. This gives Home's
/// "one next action" its why, makes the diagnostic pack-aware, and dates
/// the timeline screen.
struct LifeMomentPickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private struct Moment {
        let packId: String
        let label: String
        let symbol: String
        let color: Color
    }

    private let moments: [Moment] = [
        Moment(packId: "the_job_offer",          label: "A job offer or\nsalary talk",      symbol: "briefcase.fill",              color: Theme.Colors.warmOrange),
        Moment(packId: "open_enrollment",        label: "Picking benefits /\nopen enrollment", symbol: "heart.text.square.fill",   color: Theme.Colors.insurancePurple),
        Moment(packId: "first_apartment",        label: "Moving / first\napartment",        symbol: "key.fill",                    color: Theme.Colors.housingRose),
        Moment(packId: "credit_card_cleanup",    label: "Paying down\ncard debt",           symbol: "creditcard.fill",             color: Theme.Colors.debtCoral),
        Moment(packId: "investing_starter",      label: "Starting to\ninvest",              symbol: "chart.line.uptrend.xyaxis",   color: Theme.Colors.investIndigo),
        Moment(packId: "car_buying",             label: "Buying a\ncar",                    symbol: "car.fill",                    color: Theme.Colors.mindTeal),
        Moment(packId: "buying_a_home",          label: "Buying a\nhome",                   symbol: "house.fill",                  color: Theme.Colors.housingRose),
        Moment(packId: "student_loan_repayment", label: "Student\nloans",                   symbol: "graduationcap.fill",          color: Theme.Colors.warmOrange),
        Moment(packId: "first_paycheck",         label: "First real\npaycheck",             symbol: "dollarsign.circle.fill",      color: Theme.Colors.growthGreen),
        Moment(packId: "taxes_without_panic",    label: "Taxes",                            symbol: "doc.text.fill",               color: Theme.Colors.taxSlate),
        Moment(packId: "protect_your_money",     label: "Worried about\nscams",             symbol: "lock.shield.fill",            color: Theme.Colors.safetyCrimson),
        Moment(packId: "everyday_spending",      label: "Just everyday\nmoney",             symbol: "percent",                     color: Theme.Colors.mindTeal),
    ]

    private var canContinue: Bool {
        viewModel.signals.focusPackId != nil
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What\u{2019}s coming up in your life?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        Text("Pick the closest one first \u{2014} that becomes your focus. Add up to 2 more.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                        ], spacing: 12) {
                            ForEach(moments, id: \.packId) { moment in
                                momentCard(moment)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(canContinue ? 1 : 0.5)
                .allowsHitTesting(canContinue)
            }
        }
    }

    private func momentCard(_ moment: Moment) -> some View {
        let isFocus = viewModel.signals.focusPackId == moment.packId
        let isSecondary = viewModel.signals.secondaryPackIds.contains(moment.packId)
        let selected = isFocus || isSecondary

        return Button {
            viewModel.toggleLifeMoment(moment.packId)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: moment.symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(moment.color)
                        .frame(width: 44, height: 44)
                        .background(moment.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Spacer()
                    if isFocus {
                        Text("YOUR FOCUS")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white)
                            .tracking(0.4)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(moment.color)
                            .clipShape(Capsule())
                    } else if isSecondary {
                        // Secondaries share one neutral check — only the FOCUS
                        // earns its pack color, so the hierarchy reads at a glance.
                        CheckBadge(selected: true, color: Theme.Colors.mindTeal)
                    }
                }

                Text(moment.label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .padding(.top, 2)
            .background(isFocus ? moment.color.opacity(0.06)
                        : (isSecondary ? Theme.Colors.mindTealTint.opacity(0.5)
                           : Theme.Colors.cardBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isFocus ? moment.color
                            : (isSecondary ? Theme.Colors.mindTeal : Theme.Colors.hairline),
                        lineWidth: isFocus ? 2 : (selected ? 1.5 : 1)
                    )
            )
            .shadow(
                color: isFocus ? moment.color.opacity(0.12)
                    : (isSecondary ? Theme.Colors.mindTeal.opacity(0.10) : .black.opacity(0.04)),
                radius: selected ? 8 : 3, x: 0, y: 2
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: selected)
        .animation(.easeOut(duration: 0.18), value: isFocus)
    }
}

#Preview {
    LifeMomentPickerView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
