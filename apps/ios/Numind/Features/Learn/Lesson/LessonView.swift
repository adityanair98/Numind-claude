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
        .sheet(isPresented: $showCalc) {
            if let slug = viewModel.lesson.relatedCalculatorSlug {
                NavigationStack {
                    CalculatorRegistry.view(for: slug)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showCalc = false }
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Theme.Colors.primaryBlue)
                            }
                        }
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
                verifiedStamp
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

            // Money-moment hint — "You'll use this when…" (Phase 6c)
            if let hint = viewModel.lesson.realWorldHint {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accent)
                        .padding(.top, 2)
                    Text(hint)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Quiz count badge
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(accent)
                Text("\(QuizSessionViewModel.lessonQuestionCount(lessonId: viewModel.lesson.id, moduleId: viewModel.lesson.moduleId, sessions: progressStore.data.sessions, signals: progressStore.data.onboardingSignals)) questions to follow")
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
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.insightYellow.opacity(0.25))
                            .frame(width: 30, height: 30)
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.insightText)
                    }
                    Text("Why this works")
                        .font(Theme.Typography.small)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Colors.insightText)
                        .textCase(.uppercase)
                        .kerning(0.6)
                }
                Text(viewModel.lesson.shortcut)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
            }
        }
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(
                topLeadingRadius: Theme.Radius.card,
                bottomLeadingRadius: Theme.Radius.card,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
            .fill(Theme.Colors.insightYellow)
            .frame(width: 5)
        }
    }

    // MARK: - Verified stamp (E-E-A-T trust signal)

    /// A quiet "Verified [Month Year]" line under the teaching cards, shown only
    /// when the lesson carries a `lastVerified` date. Reinforces the accuracy
    /// moat for YMYL content without competing with the lesson copy.
    @ViewBuilder
    private var verifiedStamp: some View {
        if let raw = viewModel.lesson.lastVerified, !raw.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.Colors.growthGreen)
                Text("Verified \(Self.verifiedDateLabel(raw))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 2)
        }
    }

    /// "2026-01-15" → "Jan 2026"; falls back to the raw string if unparseable.
    private static func verifiedDateLabel(_ raw: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let date = parser.date(from: raw) else { return raw }
        let out = DateFormatter()
        out.dateFormat = "MMM yyyy"
        return out.string(from: date)
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

            VStack(spacing: 10) {
                // "Try this with your numbers" — opens the matching calculator (Phase 7a)
                if let slug = viewModel.lesson.relatedCalculatorSlug,
                   let name = CalculatorRegistry.name(for: slug) {
                    Button { showCalc = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Try this in \(name)")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(accent.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                PillButton("Start quiz") { startQuiz() }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 28)
            .background(Theme.Colors.softBackground)
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
