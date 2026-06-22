import SwiftUI

/// Post-session insight screen shown after completing the Daily Workout
/// (formerly Daily Challenge).
///
/// Displays the daily ring + skills that moved this session, a 7-axis
/// performance radar (or bar chart if fewer than 3 axes have evidence),
/// session stats, and a recommended lesson for the weakest measured axis.
///
/// Phase 10 retired the visible Level/XP headline for the goal ring +
/// capability language; the radar survives as a per-session diagnostic over
/// `NumindScoreEngine.axisResults`.
struct DailyInsightView: View {

    // MARK: - Input

    /// One row in the axis chart: current score + evidence + optional prior.
    struct AxisScore: Identifiable {
        var id: String { axis.rawValue }
        let axis: SkillAxis
        let score: Int                // 0–100 current
        let evidence: EvidenceLevel   // determines visibility on the chart
        let previousScore: Int?       // 0–100 seven days ago, nil if no history
    }

    /// Daily ring fill (0–1) after this session.
    let ringProgress: Double
    /// Whether today's ring closed (the day counts toward the streak).
    let ringClosed: Bool
    /// Skills whose state changed this session ("Net pay — Mastered").
    let skillsMoved: [SkillMove]
    let axisScores: [AxisScore]

    /// SkillAxis values that appeared in this session's question set.
    /// The weakness card is scoped to these axes only.
    let sessionAxes: Set<SkillAxis>

    let sessionCorrect: Int
    let sessionTotal: Int
    let sessionTimeString: String

    /// Weakest axis's first recommended lesson, if any.
    let recommendedLesson: Lesson?

    let onContinue: () -> Void
    var onLearnWeakness: ((Lesson) -> Void)? = nil

    // MARK: - Derived

    /// Visible axes — only ones with at least Early Read evidence get a
    /// non-zero radar value; Untested axes still render as dim spokes
    /// (handled by mapping value to 0). For the weakness/recommendation
    /// logic, we filter to measured axes only.
    private var measuredAxes: [AxisScore] {
        axisScores.filter { $0.evidence != .notStarted && $0.score > 0 }
    }

    /// Weakest axis from the session's axis set — not overall.
    /// Only shows when ≥2 session axes have measurable scores to compare.
    private var weakestAxis: AxisScore? {
        let touched = measuredAxes.filter { sessionAxes.contains($0.axis) }
        guard touched.count > 1 else { return nil }
        return touched.min { $0.score < $1.score }
    }

    private var useRadar: Bool { axisScores.count >= 3 }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                // Radar/score chart retired from the post-session surface — it's
                // a private coverage diagnostic, not a celebration (Phase 10/13).
                // The calm ring + skill moves lead, like the lesson summary.
                VStack(spacing: 24) {
                    header
                    scoreSection
                    if let weak = weakestAxis { weaknessCard(weak) }
                    statsSection
                    Spacer(minLength: 120)
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
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Today's Insight")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text("Here's how your money sense is looking.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Daily ring (Phase 10)

    private var scoreSection: some View {
        VStack(spacing: 10) {
            GoalRing(progress: ringProgress, isClosed: ringClosed, size: 130)

            Text(ringClosed ? "Ring closed — today counts toward your streak" : "Keep going to close today's ring")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ringClosed ? Theme.Colors.growthGreen : Theme.Colors.mutedText)

            if !skillsMoved.isEmpty {
                VStack(spacing: 6) {
                    ForEach(skillsMoved) { move in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("\(move.title) — Mastered")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(Theme.Colors.mindTeal)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Performance by skill")

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
        // Untested axes render as 0 (dim spoke), preserving the 7-axis shape.
        let current = axisScores.map { row in
            RadarChartView.Axis(
                label: row.axis.shortName,
                value: row.evidence == .notStarted ? 0 : Double(row.score) / 100.0
            )
        }
        let previous: [RadarChartView.Axis]? =
            axisScores.allSatisfy({ $0.previousScore != nil })
            ? axisScores.map { row in
                RadarChartView.Axis(
                    label: row.axis.shortName,
                    value: Double(row.previousScore ?? 0) / 100.0
                )
            }
            : nil

        return RadarChartView(axes: current, previousAxes: previous, size: 220)
            .frame(maxWidth: .infinity)
    }

    private var barsView: some View {
        ModuleBarsView(
            bars: axisScores.map { row in
                ModuleBarsView.Bar(
                    icon: skillIcon(row.axis),
                    label: row.axis.shortName,
                    score: row.score,
                    color: skillColor(row.axis),
                    previousScore: row.previousScore
                )
            }
        )
    }

    /// Per-axis SF Symbol — matched to the dominant module color theme for
    /// the axis (Debt = coral exclamation, Investing = green chart, etc.).
    private func skillIcon(_ axis: SkillAxis) -> String {
        switch axis {
        case .everydayMoneyMath:    return "function"
        case .cashFlowAndBudgeting: return "list.bullet.rectangle"
        case .incomeAndPaycheck:    return "creditcard.fill"
        case .debtAndCredit:        return "exclamationmark.triangle.fill"
        case .bigPurchases:         return "house.fill"
        case .protectionAndBenefits: return "heart.text.square.fill"
        case .investingAndFuture:   return "chart.line.uptrend.xyaxis"
        }
    }

    private func skillColor(_ axis: SkillAxis) -> Color {
        switch axis {
        case .everydayMoneyMath:    return Theme.Colors.warmOrange
        case .cashFlowAndBudgeting: return Theme.Colors.primaryBlue
        case .incomeAndPaycheck:    return Theme.Colors.mindTeal
        case .debtAndCredit:        return Theme.Colors.debtCoral
        case .bigPurchases:         return Theme.Colors.housingRose
        case .protectionAndBenefits: return Theme.Colors.insurancePurple
        case .investingAndFuture:   return Theme.Colors.growthGreen
        }
    }

    // MARK: - Weakness callout

    private func weaknessCard(_ weak: AxisScore) -> some View {
        HStack(spacing: 14) {
            Image(systemName: skillIcon(weak.axis))
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(skillColor(weak.axis))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text("Focus next: \(weak.axis.displayName)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Your biggest opportunity right now. A quick lesson sharpens it.")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)

                if let lesson = recommendedLesson {
                    Button {
                        onLearnWeakness?(lesson)
                    } label: {
                        Text("Try \"\(lesson.title)\" →")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.mindTeal)
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
                    icon: "list.number",
                    value: "\(sessionTotal)",
                    label: "questions",
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
                .font(.system(size: 15, weight: .bold, design: .monospaced))
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
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.Colors.ctaLabel)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Theme.Colors.ctaFill)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Theme.Colors.shadow.opacity(0.15), radius: 12, y: 6)
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
    let axes = SkillAxis.allCases.map { axis in
        DailyInsightView.AxisScore(
            axis: axis,
            score: Int.random(in: 30...90),
            evidence: .developing,
            previousScore: Int.random(in: 20...80)
        )
    }
    let modules = LocalContentRepository().allModules()
    let lesson = LocalContentRepository()
        .lessons(for: modules.first!.id).first

    DailyInsightView(
        ringProgress: 1.0,
        ringClosed: true,
        skillsMoved: [SkillMove(title: "Gross vs net", change: .mastered)],
        axisScores: axes,
        sessionAxes: Set(SkillAxis.allCases.prefix(4)),
        sessionCorrect: 7,
        sessionTotal: 10,
        sessionTimeString: "02:34",
        recommendedLesson: lesson,
        onContinue: {},
        onLearnWeakness: { _ in }
    )
}
