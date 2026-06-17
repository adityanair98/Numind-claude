import SwiftUI

private let choiceKeys = ["A", "B", "C", "D"]

struct QuizSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @ObservedObject var viewModel: QuizSessionViewModel
    let onComplete: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            scrollContent
            footer
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.lessonTitle)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.questionTimeLimit != nil {
                    countdownRing
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        timerPill
                    }
                }
            }
        }
        .onAppear {
            viewModel.startSession()
        }
        .onChange(of: viewModel.sessionState) { _, newState in
            if case .complete = newState { onComplete() }
            // Per-answer feedback is CALM — a settle + haptic, never confetti.
            // Confetti/celebration is reserved for milestone sheets only
            // (Phase 13 design-language spec; MilestoneCelebrationView owns it).
            if case .feedback = newState {
                if viewModel.isCorrectAnswer {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    // MARK: - Timer pill (standard quiz)

    private var timerPill: some View {
        Text(viewModel.elapsedTimeString)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(Theme.Colors.mutedText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.Colors.mutedTint)
            .clipShape(Capsule())
    }

    // MARK: - Countdown ring (Speed Drill)

    private var countdownRing: some View {
        let limit = viewModel.questionTimeLimit ?? 15
        let remaining = viewModel.questionTimeRemaining
        let progress = limit > 0 ? remaining / limit : 0
        let ringColor: Color = {
            if remaining > 5 { return Theme.Colors.primaryBlue }
            if remaining > 3 { return Theme.Colors.warmOrange }
            return Theme.Colors.errorSoftRed
        }()
        return ZStack {
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: remaining)
            Text("\(max(0, Int(ceil(remaining))))")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(ringColor)
                .animation(.none, value: remaining)
        }
        .frame(width: 40, height: 40)
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        Group {
            if case .teach(let card) = viewModel.sessionState {
                // Teach card takes over the full screen before new material.
                TeachCardView(card: card, accent: viewModel.moduleColor.tintColor) {
                    viewModel.advance()
                }
            } else if case .motivator(let checkpoint) = viewModel.sessionState {
                // Motivator takes over the full screen — show with daily streak from ProgressStore
                motivatorScreen(checkpoint: checkpoint)
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.sectionSpacing) {
                        beadRail
                        if let segment = viewModel.currentSegmentLabel {
                            Text(segment.uppercased())
                                .font(Theme.Typography.overline)
                                .tracking(1.4)
                                .foregroundStyle(Theme.Colors.mutedText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        switch viewModel.sessionState {
                        case .question, .answered:
                            questionContent
                                .transition(.opacity)
                        case .feedback:
                            ZStack {
                                feedbackContent
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                // Inline encouragement overlay
                                if let encouragement = viewModel.inlineEncouragement {
                                    InlineEncouragementView(
                                        encouragement: encouragement,
                                        onContinue: { viewModel.advance() }
                                    )
                                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                                }
                            }
                        case .complete, .motivator, .teach:
                            EmptyView()
                        }
                    }
                    .animation(.spring(response: 0.38, dampingFraction: 0.72), value: viewModel.sessionState)
                    .animation(.spring(response: 0.32, dampingFraction: 0.75), value: viewModel.hintRevealed)
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, 8)
                    .padding(.bottom, Theme.Spacing.buttonHeight + 52)
                }
            }
        }
    }

    /// Full-screen motivator checkpoint with daily streak injected from ProgressStore.
    private func motivatorScreen(checkpoint: MotivatorCheckpoint) -> some View {
        var cp = checkpoint
        // Inject daily streak from ProgressStore for near-finish cards
        if checkpoint.type == .nearFinish {
            cp.dailyStreak = progressStore.streak
        }
        return MotivatorView(checkpoint: cp) {
            viewModel.advance()
        }
    }

    // MARK: - Bead rail

    private var beadRail: some View {
        BeadRail(
            progress: viewModel.currentIndex + 1,
            total: viewModel.total,
            variant: .chunky
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Question content

    private var questionContent: some View {
        let q = viewModel.currentQuestion
        return VStack(spacing: Theme.Spacing.sectionSpacing) {
            // Themed graphic banner + prompt card — grouped as a visual unit
            VStack(spacing: 8) {
                QuizGraphicBanner(theme: QuestionTheme.theme(for: q.templateId))

                // Prompt card (shared between both input modes)
                NumindCard {
                    VStack(alignment: .leading, spacing: 12) {
                        // Top meta row: module label · difficulty · question counter
                        HStack(spacing: 0) {
                            Text(viewModel.lessonTitle)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(viewModel.moduleColor.tintColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(viewModel.moduleColor.tintBackground)
                                .clipShape(Capsule())
                            Spacer()
                            difficultyPips(q.difficulty)
                                .padding(.trailing, 8)
                            Text("\(viewModel.currentIndex + 1) / \(viewModel.total)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }

                        // Context + question flow together naturally.
                        // Context in normal weight, question in bold.
                        if let scenario = q.scenario {
                            Text(scenario)
                                .font(Theme.Typography.body)
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                        }

                        Text(q.prompt)
                            .font(Theme.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                    }
                }
            }

            // Input area — numpad or option cards
            if q.inputMode == .freeEntry {
                freeEntrySection(for: q)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(q.choices.enumerated()), id: \.element.id) { i, choice in
                        OptionCard(
                            key: choiceKeys[safe: i] ?? "?",
                            text: choice.text,
                            state: questionCardState(for: choice),
                            action: {
                                viewModel.select(choice.id)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        )
                    }
                }
                hintSection
            }
        }
    }

    // MARK: - Free-entry input

    private func freeEntrySection(for q: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            // Display strip
            freeEntryDisplay(for: q)
            // Numpad
            NumpadView(
                onDigit:   { viewModel.appendDigit($0); UIImpactFeedbackGenerator(style: .light).impactOccurred() },
                onDecimal: { viewModel.appendDigit("."); UIImpactFeedbackGenerator(style: .light).impactOccurred() },
                onDelete:  { viewModel.deleteDigit();   UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            )
        }
    }

    private func freeEntryDisplay(for q: QuizQuestion) -> some View {
        let raw   = viewModel.freeEntryText
        let label: String = {
            if raw.isEmpty { return q.answerFormat == .currency ? "$—" : "—" }
            switch q.answerFormat {
            case .currency: return "$\(raw)"
            case .percent:  return "\(raw)%"
            case .integer:  return raw
            }
        }()
        return Text(label)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundStyle(raw.isEmpty ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Theme.Colors.mutedTint)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .animation(.none, value: raw)
    }

    // MARK: - Hint

    @ViewBuilder
    private var hintSection: some View {
        if viewModel.hintRevealed {
            NumindCard(background: Theme.Colors.insightYellowTint) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.insightYellow.opacity(0.25))
                                .frame(width: 28, height: 28)
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.Colors.insightText)
                        }
                        Text("Shortcut")
                            .font(Theme.Typography.small)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.insightText)
                            .textCase(.uppercase)
                            .kerning(0.6)
                    }
                    Text(viewModel.lessonShortcut)
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
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        } else {
            Button {
                viewModel.revealHint()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Colors.insightText)
                    Text("Show shortcut")
                        .font(Theme.Typography.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.insightText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.Colors.insightYellowTint)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Difficulty pips

    private func difficultyPips(_ difficulty: QuestionDifficulty) -> some View {
        HStack(spacing: 3) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= difficulty.rawValue
                          ? viewModel.moduleColor.tintColor
                          : Theme.Colors.mutedTint)
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityLabel(difficulty.label)
    }

    private func questionCardState(for choice: QuizQuestion.Choice) -> OptionCardState {
        guard let selectedId = viewModel.selectedChoiceId else { return .normal }
        return choice.id == selectedId ? .selected : .normal
    }

    // MARK: - Feedback content

    private var feedbackContent: some View {
        let q = viewModel.currentQuestion
        let isCorrect = viewModel.isCorrectAnswer
        return VStack(spacing: Theme.Spacing.sectionSpacing) {
            resultHeroCard(isCorrect: isCorrect)
            answerRevealPill(for: q, isCorrect: isCorrect)
            if q.inputMode == .multipleChoice {
                optionsRecap(for: q, isCorrect: isCorrect)
            }
            whyCard(explanation: q.explanation)
        }
    }

    private func resultHeroCard(isCorrect: Bool) -> some View {
        NumindCard(background: isCorrect ? Theme.Colors.mindTealTint : Theme.Colors.warmOrangeTint) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCorrect ? Theme.Colors.mindTeal : Theme.Colors.warmOrange)
                        .frame(width: 64, height: 64)
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text(isCorrect ? "Nice — that's right." : "Not quite.")
                    .font(Theme.Typography.title)
                    .foregroundStyle(isCorrect ? Theme.Colors.mindTeal : Theme.Colors.warmOrange)
                if isCorrect {
                    Text("One more toward today's ring.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mindTeal)
                } else {
                    Text("No penalty — keep going.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                }

                // Sharpness: shown only when favorable + statistically real
                // (SharpnessEngine returns nil otherwise — by design).
                if let delta = viewModel.currentSpeedDelta {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("\(Int(delta.priorMedianSeconds))s \u{2192} \(Int(delta.currentSeconds.rounded()))s \u{2014} quicker than your usual")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Theme.Colors.insightText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.insightYellowTint)
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func answerRevealPill(for q: QuizQuestion, isCorrect: Bool) -> some View {
        let text = q.choices.first { $0.id == q.correctChoiceId }?.text ?? ""
        let background = isCorrect ? Theme.Colors.mindTeal : Theme.Colors.warmOrange
        if text.count <= 22 {
            // Short answers ("$2.43", "Roth IRA") get the big celebratory pill.
            Text(text)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(background)
                .clipShape(Capsule())
        } else {
            // Sentence-length concept answers: a capsule of wrapped 30pt text
            // reads as a blob — render a labeled answer card instead.
            VStack(alignment: .leading, spacing: 6) {
                Text("Correct answer")
                    .font(.system(size: 11, weight: .bold))
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .foregroundStyle(.white.opacity(0.75))
                Text(text)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
    }

    private func optionsRecap(for q: QuizQuestion, isCorrect: Bool) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(q.choices.enumerated()), id: \.element.id) { i, choice in
                OptionCard(
                    key: choiceKeys[safe: i] ?? "?",
                    text: choice.text,
                    state: feedbackCardState(for: choice),
                    action: {}
                )
                .opacity(isHighlighted(choice) ? 1 : 0.45)
            }
        }
    }

    private func whyCard(explanation: String) -> some View {
        NumindCard(background: Theme.Colors.insightYellowTint) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.insightYellow.opacity(0.25))
                            .frame(width: 28, height: 28)
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.Colors.insightText)
                    }
                    Text("Why")
                        .font(Theme.Typography.small)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Colors.insightText)
                        .textCase(.uppercase)
                        .kerning(0.6)
                }
                Text(explanation)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
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

    private func feedbackCardState(for choice: QuizQuestion.Choice) -> OptionCardState {
        let correctId = viewModel.currentQuestion.correctChoiceId
        let selectedId = viewModel.selectedChoiceId
        if choice.id == correctId { return .correct }
        if choice.id == selectedId { return .wrong }
        return .normal
    }

    private func isHighlighted(_ choice: QuizQuestion.Choice) -> Bool {
        let correctId = viewModel.currentQuestion.correctChoiceId
        let selectedId = viewModel.selectedChoiceId
        return choice.id == correctId || choice.id == selectedId
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            footerButton
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
                .background(Theme.Colors.softBackground)
        }
    }

    @ViewBuilder
    private var footerButton: some View {
        switch viewModel.sessionState {
        case .question, .answered:
            checkAnswerButton(enabled: viewModel.isReadyToCheck)
        case .feedback:
            PillButton("Continue") { viewModel.advance() }
        case .motivator:
            EmptyView()   // CTA lives inside MotivatorView
        case .teach:
            EmptyView()   // CTA lives inside TeachCardView
        case .complete:
            EmptyView()
        }
    }

    private func checkAnswerButton(enabled: Bool) -> some View {
        Button { viewModel.checkAnswer() } label: {
            Text("Check answer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(enabled ? .white : Theme.Colors.mutedText)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Spacing.buttonHeight)
                .background(enabled ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
