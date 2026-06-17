import SwiftUI

struct LessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    let viewModel: LessonViewModel

    enum Phase { case lesson, quiz, summary }

    @State private var phase: Phase = .lesson
    @State private var sessionVM: QuizSessionViewModel?
    @State private var isNewPersonalBest: Bool = false
    @State private var newBadgeIds: Set<String> = []
    @State private var skillChanges: [SkillMove] = []
    @State private var showCalc = false

    var body: some View {
        NavigationStack {
            phaseContent
                .background(Theme.Colors.softBackground.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch phase {
        case .lesson:
            lessonPhaseView
        case .quiz:
            if let vm = sessionVM {
                QuizSessionView(viewModel: vm) {
                    let didMasterThisSession = vm.total > 0
                        && Double(vm.correctCount) / Double(vm.total) >= 0.75

                    // Personal best — only meaningful on a passing attempt.
                    if didMasterThisSession {
                        let priorBest = progressStore.data.bestResult(for: viewModel.lesson.id)
                        if let prior = priorBest {
                            isNewPersonalBest = vm.correctCount > prior.correctCount
                                || (vm.correctCount == prior.correctCount && vm.totalXP > prior.totalXP)
                        } else {
                            isNewPersonalBest = true   // first mastered attempt is a personal best
                        }
                    } else {
                        isNewPersonalBest = false
                    }

                    // Diff mastery across the recording to surface capability
                    // language in the summary (Phase 10 — replaces +XP/Level).
                    let masteredBefore = progressStore.masteredLessonIds

                    var record = SessionRecord(
                        id: UUID(),
                        lessonId: viewModel.lesson.id,
                        moduleId: viewModel.lesson.moduleId,
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
        case .summary:
            if let vm = sessionVM {
                SessionSummaryView(
                    viewModel: vm,
                    isPersonalBest: isNewPersonalBest,
                    newBadgeIds: newBadgeIds,
                    skillChanges: skillChanges,
                    onContinue: { dismiss() },
                    onRetry: { retryQuiz() }
                )
            }
        }
    }

    // MARK: - Lesson phase

    private var lessonPhaseView: some View {
        LessonStoryView(
            viewModel: viewModel,
            questionCount: QuizSessionViewModel.lessonQuestionCount(
                lessonId: viewModel.lesson.id,
                moduleId: viewModel.lesson.moduleId,
                sessions: progressStore.data.sessions,
                signals: progressStore.data.onboardingSignals
            ),
            onStartQuiz: { startQuiz() },
            onShowCalculator: viewModel.lesson.relatedCalculatorSlug != nil
                ? { showCalc = true } : nil
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
        }
        .sheet(isPresented: $showCalc) {
            if let slug = viewModel.lesson.relatedCalculatorSlug {
                NavigationStack {
                    CalculatorRegistry.view(for: slug)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showCalc = false }
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Theme.Colors.mindTeal)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Quiz start / retry

    private func startQuiz() {
        let vm = QuizSessionViewModel(
            lesson: viewModel.lesson,
            moduleColor: viewModel.moduleColor,
            sessions: progressStore.data.sessions,   // enables SR ordering on repeat visits
            signals: progressStore.data.onboardingSignals
        )
        sessionVM = vm
        phase = .quiz
    }

    /// Regenerates the quiz with fresh random seeds → different values and answer options.
    private func retryQuiz() {
        let vm = QuizSessionViewModel(
            lesson: viewModel.lesson,
            moduleColor: viewModel.moduleColor,
            sessions: progressStore.data.sessions,
            signals: progressStore.data.onboardingSignals
        )
        isNewPersonalBest = false
        newBadgeIds = []
        skillChanges = []
        sessionVM = vm
        phase = .quiz
    }
}

#Preview {
    LessonView(viewModel: LessonViewModel(
        lesson: Lesson(
            id: "tip_18_percent",
            moduleId: "smart_shopping",
            title: "Calculate an 18% tip",
            concept: "18% is one of the most common tip amounts. Start with 10%, then add half again for 15%, then add 3% more.",
            shortcut: "Find 10% by moving the decimal left one place. Then build up: 10% + 5% + 3% = 18%.",
            example: "Bill: $46.00\n10% = $4.60\n+8% = $3.68\nTip ≈ $8.28",
            quizTemplateIds: ["tip_percent_basic", "tip_bill_total", "tip_split_tip"],
            lastVerified: nil
        ),
        moduleTitle: "Smart Shopping",
        lessonIndex: 0,
        totalLessons: 3,
        moduleColor: .blue
    ))
}
