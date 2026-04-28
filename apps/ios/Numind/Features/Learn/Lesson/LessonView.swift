import SwiftUI

struct LessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    let viewModel: LessonViewModel

    enum Phase { case lesson, quiz, summary }

    @State private var phase: Phase = .lesson
    @State private var sessionVM: QuizSessionViewModel?

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
                    progressStore.recordSession(SessionRecord(
                        id: UUID(),
                        lessonId: viewModel.lesson.id,
                        moduleId: viewModel.lesson.moduleId,
                        date: Date(),
                        correctCount: vm.correctCount,
                        totalCount: vm.total
                    ))
                    phase = .summary
                }
            }
        case .summary:
            if let vm = sessionVM {
                SessionSummaryView(viewModel: vm) {
                    dismiss()       // "Continue learning" → back to module detail
                }
            }
        }
    }

    // MARK: - Lesson phase

    private var lessonPhaseView: some View {
        ZStack(alignment: .bottom) {
            lessonScrollContent
            lessonFooter
        }
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
    }

    private var lessonScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                headerSection
                conceptCard
                insightCard
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 8)
            .padding(.bottom, Theme.Spacing.buttonHeight + 52)
        }
    }

    // MARK: - Lesson header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Colors.mutedTint)
                        Capsule()
                            .fill(Theme.Colors.primaryBlue)
                            .frame(width: geo.size.width * viewModel.progress)
                    }
                }
                .frame(height: 6)

                Text(viewModel.stepLabel)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize()
            }

            Text(viewModel.contextLabel)
                .font(Theme.Typography.small)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.Colors.primaryBlue)
                .textCase(.uppercase)
                .kerning(0.6)

            Text(viewModel.lesson.title)
                .font(Theme.Typography.title)
                .foregroundStyle(Theme.Colors.deepNavy)
        }
    }

    // MARK: - Concept card

    private var conceptCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(viewModel.lesson.concept)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)

                if !viewModel.lesson.example.isEmpty {
                    Text(viewModel.lesson.example)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.softBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    // MARK: - Insight card

    private var insightCard: some View {
        NumindCard(background: Theme.Colors.insightYellowTint) {
            HStack(alignment: .top, spacing: 12) {
                IconTile(systemName: "lightbulb.fill", tintColor: Theme.Colors.insightYellow, size: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Why this works")
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.insightText)
                    Text(viewModel.lesson.shortcut)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.insightText)
                }
            }
        }
    }

    // MARK: - Lesson footer

    private var lessonFooter: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            PillButton("Continue") { startQuiz() }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
                .background(Theme.Colors.softBackground)
        }
    }

    // MARK: - Quiz start

    private func startQuiz() {
        let vm = QuizSessionViewModel(lesson: viewModel.lesson)
        sessionVM = vm
        phase = .quiz
    }
}

#Preview {
    LessonView(viewModel: LessonViewModel(
        lesson: Lesson(
            id: "tip_18_percent",
            moduleId: "tips",
            title: "Calculate an 18% tip",
            concept: "18% is one of the most common tip amounts. Start with 10%, then add half again for 15%, then add 3% more.",
            shortcut: "Find 10% by moving the decimal left one place. Then build up: 10% + 5% + 3% = 18%.",
            example: "Bill: $46.00\n10% = $4.60\n+8% = $3.68\nTip  ≈ $8.28",
            quizTemplateIds: ["tip_percent_basic", "tip_bill_total", "tip_split_tip"]
        ),
        moduleTitle: "Tips, Tax & Bill Split",
        lessonIndex: 0,
        totalLessons: 1
    ))
}
