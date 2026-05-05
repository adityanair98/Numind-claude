import SwiftUI

/// Post-session insight screen shown after completing the daily challenge.
///
/// Displays the user's current Numind Score, a radar chart of per-module
/// performance (or bar chart if fewer than 3 modules have data), session
/// stats, and a recommended lesson for the weakest module.
struct DailyInsightView: View {

    // MARK: - Input

    struct ModuleScore: Identifiable {
        var id: String { module.id }
        let module: Module
        let score: Int          // 0–100 current
        let previousScore: Int? // 0–100 seven days ago, nil if no history
    }

    let overallScore: Int
    let scoreDelta: Int
    let moduleScores: [ModuleScore]

    let sessionCorrect: Int
    let sessionTotal: Int
    let sessionTimeString: String

    /// Weakest module's first recommended lesson, if any.
    let recommendedLesson: Lesson?

    let onContinue: () -> Void
    var onLearnWeakness: ((Lesson) -> Void)? = nil

    // MARK: - State

    @State private var scoreAnimated: Int = 0

    // MARK: - Derived

    private var weakestModule: ModuleScore? {
        moduleScores.min { $0.score < $1.score }
    }

    private var useRadar: Bool { moduleScores.count >= 3 }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    scoreSection
                    chartSection
                    if let weak = weakestModule { weaknessCard(weak) }
                    statsSection
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 24)
            }

            // CTA pinned to bottom
            ctaButton
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
                .background(
                    LinearGradient(
                        colors: [Theme.Colors.softBackground.opacity(0),
                                 Theme.Colors.softBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .ignoresSafeArea(),
                    alignment: .bottom
                )
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                scoreAnimated = overallScore
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Today's Insight")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text("Here's how your number sense is looking.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Score ring

    private var scoreSection: some View {
        VStack(spacing: 6) {
            NumindScoreRing(score: scoreAnimated, delta: scoreDelta, size: 130)

            if scoreDelta != 0 {
                Text(scoreDelta > 0
                     ? "Up \(scoreDelta) pts from last week 📈"
                     : "Down \(abs(scoreDelta)) pts from last week")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(scoreDelta > 0 ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Performance by module")

            if useRadar {
                radarView
            } else {
                barsView
            }
        }
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Theme.Colors.shadow.opacity(0.05), radius: 8, y: 4)
    }

    private var radarView: some View {
        let current = moduleScores.map {
            RadarChartView.Axis(label: $0.module.shortName,
                                value: Double($0.score) / 100.0)
        }
        let previous: [RadarChartView.Axis]? = moduleScores.allSatisfy({ $0.previousScore != nil })
            ? moduleScores.map {
                RadarChartView.Axis(label: $0.module.shortName,
                                    value: Double($0.previousScore!) / 100.0)
            }
            : nil

        return RadarChartView(axes: current, previousAxes: previous, size: 220)
            .frame(maxWidth: .infinity)
    }

    private var barsView: some View {
        ModuleBarsView(
            bars: moduleScores.map { ms in
                let color = ms.module.color.tintColor
                return ModuleBarsView.Bar(
                    icon: ms.module.icon,
                    label: ms.module.shortName,
                    score: ms.score,
                    color: color,
                    previousScore: ms.previousScore
                )
            }
        )
    }

    // MARK: - Weakness callout

    private func weaknessCard(_ weak: ModuleScore) -> some View {
        HStack(spacing: 14) {
            Text(weak.module.mascot)
                .font(.system(size: 30))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(weak.module.title) needs work")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Your weakest area right now. A quick lesson can fix it.")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)

                if let lesson = recommendedLesson {
                    Button {
                        onLearnWeakness?(lesson)
                    } label: {
                        Text("Try \"\(lesson.title)\" →")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(Theme.Colors.primaryBlueTint)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Session stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("This session")
            HStack(spacing: 12) {
                statPill(
                    icon: "checkmark.circle.fill",
                    value: "\(sessionCorrect)/\(sessionTotal)",
                    label: "correct",
                    color: Theme.Colors.growthGreen
                )
                statPill(
                    icon: "clock.fill",
                    value: sessionTimeString,
                    label: "time",
                    color: Theme.Colors.primaryBlue
                )
                statPill(
                    icon: "flame.fill",
                    value: "\(sessionCorrect * 10) XP",
                    label: "earned",
                    color: Theme.Colors.insightYellow
                )
            }
        }
    }

    private func statPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Theme.Colors.shadow.opacity(0.04), radius: 6, y: 3)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button(action: onContinue) {
            Text("Done")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Theme.Colors.primaryBlue,
                                 Theme.Colors.mindTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.6)
    }
}

// MARK: - Preview

#Preview {
    let modules = LocalContentRepository().allModules()
    let scores = modules.prefix(6).map { m in
        DailyInsightView.ModuleScore(
            module: m,
            score: Int.random(in: 30...90),
            previousScore: Int.random(in: 20...80)
        )
    }
    let lesson = LocalContentRepository()
        .lessons(for: modules.first!.id).first

    DailyInsightView(
        overallScore: 68,
        scoreDelta: 7,
        moduleScores: Array(scores),
        sessionCorrect: 7,
        sessionTotal: 10,
        sessionTimeString: "02:34",
        recommendedLesson: lesson,
        onContinue: {},
        onLearnWeakness: { _ in }
    )
}
