import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var launchCard: HomeViewModel.LessonCard?
    @State private var dailyVM: QuizSessionViewModel? = nil
    @State private var bonusRoundVM: QuizSessionViewModel? = nil
    @State private var showSpeedDrill = false
    @State private var blitzVM: BlitzViewModel? = nil
    @State private var streakVM: StreakViewModel? = nil
    @State private var estimationVM: EstimationViewModel? = nil
    @State private var comparisonVM: ComparisonViewModel? = nil
    // insightLesson is now computed inline in insightView(for:) from the session's modules
    @State private var showInsight = false
    @State private var insightSessionVM: QuizSessionViewModel? = nil   // retained while sheet shows
    @State private var lastDailyCorrectCount: Int = 0
    @State private var showScoreDetail = false
    @State private var showPackPicker = false
    @State private var presentedPack: Pack?
    @AppStorage("numind.userName") private var userName = "You"

    private let repo = LocalContentRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                BrandHeader(
                    name: userName,
                    isDailyChallengeCompleted: progressStore.isDailyChallengeCompleted,
                    numindScore: progressStore.numindScore,
                    onScoreTap: { showScoreDetail = true }
                )
                dailyChallengeSection
                streakSection
                workoutSection
                packSection
                modesSection
                if let card = viewModel.continueCard {
                    continueSection(card)
                }
                if !viewModel.upNextCards.isEmpty {
                    upNextSection
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        // Lesson launch
        .fullScreenCover(item: $launchCard) { card in
            LessonView(viewModel: LessonViewModel(
                lesson: card.lesson,
                moduleTitle: card.module.title,
                lessonIndex: card.lessonIndex,
                totalLessons: card.totalLessons,
                moduleColor: card.module.color
            ))
        }
        // Daily challenge launch
        .fullScreenCover(item: $dailyVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    recordMixedSession(
                        vm: vm, lessonId: "daily_challenge"
                    )
                    lastDailyCorrectCount = vm.correctCount
                    progressStore.markDailyChallengeCompleted()
                    insightSessionVM = vm
                    dailyVM = nil
                    showInsight = true
                }
            }
        }
        // Post-daily-challenge insight sheet
        .sheet(isPresented: $showInsight, onDismiss: {
            insightSessionVM = nil
            viewModel.refresh(using: progressStore)
        }) {
            if let vm = insightSessionVM {
                insightView(for: vm)
            }
        }
        // Bonus round launch
        .fullScreenCover(item: $bonusRoundVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    recordMixedSession(
                        vm: vm, lessonId: "bonus_round"
                    )
                    bonusRoundVM = nil
                }
            }
        }
        // Speed Drill launch
        .fullScreenCover(isPresented: $showSpeedDrill) {
            SpeedDrillView()
                .environmentObject(progressStore)
        }
        // Blitz launch
        .fullScreenCover(item: $blitzVM) { vm in
            BlitzView(viewModel: vm) {
                BlitzEngine.generateQuestionQueue(from: progressStore.data)
            }
            .environmentObject(progressStore)
        }
        // Streak launch
        .fullScreenCover(item: $streakVM) { vm in
            StreakView(
                viewModel: vm,
                generateQuestions: { generateMCQQuestions(count: 40) }
            )
            .environmentObject(progressStore)
        }
        // Estimation launch
        .fullScreenCover(item: $estimationVM) { vm in
            EstimationView(viewModel: vm)
                .environmentObject(progressStore)
        }
        // Comparison launch
        .fullScreenCover(item: $comparisonVM) { vm in
            ComparisonView(viewModel: vm)
                .environmentObject(progressStore)
        }
        // Score detail sheet
        .sheet(isPresented: $showScoreDetail) {
            scoreDetailSheet
        }
        // Pack picker sheet
        .sheet(isPresented: $showPackPicker) {
            PackPickerSheet()
                .environmentObject(progressStore)
        }
        // Single pack detail (tapped from Home cards or carousel)
        .sheet(item: $presentedPack) { pack in
            PackDetailView(pack: pack)
                .environmentObject(progressStore)
        }
        // Celebration queue — pops the next pending celebration after any
        // session that completes a pack or world. Sequential by FIFO.
        .sheet(item: Binding(
            get: { progressStore.pendingCelebrations.first },
            set: { _ in _ = progressStore.popCelebration() }
        )) { celebration in
            switch celebration {
            case .packCompleted(let pack):
                PackCompletionSheet(pack: pack)
                    .environmentObject(progressStore)
            case .worldCompleted(let module):
                WorldCompletionSheet(module: module)
            }
        }
        .onAppear {
            viewModel.refresh(using: progressStore)
            lastDailyCorrectCount = progressStore.todayDailyChallengeCorrectCount
        }
        .onChange(of: progressStore.totalSessions) { _, _ in
            viewModel.refresh(using: progressStore)
        }
    }

    // MARK: - Score detail sheet

    private var scoreDetailSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Tier hero banner + large ring
                    tierHeroBanner
                        .padding(.top, 4)

                    // 4-node progression ladder
                    tierProgressionStrip

                    // Radar / bar chart
                    scoreChartCard

                    // Per-module breakdown
                    moduleBreakdownCard
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, 12)
            }
            .background(Theme.Colors.softBackground.ignoresSafeArea())
            .navigationTitle("Numind Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showScoreDetail = false }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.primaryBlue)
                }
            }
        }
    }

    // MARK: - Tier hero banner

    private var tierHeroBanner: some View {
        let tier = ScoreTier(score: progressStore.numindScore)
        let ptsToNext = tier.pointsToNext(from: progressStore.numindScore)

        return NumindCard {
            HStack(spacing: 20) {
                // Large ring
                NumindScoreRing(score: progressStore.numindScore,
                                delta: progressStore.numindScoreDelta,
                                size: 110)

                VStack(alignment: .leading, spacing: 8) {
                    // Tier badge
                    HStack(spacing: 6) {
                        Image(systemName: tier.icon)
                            .font(.system(size: 13, weight: .bold))
                        Text(tier.name.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .kerning(0.5)
                    }
                    .foregroundStyle(tier.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(tier.color.opacity(0.12))
                    .clipShape(Capsule())

                    // Delta line
                    if progressStore.numindScoreDelta != 0 {
                        let up = progressStore.numindScoreDelta > 0
                        HStack(spacing: 4) {
                            Image(systemName: up ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 11, weight: .bold))
                            Text(up
                                 ? "+\(progressStore.numindScoreDelta) pts this week"
                                 : "\(progressStore.numindScoreDelta) pts this week")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(up ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                    }

                    // Next tier callout
                    if let pts = ptsToNext, let next = tier.next {
                        Text("\(pts) pts to \(next.name)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                    } else {
                        Text("You've reached the top tier \u{1F451}")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.Colors.growthGreen)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Tier progression strip

    private var tierProgressionStrip: some View {
        let currentTier = ScoreTier(score: progressStore.numindScore)
        let score = progressStore.numindScore
        let tiers = ScoreTier.allCases

        return NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("YOUR JOURNEY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.6)

                // Node strip
                HStack(spacing: 0) {
                    ForEach(Array(tiers.enumerated()), id: \.offset) { i, tier in
                        // Node
                        let isReached = score >= tier.minScore
                        let isCurrent = tier == currentTier

                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(isReached ? tier.color : Theme.Colors.mutedTint)
                                    .frame(width: isCurrent ? 36 : 28, height: isCurrent ? 36 : 28)

                                Image(systemName: tier.icon)
                                    .font(.system(size: isCurrent ? 15 : 11, weight: .bold))
                                    .foregroundStyle(isReached ? .white : Theme.Colors.mutedText)
                            }
                            .shadow(color: isCurrent ? tier.color.opacity(0.4) : .clear,
                                    radius: 6, y: 2)

                            Text(tier.name)
                                .font(.system(size: 9, weight: isCurrent ? .bold : .medium))
                                .foregroundStyle(isCurrent ? tier.color : Theme.Colors.mutedText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 52)
                        }

                        // Connector line between nodes
                        if i < tiers.count - 1 {
                            let nextTier = tiers[i + 1]
                            let nextReached = score >= nextTier.minScore
                            Rectangle()
                                .fill(nextReached
                                      ? LinearGradient(colors: [tier.color, nextTier.color],
                                                       startPoint: .leading, endPoint: .trailing)
                                      : LinearGradient(colors: [Theme.Colors.mutedTint, Theme.Colors.mutedTint],
                                                       startPoint: .leading, endPoint: .trailing))
                                .frame(height: 2)
                                .offset(y: -12) // align with node centers
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Score threshold labels
                HStack(spacing: 0) {
                    ForEach(Array(tiers.enumerated()), id: \.offset) { i, tier in
                        Text(tier.minScore == 0 ? "Start" : "\(tier.minScore)+")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(score >= tier.minScore ? tier.color : Theme.Colors.mutedText)
                            .frame(maxWidth: .infinity)
                        if i < tiers.count - 1 {
                            Spacer(minLength: 0).frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private var scoreChartCard: some View {
        let mods = repo.allModules()

        return NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("PERFORMANCE BY MODULE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.6)

                if mods.count >= 3 {
                    let current = mods.map {
                        RadarChartView.Axis(label: $0.shortName,
                                            value: Double(progressStore.numindScore(for: $0.id)) / 100.0)
                    }
                    let previous: [RadarChartView.Axis]? = mods.allSatisfy({
                        progressStore.numindScoreHistory(for: $0.id, daysAgo: 7) != nil
                    })
                    ? mods.map {
                        RadarChartView.Axis(label: $0.shortName,
                                            value: Double(progressStore.numindScoreHistory(for: $0.id, daysAgo: 7) ?? 0) / 100.0)
                    }
                    : nil
                    RadarChartView(axes: current, previousAxes: previous, size: 220)
                        .frame(maxWidth: .infinity)
                } else {
                    ModuleBarsView(bars: mods.map { m in
                        ModuleBarsView.Bar(
                            icon: m.icon,
                            label: m.shortName,
                            score: progressStore.numindScore(for: m.id),
                            color: m.color.tintColor,
                            previousScore: progressStore.numindScoreHistory(for: m.id, daysAgo: 7)
                        )
                    })
                }

                if progressStore.numindScore == 0 {
                    Text("Complete your first lesson to see your Numind Score.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var moduleBreakdownCard: some View {
        let mods = repo.allModules()

        return NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("MODULE SCORES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.6)

                ForEach(Array(mods.enumerated()), id: \.element.id) { i, m in
                    let score = progressStore.numindScore(for: m.id)

                    HStack(spacing: 12) {
                        IconTile(systemName: m.icon,
                                 tintColor: m.color.tintColor, size: 32)
                        Text(m.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Text("\(score)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(score > 0 ? m.color.tintColor : Theme.Colors.mutedText)
                    }
                    .padding(.vertical, 4)

                    if i < mods.count - 1 {
                        Divider().background(Theme.Colors.hairline)
                    }
                }
            }
        }
    }

    // MARK: - Daily challenge

    private var dailyChallengeSection: some View {
        DailyChallengeCard(
            isDone: progressStore.isDailyChallengeCompleted,
            progress: progressStore.isDailyChallengeCompleted ? DailyChallengeEngine.questionCount(for: progressStore.data) : 0,
            correctCount: lastDailyCorrectCount,
            timeUntilReset: viewModel.timeUntilDailyReset,
            hasHistory: progressStore.totalSessions > 0,
            onStart: { startDailyChallenge() },
            onBonusRound: { startBonusRound() }
        )
    }

    // MARK: - Insight helpers

    /// Builds the DailyInsightView using current store scores and the captured session VM.
    @ViewBuilder
    private func insightView(for vm: QuizSessionViewModel) -> some View {
        let modules = repo.allModules()
        let moduleScores = modules.map { m in
            DailyInsightView.ModuleScore(
                module: m,
                score: progressStore.numindScore(for: m.id),
                previousScore: progressStore.numindScoreHistory(for: m.id, daysAgo: 7)
            )
        }
        // Derive which modules appeared in this session's questions.
        let sessionModuleIds: Set<String> = Set(
            vm.questionResults.compactMap { repo.module(forTemplateId: $0.templateId)?.id }
        )
        DailyInsightView(
            overallScore: progressStore.numindScore,
            scoreDelta: progressStore.numindScoreDelta,
            moduleScores: moduleScores,
            sessionModuleIds: sessionModuleIds,
            sessionCorrect: vm.correctCount,
            sessionTotal: vm.total,
            sessionTimeString: vm.elapsedTimeString,
            recommendedLesson: resolveInsightLesson(sessionModuleIds: sessionModuleIds),
            onContinue: { showInsight = false },
            onLearnWeakness: { lesson in
                showInsight = false
                // Brief delay so the sheet can dismiss before launching the lesson
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    launchCard = viewModel.card(for: lesson, using: repo)
                }
            }
        )
    }

    /// Finds the first unlearned lesson in the weakest module *from the session's question set*.
    /// This ensures the recommendation is relevant to what the user just practiced.
    private func resolveInsightLesson(sessionModuleIds: Set<String>) -> Lesson? {
        let modules = repo.allModules()
        guard !modules.isEmpty else { return nil }
        // Filter to modules that were actually in this session
        let sessionModules = modules.filter { sessionModuleIds.contains($0.id) }
        guard sessionModules.count > 1 else { return nil }
        let weakest = sessionModules.min {
            progressStore.numindScore(for: $0.id) < progressStore.numindScore(for: $1.id)
        }
        guard let module = weakest else { return nil }
        return repo.lessons(for: module.id)
            .first { !progressStore.hasCompletedLesson($0.id) }
            ?? repo.lessons(for: module.id).first
    }

    private func startDailyChallenge() {
        let questions = DailyChallengeEngine.dailyQuestions(
            from: repo,
            progressData: progressStore.data,
            focusPack: progressStore.focusPack
        )
        dailyVM = QuizSessionViewModel(
            questions: questions,
            title: "Daily Challenge",
            shortcut: "Draw on all the skills you've built \u{2014} tips, discounts, salary math, and more.",
            moduleColor: .blue
        )
    }

    private func startBonusRound() {
        let questions = DailyChallengeEngine.bonusRoundQuestions(from: repo, progressData: progressStore.data)
        bonusRoundVM = QuizSessionViewModel(
            questions: questions,
            title: "Bonus Round",
            shortcut: "Extra practice \u{2014} a fresh set of questions from your modules.",
            moduleColor: .blue
        )
    }

    // MARK: - Streak

    private var streakSection: some View {
        StreakStripCard(
            streak: progressStore.streak,
            completions: progressStore.weeklyCompletions,
            availableFreezes: progressStore.availableFreezes
        )
    }

    // MARK: - Pack section (Life-Event Paths)

    /// Aggregate of the pack-related UI: focus pack callout, "Pick a path"
    /// CTA when no focus is set, and an "Also in progress" carousel below.
    /// Renders nothing if neither the focus nor any in-progress packs exist
    /// AND the user has never engaged a pack — to avoid clutter in the
    /// blank-slate state we still surface the entry-point CTA via the
    /// existing browse-paths affordance in Learn.
    @ViewBuilder
    private var packSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let focus = progressStore.focusPack {
                focusPackCard(pack: focus)
            } else {
                pickPathCard
            }
            // "Also in progress" — packs the user has touched but isn't
            // focusing on right now. Excludes the focus pack from the row
            // so it's not double-shown.
            let others = progressStore.inProgressPacks
                .filter { $0.id != progressStore.focusPackId }
            if !others.isEmpty {
                alsoInProgressRow(packs: others)
            }
        }
    }

    private func focusPackCard(pack: Pack) -> some View {
        let progress = progressStore.packProgress(packId: pack.id)
        return Button(action: { presentedPack = pack }) {
            NumindCard(background: Theme.Colors.mindTealTint) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text("📍 PATH")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .kerning(0.6)
                        Spacer()
                        Text("\(progress.done) OF \(progress.total)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Colors.deepNavy.opacity(0.65))
                            .kerning(0.5)
                    }
                    Text(pack.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .multilineTextAlignment(.leading)
                    Text(pack.tagline)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.deepNavy.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    HStack {
                        BeadRail(progress: progress.done, total: progress.total, variant: .chunky)
                        Spacer()
                        Button(action: { showPackPicker = true }) {
                            Text("Switch path")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var pickPathCard: some View {
        Button(action: { showPackPicker = true }) {
            NumindCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mindTeal)
                        .frame(width: 44, height: 44)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pick a path")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("Got a money moment coming up? Pick a curated path that gets you ready in ~20 min.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func alsoInProgressRow(packs: [Pack]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Also in progress")
            HorizontalCardScroll(items: packs, cardWidth: 220) { pack in
                otherPackCard(pack: pack)
            }
        }
    }

    private func otherPackCard(pack: Pack) -> some View {
        let progress = progressStore.packProgress(packId: pack.id)
        return Button(action: { presentedPack = pack }) {
            NumindCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pack.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(pack.tagline)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    HStack {
                        BeadRail(progress: progress.done, total: progress.total, variant: .chunky)
                        Spacer()
                        Text("\(progress.done)/\(progress.total)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Workout section

    @ViewBuilder
    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Today's workout")
            if let card = viewModel.todayCard {
                workoutCard(card, reason: viewModel.recommendations.first?.reason)
            } else {
                allCaughtUpCard
            }
        }
    }

    private func workoutCard(
        _ card: HomeViewModel.LessonCard,
        reason: LessonRecommendation.Reason? = nil
    ) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    IconTile(systemName: card.module.icon,
                             tintColor: card.module.color.tintColor, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 6) {
                            Text(card.module.title.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(card.module.color.tintColor)
                                .kerning(0.6)
                            Spacer()
                            if let reason {
                                reasonChip(reason)
                            } else {
                                HStack(spacing: 3) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10, weight: .medium))
                                    Text("5\u{2013}7 min")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(Theme.Colors.mutedText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.Colors.mutedTint)
                                .clipShape(Capsule())
                            }
                        }
                        Text(card.lesson.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(card.lesson.concept)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack {
                    BeadRail(progress: 0, total: card.questionCount, variant: .chunky)
                    Spacer()
                    Text("+\(card.xpReward) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Colors.insightYellowTint)
                        .clipShape(Capsule())
                }

                PillButton("Start workout") { launchCard = card }
            }
        }
    }

    @ViewBuilder
    private func reasonChip(_ reason: LessonRecommendation.Reason) -> some View {
        switch reason {
        case .neverAttempted:
            chipView("NEW", icon: "sparkle", color: Theme.Colors.mindTeal)
        case .inProgress:
            chipView("IN PROGRESS", icon: "arrow.right.circle", color: Theme.Colors.primaryBlue)
        case .weakModule, .weakAxis:
            chipView("NEEDS WORK", icon: "exclamationmark.triangle", color: Theme.Colors.warmOrange)
        }
    }

    private func chipView(_ label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .kerning(0.4)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    /// Shown only when all lessons are done AND no SRS reviews are due.
    private var allCaughtUpCard: some View {
        NumindCard {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.Colors.mindTeal)
                Text("You're all caught up!")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("No reviews due right now. Check back later or try a bonus round.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Game modes section

    private var modesSection: some View {
        let locked = !viewModel.modesUnlocked

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Game modes")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ModeCard.speedDrill(
                        bestLabel: bestLabel(for: progressStore.speedDrillBest),
                        locked: locked,
                        action: { startSpeedDrill() }
                    )
                    .frame(width: 155)

                    ModeCard.blitz(
                        bestLabel: bestLabel(for: progressStore.blitzBest),
                        locked: locked,
                        action: { startBlitz() }
                    )
                    .frame(width: 155)

                    ModeCard.streak(
                        bestLabel: bestLabel(for: progressStore.streakModeBest),
                        locked: locked,
                        action: { startStreak() }
                    )
                    .frame(width: 155)

                    ModeCard.estimation(
                        bestLabel: bestLabel(for: progressStore.estimationBest, suffix: " ★"),
                        locked: locked,
                        action: { startEstimation() }
                    )
                    .frame(width: 155)

                    ModeCard.comparison(
                        bestLabel: bestLabel(for: progressStore.comparisonBest, suffix: "/15"),
                        locked: locked,
                        action: { startComparison() }
                    )
                    .frame(width: 155)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
            }
            // Let scroll bleed to screen edges
            .padding(.horizontal, -Theme.Spacing.screenHorizontal)
        }
    }

    // MARK: - Mode helpers

    private func bestLabel(for score: Int, suffix: String = "") -> String? {
        score > 0 ? "Best: \(score)\(suffix)" : nil
    }

    private func startSpeedDrill() {
        guard viewModel.modesUnlocked else { return }
        showSpeedDrill = true
    }

    private func startBlitz() {
        guard viewModel.modesUnlocked else { return }
        let questions = BlitzEngine.generateQuestionQueue(from: progressStore.data)
        guard !questions.isEmpty else { return }
        blitzVM = BlitzViewModel(questions: questions, previousBest: progressStore.blitzBest)
    }

    private func startStreak() {
        guard viewModel.modesUnlocked else { return }
        let questions = generateMCQQuestions(count: 40)
        guard !questions.isEmpty else { return }
        streakVM = StreakViewModel(questions: questions, previousBest: progressStore.streakModeBest)
    }

    private func startEstimation() {
        guard viewModel.modesUnlocked else { return }
        let templates = masteredTemplates()
        guard !templates.isEmpty else { return }
        let items = EstimationViewModel.generateItems(from: templates, count: 10)
        guard !items.isEmpty else { return }
        estimationVM = EstimationViewModel(items: items, previousBest: progressStore.estimationBest)
    }

    private func startComparison() {
        guard viewModel.modesUnlocked else { return }
        let templates = masteredTemplates()
        guard templates.count >= 2 else { return }
        let pairs = ComparisonViewModel.generatePairs(from: templates, count: 15)
        guard !pairs.isEmpty else { return }
        comparisonVM = ComparisonViewModel(pairs: pairs, previousBest: progressStore.comparisonBest)
    }

    // MARK: - Continue learning

    private func continueSection(_ card: HomeViewModel.LessonCard) -> some View {
        let lessons = repo.lessons(for: card.module.id)
        let completed = progressStore.completedLessonCount(moduleId: card.module.id)
        let progress: Double = lessons.isEmpty ? 0 : Double(completed) / Double(lessons.count)

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Continue learning")
            NumindCard {
                Button { launchCard = card } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            IconTile(systemName: card.module.icon,
                                     tintColor: card.module.color.tintColor)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(card.module.title)
                                    .font(Theme.Typography.small)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(card.module.color.tintColor)
                                    .textCase(.uppercase)
                                    .kerning(0.5)
                                Text(card.lesson.title)
                                    .font(Theme.Typography.headline)
                                    .foregroundStyle(Theme.Colors.deepNavy)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Theme.Colors.mutedTint)
                                Capsule()
                                    .fill(card.module.color.tintColor)
                                    .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                            }
                        }
                        .frame(height: 6)

                        Text("\(completed) of \(lessons.count) lessons \u{00B7} Resume")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Up next

    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Up next")
            NumindCard {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.upNextCards.enumerated()), id: \.element.id) { i, card in
                        Button { launchCard = card } label: {
                            HStack(spacing: 14) {
                                IconTile(systemName: card.module.icon,
                                         tintColor: card.module.color.tintColor,
                                         size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.lesson.title)
                                        .font(Theme.Typography.body)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Theme.Colors.deepNavy)
                                    Text(card.module.title)
                                        .font(Theme.Typography.small)
                                        .foregroundStyle(Theme.Colors.mutedText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.mutedText)
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        if i < viewModel.upNextCards.count - 1 {
                            Divider().background(Theme.Colors.hairline)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mixed-session recording

    /// Records a mixed-pool session (daily challenge, bonus round) by splitting
    /// question results into per-module session records so the Numind Score
    /// engine can attribute each answer to the correct module.
    private func recordMixedSession(vm: QuizSessionViewModel, lessonId: String) {
        let groups = Dictionary(grouping: vm.questionResults) { result in
            repo.module(forTemplateId: result.templateId)?.id ?? "mixed"
        }

        let sortedKeys = groups.keys.sorted()
        for (i, moduleId) in sortedKeys.enumerated() {
            let results = groups[moduleId]!
            let correct = results.filter(\.isCorrect).count
            var record = SessionRecord(
                id: UUID(),
                lessonId: lessonId,
                moduleId: moduleId,
                date: Date(),
                correctCount: correct,
                totalCount: results.count
            )
            record.questionResults = results
            // Attach bonus XP only to the first sub-session to avoid double-counting.
            record.bonusXP = i == 0 ? vm.bonusXP : 0
            progressStore.recordSession(record)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }

    /// Templates from mastered lessons, for game modes.
    private func masteredTemplates() -> [QuizTemplate] {
        let pool = MasteredTemplatePool.templates(
            from: progressStore.data,
            repository: repo
        )
        return pool.isEmpty ? repo.allTemplates() : pool
    }

    /// Generates MCQ questions from mastered templates for game modes.
    private func generateMCQQuestions(count: Int) -> [QuizQuestion] {
        let templates = MasteredTemplatePool.mcqTemplates(
            from: progressStore.data,
            repository: repo
        )
        let pool = templates.isEmpty
            ? repo.allTemplates().filter { ($0.inputMode ?? .multipleChoice) == .multipleChoice }
            : templates
        guard !pool.isEmpty else { return [] }

        var questions: [QuizQuestion] = []
        var usedFingerprints: Set<String> = []
        var idx = 0
        while questions.count < count && idx < count * 3 {
            let template = pool[idx % pool.count]
            let q = QuizEngine.generate(from: template)
            let fp = q.prompt + "|" + (q.scenario ?? "")
            if !usedFingerprints.contains(fp) {
                usedFingerprints.insert(fp)
                questions.append(q)
            }
            idx += 1
        }
        return questions
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ProgressStore())
    }
}
