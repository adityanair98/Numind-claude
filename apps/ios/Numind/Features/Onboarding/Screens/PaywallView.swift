import SwiftUI

/// Screen 25 — Paywall (RevenueCat placeholder)
/// Toggle weekly/yearly, feature list, trial timeline.
struct PaywallView: View {
    @State private var selectedPlan: Plan = .annual
    let onSubscribe: () -> Void
    let onRestore: () -> Void

    enum Plan { case weekly, annual }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Marketing hero — goldTint radial card + serif headline
                        // (paywall is a marketing surface, so serif is allowed).
                        heroCard
                            .padding(.top, 8)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)

                        Text("Start free for 7 days \u{2014} reminded before any charge.")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)

                        // Plan cards
                        HStack(spacing: 12) {
                            planCard(
                                label: "Weekly", price: "$3.99", period: "/ week",
                                sub: "Cancel anytime", plan: .weekly
                            )
                            planCard(
                                label: "Annual", price: "$29.99", period: "/ year",
                                sub: "$0.58/wk \u{00B7} Save 85%", plan: .annual,
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

                        Text("Free for 7 days, then \(selectedPlan == .annual ? "$29.99/year" : "$3.99/week"). Cancel anytime.")
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

    // MARK: - Marketing hero (Phase 13)

    private var heroCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                artifactCircle(text: "%", fill: Theme.Colors.insightYellow, fg: Theme.Colors.deepNavy)
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Theme.Colors.mindTeal)
                        .frame(width: 56, height: 56)
                    Image(systemName: "cart.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                artifactCircle(text: "$", fill: Theme.Colors.mindTealTint, fg: Theme.Colors.mindTeal)
            }

            Text("Walk in ready. Every time.")
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RadialGradient(
                colors: [Theme.Colors.insightYellowTint, Theme.Colors.cardBackground],
                center: .top, startRadius: 10, endRadius: 300
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
    }

    private func artifactCircle(text: String, fill: Color, fg: Color) -> some View {
        ZStack {
            Circle().fill(fill).frame(width: 56, height: 56)
            Text(text)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(fg)
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
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
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
                        isSelected ? Theme.Colors.deepNavy : Theme.Colors.hairline,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(alignment: .top) {
                if let badge {
                    // Positive = teal, never gold (a savings badge is good news).
                    Text(badge)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.mindTeal)
                        .clipShape(Capsule())
                        .offset(y: -10)
                }
            }
            .shadow(
                color: .black.opacity(featured ? 0.07 : 0.04),
                radius: featured ? 8 : 3, x: 0, y: featured ? 4 : 1
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

            featureRow("All 12 life-moment paths \u{00B7} 134 skills")
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
                    glyph: "sparkles", color: Theme.Colors.mindTeal,
                    day: "Today", title: "Start", sub: "Full access"
                )
                Spacer()
                timelineStep(
                    glyph: "bell.fill", color: Theme.Colors.ember,
                    day: "Day 5", title: "Reminder", sub: "We ping you before"
                )
                Spacer()
                timelineStep(
                    glyph: "flag.checkered", color: Theme.Colors.mindTeal,
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
            Image(systemName: glyph)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
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
