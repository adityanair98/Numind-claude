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
    @State private var presentedCalc: CalcRef?

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
                    readinessSection
                    outcomesSection
                    toolsForPathSection
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
        .sheet(item: $presentedCalc) { ref in
            NavigationStack {
                CalculatorRegistry.view(for: ref.id)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { presentedCalc = nil }
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                        }
                    }
            }
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
                    HStack(spacing: 4) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("FOCUS")
                            .font(Theme.Typography.small)
                    }
                    .foregroundStyle(Theme.Colors.mindTeal)
                }
                Text("\(progress.done) of \(progress.total) lessons")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Text(pack.title)
                .font(Theme.Typography.serifDisplay)
                .foregroundStyle(Theme.Colors.deepNavy)
                .fixedSize(horizontal: false, vertical: true)
            Text(pack.tagline)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.deepNavy.opacity(0.8))

            // Live moment line (Phase 12) — only inside a genuine window.
            if let moment = MomentsRegistry.currentMoments(
                signals: progressStore.data.onboardingSignals,
                packIds: [pack.id]
            ).first(where: { $0.packId == pack.id }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11, weight: .bold))
                    Text(moment.title)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Theme.Colors.insightText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.Colors.insightYellowTint)
                .clipShape(Capsule())
            }

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

    // MARK: - Readiness (Phase 9)

    /// The honest, decision-scoped competence signal for this path: a state
    /// badge + contextual copy + (when Almost ready) the single next action.
    /// Replaces any "you're ready for real life" verdict with an evidence-
    /// scoped claim ("you've got the essentials down").
    private var readinessSection: some View {
        let state = progressStore.readiness(for: pack)
        return NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your readiness")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Spacer()
                    ReadinessBadge(state: state)
                }
                Text(readinessCopy(for: state))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func readinessCopy(for state: ReadinessEngine.State) -> String {
        switch state {
        case .notStarted:
            return "Start with the core lessons below to build toward Ready."
        case .learning:
            return "You're building. Master the core lessons to reach Ready."
        case .almostReady(_, let nextAction):
            return "Almost there — \(nextAction)"
        case .ready:
            return ReadinessEngine.readyLabel(for: pack)
        case .sharp:
            return "\(ReadinessEngine.readyLabel(for: pack)) And it's all fresh — nicely done."
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

    // MARK: - Tools for this path (Phase 7b cross-link)

    /// Distinct calculator slugs across the pack's lessons (registry-backed).
    private var packCalcSlugs: [String] {
        var seen = Set<String>(); var out: [String] = []
        for id in pack.lessonIds {
            if let s = repo.lesson(id: id)?.relatedCalculatorSlug,
               CalculatorRegistry.name(for: s) != nil, !seen.contains(s) {
                seen.insert(s); out.append(s)
            }
        }
        return out
    }

    @ViewBuilder
    private var toolsForPathSection: some View {
        let slugs = packCalcSlugs
        if !slugs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("TOOLS FOR THIS PATH")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .tracking(1.0)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(slugs, id: \.self) { slug in
                            Button { presentedCalc = CalcRef(id: slug) } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "wrench.and.screwdriver")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(CalculatorRegistry.name(for: slug) ?? "")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(Theme.Colors.mindTeal)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(Theme.Colors.mindTealTint)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
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
                .foregroundStyle(Theme.Colors.ctaLabel)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Spacing.buttonHeight)
                .background(Theme.Colors.ctaFill)
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

/// Identifiable slug wrapper for presenting a calculator sheet (Phase 7b).
struct CalcRef: Identifiable { let id: String }

/// Lightweight payload for `.fullScreenCover(item:)` to launch a lesson.
struct LessonLaunch: Identifiable {
    let id: String
    let lesson: Lesson
    let module: Module
    let lessonIndex: Int
    let totalLessons: Int
}
