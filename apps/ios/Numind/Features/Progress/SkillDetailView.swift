import SwiftUI

struct SkillDetailView: View {
    @EnvironmentObject private var store: ProgressStore
    private let repo = LocalContentRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                ForEach(repo.allModules()) { module in
                    moduleSection(module)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Skill Mastery")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Module section

    private func moduleSection(_ module: Module) -> some View {
        let level = store.skillLevel(moduleId: module.id)
        let progress = store.skillLevelProgress(moduleId: module.id)
        let lessons = repo.lessons(for: module.id)

        return VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack(spacing: 12) {
                IconTile(systemName: module.icon, tintColor: module.color.tintColor, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(module.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(module.subtitle)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
                if level > 0 {
                    Text("Lvl \(level)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(module.color.tintColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(module.color.tintBackground)
                        .clipShape(Capsule())
                }
            }

            // Level progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.Colors.mutedTint)
                    Capsule()
                        .fill(module.color.tintColor)
                        .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                }
            }
            .frame(height: 5)

            Text(level == 0
                 ? "Complete lessons to start levelling up"
                 : "Level \(level) of 5 · \(Int(progress * 100))% to next")
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)

            // Lesson rows
            NumindCard {
                VStack(spacing: 0) {
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { i, lesson in
                        lessonRow(lesson, module: module, isLast: i == lessons.count - 1)
                    }
                }
            }
        }
    }

    // MARK: - Lesson row

    private func lessonRow(_ lesson: Lesson, module: Module, isLast: Bool) -> some View {
        let isDone = store.hasCompletedLesson(lesson.id)
        let accuracy = store.bestAccuracy(lessonId: lesson.id)

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isDone ? module.color.tintColor : Theme.Colors.mutedText.opacity(0.4))

                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.Colors.deepNavy)

                    if let acc = accuracy {
                        HStack(spacing: 4) {
                            Image(systemName: "scope")
                                .font(.system(size: 10))
                            Text("Best accuracy: \(Int(acc * 100))%")
                                .font(Theme.Typography.small)
                        }
                        .foregroundStyle(acc >= 0.8 ? module.color.tintColor : Theme.Colors.mutedText)
                    } else {
                        Text("Not attempted yet")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }

                Spacer()

                if isDone {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }
            }
            .padding(.vertical, 14)

            if !isLast {
                Divider()
                    .background(Theme.Colors.hairline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SkillDetailView()
            .environmentObject(ProgressStore())
    }
}
