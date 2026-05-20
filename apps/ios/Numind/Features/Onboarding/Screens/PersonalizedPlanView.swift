import SwiftUI

/// Screen 19 — Personalized Plan
/// Shows daily goal, focus areas with progress bars, timeline.
struct PersonalizedPlanView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("numind.userName") private var userName = "You"
    let onContinue: () -> Void

    private var minutesPerDay: Int { viewModel.signals.dailyMinutes ?? 10 }
    private var challengeCount: Int { viewModel.signals.dailyChallengeCount }

    private var aspirationText: String {
        switch viewModel.signals.aspiration {
        case .tipInstantly:       return "tip in your head instantly"
        case .confidentWithMoney: return "feel confident with money decisions"
        case .spotGoodDeals:      return "spot good deals effortlessly"
        case .fasterThanPhone:    return "do mental math faster than your phone"
        case nil:                 return "build your everyday math skills"
        }
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

                        (Text("You said you want to ") +
                         Text(aspirationText).fontWeight(.semibold).foregroundColor(Theme.Colors.deepNavy) +
                         Text(" \u{2014} here\u{2019}s how we\u{2019}ll get there."))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineSpacing(3)
                            .padding(.top, 8)

                        // Hero plan card
                        dailyGoalCard
                            .padding(.top, 18)

                        // Focus areas
                        Text("Focus areas")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 22)

                        VStack(spacing: 10) {
                            ForEach(focusRows, id: \.name) { row in
                                focusRowView(row)
                            }
                        }
                        .padding(.top, 10)

                        // Timeline card
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

    // MARK: - Daily Goal Card

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Daily goal")
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(.white.opacity(0.6))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(minutesPerDay) min")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("/ day")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.insightYellow)
            }
            .padding(.top, 6)

            Text("~\(challengeCount) questions \u{00B7} resets at midnight")
                .font(Theme.Typography.caption)
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
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

    // MARK: - Focus Rows

    private struct FocusRowData: Identifiable {
        var id: String { name }
        let name: String
        let target: String
        let color: Color
        let progress: Double
    }

    private let colorMap: [String: Color] = [
        "tips": Theme.Colors.mindTeal,
        "discounts": Theme.Colors.primaryBlue,
        "salary": Theme.Colors.warmOrange,
        "investing": Theme.Colors.investIndigo,
        "estimation": Theme.Colors.growthGreen,
        "debt": Theme.Colors.debtCoral,
    ]

    private let nameMap: [String: String] = [
        "tips": "Tipping & percentages",
        "discounts": "Shopping & discounts",
        "salary": "Salary & income",
        "investing": "Returns & investing",
        "estimation": "Splitting & estimation",
        "debt": "Debt & interest rates",
    ]

    private var focusRows: [FocusRowData] {
        viewModel.signals.recommendationPriority.prefix(4).enumerated().map { index, topicId in
            let difficulty = viewModel.signals.startingDifficulties[topicId] ?? .beginner
            let target: String
            let progress: Double
            switch difficulty {
            case .intermediate: target = "from Strong \u{2192} Mastery"; progress = 0.4
            case .foundation:   target = "from Needs Work \u{2192} Strong"; progress = 0.18
            case .beginner:     target = "Starting fresh"; progress = 0.05
            }
            return FocusRowData(
                name: nameMap[topicId] ?? topicId.capitalized,
                target: target,
                color: colorMap[topicId] ?? Theme.Colors.primaryBlue,
                progress: progress
            )
        }
    }

    private func focusRowView(_ row: FocusRowData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(row.color)
                    .frame(width: 8, height: 8)
                Text(row.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                Text(row.target)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.Colors.mutedTint)
                    Capsule()
                        .fill(row.color)
                        .frame(width: geo.size.width * row.progress)
                }
            }
            .frame(height: 6)
            .clipShape(Capsule())
        }
        .padding(14)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    // MARK: - Timeline Card

    private var timelineCard: some View {
        NumindCard {
            HStack(alignment: .top, spacing: 12) {
                Text("\u{1F3AF}")
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
                    Text("In 30 days, you\u{2019}ll \(aspirationText).")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(2)
                        .padding(.top, 2)
                    Text("Based on your time commitment + diagnostic.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 4)
                }
            }
        }
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
