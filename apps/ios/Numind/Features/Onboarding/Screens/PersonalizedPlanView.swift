import SwiftUI

/// Screen 19 — Personalized Plan (v2).
///
/// Three cards: the daily ring (anything counts), the path (focus pack core
/// skills with the readiness gates named), and the timeline — DATED when the
/// moment has a real deadline ("Ready around Oct 18, before Nov 1").
struct PersonalizedPlanView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("numind.userName") private var userName = "You"
    let onContinue: () -> Void

    private var minutesPerDay: Int { viewModel.signals.dailyMinutes ?? 10 }
    private var challengeCount: Int { viewModel.signals.dailyChallengeCount }
    private var packTitle: String { viewModel.focusPack?.title ?? "your focus" }
    private var coreCount: Int { max(viewModel.moneyMapRows.count, 3) }

    private var deadline: MomentsRegistry.Deadline? {
        guard let id = viewModel.signals.focusPackId else { return nil }
        return MomentsRegistry.nextDeadline(for: id)
    }

    private var readyDate: Date {
        MomentsRegistry.readyEstimate(coreSkillCount: coreCount)
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your plan")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.primaryBlue)
                            .padding(.top, 4)

                        Text("Your Numind Plan, \(userName)")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 10)

                        (Text("Goal: walk into ") +
                         Text(packTitle).fontWeight(.semibold).foregroundColor(Theme.Colors.deepNavy) +
                         Text(" prepared \u{2014} here\u{2019}s how we\u{2019}ll get there."))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(3)
                            .padding(.top, 8)

                        dailyRingCard
                            .padding(.top, 18)

                        Text("Your path")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 22)

                        pathCard
                            .padding(.top, 10)

                        timelineCard
                            .padding(.top, 22)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Start my plan") { onContinue() }
                }
            }
        }
    }

    // MARK: - Daily Ring Card

    private var dailyRingCard: some View {
        HStack(spacing: 18) {
            GoalRing(progress: 0.65, isClosed: false, size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily ring")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.6))
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(challengeCount) questions")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\u{2248} \(minutesPerDay) min")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }
                Text("Anything counts \u{2014} a workout, a lesson, a refresh.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Theme.Colors.deepNavy, Color(red: 0.11, green: 0.20, blue: 0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Theme.Colors.deepNavy.opacity(0.18), radius: 18, x: 0, y: 8)
    }

    // MARK: - Path Card

    private var pathCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(packTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                Text("\(coreCount) CORE SKILLS")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Colors.mindTeal)
            }

            VStack(alignment: .leading, spacing: 10) {
                gateRow(number: 1, text: "Learn each core skill", icon: "book")
                gateRow(number: 2, text: "Prove the hard ones", icon: "bolt")
                gateRow(number: 3, text: "Hold them over time", icon: "calendar")
                gateRow(number: 4, text: "Apply one to a real scenario", icon: "checkmark.seal")
            }

            Text("Clear all four and the pack reads Ready \u{2014} the honest kind.")
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .padding(18)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func gateRow(number: Int, text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryBlue)
                .frame(width: 24, height: 24)
                .background(Theme.Colors.primaryBlueTint)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.Colors.deepNavy)
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)
        }
    }

    // MARK: - Timeline Card

    private var timelineCard: some View {
        NumindCard {
            HStack(alignment: .top, spacing: 12) {
                Text("\u{1F4C5}")
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Timeline")
                        .font(Theme.Typography.small)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.mutedText)
                    Text(timelineHeadline)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(2)
                        .padding(.top, 2)
                    Text("Based on your pace and your diagnostic. \u{201C}On track\u{201D} \u{2014} Ready itself is earned, not scheduled.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .lineSpacing(2)
                        .padding(.top, 4)
                }
            }
        }
    }

    private var timelineHeadline: String {
        let readyText = readyDate.formatted(.dateTime.month(.wide).day())
        if let deadline {
            let deadlineText = deadline.date.formatted(.dateTime.month(.wide).day())
            if readyDate < deadline.date {
                return "\(deadline.label) \(deadlineText). At your pace, you\u{2019}re on track to be Ready around \(readyText)."
            }
            return "\(deadline.label) \(deadlineText) \u{2014} it\u{2019}s tight, so we\u{2019}ll front-load the core skills. Start today."
        }
        return "At your pace, you\u{2019}re on track to be Ready around \(readyText)."
    }
}

#Preview {
    PersonalizedPlanView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
