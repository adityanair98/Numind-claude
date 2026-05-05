import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedModuleIndex: Int = 0
    @State private var selectedLesson: Lesson?
    @State private var mixedModeVM: QuizSessionViewModel?
    @State private var recallVM: QuizSessionViewModel?
    private let repo = LocalContentRepository()

    private var modules: [Module] { repo.allModules() }
    private var selectedModule: Module { modules[selectedModuleIndex] }
    private var lessons: [Lesson] { repo.lessons(for: selectedModule.id) }

    // Totals for header
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

                mixedModeCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 20)

                moduleTabStrip
                    .padding(.bottom, 8)

                moduleSpotlight
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 14)

                lessonListSection
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                drillsSection
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 40)
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedLesson) { lesson in
            lessonCover(for: lesson)
        }
        .fullScreenCover(item: $mixedModeVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    mixedModeVM = nil
                }
            }
        }
        .fullScreenCover(item: $recallVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    recallVM = nil
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Practice Header
    // ═══════════════════════════════════════════════════════════════

    private var practiceHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image("NumindWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
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
    // MARK: - Mixed Mode Card
    // ═══════════════════════════════════════════════════════════════

    private var mixedModeCard: some View {
        HeroCard(variant: .navy) {
            VStack(alignment: .leading, spacing: 0) {
                // Eyebrow
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightYellow)
                    Text("MIXED MODE")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(0.6)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.16))
                .clipShape(Capsule())
                .padding(.bottom, 8)

                Text("Surprise me with\n10 random questions")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .padding(.bottom, 6)

                Text("Pulled from every module you've unlocked.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 16)

                // CTA button
                Button {
                    launchMixedMode()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Start Mixed Round")
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

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Module Tab Strip
    // ═══════════════════════════════════════════════════════════════

    private var moduleTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(modules.enumerated()), id: \.element.id) { i, module in
                    moduleTab(module: module, index: i)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
    }

    private func moduleTab(module: Module, index: Int) -> some View {
        let isSelected = index == selectedModuleIndex
        let accent = module.color.tintColor

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedModuleIndex = index
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

                    // Glyph badge on selected
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
    // MARK: - Module Spotlight
    // ═══════════════════════════════════════════════════════════════

    private var moduleSpotlight: some View {
        let accent = selectedModule.color.tintColor
        let tint = selectedModule.color.tintBackground
        let total = lessons.count
        let completed = lessons.filter { progressStore.hasMasteredLesson($0.id) }.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return ZStack(alignment: .bottomTrailing) {
            // Watermark glyph
            Text(selectedModule.glyph)
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
                        Text(selectedModule.mascot)
                            .font(.system(size: 22))
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedModule.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineLimit(1)
                        Text(selectedModule.subtitle)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }

                    Spacer(minLength: 0)

                    // Dice shuffle button
                    Button {
                        pickRandomLessonInModule()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.Colors.cardBackground)
                                .frame(width: 40, height: 40)
                                .shadow(color: accent.opacity(0.18), radius: 5, y: 2)
                            Image(systemName: "dice.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(accent)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Progress bar + label
                HStack(spacing: 10) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(accent.opacity(0.18))
                            Capsule()
                                .fill(accent)
                                .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                        }
                    }
                    .frame(height: 8)

                    Text("\(completed)/\(total) mastered")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(accent)
                        .tracking(0.3)
                        .fixedSize()
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
        .id(selectedModule.id)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Lesson List
    // ═══════════════════════════════════════════════════════════════

    private var lessonListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(lessons.count) Lessons".uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 2)

            VStack(spacing: 0) {
                ForEach(Array(lessons.enumerated()), id: \.element.id) { i, lesson in
                    lessonRow(lesson: lesson, index: i)
                    if i < lessons.count - 1 {
                        Divider()
                            .padding(.leading, 16 + 36 + 14)
                    }
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
    }

    private func lessonRow(lesson: Lesson, index: Int) -> some View {
        let accent = selectedModule.color.tintColor
        let mastered = progressStore.hasMasteredLesson(lesson.id)
        let attempted = progressStore.hasCompletedLesson(lesson.id)
        let bestAcc = progressStore.bestAccuracy(lessonId: lesson.id)

        return Button {
            selectedLesson = lesson
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 14) {
                // Index tile (rounded rect)
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(mastered ? accent : (attempted ? Theme.Colors.warmOrangeTint : Theme.Colors.mutedTint))
                        .frame(width: 36, height: 36)
                        .shadow(
                            color: mastered ? accent.opacity(0.3) : .clear,
                            radius: mastered ? 5 : 0, y: 2
                        )
                    if mastered {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(attempted ? Theme.Colors.warmOrange : Theme.Colors.mutedText)
                    }
                }

                // Title + accuracy bar
                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let acc = bestAcc {
                        HStack(spacing: 6) {
                            // Mini accuracy bar
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.Colors.mutedTint)
                                    .frame(width: 60, height: 4)
                                Capsule()
                                    .fill(mastered ? accent : Theme.Colors.warmOrange)
                                    .frame(width: 60 * CGFloat(min(acc, 1)), height: 4)
                            }
                            Text("\(Int(acc * 100))% best")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(mastered ? accent : Theme.Colors.warmOrange)
                        }
                    } else {
                        Text("Not attempted yet")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Status + chevron
                HStack(spacing: 4) {
                    if mastered {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(accent)
                    } else if attempted {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.warmOrange)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Drills Section
    // ═══════════════════════════════════════════════════════════════

    private var drillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text("Drills")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                Text("Pure reps")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            .padding(.horizontal, 2)

            HStack(spacing: 10) {
                drillCard(
                    title: "Speed Drill",
                    subtitle: "60s sprint",
                    icon: "bolt.fill",
                    gradientStart: Theme.Colors.mindTeal,
                    gradientEnd: Color(red: 0.12, green: 0.66, blue: 0.59)
                ) {
                    launchSpeedDrill()
                }

                drillCard(
                    title: "Blitz Mode",
                    subtitle: "No mercy",
                    icon: "timer",
                    gradientStart: Theme.Colors.warmOrange,
                    gradientEnd: Color(red: 0.90, green: 0.35, blue: 0.12)
                ) {
                    launchBlitz()
                }

                drillCard(
                    title: "Recall",
                    subtitle: "Past misses",
                    icon: "arrow.counterclockwise",
                    gradientStart: Theme.Colors.investIndigo,
                    gradientEnd: Color(red: 0.25, green: 0.25, blue: 0.72)
                ) {
                    launchRecall()
                }
            }
        }
    }

    private func drillCard(
        title: String,
        subtitle: String,
        icon: String,
        gradientStart: Color,
        gradientEnd: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                // Decorative orbs
                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 70, height: 70)
                    .offset(x: 15, y: 20)
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 24, height: 24)
                    .offset(x: -2, y: -70)

                VStack(alignment: .leading, spacing: 0) {
                    // Icon tile
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.opacity(0.25))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
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
                    colors: [gradientStart, gradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: gradientStart.opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Actions
    // ═══════════════════════════════════════════════════════════════

    private func pickRandomLessonInModule() {
        guard !lessons.isEmpty else { return }
        selectedLesson = lessons.randomElement()
    }

    private func launchMixedMode() {
        let pool = MasteredTemplatePool.templates(
            from: progressStore.data,
            repository: repo
        )
        let templates = pool.isEmpty ? repo.allTemplates() : pool
        guard !templates.isEmpty else { return }

        let shuffled = templates.shuffled()
        let picked = Array(shuffled.prefix(10))
        let questions = picked.map { QuizEngine.generate(from: $0) }

        mixedModeVM = QuizSessionViewModel(
            questions: questions,
            title: "Mixed Mode",
            shortcut: "Random questions from every module you've unlocked.",
            moduleColor: .teal
        )
    }

    private func launchSpeedDrill() {
        // Navigate to existing SpeedDrillView via fullScreenCover
        // For now, launch as a quiz session with 15s timer
        let pool = MasteredTemplatePool.mcqTemplates(
            from: progressStore.data,
            repository: repo
        )
        guard !pool.isEmpty else { return }
        let shuffled = pool.shuffled()
        let picked = Array(shuffled.prefix(10))
        let questions = picked.map { QuizEngine.generate(from: $0) }

        mixedModeVM = QuizSessionViewModel(
            questions: questions,
            title: "Speed Drill",
            shortcut: "60 seconds per question. Go fast!",
            moduleColor: .teal,
            questionTimeLimit: 15
        )
    }

    private func launchBlitz() {
        let pool = MasteredTemplatePool.mcqTemplates(
            from: progressStore.data,
            repository: repo
        )
        guard !pool.isEmpty else { return }
        let shuffled = pool.shuffled()
        let picked = Array(shuffled.prefix(10))
        let questions = picked.map { QuizEngine.generate(from: $0) }

        mixedModeVM = QuizSessionViewModel(
            questions: questions,
            title: "Blitz Mode",
            shortcut: "No mercy. Answer as many as you can.",
            moduleColor: .orange
        )
    }

    private func launchRecall() {
        // Build recall from past wrong answers
        let allResults = progressStore.data.sessions.flatMap { $0.questionResults }
        guard let vm = ReviewMistakesEngine.build(
            fromStored: allResults,
            moduleColor: .indigo,
            repository: repo
        ) else { return }

        recallVM = vm
    }

    // MARK: - Lesson cover

    private func lessonCover(for lesson: Lesson) -> some View {
        let module = modules.first { $0.lessonIds.contains(lesson.id) } ?? selectedModule
        let moduleLessons = repo.lessons(for: module.id)
        return LessonView(viewModel: LessonViewModel(
            lesson: lesson,
            moduleTitle: module.title,
            lessonIndex: moduleLessons.firstIndex(of: lesson) ?? 0,
            totalLessons: moduleLessons.count,
            moduleColor: module.color
        ))
        .environmentObject(progressStore)
    }
}

#Preview {
    NavigationStack {
        PracticeView()
            .environmentObject(ProgressStore())
    }
}
