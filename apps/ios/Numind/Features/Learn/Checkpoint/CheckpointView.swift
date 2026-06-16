import SwiftUI

/// Presents a module review quiz (no lesson-content phase — jumps straight to questions).
/// Progress is recorded with the review's stable ID so mastery gating works identically
/// to lesson nodes.
struct CheckpointView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore

    let reviewId: String
    let reviewLessonIds: [String]
    let module: Module

    enum Phase { case quiz, summary }
    @State private var phase: Phase = .quiz
    @State private var sessionVM: QuizSessionViewModel? = nil
    @State private var isNewPersonalBest = false
    @State private var newBadgeIds: Set<String> = []
    @State private var skillChanges: [SkillMove] = []

    var body: some View {
        NavigationStack {
            phaseContent
                .background(Theme.Colors.softBackground.ignoresSafeArea())
        }
        .onAppear { buildQuiz() }
    }

    // MARK: - Phase content

    @ViewBuilder
    private var phaseContent: some View {
        switch phase {
        case .quiz:
            if let vm = sessionVM {
                QuizSessionView(viewModel: vm) { onQuizComplete(vm: vm) }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .summary:
            if let vm = sessionVM {
                SessionSummaryView(
                    viewModel: vm,
                    isPersonalBest: isNewPersonalBest,
                    newBadgeIds: newBadgeIds,
                    skillChanges: skillChanges,
                    onContinue: { dismiss() },
                    onRetry:    { retryQuiz() }
                )
            }
        }
    }

    // MARK: - Quiz lifecycle

    private func buildQuiz() {
        let questions = CheckpointQuizEngine.build(lessonIds: reviewLessonIds)
        sessionVM = QuizSessionViewModel(
            questions: questions,
            title: "Module Review",
            shortcut: "Apply everything you've learned in \(module.title).",
            moduleColor: module.color
        )
        phase = .quiz
    }

    private func retryQuiz() {
        isNewPersonalBest = false
        newBadgeIds       = []
        skillChanges      = []
        buildQuiz()
    }

    private func onQuizComplete(vm: QuizSessionViewModel) {
        let didMasterThisSession = vm.total > 0
            && Double(vm.correctCount) / Double(vm.total) >= 0.75

        // Personal best — only meaningful on a passing attempt.
        if didMasterThisSession {
            let priorBest = progressStore.data.bestResult(for: reviewId)
            if let prior = priorBest {
                isNewPersonalBest = vm.correctCount > prior.correctCount
                    || (vm.correctCount == prior.correctCount && vm.totalXP > prior.totalXP)
            } else {
                isNewPersonalBest = true   // first mastered attempt is a personal best
            }
        } else {
            isNewPersonalBest = false
        }

        // Diff mastery across the recording for capability language in the
        // summary (Phase 10 — replaces +XP/Level).
        let masteredBefore = progressStore.masteredLessonIds

        var record = SessionRecord(
            id: UUID(),
            lessonId: reviewId,       // e.g. "review_tips_0" — stable for mastery tracking
            moduleId: module.id,      // ties to module for streak context
            date: Date(),
            correctCount: vm.correctCount,
            totalCount: vm.total
        )
        record.questionResults = vm.questionResults
        progressStore.recordSession(record)
        newBadgeIds = progressStore.newlyEarnedBadgeIds

        let repo = LocalContentRepository()
        skillChanges = progressStore.masteredLessonIds
            .subtracting(masteredBefore)
            .compactMap { repo.lesson(id: $0) }
            .map { SkillMove(title: $0.title, change: .mastered) }

        phase = .summary
    }
}
