import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    private let modules = LocalContentRepository().allModules()
    private let repo = LocalContentRepository()
    private let weekDayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    @State private var ringProgress: Double = 0
    @State private var showProfile = false

    var body: some View {
        Group {
            if store.totalSessions == 0 {
                emptyState
            } else {
                filledContent
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showProfile = false }
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                        }
                    }
            }
            .environmentObject(store)
        }
        .onAppear {
            let target = min(Double(store.streak), 7) / 7.0
            withAnimation(.easeOut(duration: 0.9)) {
                ringProgress = target
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Header
    // ═══════════════════════════════════════════════════════════════

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()
                Button {
                    showProfile = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.cardBackground)
                            .frame(width: 36, height: 36)
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .buttonStyle(.plain)
            }

            Text("Progress")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressHeader
                Spacer(minLength: 80)
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryBlueTint)
                        .frame(width: 96, height: 96)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.Colors.primaryBlue)
                }
                VStack(spacing: 8) {
                    Text("No sessions yet")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Complete your first lesson to\nsee your progress here.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                Spacer(minLength: 100)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Filled content

    private var filledContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                progressHeader

                // Your Improvement (only shows positive stats)
                improvementCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 18)

                streakHeroCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 18)

                // Numind Score + radar chart
                numindScoreSection
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                sectionLabel("Weekly goal")
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 10)
                weeklyGoalCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                sectionLabel("Weekly XP")
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 10)
                weeklyXPCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                // Paths in progress — shows packs the user has touched but
                // not yet finished, with a thin progress bar each. Hidden
                // entirely when there's nothing in progress.
                let inProgressPacks = store.inProgressPacks
                if !inProgressPacks.isEmpty {
                    sectionLabel("Paths in progress")
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 10)
                    pathsInProgressCard(packs: inProgressPacks)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 22)
                }

                HStack(alignment: .firstTextBaseline) {
                    sectionLabel("Skill mastery")
                    Spacer()
                    NavigationLink(destination: SkillDetailView()) {
                        Text("See all")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 10)
                skillMasteryCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                let recent = store.recentSessions(limit: 5)
                if !recent.isEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        sectionLabel("Recent activity")
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 10)
                    recentActivityCard(sessions: recent)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 22)
                }

                sectionLabel("Badges")
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 10)
                badgesGrid
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 40)
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Numind Score + Radar
    // ═══════════════════════════════════════════════════════════════

    private var numindScoreSection: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NUMIND SCORE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .kerning(0.6)
                        Text(store.numindScore > 0 ? store.numindSubtitle : "Your overall number sense")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    NumindScoreRing(score: store.numindScore,
                                   delta: store.numindScoreDelta,
                                   size: 76)
                }

                Divider().background(Theme.Colors.hairline)

                // 7-axis radar (Phase 5d). Replaces the per-module radar.
                // Untested axes render as 0 — RadarChartView already handles
                // the dimmed-spoke visual via the value being 0.
                let axisResults = store.numindAxisResults
                let current = axisResults.map { r in
                    RadarChartView.Axis(
                        label: r.axis.shortName,
                        value: r.evidence == .untested ? 0 : Double(r.score) / 100.0
                    )
                }
                RadarChartView(axes: current, previousAxes: nil, size: 220)
                    .frame(maxWidth: .infinity)

                // Per-axis evidence labels — small text under the chart so
                // users see which axes are "Reliable" vs "Early Read" etc.
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(axisResults, id: \.axis) { r in
                        HStack {
                            Text(r.axis.shortName)
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.deepNavy.opacity(r.evidence == .untested ? 0.45 : 1.0))
                            Spacer()
                            Text(r.evidence.label)
                                .font(Theme.Typography.small)
                                .foregroundStyle(evidenceColor(r.evidence))
                        }
                    }
                }
                .padding(.top, 4)

                if store.numindScore == 0 {
                    Text("Complete your first lesson to see your Numind Score.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Your Improvement
    // ═══════════════════════════════════════════════════════════════

    @ViewBuilder
    private var improvementCard: some View {
        let stats = ImprovementCalculator.compute(from: store.data, scoreDelta: store.numindScoreDelta)
        let speedUp = ImprovementCalculator.speedImprovement(stats)
        let accUp = ImprovementCalculator.accuracyImprovement(stats)
        let hasPositive = speedUp != nil || accUp != nil || stats.scoreDelta > 0 || stats.skillsMastered > 0

        if hasPositive {
            NumindCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.growthGreen)
                        Text("YOUR IMPROVEMENT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .kerning(0.6)
                    }

                    // 2-column grid of positive stats
                    let items = buildImprovementItems(stats: stats, speedUp: speedUp, accUp: accUp)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(items, id: \.label) { item in
                            improvementStatView(item)
                        }
                    }
                }
            }
        }
    }

    private struct ImprovementItem {
        let icon: String
        let value: String
        let label: String
        let color: Color
    }

    private func buildImprovementItems(
        stats: ImprovementCalculator.Stats,
        speedUp: Int?,
        accUp: Int?
    ) -> [ImprovementItem] {
        var items: [ImprovementItem] = []

        if let pct = speedUp {
            items.append(ImprovementItem(
                icon: "bolt.fill",
                value: "\(pct)% faster",
                label: "Response speed",
                color: Theme.Colors.primaryBlue
            ))
        }

        if let pct = accUp {
            items.append(ImprovementItem(
                icon: "target",
                value: "+\(pct)%",
                label: "Accuracy",
                color: Theme.Colors.mindTeal
            ))
        }

        if stats.scoreDelta > 0 {
            items.append(ImprovementItem(
                icon: "chart.line.uptrend.xyaxis",
                value: "+\(stats.scoreDelta) pts",
                label: "Numind Score",
                color: Theme.Colors.growthGreen
            ))
        }

        if stats.skillsMastered > 0 {
            items.append(ImprovementItem(
                icon: "checkmark.seal.fill",
                value: "\(stats.skillsMastered)",
                label: "Skills mastered",
                color: Theme.Colors.warmOrange
            ))
        }

        return items
    }

    private func improvementStatView(_ item: ImprovementItem) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(item.color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(item.value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(item.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Spacer(minLength: 0)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Streak Hero Card
    // ═══════════════════════════════════════════════════════════════

    private var streakHeroCard: some View {
        HeroCard(variant: .navy) {
            HStack(spacing: 14) {
                // Streak ring (116pt)
                streakRingLarge
                    .frame(width: 116, height: 116)

                VStack(alignment: .leading, spacing: 0) {
                    // Personal Best pill
                    if store.streak >= store.bestStreak && store.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.Colors.insightYellow)
                            Text("PERSONAL BEST")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(Theme.Colors.insightYellow)
                                .tracking(0.5)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Colors.insightYellow.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.bottom, 6)
                    }

                    // Streak tier message
                    Text(streakTierMessage)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .padding(.bottom, 2)

                    Text("Best ever: \(store.bestStreak) days")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 12)

                    // Inline stats
                    HStack(spacing: 0) {
                        inlineStat(value: "\(store.totalXP)", label: "Total XP")
                        statDivider
                        inlineStat(value: store.totalSessions > 0 ? "\(Int(store.accuracy * 100))%" : "\u{2014}", label: "Accuracy")
                        statDivider
                        inlineStat(value: "\(store.totalSessions)", label: "Sessions")
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var streakRingLarge: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: 9)

            // Gradient progress ring
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    AngularGradient(
                        colors: [Theme.Colors.insightYellow, Theme.Colors.warmOrange, Theme.Colors.insightYellow],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Day tick marks
            ForEach(0..<7, id: \.self) { i in
                let angle = Double(i) / 7.0 * 360.0 - 90.0
                let radians = angle * .pi / 180.0
                let r1: CGFloat = 40
                let r2: CGFloat = 44
                Path { path in
                    path.move(to: CGPoint(
                        x: 58 + cos(radians) * r1,
                        y: 58 + sin(radians) * r1
                    ))
                    path.addLine(to: CGPoint(
                        x: 58 + cos(radians) * r2,
                        y: 58 + sin(radians) * r2
                    ))
                }
                .stroke(.white.opacity(0.25), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 116, height: 116)
            }

            // Center content
            VStack(spacing: 2) {
                Text("\u{1F525}")
                    .font(.system(size: 22))
                Text("\(store.streak)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("DAYS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.5)
            }
        }
    }

    private var streakTierMessage: String {
        let streak = store.streak
        if streak >= 7 { return "You're on fire \u{1F525}" }
        if streak >= 3 { return "Nice rhythm" }
        if streak >= 1 { return "Building momentum" }
        return "Start your streak!"
    }

    private func inlineStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.55))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.15))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 4)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Weekly Goal
    // ═══════════════════════════════════════════════════════════════

    private var weeklyGoalCard: some View {
        let done = store.weeklyWorkouts
        let goal = store.weeklyGoal
        let remaining = max(0, goal - done)
        let reached = done >= goal
        let todayIndex = Calendar.current.component(.weekday, from: Date())
        // Convert Sunday=1..Saturday=7 to Monday=0..Sunday=6
        let todayMon = (todayIndex + 5) % 7

        return VStack(spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(done) of \(goal) workouts")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(reached ? "Goal reached \u{2014} great work!" : "\(remaining) more to hit your goal")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.Colors.insightYellowTint)
                        .frame(width: 38, height: 38)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }
            }

            HStack(spacing: 6) {
                ForEach(Array(weekDayLabels.enumerated()), id: \.offset) { i, label in
                    let isDone = store.weeklyCompletions.indices.contains(i)
                        ? store.weeklyCompletions[i] : false
                    let isToday = i == todayMon

                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isDone ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                                .frame(height: 32)
                                .shadow(
                                    color: isDone ? Theme.Colors.primaryBlue.opacity(0.3) : .clear,
                                    radius: isDone ? 4 : 0, y: 2
                                )
                            if !isDone && isToday {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Theme.Colors.primaryBlue, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                                    .frame(height: 32)
                            }
                            if isDone {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            } else if isToday {
                                Circle()
                                    .fill(Theme.Colors.primaryBlue)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        Text(label)
                            .font(.system(size: 10, weight: isToday ? .heavy : .medium))
                            .foregroundStyle(isToday ? Theme.Colors.primaryBlue : Theme.Colors.mutedText)
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Weekly XP
    // ═══════════════════════════════════════════════════════════════

    private var weeklyXPCard: some View {
        let weeks = store.weeklyXPHistory()
        let maxXP = max(1, weeks.map { $0.xp }.max() ?? 1)
        let currentXP = weeks.last?.xp ?? 0
        let rank = weeks.filter { $0.xp > currentXP }.count + 1
        let isBestEver = currentXP > 0 && weeks.dropLast().allSatisfy { $0.xp < currentXP }
        let maxBarHeight: CGFloat = 92

        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentXP > 0
                         ? "Ranked #\(rank) of last 4 weeks"
                         : "No XP yet this week")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    HStack(spacing: 0) {
                        Text("\(currentXP) XP")
                            .font(Theme.Typography.small)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.primaryBlue)
                        Text(" this week")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                Spacer()
                if isBestEver {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Best week!")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.4)
                    }
                    .foregroundStyle(Theme.Colors.insightText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(Capsule())
                }
            }

            // Bar chart
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    VStack(spacing: 4) {
                        Text(week.xp > 0 ? "\(week.xp)" : "")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                week.isCurrent ? Theme.Colors.primaryBlue : Theme.Colors.mutedText
                            )
                            .frame(height: 14)

                        let barH: CGFloat = week.xp == 0
                            ? 4
                            : max(14, CGFloat(week.xp) / CGFloat(maxXP) * maxBarHeight)

                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    week.isCurrent
                                        ? LinearGradient(
                                            colors: [Theme.Colors.primaryBlue, Color(red: 0.14, green: 0.34, blue: 0.83)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                          )
                                        : LinearGradient(colors: [Theme.Colors.mutedTint], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(height: barH)
                                .shadow(
                                    color: week.isCurrent ? Theme.Colors.primaryBlue.opacity(0.35) : .clear,
                                    radius: week.isCurrent ? 7 : 0, y: 3
                                )

                            // Highlight strip on current bar
                            if week.isCurrent && barH > 10 {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.white.opacity(0.35))
                                    .frame(height: 6)
                            }
                        }

                        Text(week.label)
                            .font(.system(size: 10, weight: week.isCurrent ? .bold : .regular))
                            .foregroundStyle(
                                week.isCurrent ? Theme.Colors.deepNavy : Theme.Colors.mutedText
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: maxBarHeight + 14 + 4 + 16 + 4)
        }
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Paths in progress
    // ═══════════════════════════════════════════════════════════════

    /// Shows each in-progress pack as a row with title + tagline +
    /// `done / total · ▓▓▓░░` progress bar. Read-only; tapping a row is
    /// out of scope here (use Home or the Learn → Paths tab).
    private func pathsInProgressCard(packs: [Pack]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(packs.enumerated()), id: \.element.id) { i, pack in
                pathProgressRow(pack: pack, isLast: i == packs.count - 1)
            }
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    private func pathProgressRow(pack: Pack, isLast: Bool) -> some View {
        let progress = store.packProgress(packId: pack.id)
        let isFocus = store.focusPackId == pack.id
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(pack.title)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                if isFocus {
                    Text("FOCUS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.deepNavy)
                        .clipShape(Capsule())
                }
                Text("\(progress.done) of \(progress.total)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            BeadRail(progress: progress.done, total: progress.total, variant: .chunky)
            if !isLast {
                Divider()
                    .background(Theme.Colors.hairline)
            }
        }
        .padding(Theme.Spacing.cardPadding)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Skill Mastery (milestone dots)
    // ═══════════════════════════════════════════════════════════════

    private var skillMasteryCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(modules.enumerated()), id: \.element.id) { i, module in
                skillMasteryRow(module: module, isLast: i == modules.count - 1)
            }
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    private func skillMasteryRow(module: Module, isLast: Bool) -> some View {
        let accent = module.color.tintColor
        let level = store.skillLevel(moduleId: module.id)
        let progress = store.skillLevelProgress(moduleId: module.id)

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Mascot emoji tile
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(accent.opacity(0.2), lineWidth: 1)
                        )
                    Text(module.mascot)
                        .font(.system(size: 22))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(module.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineLimit(1)
                        Spacer()
                        Text(level > 0 ? "LVL \(level)" : "\u{2014}")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(level > 0 ? accent : Theme.Colors.mutedText)
                            .tracking(0.4)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(level > 0 ? accent.opacity(0.14) : Theme.Colors.mutedTint)
                            .clipShape(Capsule())
                    }

                    // Milestone dots (5 levels)
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { k in
                            let reached = k < level
                            let inProgress = k == level && progress > 0

                            Circle()
                                .fill(reached ? accent : Theme.Colors.mutedTint)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .strokeBorder(inProgress ? accent : .clear, lineWidth: 2)
                                )

                            if k < 4 {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Theme.Colors.mutedTint)
                                        Capsule()
                                            .fill(accent)
                                            .frame(width: geo.size.width * CGFloat(
                                                reached ? 1.0 : (inProgress ? progress : 0)
                                            ))
                                    }
                                }
                                .frame(height: 3)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            if !isLast {
                Divider()
                    .padding(.leading, 16 + 40 + 12)
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Badges
    // ═══════════════════════════════════════════════════════════════

    private var badgesGrid: some View {
        let earned = store.data.earnedBadgeIds
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        return VStack(alignment: .leading, spacing: 10) {
            Text("\(earned.count) of \(BadgeCatalog.all.count) unlocked")
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(BadgeCatalog.all) { badge in
                    badgeCell(badge, isEarned: earned.contains(badge.id))
                }
            }
            .padding(16)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
        }
    }

    private func badgeCell(_ badge: Badge, isEarned: Bool) -> some View {
        let tierColor = badgeTierColor(badge.tier)

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        isEarned
                            ? RadialGradient(
                                colors: [tierColor.opacity(0.4), tierColor.opacity(0.18)],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 28
                              )
                            : RadialGradient(colors: [Theme.Colors.mutedTint], center: .center, startRadius: 0, endRadius: 28)
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isEarned ? tierColor : Theme.Colors.hairline,
                                lineWidth: isEarned ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isEarned ? tierColor.opacity(0.3) : .clear,
                        radius: isEarned ? 7 : 0, y: 3
                    )

                Image(systemName: isEarned ? badge.icon : "lock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isEarned ? tierColor : Theme.Colors.mutedText.opacity(0.5))

                // Earned checkmark
                if isEarned {
                    ZStack {
                        Circle()
                            .fill(tierColor)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle().stroke(.white, lineWidth: 2)
                            )
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 18, y: 18)
                }
            }

            Text(badge.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isEarned ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 80)
        }
    }

    private func badgeTierColor(_ tier: BadgeTier) -> Color {
        switch tier {
        case .bronze: return Color(red: 0.78, green: 0.50, blue: 0.20)
        case .silver: return Theme.Colors.mindTeal
        case .gold:   return Theme.Colors.insightYellow
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Recent Activity
    // ═══════════════════════════════════════════════════════════════

    private func recentActivityCard(sessions: [SessionRecord]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(sessions.enumerated()), id: \.element.id) { i, session in
                recentRow(session, isLast: i == sessions.count - 1)
            }
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    private func recentRow(_ session: SessionRecord, isLast: Bool) -> some View {
        let module = modules.first { $0.id == session.moduleId }
        let lesson = repo.lessons(for: session.moduleId).first { $0.id == session.lessonId }
        let accuracy = Int(Double(session.correctCount) / Double(max(session.totalCount, 1)) * 100)
        let accent = module?.color.tintColor ?? Theme.Colors.primaryBlue

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Mascot emoji tile
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .strokeBorder(accent.opacity(0.2), lineWidth: 1)
                        )
                    Text(module?.mascot ?? "\u{1F4DA}")
                        .font(.system(size: 19))
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 1) {
                    Text(lesson?.title ?? session.lessonId)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineLimit(1)
                    Text(relativeDate(session.date))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.Colors.mutedText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(session.correctCount)/\(session.totalCount)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("\(accuracy)%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(accuracy >= 80
                                         ? Theme.Colors.mindTeal
                                         : Theme.Colors.warmOrange)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            if !isLast {
                Divider()
                    .padding(.leading, 16 + 36 + 12)
            }
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date)     { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    // MARK: - Helpers

    private func evidenceColor(_ level: EvidenceLevel) -> Color {
        switch level {
        case .untested:   return Theme.Colors.mutedText.opacity(0.55)
        case .earlyRead:  return Theme.Colors.warmOrange
        case .developing: return Theme.Colors.primaryBlue
        case .reliable:   return Theme.Colors.growthGreen
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(Theme.Colors.mutedText)
            .tracking(1.2)
    }
}

#Preview {
    NavigationStack {
        ProgressTabView()
            .environmentObject(ProgressStore())
    }
}
