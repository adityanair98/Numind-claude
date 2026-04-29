import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedLesson: Lesson?
    private let repo = LocalContentRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                headerSection
                surpriseMeCard
                sectionLabel("Choose a skill")
                moduleSkillList
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $selectedLesson) { lesson in
            lessonCover(for: lesson)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pick a category to focus on.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
        }
    }

    // MARK: - Surprise Me

    private var surpriseMeCard: some View {
        Button {
            pickRandomLesson()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                        .fill(Theme.Colors.primaryBlue)
                        .frame(width: 52, height: 52)
                    Image(systemName: "dice.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Surprise Me")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.white)
                    Text("We'll pick a skill for you")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [Theme.Colors.primaryBlue, Theme.Colors.primaryBlue.opacity(0.75)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Module skill list

    private var moduleSkillList: some View {
        VStack(spacing: 10) {
            ForEach(repo.allModules()) { module in
                let lessons = repo.lessons(for: module.id)
                if !lessons.isEmpty {
                    moduleSkillCard(module: module, lessons: lessons)
                }
            }
        }
    }

    private func moduleSkillCard(module: Module, lessons: [Lesson]) -> some View {
        NumindCard(background: module.color.tintBackground) {
            VStack(alignment: .leading, spacing: 12) {
                // Module header
                HStack(spacing: 12) {
                    IconTile(systemName: module.icon, tintColor: module.color.tintColor, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(module.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(module.subtitle)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    Spacer()
                }

                // Lesson pills
                FlowRow(spacing: 8) {
                    ForEach(lessons) { lesson in
                        Button {
                            selectedLesson = lesson
                        } label: {
                            HStack(spacing: 5) {
                                let isDone = progressStore.hasCompletedLesson(lesson.id)
                                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(isDone ? module.color.tintColor : Theme.Colors.mutedText)
                                Text(lesson.title)
                                    .font(Theme.Typography.small)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Theme.Colors.deepNavy)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.Colors.cardBackground)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func pickRandomLesson() {
        let allLessons = repo.allModules().flatMap { repo.lessons(for: $0.id) }
        guard !allLessons.isEmpty else { return }
        selectedLesson = allLessons.randomElement()
    }

    private func lessonCover(for lesson: Lesson) -> some View {
        let modules = repo.allModules()
        let module = modules.first { $0.lessonIds.contains(lesson.id) }
        let lessons = module.map { repo.lessons(for: $0.id) } ?? []
        return LessonView(viewModel: LessonViewModel(
            lesson: lesson,
            moduleTitle: module?.title ?? "",
            lessonIndex: lessons.firstIndex(of: lesson) ?? 0,
            totalLessons: lessons.count,
            moduleColor: module?.color ?? .blue
        ))
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

// MARK: - Simple flow layout for lesson pills

struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView()
            .environmentObject(ProgressStore())
    }
}
