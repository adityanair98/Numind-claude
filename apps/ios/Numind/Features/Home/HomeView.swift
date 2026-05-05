import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var launchCard: HomeViewModel.LessonCard?
    @State private var dailyVM: QuizSessionViewModel? = nil
    @State private var bonusRoundVM: QuizSessionViewModel? = nil
    @State private var showSpeedDrill = false
    @State private var blitzVM: BlitzViewModel? = nil
    @State private var insightLesson: Lesson? = nil   // built when daily challenge ends
    @State private var showInsight = false
    @State private var insightSessionVM: QuizSessionViewModel? = nil   // retained while sheet shows
    @AppStorage("numind.userName") private var userName = "You"

    private let repo = LocalContentRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                BrandHeader(
                    name: userName,
                    isDailyChallengeCompleted: progressStore.isDailyChallengeCompleted,
                    numindScore: progressStore.numindScore
                )
                dailyChallengeSection
                streakSection
                workoutSection
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
                    var record = SessionRecord(
                        id: UUID(),
                        lessonId: "daily_challenge",
                        moduleId: "mixed",
                        date: Date(),
                        correctCount: vm.correctCount,
                        totalCount: vm.total
                    )
                    record.questionResults = vm.questionResults
                    record.bonusXP = vm.bonusXP
                    progressStore.recordSession(record)
                    progressStore.markDailyChallengeCompleted()
                    // Resolve lesson recommendation for the weakest module
                    insightLesson = resolveInsightLesson()
                    insightSessionVM = vm
                    dailyVM = nil
                    showInsight = true
                }
            }
        }
        // Post-daily-challenge insight sheet
        .sheet(isPresented: $showInsight, onDismiss: {
            insightSessionVM = nil
            insightLesson = nil
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
                    var record = SessionRecord(
                        id: UUID(),
                        lessonId: "bonus_round",
                        moduleId: "mixed",
                        date: Date(),
                        correctCount: vm.correctCount,
                        totalCount: vm.total
                    )
                    record.questionResults = vm.questionResults
                    record.bonusXP = vm.bonusXP
                    progressStore.recordSession(record)
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
        .onAppear { viewModel.refresh(using: progressStore) }
        .onChange(of: progressStore.totalSessions) { _, _ in
            viewModel.refresh(using: progressStore)
        }
    }

    // MARK: - Daily challenge

    private var dailyChallengeSection: some View {
        DailyChallengeCard(
            isDone: progressStore.isDailyChallengeCompleted,
            progress: progressStore.isDailyChallengeCompleted ? DailyChallengeEngine.questionCount : 0,
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
        DailyInsightView(
            overallScore: progressStore.numindScore,
            scoreDelta: progressStore.numindScoreDelta,
            moduleScores: moduleScores,
            sessionCorrect: vm.correctCount,
            sessionTotal: vm.total,
            sessionTimeString: vm.elapsedTimeString,
            recommendedLesson: insightLesson,
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

    /// Finds the first unlearned lesson in the weakest module to surface as a recommendation.
    private func resolveInsightLesson() -> Lesson? {
        let modules = repo.allModules()
        guard !modules.isEmpty else { return nil }
        let weakest = modules.min {
            progressStore.numindScore(for: $0.id) < progressStore.numindScore(for: $1.id)
        }
        guard let module = weakest else { return nil }
        return repo.lessons(for: module.id)
            .first { !progressStore.hasCompletedLesson($0.id) }
            ?? repo.lessons(for: module.id).first   // fallback: first lesson even if done
    }

    private func startDailyChallenge() {
        let questions = DailyChallengeEngine.dailyQuestions(from: repo, progressData: progressStore.data)
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
            completions: progressStore.weeklyCompletions
        )
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
        case .weakModule:
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
            HStack(spacing: 12) {
                ModeCard.speedDrill(
                    bestLabel: speedDrillBestLabel,
                    locked: locked,
                    action: { startSpeedDrill() }
                )
                ModeCard.blitz(
                    bestLabel: blitzBestLabel,
                    locked: locked,
                    action: { startBlitz() }
                )
            }
        }
    }

    private var speedDrillBestLabel: String? {
        progressStore.bestAccuracy(lessonId: "speed_drill")
            .map { "\(Int($0 * 100))% best accuracy" }
    }

    private var blitzBestLabel: String? {
        let best = progressStore.blitzBest
        return best > 0 ? "Best: \(best) correct" : nil
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
