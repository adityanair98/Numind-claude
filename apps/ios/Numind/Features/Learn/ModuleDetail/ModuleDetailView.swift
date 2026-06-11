import SwiftUI

struct ModuleDetailView: View {
    @StateObject private var viewModel: ModuleDetailViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLesson: Lesson?
    @State private var practiceVM: QuizSessionViewModel?

    init(module: Module, moduleIndex: Int, totalModules: Int) {
        _viewModel = StateObject(wrappedValue: ModuleDetailViewModel(
            module: module, moduleIndex: moduleIndex, totalModules: totalModules
        ))
    }

    private var accent: Color { viewModel.module.color.tintColor }
    private var masteredCount: Int {
        viewModel.lessons.filter { progressStore.hasMasteredLesson($0.id) }.count
    }
    private var averageAccuracy: Double {
        let done = viewModel.lessons.compactMap { progressStore.bestAccuracy(lessonId: $0.id) }
        guard !done.isEmpty else { return 0 }
        return done.reduce(0, +) / Double(done.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                bodyContent
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonView(viewModel: LessonViewModel(
                lesson: lesson,
                moduleTitle: viewModel.module.title,
                lessonIndex: viewModel.lessons.firstIndex(of: lesson) ?? 0,
                totalLessons: viewModel.lessons.count,
                moduleColor: viewModel.module.color
            ))
        }
        .fullScreenCover(item: $practiceVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    practiceVM = nil
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Hero Header
    // ═══════════════════════════════════════════════════════════════

    private var heroHeader: some View {
        let total = viewModel.lessons.count
        let progress = total > 0 ? Double(masteredCount) / Double(total) : 0

        return ZStack(alignment: .topLeading) {
            // Background gradient
            LinearGradient(
                colors: [accent, accent.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Watermark glyph
            Text(viewModel.module.glyph)
                .font(.system(size: 240, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.13))
                .offset(x: 100, y: -30)
                .allowsHitTesting(false)

            // Decorative orbs
            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 180, height: 180)
                .offset(x: 200, y: 120)
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 110, height: 110)
                .offset(x: -40, y: 140)

            VStack(alignment: .leading, spacing: 0) {
                // Toolbar
                HStack {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.18))
                                .frame(width: 38, height: 38)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(viewModel.moduleLabel.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    // Placeholder for symmetry
                    Circle()
                        .fill(.clear)
                        .frame(width: 38, height: 38)
                }
                .padding(.top, 8)

                // Mascot + title
                HStack(alignment: .bottom, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white.opacity(0.22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                            )
                        Text(viewModel.module.mascot)
                            .font(.system(size: 40))
                            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                    }
                    .frame(width: 78, height: 78)
                    .shadow(color: .black.opacity(0.18), radius: 11, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.module.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(viewModel.module.subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(.bottom, 2)
                }
                .padding(.top, 22)

                // Stat strip
                HStack(spacing: 0) {
                    heroStat(value: "\(masteredCount)/\(total)", label: "Lessons")
                    heroDivider
                    heroStat(value: "\(Int(averageAccuracy * 100))%", label: "Accuracy")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                )
                .padding(.top, 22)

                // Progress bar
                VStack(spacing: 6) {
                    HStack {
                        Text("TOPIC PROGRESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                            .tracking(0.4)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.20))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Colors.insightYellow, .white],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                                .shadow(color: Theme.Colors.insightYellow, radius: 6)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.top, 14)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 22)
        }
    }

    private func heroStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.78))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private var heroDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 28)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Body Content
    // ═══════════════════════════════════════════════════════════════

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
            // Curriculum header
            HStack {
                Text("Curriculum \u{00B7} \(viewModel.lessons.count) lessons".uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .tracking(0.8)
                Spacer()
                Text("\(masteredCount)/\(viewModel.lessons.count) mastered")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(accent)
            }
            .padding(.horizontal, 4)

            // Lesson list
            VStack(spacing: 0) {
                ForEach(Array(viewModel.lessons.enumerated()), id: \.element.id) { index, lesson in
                    lessonRow(lesson: lesson, index: index, isLast: index == viewModel.lessons.count - 1)
                    if index < viewModel.lessons.count - 1 {
                        Divider()
                            .padding(.leading, 16 + 36 + 14)
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)

            footerNote
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.vertical, Theme.Spacing.sectionSpacing)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Lesson Row
    // ═══════════════════════════════════════════════════════════════

    private func lessonRow(lesson: Lesson, index: Int, isLast: Bool) -> some View {
        let isDone = progressStore.hasMasteredLesson(lesson.id)
        let isAttempted = progressStore.hasCompletedLesson(lesson.id)
        let bestAcc = progressStore.bestAccuracy(lessonId: lesson.id)
        let moduleColor = viewModel.module.color
        // Unlock: previous lesson must be completed (any score). Mastery is aspirational only.
        let prevCompleted = index == 0 || progressStore.hasCompletedLesson(viewModel.lessons[index - 1].id)
        let isLocked = !isDone && !isAttempted && !prevCompleted

        return Button {
            guard !isLocked else { return }
            selectedLesson = lesson
        } label: {
            HStack(spacing: 14) {
                // Lesson tile with connector rail
                ZStack {
                    // Connector rail to next row
                    if !isLast {
                        Rectangle()
                            .fill(isDone ? accent.opacity(0.4) : Theme.Colors.mutedTint)
                            .frame(width: 2)
                            .offset(y: 28)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(tileFill(isDone: isDone, isAttempted: isAttempted, isLocked: isLocked))
                            .frame(width: 36, height: 36)
                            .shadow(
                                color: isDone ? accent.opacity(0.35) : .clear,
                                radius: isDone ? 5 : 0, y: 2
                            )

                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mutedText)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(isAttempted ? Theme.Colors.warmOrange : accent)
                        }
                    }
                }
                .frame(width: 36)

                // Title + subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineLimit(2)

                    if isDone, let acc = bestAcc {
                        // Mastered: accuracy bar + question count
                        HStack(spacing: 8) {
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.Colors.mutedTint)
                                    .frame(width: 70, height: 4)
                                Capsule()
                                    .fill(accent)
                                    .frame(width: 70 * CGFloat(min(acc, 1)), height: 4)
                            }
                            Text("\(Int(acc * 100))% accuracy")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(accent)
                            Text("\u{00B7} \(lesson.quizTemplateIds.count)q")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                    } else if isLocked {
                        Text("Unlocks after lesson \(index)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                    } else {
                        Text(lesson.concept)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Trailing action
                if isDone {
                    Button {
                        launchPractice(lesson: lesson)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("Practice")
                                .font(.system(size: 11, weight: .heavy))
                                .textCase(.uppercase)
                                .tracking(0.3)
                        }
                        .foregroundStyle(accent)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(moduleColor.tintBackground)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.Colors.mutedText)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .opacity(isLocked ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private func tileFill(isDone: Bool, isAttempted: Bool, isLocked: Bool) -> Color {
        if isDone { return accent }
        if isAttempted { return Theme.Colors.warmOrangeTint }
        if isLocked { return Theme.Colors.mutedTint }
        return accent.opacity(0.16)
    }

    private func launchPractice(lesson: Lesson) {
        let repo = LocalContentRepository()
        let sessions = progressStore.data.sessions
        let templates = SpacedRepetitionEngine.sortedTemplates(
            for: lesson.id,
            sessions: sessions,
            repository: repo
        )
        guard !templates.isEmpty else { return }
        let questions = templates.map { QuizEngine.generate(from: $0) }
        practiceVM = QuizSessionViewModel(
            questions: questions,
            title: lesson.title,
            shortcut: lesson.shortcut,
            moduleColor: viewModel.module.color
        )
    }

    // MARK: - Footer

    private var footerNote: some View {
        Text("Tap a completed lesson to practice again anytime")
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack {
        ModuleDetailView(
            module: Module(
                id: "smart_shopping",
                title: "Smart Shopping",
                subtitle: "Tips, discounts, and everyday savings",
                icon: "cart.fill",
                color: .blue,
                lessonIds: ["tip_18_percent"],
                mascot: "\u{1F6D2}",
                glyph: "%"
            ),
            moduleIndex: 0,
            totalModules: 4
        )
    }
}
