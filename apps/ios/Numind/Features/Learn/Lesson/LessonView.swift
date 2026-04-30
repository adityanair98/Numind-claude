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
                    phase = .summary
                }
            }
        case .summary:
            if let vm = sessionVM {
                SessionSummaryView(viewModel: vm) {
                    dismiss()
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
                lessonHero
                ruleCard
                workedExampleCard
                whyCard
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, 8)
            .padding(.bottom, Theme.Spacing.buttonHeight + 52)
        }
    }

    // MARK: - Accent colour helper

    private var accent: Color { viewModel.moduleColor.tintColor }

    // MARK: - Lesson hero

    private var lessonHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Slim progress bar + step counter
            HStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Colors.mutedTint)
                        Capsule()
                            .fill(accent)
                            .frame(width: geo.size.width * viewModel.progress)
                    }
                }
                .frame(height: 4)
                Text(viewModel.stepLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize()
            }

            // Category chip
            Text(viewModel.contextLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(accent)
                .textCase(.uppercase)
                .kerning(0.6)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(accent.opacity(0.12))
                .clipShape(Capsule())

            // Lesson title
            Text(viewModel.lesson.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)

            // Quiz count badge
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(accent)
                Text("\(viewModel.lesson.quizTemplateIds.count) questions to follow")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.Colors.cardBackground)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Theme.Colors.hairline, lineWidth: 1))
        }
    }

    // MARK: - Rule card

    private var ruleCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("The rule")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(accent)
                    .textCase(.uppercase)
                    .kerning(0.6)
                Text(viewModel.lesson.concept)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Worked example card

    private var workedExampleCard: some View {
        let lines = viewModel.lesson.example
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Worked example")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)
                .textCase(.uppercase)
                .kerning(0.6)

            VStack(spacing: 0) {
                ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
                    let isLast = i == lines.count - 1
                    let parts = exampleLineParts(line)

                    HStack {
                        Text(parts.label)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(isLast ? accent : Theme.Colors.mutedText)
                        Spacer()
                        if !parts.value.isEmpty {
                            Text(parts.value)
                                .font(.system(size: 14, weight: isLast ? .bold : .regular, design: .monospaced))
                                .foregroundStyle(isLast ? accent : Theme.Colors.deepNavy)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(isLast ? accent.opacity(0.09) : Color.clear)

                    if !isLast {
                        Divider()
                            .background(Theme.Colors.hairline)
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private func exampleLineParts(_ line: String) -> (label: String, value: String) {
        for sep in [" = ", " ≈ ", ": "] {
            if let range = line.range(of: sep) {
                return (
                    String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespaces),
                    String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                )
            }
        }
        return (line, "")
    }

    // MARK: - Why card

    private var whyCard: some View {
        NumindCard(background: Theme.Colors.insightYellowTint) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.Colors.insightText)
                    Text("Why this works")
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.insightText)
                }
                Text(viewModel.lesson.shortcut)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Footer

    private var lessonFooter: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            PillButton("Start quiz") { startQuiz() }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
                .background(Theme.Colors.softBackground)
        }
    }

    // MARK: - Quiz start

    private func startQuiz() {
        let vm = QuizSessionViewModel(lesson: viewModel.lesson, moduleColor: viewModel.moduleColor)
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
            example: "Bill: $46.00\n10% = $4.60\n+8% = $3.68\nTip ≈ $8.28",
            quizTemplateIds: ["tip_percent_basic", "tip_bill_total", "tip_split_tip"]
        ),
        moduleTitle: "Tips, Tax & Bill Split",
        lessonIndex: 0,
        totalLessons: 3,
        moduleColor: .blue
    ))
}
