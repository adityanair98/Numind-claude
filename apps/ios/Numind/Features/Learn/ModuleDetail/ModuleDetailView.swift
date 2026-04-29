import SwiftUI

struct ModuleDetailView: View {
    @StateObject private var viewModel: ModuleDetailViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedLesson: Lesson?

    init(module: Module, moduleIndex: Int, totalModules: Int) {
        _viewModel = StateObject(wrappedValue: ModuleDetailViewModel(
            module: module, moduleIndex: moduleIndex, totalModules: totalModules
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                moduleHeaderCard
                lessonListSection
                footerNote
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle(viewModel.module.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonView(viewModel: LessonViewModel(
                lesson: lesson,
                moduleTitle: viewModel.module.title,
                lessonIndex: viewModel.lessons.firstIndex(of: lesson) ?? 0,
                totalLessons: viewModel.lessons.count,
                moduleColor: viewModel.module.color
            ))
        }
    }

    // MARK: - Module header card

    private var moduleHeaderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                IconTile(
                    systemName: viewModel.module.icon,
                    tintColor: .white,
                    size: 48
                )
                .background(.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.iconTile, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.moduleLabel)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(viewModel.module.subtitle)
                        .font(Theme.Typography.small)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
            }

            let completed = progressStore.completedLessonCount(moduleId: viewModel.module.id)
            let total = viewModel.lessons.count
            let progress = total > 0 ? Double(completed) / Double(total) : 0

            HStack {
                Text("\(completed) of \(total) lessons")
                    .font(Theme.Typography.small)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(Theme.Typography.small)
                    .foregroundStyle(.white.opacity(0.85))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.22))
                    Capsule()
                        .fill(Theme.Colors.insightYellow)
                        .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                }
            }
            .frame(height: 6)
        }
        .padding(22)
        .background(viewModel.module.color.tintColor)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Lesson list

    private var lessonListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Lessons")

            VStack(spacing: 0) {
                ForEach(Array(viewModel.lessons.enumerated()), id: \.element.id) { index, lesson in
                    lessonRow(lesson: lesson, index: index)
                    if index < viewModel.lessons.count - 1 {
                        Divider()
                            .padding(.leading, 18 + 36 + 14) // align to text
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }

    private func lessonRow(lesson: Lesson, index: Int) -> some View {
        let isDone = progressStore.hasCompletedLesson(lesson.id)
        let moduleColor = viewModel.module.color
        return Button {
            selectedLesson = lesson
        } label: {
            HStack(spacing: 14) {
                lessonTile(index: index, isDone: isDone, moduleColor: moduleColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    if isDone {
                        Text("Completed · \(lesson.quizTemplateIds.count) questions")
                            .font(Theme.Typography.small)
                            .foregroundStyle(moduleColor.tintColor)
                    } else {
                        Text(lesson.concept)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
        }
        .buttonStyle(.plain)
    }

    private func lessonTile(index: Int, isDone: Bool, moduleColor: ModuleColor) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                .fill(isDone ? moduleColor.tintBackground : Theme.Colors.mutedTint)
            if isDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(moduleColor.tintColor)
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .frame(width: 36, height: 36)
    }

    // MARK: - Footer

    private var footerNote: some View {
        Text("More lessons coming soon")
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .frame(maxWidth: .infinity)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

#Preview {
    NavigationStack {
        ModuleDetailView(
            module: Module(
                id: "tips",
                title: "Tips, Tax & Bill Split",
                subtitle: "Everyday restaurant and shopping math",
                icon: "percent",
                color: .blue,
                lessonIds: ["tip_18_percent"]
            ),
            moduleIndex: 0,
            totalModules: 4
        )
    }
}
