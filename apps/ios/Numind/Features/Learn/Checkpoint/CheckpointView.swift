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
    @State private var sessionNumindScore: Int = 0
    @State private var sessionScoreDelta: Int = 0
    @State private var pendingLevelUp: LevelUpInfo? = nil

    var body: some View {
        NavigationStack {
            phaseContent
                .background(Theme.Colors.softBackground.ignoresSafeArea())
        }
        // Level-up ceremony (if a module level crossed) → then summary.
        .fullScreenCover(item: $pendingLevelUp, onDismiss: { phase = .summary }) { info in
            LevelUpView(info: info)
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
                    numindScore: sessionNumindScore,
                    scoreDelta: sessionScoreDelta,
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
        pendingLevelUp    = nil
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

        // Capture level and score BEFORE recording.
        let prevLevel = progressStore.skillLevel(moduleId: module.id)
        let scoreBefore = progressStore.numindScore

        var record = SessionRecord(
            id: UUID(),
            lessonId: reviewId,       // e.g. "review_tips_0" — stable for mastery tracking
            moduleId: module.id,      // ties to module for XP / streak context
            date: Date(),
            correctCount: vm.correctCount,
            totalCount: vm.total
        )
        record.questionResults = vm.questionResults
        record.bonusXP         = vm.bonusXP
        progressStore.recordSession(record)
        newBadgeIds = progressStore.newlyEarnedBadgeIds
        sessionNumindScore = progressStore.numindScore
        sessionScoreDelta = progressStore.numindScore - scoreBefore

        // Level-up ceremony only fires when the user actually mastered the review.
        if didMasterThisSession {
            let newLevel = progressStore.skillLevel(moduleId: module.id)
            if newLevel > prevLevel {
                pendingLevelUp = LevelUpInfo(
                    moduleName:  module.title,
                    moduleIcon:  module.icon,
                    moduleColor: module.color,
                    newLevel:    newLevel
                )
                // phase = .summary deferred to fullScreenCover onDismiss
            } else {
                phase = .summary
            }
        } else {
            phase = .summary
        }
    }
}
