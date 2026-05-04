import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedModuleIndex: Int = 0
    @State private var selectedLesson: Lesson?
    private let repo = LocalContentRepository()

    private var modules: [Module] { repo.allModules() }
    private var selectedModule: Module { modules[selectedModuleIndex] }
    private var lessons: [Lesson] { repo.lessons(for: selectedModule.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                moduleTabStrip
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                moduleHeaderCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 20)

                lessonList
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 40)
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $selectedLesson) { lesson in
            lessonCover(for: lesson)
        }
    }

    // MARK: - Module tab strip

    private var moduleTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
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
                    RoundedRectangle(cornerRadius: Theme.Radius.iconTile, style: .continuous)
                        .fill(isSelected ? accent.opacity(0.15) : Theme.Colors.cardBackground)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.iconTile, style: .continuous)
                                .strokeBorder(
                                    isSelected ? accent : Theme.Colors.hairline,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isSelected ? accent.opacity(0.2) : .clear,
                            radius: 8, y: 3
                        )
                    Image(systemName: module.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isSelected ? accent : Theme.Colors.mutedText)
                }

                Text(moduleShortName(module))
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? accent : Theme.Colors.mutedText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private func moduleShortName(_ module: Module) -> String {
        // Use first word of title, capped at 8 chars
        let first = module.title.components(separatedBy: " ").first ?? module.title
        return first.count > 8 ? String(first.prefix(7)) + "…" : first
    }

    // MARK: - Module header card

    private var moduleHeaderCard: some View {
        let accent = selectedModule.color.tintColor
        let tint = selectedModule.color.tintBackground
        let total = lessons.count
        let completed = lessons.filter { progressStore.hasMasteredLesson($0.id) }.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return NumindCard(background: tint) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedModule.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)

                        Text(selectedModule.subtitle)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Surprise Me button
                    Button {
                        pickRandomLessonInModule()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(accent.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: "dice.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(accent)
                        }
                    }
                    .buttonStyle(.plain)

                    // Decorative icon (watermark)
                    Image(systemName: selectedModule.icon)
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(accent.opacity(0.12))
                        .padding(.leading, 4)
                }

                Spacer().frame(height: 16)

                // Progress bar + label
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(accent.opacity(0.2))
                            Capsule()
                                .fill(accent)
                                .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                        }
                    }
                    .frame(height: 6)

                    Text("\(completed)/\(total) mastered")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(accent.opacity(0.8))
                }
            }
        }
        .id(selectedModule.id) // force redraw on tab change
    }

    // MARK: - Lesson list

    private var lessonList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lessons".uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.8)
                .padding(.horizontal, 2)

            NumindCard {
                VStack(spacing: 0) {
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { i, lesson in
                        lessonRow(lesson: lesson, index: i)
                        if i < lessons.count - 1 {
                            Divider()
                                .padding(.leading, 18 + 32 + 14)
                                .background(Theme.Colors.hairline)
                        }
                    }
                }
            }
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
                // Index circle
                ZStack {
                    Circle()
                        .fill(mastered ? accent : (attempted ? Theme.Colors.warmOrangeTint : Theme.Colors.mutedTint))
                        .frame(width: 32, height: 32)
                    if mastered {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(attempted ? Theme.Colors.warmOrange : Theme.Colors.mutedText)
                    }
                }

                // Title + subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let acc = bestAcc {
                        Text("Best: \(Int(acc * 100))%")
                            .font(Theme.Typography.small)
                            .foregroundStyle(mastered ? accent : Theme.Colors.warmOrange)
                    } else {
                        Text("Not attempted yet")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Status icon + chevron
                HStack(spacing: 6) {
                    if mastered {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(accent)
                    } else if attempted {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.Colors.warmOrange)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func pickRandomLessonInModule() {
        guard !lessons.isEmpty else { return }
        selectedLesson = lessons.randomElement()
    }

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
