import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var launchCard: HomeViewModel.LessonCard?
    @State private var dailyVM: QuizSessionViewModel? = nil
    @State private var bonusRoundVM: QuizSessionViewModel? = nil
    @State private var refreshVM: QuizSessionViewModel? = nil
    // insightLesson is now computed inline in insightView(for:) from the session's modules
    @State private var showInsight = false
    @State private var insightSessionVM: QuizSessionViewModel? = nil   // retained while sheet shows
    @State private var lastDailyCorrectCount: Int = 0
    @State private var showScoreDetail = false
    @State private var showPackPicker = false
    @State private var presentedPack: Pack?
    @AppStorage("numind.userName") private var userName = "You"

    private let repo = LocalContentRepository()

    /// Skills mastered during today's workout — feeds the insight sheet's
    /// capability language (Phase 10).
    @State private var insightSkillMoves: [SkillMove] = []

    /// Skills restored by the last refresh session (Phase 12 — the
    /// recurring "caught it fading" narration; first-ever save shows the
    /// milestone instead).
    @State private var refreshSaveMoves: [SkillMove] = []
    @State private var showRefreshSaveToast = false

    // Sharpness check + real-world saves (Phase 12)
    @State private var checkVM: QuizSessionViewModel? = nil
    @State private var checkResult: SharpnessCheckRecord? = nil
    @State private var showSavePrompt = false

    var body: some View {
        ScrollView {
            // Home is a content feed, not a celebration surface — a tighter
            // rhythm than the global sectionSpacing (28) so it doesn't read
            // oversized/sparse with only ~3 cards per screen.
            VStack(alignment: .leading, spacing: 18) {
                BrandHeader(name: userName, streak: progressStore.streak)
                dailyChallengeSection
                momentChipSection
                streakSection
                refreshSection
                sharpnessCheckSection
                if let card = viewModel.continueCard {
                    continueSection(card)
                }
                packSection
                quickAccessRow
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        // Refresh-save toast — the recurring everyday echo of a skill caught
        // before it faded (the first-ever save shows a milestone instead).
        .overlay(alignment: .top) {
            if showRefreshSaveToast {
                refreshSaveToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { showRefreshSaveToast = false }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showRefreshSaveToast)
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
                    // Diff mastery across the recording for the insight
                    // sheet's capability language (Phase 10).
                    let masteredBefore = progressStore.masteredLessonIds
                    recordMixedSession(
                        vm: vm, lessonId: "daily_challenge"
                    )
                    insightSkillMoves = progressStore.masteredLessonIds
                        .subtracting(masteredBefore)
                        .compactMap { repo.lesson(id: $0) }
                        .map { SkillMove(title: $0.title, change: .mastered) }
                    lastDailyCorrectCount = vm.correctCount
                    progressStore.markDailyChallengeCompleted()
                    AnalyticsService.capture(.workoutCompleted, properties: [
                        "correct": vm.correctCount, "total": vm.total
                    ])
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
            // Weekly real-world saves prompt (max 1/7 days, post-ring moment).
            if progressStore.isSavePromptDue,
               !SharpnessCheckGate.saveChips(sessions: progressStore.data.sessions).isEmpty {
                showSavePrompt = true
            }
        }) {
            if let vm = insightSessionVM {
                insightView(for: vm)
            }
        }
        // Sharpness check session (diagnostic mode — never a SessionRecord)
        .fullScreenCover(item: $checkVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    let seconds = vm.results.map(\.timeSpentSeconds).sorted()
                    let median = seconds.isEmpty ? 0
                        : seconds.count % 2 == 0
                            ? (seconds[seconds.count / 2 - 1] + seconds[seconds.count / 2]) / 2
                            : seconds[seconds.count / 2]
                    let record = SharpnessCheckRecord(
                        date: Date(),
                        correct: vm.correctCount,
                        total: vm.total,
                        medianSeconds: median
                    )
                    progressStore.recordSharpnessCheck(record)
                    checkVM = nil
                    checkResult = record
                }
            }
        }
        // Sharpness check result
        .sheet(item: $checkResult) { record in
            let previous = progressStore.sharpnessChecks
                .filter { $0.date < record.date }
                .max { $0.date < $1.date }
            let day1: (correct: Int, total: Int)? = {
                let results = progressStore.data.onboardingSignals?.diagnosticResults ?? []
                guard !results.isEmpty else { return nil }
                return (results.filter(\.isCorrect).count, results.count)
            }()
            SharpnessCheckResultView(
                record: record,
                dayOne: day1,
                previousCheck: previous,
                staleCount: progressStore.staleSkillCount,
                onStartRefresh: { launchRefresh() }
            )
        }
        // Weekly real-world saves prompt
        .sheet(isPresented: $showSavePrompt) {
            savePromptSheet
                .presentationDetents([.medium])
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
        // Refresh — the one consolidated review entry point (Phase 10-A8):
        // stale mastered skills + unfixed mistakes in a single session
        .fullScreenCover(item: $refreshVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    let staleBefore = Set(FreshnessEngine.staleLessons(
                        masteredLessonIds: progressStore.masteredLessonIds,
                        sessions: progressStore.data.sessions,
                        repository: repo
                    ))
                    recordMixedSession(vm: vm, lessonId: "refresh_review")
                    let staleAfter = Set(FreshnessEngine.staleLessons(
                        masteredLessonIds: progressStore.masteredLessonIds,
                        sessions: progressStore.data.sessions,
                        repository: repo
                    ))
                    refreshSaveMoves = staleBefore.subtracting(staleAfter)
                        .compactMap { repo.lesson(id: $0) }
                        .map { SkillMove(title: $0.title, change: .refreshed) }
                    if !refreshSaveMoves.isEmpty && progressStore.pendingMilestone == nil {
                        withAnimation { showRefreshSaveToast = true }
                    }
                    refreshVM = nil
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
                    readinessHero
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
            .navigationTitle("Readiness")
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

    // MARK: - Readiness hero (Phase 10 — capability language, no Level/XP)

    private var readinessHero: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                if let pack = progressStore.focusPack {
                    let state = progressStore.readiness(for: pack)
                    let core = ReadinessEngine.coreLessons(for: pack)
                    let mastered = core.filter { progressStore.hasMasteredLessonNow($0) }.count

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pack.title.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.Colors.mutedText)
                                .kerning(0.6)
                            Text("\(mastered) of \(core.count) core skills mastered")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Theme.Colors.deepNavy)
                        }
                        Spacer()
                        ReadinessBadge(state: state)
                    }

                    // The named missing gate follows the pack everywhere.
                    if case .almostReady(_, let nextAction) = state {
                        Label(nextAction, systemImage: "arrow.right.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text("Pick a path to get decision-ready")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
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
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
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
            onBonusRound: { startBonusRound() },
            total: DailyChallengeEngine.questionCount(for: progressStore.data),
            dailyMinutes: progressStore.data.onboardingSignals?.dailyMinutes ?? 5,
            ringProgress: progressStore.ringProgress,
            ringCenter: "\(min(progressStore.todayQuestionCount, progressStore.ringTarget))/\(progressStore.ringTarget)",
            isRingClosed: progressStore.isRingClosedToday,
            onRingTap: { showScoreDetail = true }
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
        DailyInsightView(
            ringProgress: progressStore.ringProgress,
            ringClosed: progressStore.isRingClosedToday,
            skillsMoved: insightSkillMoves,
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
        let plan = DailyWorkoutEngine.plan(
            from: repo,
            progressData: progressStore.data,
            focusPack: progressStore.focusPack
        )
        var teachCards: [Int: TeachCard] = [:]
        if let card = plan.teachCard, let index = plan.teachCardIndex {
            teachCards[index] = card
        }
        dailyVM = QuizSessionViewModel(
            questions: plan.questions,
            title: "Daily Workout",
            shortcut: "Draw on all the skills you've built \u{2014} tips, discounts, paychecks, and more.",
            moduleColor: .blue,
            teachCards: teachCards,
            segmentLabels: plan.segmentLabels,
            speedBaselines: SharpnessEngine.baselines(
                for: plan.questions.map(\.templateId),
                sessions: progressStore.data.sessions
            )
        )
        AnalyticsService.capture(.workoutStarted, properties: [
            "question_count": plan.questions.count
        ])
    }

    private func startBonusRound() {
        let questions = DailyChallengeEngine.bonusRoundQuestions(from: repo, progressData: progressStore.data)
        bonusRoundVM = QuizSessionViewModel(
            questions: questions,
            title: "More Practice",
            shortcut: "Extra practice \u{2014} a fresh set of questions from your modules.",
            moduleColor: .blue,
            speedBaselines: SharpnessEngine.baselines(
                for: questions.map(\.templateId),
                sessions: progressStore.data.sessions
            )
        )
    }

    // MARK: - Refresh (consolidated, Phase 10-A8)

    /// A gentle, opportunity-framed card — "N skills to refresh" — that appears
    /// when mastered skills have gone stale OR recent mistakes are still
    /// unfixed (the old Recall surface folded in). Tapping starts one short
    /// session that restores both. Never a penalty.
    @ViewBuilder
    private var refreshSection: some View {
        let count = RefreshSessionBuilder.skillCount(
            masteredLessonIds: progressStore.masteredLessonIds,
            sessions: progressStore.data.sessions,
            repository: repo
        )
        if count > 0 {
            Button(action: launchRefresh) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.Colors.mindTeal.opacity(0.14))
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(count) skill\(count == 1 ? "" : "s") to refresh")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("Bring back fading skills and fix recent misses.")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(14)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.mindTeal.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
    }

    /// Builds the consolidated refresh session — stale mastered templates
    /// plus unfixed mistakes, regenerated with fresh values.
    private func launchRefresh() {
        guard let session = RefreshSessionBuilder.build(
            masteredLessonIds: progressStore.masteredLessonIds,
            sessions: progressStore.data.sessions,
            repository: repo
        ) else { return }
        refreshVM = QuizSessionViewModel(
            questions: session.questions,
            title: "Refresh",
            shortcut: "Bring your skills back to sharp \u{2014} same methods, fresh numbers.",
            moduleColor: .teal,
            speedBaselines: SharpnessEngine.baselines(
                for: session.questions.map(\.templateId),
                sessions: progressStore.data.sessions
            )
        )
        AnalyticsService.capture(.refreshStarted, properties: [
            "skill_count": session.skillCount
        ])
    }

    // MARK: - Coming up (moments, Phase 12)

    /// Pack IDs the moments registry treats as "this user's moments".
    private var momentPackIds: Set<String> {
        var ids = Set(progressStore.data.onboardingSignals?.selectedPackIds ?? [])
        ids.formUnion(progressStore.inProgressPacks.map(\.id))
        if let focus = progressStore.focusPackId { ids.insert(focus) }
        return ids
    }

    /// Top-1 live moment as a slim chip — "about N weeks" granularity,
    /// nothing rendered outside a genuine window.
    @ViewBuilder
    private var momentChipSection: some View {
        if let moment = MomentsRegistry.currentMoments(
            signals: progressStore.data.onboardingSignals,
            packIds: momentPackIds
        ).first {
            Button {
                if let packId = moment.packId, let pack = repo.pack(id: packId) {
                    presentedPack = pack
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightText)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.insightYellowTint)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(moment.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(moment.detail)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                    if moment.packId != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .padding(12)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.insightYellow.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Sharpness check (Phase 12)

    /// Monthly 2-minute check — appears 28+ days after the last one (or
    /// the day-1 diagnostic). Results never touch the session log.
    @ViewBuilder
    private var sharpnessCheckSection: some View {
        if progressStore.isSharpnessCheckDue, progressStore.focusPackId != nil {
            Button(action: launchSharpnessCheck) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.Colors.investIndigo.opacity(0.14))
                            .frame(width: 44, height: 44)
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(Theme.Colors.investIndigo)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly sharpness check")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("2 minutes \u{2014} see how far you\u{2019}ve come since day 1.")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(14)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.investIndigo.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
    }

    private func launchSharpnessCheck() {
        let signals = progressStore.data.onboardingSignals
        let items = DiagnosticQuestionBuilder.build(
            focusPackId: progressStore.focusPackId ?? signals?.focusPackId,
            secondaryPackIds: signals?.secondaryPackIds ?? [],
            repository: repo
        )
        guard !items.isEmpty else { return }
        checkVM = QuizSessionViewModel(
            questions: items.map(\.question),
            title: "Sharpness Check",
            shortcut: "No grades \u{2014} just an honest look at where your skills sit today.",
            moduleColor: .indigo,
            speedBaselines: SharpnessEngine.baselines(
                for: items.map(\.question.templateId),
                sessions: progressStore.data.sessions
            )
        )
    }

    // MARK: - Real-world saves prompt (Phase 12)

    private var savePromptSheet: some View {
        let chips = SharpnessCheckGate.saveChips(sessions: progressStore.data.sessions)
        return VStack(alignment: .leading, spacing: 16) {
            Text("Real life check")
                .font(Theme.Typography.small)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Theme.Colors.mutedText)
                .padding(.top, 24)

            Text("Did any of these come up in real life this week?")
                .font(Theme.Typography.title)
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineSpacing(2)

            VStack(spacing: 10) {
                ForEach(chips, id: \.self) { chip in
                    Button {
                        progressStore.recordSavePrompt(label: chip)
                        showSavePrompt = false
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.Colors.growthGreen)
                            Text(chip)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(14)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                progressStore.recordSavePrompt(label: nil)
                showSavePrompt = false
            } label: {
                Text("None this week")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Theme.Colors.softBackground.ignoresSafeArea())
    }

    // MARK: - Refresh-save toast (Phase 12)

    private var refreshSaveToast: some View {
        let titles = refreshSaveMoves.map(\.title)
        let line = titles.prefix(2).joined(separator: ", ")
            + (titles.count > 2 ? " +\(titles.count - 2) more" : "")
        return HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Back to sharp")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("Refreshed: \(line)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.mindTeal, Theme.Colors.growthGreen],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Theme.Colors.mindTeal.opacity(0.3), radius: 10, y: 4)
        )
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 8)
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
                        Label("PATH", systemImage: "signpost.right.fill")
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
    /// carousel. (Phase 10-A8: the Recall chip folded into the Refresh card;
    /// its slot is now extra practice.)
    private var quickAccessRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Quick access")
            HStack(spacing: 12) {
                quickChip(icon: "square.stack.3d.up.fill",
                          title: "More practice",
                          subtitle: "A fresh set of questions",
                          tint: Theme.Colors.primaryBlue) {
                    startBonusRound()
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
            progressStore.recordSession(record)
        }

        let sessionType: String = switch lessonId {
        case "daily_challenge": "daily_workout"
        case "bonus_round":     "more_practice"
        case "refresh_review":  "refresh"
        default:                lessonId
        }
        AnalyticsService.capture(.sessionCompleted, properties: ["type": sessionType])
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
