import SwiftUI

/// Screen 25 — Paywall (RevenueCat placeholder)
/// Toggle monthly/yearly, feature list, trial timeline.
struct PaywallView: View {
    @State private var selectedPlan: Plan = .annual
    let onSubscribe: () -> Void
    let onRestore: () -> Void

    enum Plan { case monthly, annual }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero badge
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Colors.primaryBlue, Theme.Colors.investIndigo],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .shadow(color: Theme.Colors.primaryBlue.opacity(0.32), radius: 18, x: 0, y: 8)

                            Text("\u{1F9E0}")
                                .font(.system(size: 44))

                            // PRO badge
                            Text("PRO")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .tracking(0.4)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.Colors.insightYellow)
                                .clipShape(Capsule())
                                .shadow(color: Theme.Colors.insightYellow.opacity(0.4), radius: 5, x: 0, y: 2)
                                .offset(x: 28, y: -30)
                        }
                        .padding(.top, 8)

                        Text("Try Numind free for 7 days \u{2014} be ready for what\u{2019}s coming")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .multilineTextAlignment(.center)
                            .padding(.top, 18)

                        Text("You\u{2019}ll be reminded before any charge.")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        // Plan cards
                        HStack(spacing: 12) {
                            planCard(
                                label: "Monthly", price: "$4.99", period: "/ month",
                                sub: "Cancel anytime", plan: .monthly
                            )
                            planCard(
                                label: "Annual", price: "$29.99", period: "/ year",
                                sub: "$2.50/mo \u{00B7} Save 50%", plan: .annual,
                                badge: "BEST VALUE"
                            )
                        }
                        .padding(.top, 22)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)

                        // Feature list
                        featureList
                            .padding(.top, 22)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)

                        // Trial timeline
                        trialTimeline
                            .padding(.top, 22)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    }
                    .padding(.bottom, 140)
                }

                onboardingFooter(dark: false) {
                    VStack(spacing: 4) {
                        PillButton("Start 7-day free trial") { onSubscribe() }

                        Text("Free for 7 days, then \(selectedPlan == .annual ? "$29.99/year" : "$4.99/month"). Cancel anytime.")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)

                        HStack(spacing: 16) {
                            Button("Restore") { onRestore() }
                            Button("Terms") { }
                            Button("Privacy") { }
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    // MARK: - Plan Card

    private func planCard(
        label: String, price: String, period: String, sub: String,
        plan: Plan, badge: String? = nil
    ) -> some View {
        let featured = plan == .annual
        let isSelected = selectedPlan == plan

        return Button {
            selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(price)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(period)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(.top, 6)

                Text(sub)
                    .font(.system(size: 13, weight: featured ? .semibold : .regular))
                    .foregroundStyle(featured ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .frame(minHeight: 150)
            .background(
                featured
                    ? LinearGradient(
                        colors: [Color(red: 1, green: 0.99, blue: 0.92), Theme.Colors.cardBackground],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [Theme.Colors.cardBackground, Theme.Colors.cardBackground],
                        startPoint: .top, endPoint: .bottom
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? (featured ? Theme.Colors.insightYellow : Theme.Colors.primaryBlue)
                            : Theme.Colors.hairline,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(alignment: .top) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .tracking(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.insightYellow)
                        .clipShape(Capsule())
                        .shadow(color: Theme.Colors.insightYellow.opacity(0.4), radius: 5, x: 0, y: 2)
                        .offset(y: -10)
                }
            }
            .shadow(
                color: featured ? Theme.Colors.insightYellow.opacity(0.30) : .black.opacity(0.04),
                radius: featured ? 14 : 3, x: 0, y: featured ? 6 : 1
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }

    // MARK: - Feature List

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You get")
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Colors.mutedText)

            featureRow("All 12 life-moment paths \u{00B7} 127 skills")
            featureRow("Daily workout + honest Readiness tracking")
            featureRow("12 built-in calculators")
            featureRow("Skill refresh + streak protection")
            featureRow("Moment alerts \u{2014} enrollment, tax season, FSA deadlines")
        }
        .padding(18)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.Colors.mindTeal)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
    }

    // MARK: - Trial Timeline

    private var trialTimeline: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your trial")
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Colors.mutedText)

            // Connection line + steps
            HStack(alignment: .top, spacing: 0) {
                timelineStep(
                    glyph: "\u{2728}", color: Theme.Colors.primaryBlue,
                    day: "Today", title: "Start", sub: "Full Pro access"
                )
                Spacer()
                timelineStep(
                    glyph: "\u{1F514}", color: Theme.Colors.warmOrange,
                    day: "Day 5", title: "Reminder", sub: "We ping you before"
                )
                Spacer()
                timelineStep(
                    glyph: "\u{1F3AF}", color: Theme.Colors.mindTeal,
                    day: "Day 7", title: "Continue or cancel", sub: "Your choice"
                )
            }
        }
        .padding(16)
        .background(Theme.Colors.primaryBlueTint)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func timelineStep(glyph: String, color: Color, day: String, title: String, sub: String) -> some View {
        VStack(spacing: 6) {
            Text(glyph)
                .font(.system(size: 14))
                .frame(width: 32, height: 32)
                .background(Theme.Colors.cardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(color, lineWidth: 2)
                )

            Text(day)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)

            Text(sub)
                .font(.system(size: 10))
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 90)
        }
    }
}

#Preview {
    PaywallView(onSubscribe: {}, onRestore: {})
}
