import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    /// `nil` = "All Modules"; otherwise a specific module ID scopes the drills.
    @State private var selectedModuleId: String? = nil
    @State private var quizVM: QuizSessionViewModel?
    @State private var recallVM: QuizSessionViewModel?
    @State private var streakVM: StreakViewModel?
    @State private var trueFalseVM: TrueFalseViewModel?
    @State private var estimationVM: EstimationViewModel?
    @State private var comparisonVM: ComparisonViewModel?

    /// Tracks whether the current quizVM session is a speed drill (vs. quick quiz).
    @State private var isSpeedDrill = false

    private let repo = LocalContentRepository()

    private var modules: [Module] { repo.allModules() }
    private var selectedModule: Module? {
        guard let id = selectedModuleId else { return nil }
        return modules.first { $0.id == id }
    }

    // Header totals
    private var totalLessons: Int {
        modules.reduce(0) { $0 + repo.lessons(for: $1.id).count }
    }
    private var totalMastered: Int {
        modules.reduce(0) { acc, mod in
            acc + repo.lessons(for: mod.id).filter { progressStore.hasMasteredLesson($0.id) }.count
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                practiceHeader
                    .padding(.bottom, 12)

                moduleTabStrip
                    .padding(.bottom, 14)

                if let mod = selectedModule {
                    moduleSpotlight(mod)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 14)
                }

                heroQuizCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 20)

                drillsSection
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 40)
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $quizVM) { vm in
            PracticeQuizContainer(
                viewModel: vm,
                progressStore: progressStore,
                recordSession: {
                    recordSession(vm: vm)
                    if isSpeedDrill {
                        progressStore.updateSpeedDrillBest(score: vm.correctCount)
                    }
                },
                onDismiss: { quizVM = nil },
                previousBest: isSpeedDrill ? progressStore.speedDrillBest : nil
            )
        }
        .fullScreenCover(item: $recallVM) { vm in
            PracticeQuizContainer(
                viewModel: vm,
                progressStore: progressStore,
                recordSession: {
                    recordSession(vm: vm)
                    progressStore.updateRecallBest(score: vm.correctCount)
                },
                onDismiss: { recallVM = nil },
                previousBest: progressStore.recallBest
            )
        }
        .fullScreenCover(item: $streakVM) { vm in
            StreakView(
                viewModel: vm,
                generateQuestions: { generateMCQQuestions(count: 40) }
            )
            .environmentObject(progressStore)
        }
        .fullScreenCover(item: $trueFalseVM) { vm in
            TrueFalseView(viewModel: vm)
                .environmentObject(progressStore)
        }
        .fullScreenCover(item: $estimationVM) { vm in
            EstimationView(viewModel: vm)
                .environmentObject(progressStore)
        }
        .fullScreenCover(item: $comparisonVM) { vm in
            ComparisonView(viewModel: vm)
                .environmentObject(progressStore)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Practice Header
    // ═══════════════════════════════════════════════════════════════

    private var practiceHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                masteryPill
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Practice")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Sharpen any skill, anytime.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var masteryPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.Colors.mindTeal)
            HStack(spacing: 0) {
                Text("\(totalMastered)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("/\(totalLessons)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Theme.Colors.cardBackground)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Module Tab Strip
    // ═══════════════════════════════════════════════════════════════

    private var moduleTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                allModulesTab
                ForEach(modules) { module in
                    moduleTab(module: module)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
    }

    private var allModulesTab: some View {
        let isSelected = selectedModuleId == nil
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedModuleId = nil
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isSelected ? Theme.Colors.primaryBlue : Theme.Colors.cardBackground)
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    isSelected ? .clear : Theme.Colors.hairline,
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isSelected ? Theme.Colors.primaryBlue.opacity(0.4) : .black.opacity(0.05),
                            radius: isSelected ? 8 : 3,
                            y: isSelected ? 4 : 2
                        )

                    Image(systemName: "shuffle")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isSelected ? .white : Theme.Colors.mutedText)
                }

                Text("All")
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Theme.Colors.primaryBlue : Theme.Colors.mutedText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private func moduleTab(module: Module) -> some View {
        let isSelected = selectedModuleId == module.id
        let accent = module.color.tintColor

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedModuleId = module.id
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isSelected ? accent : Theme.Colors.cardBackground)
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    isSelected ? .clear : Theme.Colors.hairline,
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isSelected ? accent.opacity(0.4) : .black.opacity(0.05),
                            radius: isSelected ? 8 : 3,
                            y: isSelected ? 4 : 2
                        )

                    Text(module.mascot)
                        .font(.system(size: 26))
                        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)

                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.insightYellow)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                            Text(module.glyph)
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.Colors.insightText)
                        }
                        .offset(x: 24, y: -24)
                    }
                }

                Text(module.shortName)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? accent : Theme.Colors.mutedText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Module Spotlight (specific module selected)
    // ═══════════════════════════════════════════════════════════════

    private func moduleSpotlight(_ module: Module) -> some View {
        let accent = module.color.tintColor
        let tint   = module.color.tintBackground
        let score  = progressStore.numindScore(for: module.id)
        let tier   = ScoreTier(score: score)

        // Module practice stats
        let moduleSessions = progressStore.data.sessions.filter { $0.moduleId == module.id }
        let totalCorrect = moduleSessions.reduce(0) { $0 + $1.correctCount }
        let totalQs = moduleSessions.reduce(0) { $0 + $1.totalCount }
        let accuracy = totalQs > 0 ? Double(totalCorrect) / Double(totalQs) * 100 : 0

        return ZStack(alignment: .bottomTrailing) {
            // Watermark glyph
            Text(module.glyph)
                .font(.system(size: 140, weight: .heavy, design: .rounded))
                .foregroundStyle(accent.opacity(0.1))
                .offset(x: 10, y: 30)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Mascot tile
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(accent)
                            .shadow(color: accent.opacity(0.4), radius: 7, y: 3)
                        Text(module.mascot)
                            .font(.system(size: 22))
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(module.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineLimit(1)
                        Text(module.subtitle)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }

                    Spacer(minLength: 0)
                }

                // Practice stats row
                HStack(spacing: 8) {
                    statBadge(
                        value: score > 0 ? "\(score)" : "—",
                        label: "Score",
                        color: score > 0 ? tier.color : Theme.Colors.mutedText
                    )
                    statBadge(
                        value: totalQs > 0 ? "\(Int(accuracy))%" : "—",
                        label: "Accuracy",
                        color: accent
                    )
                    statBadge(
                        value: "\(moduleSessions.count)",
                        label: moduleSessions.count == 1 ? "Session" : "Sessions",
                        color: accent
                    )
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [tint, tint.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(accent.opacity(0.18), lineWidth: 1.5)
        )
        .clipped()
        .id(module.id)
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Theme.Colors.mutedText)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.Colors.cardBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Hero Quiz Card
    // ═══════════════════════════════════════════════════════════════

    private var heroQuizCard: some View {
        let isAll = selectedModuleId == nil
        let moduleName = selectedModule?.title ?? ""
        let locked = !modesUnlocked

        return HeroCard(variant: .navy) {
            VStack(alignment: .leading, spacing: 0) {
                // Eyebrow
                HStack(spacing: 4) {
                    Image(systemName: locked ? "lock.fill" : (isAll ? "sparkles" : "brain.head.profile"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightYellow)
                    Text(locked ? "LOCKED" : (isAll ? "MIXED MODE" : "QUICK QUIZ"))
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(0.6)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.16))
                .clipShape(Capsule())
                .padding(.bottom, 8)

                Text(locked
                    ? "Complete a lesson\nto start practicing"
                    : (isAll
                        ? "Surprise me with\n10 random questions"
                        : "Quick quiz from\n\(moduleName)"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .padding(.bottom, 6)

                Text(locked
                    ? "Master your first lesson in the Learn tab to unlock drills and game modes."
                    : (isAll
                        ? "Pulled from every module you've unlocked."
                        : "10 questions to sharpen your skills."))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 16)

                // CTA
                if !locked {
                    Button {
                        launchQuickQuiz()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "dice.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(isAll ? "Start Mixed Round" : "Start Quick Quiz")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Theme.Colors.mindTeal, Color(red: 0.15, green: 0.71, blue: 0.65)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Theme.Colors.mindTeal.opacity(0.4), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Drills Section
    // ═══════════════════════════════════════════════════════════════

    private var modesUnlocked: Bool {
        MasteredTemplatePool.hasUnlockedModes(
            progressData: progressStore.data,
            repository: repo
        )
    }

    private var drillsSection: some View {
        let scopeLabel = selectedModule?.shortName ?? "All"
        let locked = !modesUnlocked

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text("Drills")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                if locked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Complete a lesson to unlock")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Theme.Colors.mutedText)
                } else {
                    Text(scopeLabel)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .padding(.horizontal, 2)

            // Row 1: classic drills
            HStack(spacing: 10) {
                drillCard(
                    title: "Speed Drill",
                    subtitle: "15s per Q",
                    icon: "bolt.fill",
                    gradientStart: Theme.Colors.mindTeal,
                    gradientEnd: Color(red: 0.12, green: 0.66, blue: 0.59),
                    bestScore: progressStore.speedDrillBest,
                    locked: locked
                ) {
                    launchSpeedDrill()
                }

                drillCard(
                    title: "Blitz Mode",
                    subtitle: "No mercy",
                    icon: "timer",
                    gradientStart: Theme.Colors.warmOrange,
                    gradientEnd: Color(red: 0.90, green: 0.35, blue: 0.12),
                    bestScore: progressStore.blitzBest,
                    locked: locked
                ) {
                    launchBlitz()
                }

                drillCard(
                    title: "Recall",
                    subtitle: "Past misses",
                    icon: "arrow.counterclockwise",
                    gradientStart: Theme.Colors.investIndigo,
                    gradientEnd: Color(red: 0.25, green: 0.25, blue: 0.72),
                    bestScore: progressStore.recallBest,
                    locked: locked
                ) {
                    launchRecall()
                }
            }

            // Row 2: new game modes
            HStack(spacing: 10) {
                drillCard(
                    title: "Streak",
                    subtitle: "Don't miss",
                    icon: "flame.fill",
                    gradientStart: Color(red: 0.95, green: 0.30, blue: 0.25),
                    gradientEnd: Color(red: 0.85, green: 0.20, blue: 0.18),
                    bestScore: progressStore.streakModeBest,
                    locked: locked
                ) {
                    launchStreak()
                }

                drillCard(
                    title: "True/False",
                    subtitle: "Snap judge",
                    icon: "hand.thumbsup.fill",
                    gradientStart: Theme.Colors.primaryBlue,
                    gradientEnd: Color(red: 0.18, green: 0.30, blue: 0.72),
                    bestScore: progressStore.trueFalseBest,
                    locked: locked
                ) {
                    launchTrueFalse()
                }

                drillCard(
                    title: "Estimate",
                    subtitle: "How close?",
                    icon: "scope",
                    gradientStart: Theme.Colors.insightYellow,
                    gradientEnd: Color(red: 0.88, green: 0.60, blue: 0.10),
                    bestScore: progressStore.estimationBest,
                    locked: locked
                ) {
                    launchEstimation()
                }
            }

            // Row 3: comparison
            HStack(spacing: 10) {
                drillCard(
                    title: "Compare",
                    subtitle: "Which is more?",
                    icon: "arrow.left.arrow.right",
                    gradientStart: Theme.Colors.growthGreen,
                    gradientEnd: Color(red: 0.15, green: 0.58, blue: 0.40),
                    bestScore: progressStore.comparisonBest,
                    locked: locked
                ) {
                    launchComparison()
                }

                // Spacers to maintain grid alignment
                Color.clear.frame(minHeight: 120)
                Color.clear.frame(minHeight: 120)
            }
        }
    }

    private func drillCard(
        title: String,
        subtitle: String,
        icon: String,
        gradientStart: Color,
        gradientEnd: Color,
        bestScore: Int? = nil,
        locked: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button { if !locked { action() } } label: {
            ZStack {
                // Decorative orbs (purely visual — no score text)
                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 70, height: 70)
                    .offset(x: 15, y: 20)

                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 24, height: 24)
                    .offset(x: -2, y: -70)

                VStack(alignment: .leading, spacing: 0) {
                    // Icon tile + best score badge
                    HStack(alignment: .top) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.opacity(0.25))
                                .frame(width: 32, height: 32)
                            Image(systemName: locked ? "lock.fill" : icon)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Spacer(minLength: 0)

                        if let best = bestScore, best > 0, !locked {
                            HStack(spacing: 3) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color(red: 0.95, green: 0.75, blue: 0.1))
                                Text("\(best)")
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.3))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 14)

                    Spacer(minLength: 0)

                    Text(title)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .frame(minHeight: 120)
            .background(
                LinearGradient(
                    colors: locked
                        ? [Theme.Colors.mutedText.opacity(0.5), Theme.Colors.mutedText.opacity(0.35)]
                        : [gradientStart, gradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: (locked ? Theme.Colors.mutedText : gradientStart).opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!locked)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Actions
    // ═══════════════════════════════════════════════════════════════

    private func launchQuickQuiz() {
        let templates = templatesForSelection()
        guard !templates.isEmpty else { return }

        let picked = Array(templates.shuffled().prefix(10))
        var usedFingerprints: Set<String> = []
        var questions: [QuizQuestion] = []
        for t in picked {
            var q = QuizEngine.generate(from: t)
            var fp = q.prompt + "|" + (q.scenario ?? "")
            var attempts = 1
            while usedFingerprints.contains(fp) && attempts < 10 {
                q = QuizEngine.generate(from: t)
                fp = q.prompt + "|" + (q.scenario ?? "")
                attempts += 1
            }
            usedFingerprints.insert(fp)
            questions.append(q)
        }

        let title = selectedModule?.title ?? "Mixed Mode"
        isSpeedDrill = false
        quizVM = QuizSessionViewModel(
            questions: questions,
            title: title,
            shortcut: selectedModuleId == nil
                ? "Random questions from every module."
                : "Questions from \(title).",
            moduleColor: selectedModule?.color ?? .teal
        )
    }

    private func launchSpeedDrill() {
        let templates = mcqTemplatesForSelection()
        guard !templates.isEmpty else { return }

        let picked = Array(templates.shuffled().prefix(10))
        let questions = picked.map { QuizEngine.generate(from: $0) }

        isSpeedDrill = true
        quizVM = QuizSessionViewModel(
            questions: questions,
            title: "Speed Drill",
            shortcut: "15 seconds per question. Go fast!",
            moduleColor: selectedModule?.color ?? .teal,
            questionTimeLimit: 15
        )
    }

    private func launchBlitz() {
        let templates = mcqTemplatesForSelection()
        guard !templates.isEmpty else { return }

        let picked = Array(templates.shuffled().prefix(10))
        let questions = picked.map { QuizEngine.generate(from: $0) }

        quizVM = QuizSessionViewModel(
            questions: questions,
            title: "Blitz Mode",
            shortcut: "No mercy. Answer as many as you can.",
            moduleColor: selectedModule?.color ?? .orange
        )
    }

    private func launchRecall() {
        let allResults: [QuestionResult]
        if let moduleId = selectedModuleId {
            allResults = progressStore.data.sessions
                .filter { $0.moduleId == moduleId }
                .flatMap { $0.questionResults }
        } else {
            allResults = progressStore.data.sessions.flatMap { $0.questionResults }
        }
        guard let vm = ReviewMistakesEngine.build(
            fromStored: allResults,
            moduleColor: selectedModule?.color ?? .indigo,
            repository: repo
        ) else { return }
        recallVM = vm
    }

    private func launchStreak() {
        let questions = generateMCQQuestions(count: 40) // large pool since game can go long
        guard !questions.isEmpty else { return }
        streakVM = StreakViewModel(
            questions: questions,
            previousBest: progressStore.streakModeBest
        )
    }

    private func launchTrueFalse() {
        let templates = templatesForSelection()
        guard !templates.isEmpty else { return }
        let items = TrueFalseViewModel.generateItems(from: templates, count: 20)
        guard !items.isEmpty else { return }
        trueFalseVM = TrueFalseViewModel(items: items, previousBest: progressStore.trueFalseBest)
    }

    private func launchEstimation() {
        let templates = templatesForSelection()
        guard !templates.isEmpty else { return }
        let items = EstimationViewModel.generateItems(from: templates, count: 10)
        guard !items.isEmpty else { return }
        estimationVM = EstimationViewModel(items: items, previousBest: progressStore.estimationBest)
    }

    private func launchComparison() {
        let templates = templatesForSelection()
        guard templates.count >= 2 else { return }
        let pairs = ComparisonViewModel.generatePairs(from: templates, count: 15)
        guard !pairs.isEmpty else { return }
        comparisonVM = ComparisonViewModel(pairs: pairs, previousBest: progressStore.comparisonBest)
    }

    /// Generates MCQ questions from the current module selection for game modes.
    private func generateMCQQuestions(count: Int) -> [QuizQuestion] {
        let templates = mcqTemplatesForSelection()
        guard !templates.isEmpty else { return [] }
        let shuffled = templates.shuffled()
        var questions: [QuizQuestion] = []
        var usedFingerprints: Set<String> = []
        var idx = 0
        while questions.count < count {
            let template = shuffled[idx % shuffled.count]
            var q = QuizEngine.generate(from: template)
            var fp = q.prompt + "|" + (q.scenario ?? "")
            var attempts = 1
            while usedFingerprints.contains(fp) && attempts < 10 {
                q = QuizEngine.generate(from: template)
                fp = q.prompt + "|" + (q.scenario ?? "")
                attempts += 1
            }
            usedFingerprints.insert(fp)
            questions.append(q)
            idx += 1
        }
        return questions.shuffled()
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Template Helpers
    // ═══════════════════════════════════════════════════════════════

    private func templatesForSelection() -> [QuizTemplate] {
        if let moduleId = selectedModuleId {
            return repo.lessons(for: moduleId).flatMap { repo.templates(for: $0.id) }
        } else {
            let pool = MasteredTemplatePool.templates(
                from: progressStore.data,
                repository: repo
            )
            return pool.isEmpty ? repo.allTemplates() : pool
        }
    }

    private func mcqTemplatesForSelection() -> [QuizTemplate] {
        if let moduleId = selectedModuleId {
            return repo.lessons(for: moduleId)
                .flatMap { repo.templates(for: $0.id) }
                .filter { ($0.inputMode ?? .multipleChoice) == .multipleChoice }
        } else {
            let pool = MasteredTemplatePool.mcqTemplates(
                from: progressStore.data,
                repository: repo
            )
            return pool.isEmpty
                ? repo.allTemplates().filter { ($0.inputMode ?? .multipleChoice) == .multipleChoice }
                : pool
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Session Recording
    // ═══════════════════════════════════════════════════════════════

    /// Records the completed quiz session, splitting by module when needed.
    private func recordSession(vm: QuizSessionViewModel) {
        let groups = Dictionary(grouping: vm.questionResults) { result in
            repo.module(forTemplateId: result.templateId)?.id ?? "mixed"
        }
        let lessonId = selectedModuleId.map { "practice_\($0)" } ?? "practice_mixed"
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
            record.bonusXP = i == 0 ? vm.bonusXP : 0
            progressStore.recordSession(record)
        }
    }
}

// MARK: - Practice Quiz Container
// Wraps QuizSessionView with a post-session summary that shows the Numind Score delta.

private struct PracticeQuizContainer: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    @ObservedObject var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    let recordSession: () -> Void
    let onDismiss: () -> Void
    /// Previous best score for this mode — enables celebration when beaten.
    let previousBest: Int?

    @State private var showSummary = false
    @State private var numindScore: Int = 0
    @State private var scoreDelta: Int = 0
    @State private var isNewBest: Bool = false

    var body: some View {
        Group {
            if showSummary {
                summaryView
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                NavigationStack {
                    QuizSessionView(viewModel: viewModel) {
                        // Detect new personal best before recording
                        if let best = previousBest, viewModel.correctCount > best, viewModel.correctCount > 0 {
                            isNewBest = true
                        }
                        // Record and capture score delta
                        let scoreBefore = progressStore.numindScore
                        recordSession()
                        numindScore = progressStore.numindScore
                        scoreDelta = progressStore.numindScore - scoreBefore
                        showSummary = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSummary)
    }

    private var summaryView: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.sectionSpacing) {
                    // Hero
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(viewModel.moduleColor.tintBackground)
                                .frame(width: 72, height: 72)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(viewModel.moduleColor.tintColor)
                        }

                        Text("Practice complete!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)

                        if isNewBest {
                            NewBestBadge()
                        }
                    }

                    // Stats row
                    HStack(spacing: 12) {
                        statPill(
                            icon: "checkmark.circle.fill",
                            value: "\(viewModel.correctCount)/\(viewModel.total)",
                            label: "correct",
                            color: Theme.Colors.growthGreen
                        )
                        statPill(
                            icon: "clock.fill",
                            value: viewModel.elapsedTimeString,
                            label: "time",
                            color: Theme.Colors.primaryBlue
                        )
                        statPill(
                            icon: "flame.fill",
                            value: "\(viewModel.totalXP) XP",
                            label: "earned",
                            color: Theme.Colors.insightYellow
                        )
                    }

                    // Numind Score card
                    if numindScore > 0 {
                        NumindCard {
                            HStack(spacing: 14) {
                                NumindScoreRing(score: numindScore, size: 52)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ScoreTier(score: numindScore).name)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(ScoreTier(score: numindScore).color)
                                    if scoreDelta != 0 {
                                        let isUp = scoreDelta > 0
                                        HStack(spacing: 4) {
                                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("\(isUp ? "+" : "")\(scoreDelta) pts")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundStyle(isUp ? Theme.Colors.mindTeal : Theme.Colors.errorSoftRed)
                                    }
                                }

                                Spacer()

                                Text("NUMIND\nSCORE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(Theme.Colors.mutedText)
                                    .tracking(0.5)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }

                    // Done button
                    VStack(spacing: 12) {
                        PillButton("Done", variant: .primary) {
                            onDismiss()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 48)
                .padding(.bottom, 40)
            }

            if isNewBest {
                ConfettiBurst()
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
}

#Preview {
    NavigationStack {
        PracticeView()
            .environmentObject(ProgressStore())
    }
}
