import SwiftUI

/// Presents a Speed Drill session — 8 MCQ questions with a 15-second per-question
/// countdown — and shows a SessionSummaryView on completion.
///
/// Follows the same phase pattern as CheckpointView: quiz → summary within
/// a single fullScreenCover, with retry support.
struct SpeedDrillView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore

    enum Phase { case quiz, summary }
    @State private var phase: Phase = .quiz
    @State private var sessionVM: QuizSessionViewModel? = nil
    @State private var isNewPersonalBest = false
    @State private var newBadgeIds: Set<String> = []
    @State private var sessionNumindScore: Int = 0
    @State private var sessionScoreDelta: Int = 0

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
                    numindScore: sessionNumindScore,
                    scoreDelta: sessionScoreDelta,
                    onContinue: { dismiss() },
                    onRetry:    { retryDrill() }
                )
            }
        }
    }

    // MARK: - Quiz lifecycle

    private func buildQuiz() {
        let templates = MasteredTemplatePool.mcqTemplates(from: progressStore.data)
        guard !templates.isEmpty else {
            // Fallback: shouldn't happen — modes are locked until templates exist.
            dismiss()
            return
        }

        var shuffled = templates.shuffled()
        var questions: [QuizQuestion] = []
        var idx = 0
        while questions.count < QuizSessionViewModel.targetQuestionCount {
            questions.append(QuizEngine.generate(from: shuffled[idx % shuffled.count]))
            idx += 1
        }
        questions.shuffle()

        sessionVM = QuizSessionViewModel(
            questions: questions,
            title: "Speed Drill",
            shortcut: "Answer fast! 15 seconds per question — time's up means wrong.",
            moduleColor: .teal,
            questionTimeLimit: 15.0
        )
        phase = .quiz
    }

    private func retryDrill() {
        isNewPersonalBest = false
        newBadgeIds       = []
        buildQuiz()
    }

    private func onQuizComplete(vm: QuizSessionViewModel) {
        let didMasterThisSession = vm.total > 0
            && Double(vm.correctCount) / Double(vm.total) >= 0.75

        // Personal best: compare against all prior speed_drill sessions.
        if didMasterThisSession {
            let priorBest = progressStore.data.bestResult(for: "speed_drill")
            if let prior = priorBest {
                isNewPersonalBest = vm.correctCount > prior.correctCount
                    || (vm.correctCount == prior.correctCount && vm.totalXP > prior.totalXP)
            } else {
                isNewPersonalBest = true   // first passing attempt is always a personal best
            }
        } else {
            isNewPersonalBest = false
        }

        let scoreBefore = progressStore.numindScore

        var record = SessionRecord(
            id: UUID(),
            lessonId: "speed_drill",
            moduleId: "mixed",
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

        phase = .summary
    }
}
