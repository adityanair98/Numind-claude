import SwiftUI

/// Screen 18 — Diagnostic Results
/// Shows starting level badge + per-topic breakdown.
struct DiagnosticResultsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private var overallLabel: String {
        DiagnosticCalibrator.overallLevel(difficulties: viewModel.signals.startingDifficulties)
    }

    private var overallNumber: Int {
        DiagnosticCalibrator.overallLevelNumber(difficulties: viewModel.signals.startingDifficulties)
    }

    private var levelSubtext: String {
        switch overallNumber {
        case 3:  return "Strong foundations \u{2014} let\u{2019}s take you further."
        case 1:  return "We\u{2019}ve built your perfect starting point."
        default: return "You\u{2019}ll move quickly with practice."
        }
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Diagnostic complete")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .padding(.top, 4)

                        Text("Here\u{2019}s where you stand")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 10)

                        Text("A starting picture \u{2014} not a verdict.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        // Summary card
                        summaryCard
                            .padding(.top, 22)

                        // Per-topic breakdown
                        Text("Your topics")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 22)

                        VStack(spacing: 10) {
                            ForEach(topicRows, id: \.name) { row in
                                topicRowView(row)
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("See my plan") { onContinue() }
                }
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Starting level")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.mutedText)
                Text(overallLabel)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(levelSubtext)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Spacer()
            levelBadge
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.Colors.cardBackground, Theme.Colors.primaryBlueTint],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var levelBadge: some View {
        VStack(spacing: 2) {
            Text("LVL")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .tracking(1)
            Text("\(overallNumber)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 64, height: 64)
        .background(Theme.Colors.primaryBlue)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Theme.Colors.primaryBlue.opacity(0.35), radius: 9, x: 0, y: 4)
    }

    // MARK: - Topic Rows

    private struct TopicRowData {
        let name: String
        let status: String
        let note: String
        let color: Color
        let glyph: String
        let fillCount: Int
    }

    private var topicRows: [TopicRowData] {
        let colorMap: [String: Color] = [
            "tips": Theme.Colors.mindTeal,
            "discounts": Theme.Colors.primaryBlue,
            "salary": Theme.Colors.warmOrange,
            "investing": Theme.Colors.investIndigo,
            "estimation": Theme.Colors.growthGreen,
            "debt": Theme.Colors.debtCoral,
        ]
        let nameMap: [String: String] = [
            "tips": "Tipping & %",
            "discounts": "Shopping & discounts",
            "salary": "Salary & income",
            "investing": "Returns & investing",
            "estimation": "Splitting & estimation",
            "debt": "Debt & interest",
        ]

        return viewModel.signals.topicInterests.sorted().compactMap { topicId in
            let difficulty = viewModel.signals.startingDifficulties[topicId] ?? .beginner
            let status: String
            let note: String
            let glyph: String
            let fill: Int

            switch difficulty {
            case .intermediate:
                status = "strong"
                note = "Strong foundations"
                glyph = "\u{2713}"
                fill = 5
            case .foundation:
                status = "work"
                note = "Needs work"
                glyph = "\u{21BB}"
                fill = 3
            case .beginner:
                status = "fresh"
                note = "Starting fresh"
                glyph = "\u{2726}"
                fill = 1
            }

            return TopicRowData(
                name: nameMap[topicId] ?? topicId.capitalized,
                status: status,
                note: note,
                color: colorMap[topicId] ?? Theme.Colors.primaryBlue,
                glyph: glyph,
                fillCount: fill
            )
        }
    }

    private func topicRowView(_ row: TopicRowData) -> some View {
        HStack(spacing: 12) {
            Text(row.glyph)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(row.color)
                .frame(width: 36, height: 36)
                .background(row.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(row.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(row.note)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }

            Spacer()

            // Bead bar
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < row.fillCount ? row.color : Theme.Colors.mutedTint)
                        .frame(width: 8, height: 16)
                }
            }
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
}

#Preview {
    DiagnosticResultsView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
