import SwiftUI

struct ModuleDetailView: View {
    @StateObject private var viewModel: ModuleDetailViewModel
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
                totalLessons: viewModel.lessons.count
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

            HStack {
                Text("0 of \(viewModel.lessons.count) lessons")
                    .font(Theme.Typography.small)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("0%")
                    .font(Theme.Typography.small)
                    .foregroundStyle(.white.opacity(0.85))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.22))
                    Capsule()
                        .fill(Theme.Colors.insightYellow)
                        .frame(width: 0)
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
        Button {
            selectedLesson = lesson
        } label: {
            HStack(spacing: 14) {
                numberTile(index: index)

                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("\(lesson.quizTemplateIds.count) questions")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
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

    private func numberTile(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                .fill(Theme.Colors.primaryBlueTint)
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryBlue)
        }
        .frame(width: 36, height: 36)
    }

    // MARK: - Footer

    private var footerNote: some View {
        Text("Lessons unlock as you progress")
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
