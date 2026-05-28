import SwiftUI

/// Full-screen detail view for a Pack. Shows hero, anchor lesson, the
/// ordered lesson list with mastery indicators, and a footer CTA that
/// either marks the pack as the user's focus or jumps to the next undone
/// lesson if it's already the focus.
///
/// Tapping any lesson opens `LessonView` (soft-locks: every lesson is
/// tappable). When the user closes the lesson, control returns here.
struct PackDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    let pack: Pack

    @State private var launchLesson: LessonLaunch?

    /// Resolves lesson lookups + pack-level neighbors (which module each
    /// lesson lives in, for the right `moduleColor` and lesson index).
    private let repo = LocalContentRepository()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                    heroSection
                    if let anchor = anchorLesson {
                        anchorSection(anchor: anchor)
                    }
                    outcomesSection
                    lessonListSection
                    ctaSection
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.sectionSpacing)
            }
            .background(Theme.Colors.softBackground.ignoresSafeArea())
            .navigationTitle(pack.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
        }
        .fullScreenCover(item: $launchLesson) { launch in
            LessonView(viewModel: LessonViewModel(
                lesson: launch.lesson,
                moduleTitle: launch.module.title,
                lessonIndex: launch.lessonIndex,
                totalLessons: launch.totalLessons,
                moduleColor: launch.module.color
            ))
        }
    }

    // MARK: - Derived

    private var anchorLesson: Lesson? {
        repo.lesson(id: pack.anchorLessonId)
    }

    private var progress: (done: Int, total: Int) {
        progressStore.packProgress(packId: pack.id)
    }

    private var isFocus: Bool {
        progressStore.focusPackId == pack.id
    }

    private var nextUndoneLessonId: String? {
        let mastered = progressStore.masteredLessonIds
        return pack.lessonIds.first { !mastered.contains($0) }
    }

    private var ctaTitle: String {
        if let nextId = nextUndoneLessonId,
           let lesson = repo.lesson(id: nextId) {
            if isFocus {
                return "Continue path — \(lesson.title)"
            } else {
                return "Make this my focus"
            }
        }
        return "Path complete ✓"
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if isFocus {
                    Text("📍 FOCUS")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mindTeal)
                }
                Text("\(progress.done) of \(progress.total) lessons")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Text(pack.title)
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.deepNavy)
            Text(pack.tagline)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.deepNavy.opacity(0.8))

            // Description
            Text(pack.description)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .padding(.top, 4)

            HStack(spacing: 12) {
                statChip(label: "\(pack.lessonIds.count) lessons")
                statChip(label: "~\(pack.estimatedMinutes) min")
            }
            .padding(.top, 4)
        }
    }

    private func statChip(label: String) -> some View {
        Text(label)
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.deepNavy)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.Colors.mutedTint)
            .clipShape(Capsule())
    }

    // MARK: - Anchor

    private func anchorSection(anchor: Lesson) -> some View {
        NumindCard(background: Theme.Colors.mindTealTint) {
            VStack(alignment: .leading, spacing: 8) {
                Text("START HERE")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mindTeal)
                Text(anchor.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(anchor.shortcut)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .lineLimit(3)
                Button(action: { launch(lessonId: anchor.id) }) {
                    HStack {
                        Text("Take this first")
                            .font(Theme.Typography.headline)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .padding(.vertical, 10)
                }
            }
        }
    }

    // MARK: - Outcomes (Phase 6c)

    /// Up to 4 distinct money-moment hints from the pack's lessons — answers
    /// "what real situations does this path prepare me for?"
    private var outcomeHints: [String] {
        var seen = Set<String>()
        var hints: [String] = []
        for id in pack.lessonIds {
            guard let h = repo.lesson(id: id)?.realWorldHint, !seen.contains(h) else { continue }
            seen.insert(h)
            hints.append(h)
            if hints.count == 4 { break }
        }
        return hints
    }

    @ViewBuilder
    private var outcomesSection: some View {
        let hints = outcomeHints
        if !hints.isEmpty {
            NumindCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Real-life moments this path prepares you for")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(hints.enumerated()), id: \.offset) { _, hint in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.mindTeal)
                                    .padding(.top, 1)
                                Text(hint)
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Colors.deepNavy.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Lesson list

    private var lessonListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The path, in order")
                .font(Theme.Typography.title)
                .foregroundStyle(Theme.Colors.deepNavy)

            VStack(spacing: 8) {
                ForEach(Array(pack.lessonIds.enumerated()), id: \.offset) { index, lessonId in
                    if let lesson = repo.lesson(id: lessonId) {
                        lessonRow(index: index, lesson: lesson)
                    }
                }
            }
        }
    }

    private func lessonRow(index: Int, lesson: Lesson) -> some View {
        let isMastered = progressStore.hasMasteredLesson(lesson.id)
        let isAnchor = lesson.id == pack.anchorLessonId
        return Button(action: { launch(lessonId: lesson.id) }) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isMastered ? Theme.Colors.growthGreenTint : Theme.Colors.mutedTint)
                        .frame(width: 32, height: 32)
                    if isMastered {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.growthGreen)
                    } else {
                        Text("\(index + 1)")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.deepNavy)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .multilineTextAlignment(.leading)
                    if isAnchor {
                        Text("ANCHOR LESSON")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            .padding(Theme.Spacing.cardPadding)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        Button(action: ctaTap) {
            Text(ctaTitle)
                .font(Theme.Typography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Spacing.buttonHeight)
                .background(Theme.Colors.deepNavy)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
        }
        .disabled(nextUndoneLessonId == nil)
        .opacity(nextUndoneLessonId == nil ? 0.5 : 1.0)
    }

    private func ctaTap() {
        if isFocus, let nextId = nextUndoneLessonId {
            launch(lessonId: nextId)
        } else if nextUndoneLessonId != nil {
            progressStore.setFocusPack(pack.id)
        }
    }

    // MARK: - Lesson launch

    private func launch(lessonId: String) {
        guard let lesson = repo.lesson(id: lessonId),
              let module = repo.allModules().first(where: { $0.lessonIds.contains(lesson.id) })
        else { return }
        let lessonIndex = module.lessonIds.firstIndex(of: lesson.id) ?? 0
        launchLesson = LessonLaunch(
            id: lesson.id,
            lesson: lesson,
            module: module,
            lessonIndex: lessonIndex,
            totalLessons: module.lessonIds.count
        )
    }
}

/// Lightweight payload for `.fullScreenCover(item:)` to launch a lesson.
struct LessonLaunch: Identifiable {
    let id: String
    let lesson: Lesson
    let module: Module
    let lessonIndex: Int
    let totalLessons: Int
}
