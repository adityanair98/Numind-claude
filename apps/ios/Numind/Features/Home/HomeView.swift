import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var launchCard: HomeViewModel.LessonCard?
    @State private var dailyVM: QuizSessionViewModel? = nil
    @State private var bonusRoundVM: QuizSessionViewModel? = nil
    @State private var recallVM: QuizSessionViewModel? = nil
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
                    level: progressStore.level,
                    levelProgress: progressStore.levelProgress,
                    onScoreTap: { showScoreDetail = true }
                )
                dailyChallengeSection
                streakSection
                if let card = viewModel.continueCard {
                    continueSection(card)
                }
                packSection
                quickAccessRow
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
        // Recall — "review your weak spots" (moved from Practice in 7a)
        .fullScreenCover(item: $recallVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    recordMixedSession(vm: vm, lessonId: "recall_review")
                    progressStore.updateRecallBest(score: vm.correctCount)
                    recallVM = nil
                }
            }
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

    // MARK: - Level & Readiness detail sheet

    private var scoreDetailSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    levelHero
                        .padding(.top, 4)

                    // Coverage diagnostic (mastered / total per axis)
                    coverageCard

                    // The honest competence surface: per-pack Readiness
                    readinessBoardCard
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, 12)
            }
            .background(Theme.Colors.softBackground.ignoresSafeArea())
            .navigationTitle("Level & Readiness")
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

    // MARK: - Level hero

    private var levelHero: some View {
        NumindCard {
            HStack(spacing: 20) {
                LevelRing(level: progressStore.level,
                          progress: progressStore.levelProgress,
                          size: 110)

                VStack(alignment: .leading, spacing: 8) {
                    Text("LEVEL \(progressStore.level)")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Theme.Colors.mutedText)
                        .kerning(0.5)
                    Text("\(progressStore.xp) XP")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)

                    // Next-level hint — honest when depth-gated.
                    if progressStore.isDepthGated {
                        Label("Master a lesson's hard questions to reach Level \(progressStore.level + 1)",
                              systemImage: "lock.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.Colors.warmOrange)
                            .fixedSize(horizontal: false, vertical: true)
                    } else if let toNext = progressStore.xpToNextLevel {
                        Text("\(toNext) XP to Level \(progressStore.level + 1)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                    } else {
                        Text("Top level reached 🎉")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }

                    // Decisions you're ready for — the competence headline.
                    if progressStore.readyPackCount > 0 {
                        Label("\(progressStore.readyPackCount) decision path\(progressStore.readyPackCount == 1 ? "" : "s") you're ready for",
                              systemImage: "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.growthGreen)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Skill coverage (diagnostic)

    private var coverageCard: some View {
        let coverage = progressStore.axisCoverage
        return NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("SKILL COVERAGE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .kerning(0.6)

                // Coverage shape (mastered / total) — NOT a competence grade.
                let axes = coverage.map {
                    RadarChartView.Axis(label: $0.axis.shortName, value: $0.fraction)
                }
                RadarChartView(axes: axes, previousAxes: nil, size: 220)
                    .frame(maxWidth: .infinity)

                Text("How much of each area you've locked in — not a grade.")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .frame(maxWidth: .infinity, alignment: .center)

                Divider().background(Theme.Colors.hairline)

                ForEach(coverage) { row in
                    HStack(spacing: 12) {
                        Image(systemName: skillIcon(row.axis))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(skillColor(row.axis))
                            .frame(width: 32, height: 32)
                            .background(skillColor(row.axis).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        Text(row.axis.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Text("\(row.mastered)/\(row.total)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(row.mastered > 0
                                ? skillColor(row.axis) : Theme.Colors.mutedText)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Pack readiness board

    private var readinessBoardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DECISIONS YOU'RE GETTING READY FOR")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.6)
            PackReadinessBoard(rows: LocalContentRepository().allPacks().map {
                PackReadinessBoard.Row(id: $0.id, title: $0.title,
                                       state: progressStore.readiness(for: $0))
            })
        }
    }

    /// SF Symbol per skill axis (mirrors DailyInsightView.skillIcon for
    /// visual consistency across both surfaces).
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

    /// Builds the DailyInsightView using current store axis scores and the
    /// captured session VM.
    @ViewBuilder
    private func insightView(for vm: QuizSessionViewModel) -> some View {
        // Live per-axis snapshot (current scores + evidence) for the chart.
        let results = progressStore.numindAxisResults
        let axisScores = results.map { r in
            DailyInsightView.AxisScore(
                axis: r.axis,
                score: r.score,
                evidence: r.evidence,
                // Phase 9: composite score history is retired, so there's no
                // prior-week overlay. Nil collapses gracefully in the radar.
                previousScore: nil
            )
        }
        // Derive which axes appeared in this session's questions, via the
        // template -> lesson -> primarySkill chain.
        let sessionAxes: Set<SkillAxis> = Set(
            vm.questionResults.compactMap { qr in
                repo.lesson(forTemplateId: qr.templateId)?.primarySkill
            }
        )
        let sessionXP = vm.questionResults.reduce(0) { acc, qr in
            acc + (qr.isCorrect ? MomentumEngine.xp(for: qr.difficulty) : 0)
        }
        DailyInsightView(
            level: progressStore.level,
            levelProgress: progressStore.levelProgress,
            sessionXP: sessionXP,
            axisScores: axisScores,
            sessionAxes: sessionAxes,
            sessionCorrect: vm.correctCount,
            sessionTotal: vm.total,
            sessionTimeString: vm.elapsedTimeString,
            recommendedLesson: resolveInsightLesson(sessionAxes: sessionAxes),
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

    /// Finds the first unlearned lesson whose primarySkill matches the
    /// weakest measured axis *from the session's question set*. Falls back
    /// gracefully so the user always has a relevant next step.
    private func resolveInsightLesson(sessionAxes: Set<SkillAxis>) -> Lesson? {
        guard sessionAxes.count > 1 else { return nil }
        let results = progressStore.numindAxisResults
            .filter { sessionAxes.contains($0.axis) && $0.evidence != .notStarted }
        guard let weakest = results.min(by: { $0.score < $1.score }) else { return nil }
        // Find a lesson in the curriculum whose primary skill matches the
        // weakest axis and that the user hasn't completed yet.
        let allLessons = repo.allModules().flatMap { repo.lessons(for: $0.id) }
        return allLessons.first {
            $0.primarySkill == weakest.axis && !progressStore.hasCompletedLesson($0.id)
        }
        ?? allLessons.first { $0.primarySkill == weakest.axis }
    }

    private func startDailyChallenge() {
        let questions = DailyChallengeEngine.dailyQuestions(
            from: repo,
            progressData: progressStore.data,
            focusPack: progressStore.focusPack
        )
        dailyVM = QuizSessionViewModel(
            questions: questions,
            title: "Daily Workout",
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

    /// "Review your weak spots" — rebuilds a quiz from the questions the user
    /// has previously missed (Recall, moved from the retired Practice tab).
    /// Falls back to a fresh bonus round when there's no history yet.
    private func launchRecall() {
        let allResults = progressStore.data.sessions.flatMap { $0.questionResults }
        if let vm = ReviewMistakesEngine.build(fromStored: allResults, moduleColor: .indigo, repository: repo) {
            recallVM = vm
        } else {
            startBonusRound()
        }
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

    // MARK: - Quick access (Phase 6c)

    /// Compact entry points below the fold — replaces the retired Game Modes
    /// carousel. An "Open Tools" chip and a Recall "Review weak spots" chip
    /// get added here in 7a once the Tools tab + Recall move from Practice.
    private var quickAccessRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Quick access")
            HStack(spacing: 12) {
                quickChip(icon: "arrow.uturn.backward",
                          title: "Review weak spots",
                          subtitle: "Redo what you've missed",
                          tint: Theme.Colors.primaryBlue) {
                    launchRecall()
                }
                quickChip(icon: progressStore.focusPack == nil ? "map.fill" : "rectangle.stack.fill",
                          title: progressStore.focusPack == nil ? "Pick a path" : "Browse paths",
                          subtitle: progressStore.focusPack == nil ? "Get ready for a moment" : "Switch or add",
                          tint: Theme.Colors.mindTeal) {
                    showPackPicker = true
                }
            }
        }
    }

    private func quickChip(icon: String, title: String, subtitle: String,
                           tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            NumindCard {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 38, height: 38)
                        .background(tint.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(title)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(subtitle)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Continue learning

    private func continueSection(_ card: HomeViewModel.LessonCard) -> some View {
        let lessons = repo.lessons(for: card.module.id)
        let completed = progressStore.completedLessonCount(moduleId: card.module.id)
        let progress: Double = lessons.isEmpty ? 0 : Double(completed) / Double(lessons.count)

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Continue your path")
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

}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ProgressStore())
    }
}
