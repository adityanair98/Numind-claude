import SwiftUI

/// The lesson as a story, not a flashcard (Phase 13).
///
/// Five beats, one idea per screen, predict-before-teach: the learner meets
/// the real-world moment, guesses cold on a no-stakes question, and only THEN
/// gets the shortcut — earned, not handed over. The worked example steps in
/// one line at a time. The full concept lands last, when there's a hook to
/// hang it on. A persistent "Skip to practice" respects returning users.
///
/// The guess never creates a SessionRecord — same honesty rule as the
/// onboarding diagnostic.
struct LessonStoryView: View {
    let viewModel: LessonViewModel
    let questionCount: Int
    let onStartQuiz: () -> Void
    let onShowCalculator: (() -> Void)?

    private enum Beat: Int, CaseIterable {
        case moment, guess, shortcut, example, rule
    }

    @State private var beatIndex = 0
    @State private var selectedChoiceId: UUID?
    @State private var revealedLines = 1

    private let predictQuestion: QuizQuestion?
    private let exampleLines: [String]

    init(viewModel: LessonViewModel,
         questionCount: Int,
         onStartQuiz: @escaping () -> Void,
         onShowCalculator: (() -> Void)?) {
        self.viewModel = viewModel
        self.questionCount = questionCount
        self.onStartQuiz = onStartQuiz
        self.onShowCalculator = onShowCalculator

        let template = LocalContentRepository()
            .templates(for: viewModel.lesson.id)
            .sorted {
                ($0.isApplicationItem ? 1 : 0, $0.difficulty)
                    < ($1.isApplicationItem ? 1 : 0, $1.difficulty)
            }
            .first
        self.predictQuestion = template.map { QuizEngine.generate(from: $0) }

        self.exampleLines = viewModel.lesson.example
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }

    private var beats: [Beat] {
        predictQuestion == nil
            ? [.moment, .shortcut, .example, .rule]
            : Beat.allCases
    }

    private var beat: Beat { beats[min(beatIndex, beats.count - 1)] }
    private var accent: Color { viewModel.moduleColor.tintColor }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                beatProgressBar
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, 6)

                ScrollView(showsIndicators: false) {
                    beatContent
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.top, 22)
                        .padding(.bottom, Theme.Spacing.buttonHeight + 96)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(beatIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                .animation(.spring(response: 0.42, dampingFraction: 0.86), value: beatIndex)
            }
            footer
        }
        .toolbar {
            if beat != .rule {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip to practice") { onStartQuiz() }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
    }

    // MARK: - Progress

    private var beatProgressBar: some View {
        HStack(spacing: 5) {
            ForEach(0..<beats.count, id: \.self) { i in
                Capsule()
                    .fill(i <= beatIndex ? accent : Theme.Colors.mutedTint)
                    .frame(height: 4)
                    .animation(.easeOut(duration: 0.25), value: beatIndex)
            }
        }
    }

    // MARK: - Beats

    @ViewBuilder
    private var beatContent: some View {
        switch beat {
        case .moment:   momentBeat
        case .guess:    guessBeat
        case .shortcut: shortcutBeat
        case .example:  exampleBeat
        case .rule:     ruleBeat
        }
    }

    private var momentBeat: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.contextLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(accent)
                .textCase(.uppercase)
                .kerning(0.6)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(accent.opacity(0.12))
                .clipShape(Capsule())

            Text(viewModel.lesson.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .fixedSize(horizontal: false, vertical: true)

            if let hint = viewModel.lesson.realWorldHint {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "target")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accent)
                        .padding(.top, 3)
                    Text(hint)
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
                )
                .padding(.top, 6)
            }

            Text("About a minute, then \(questionCount) questions.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .padding(.top, 2)
        }
    }

    private var guessBeat: some View {
        VStack(alignment: .leading, spacing: 14) {
            overline("Try it cold", color: accent)

            Text("Take a guess \u{2014} no stakes, just instincts.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)

            if let q = predictQuestion {
                if let scenario = q.scenario {
                    Text(scenario)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .italic()
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }

                Text(q.prompt)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 6)

                VStack(spacing: 10) {
                    ForEach(Array(q.choices.enumerated()), id: \.element.id) { i, choice in
                        OptionCard(
                            key: i < 4 ? ["A", "B", "C", "D"][i] : "?",
                            text: choice.text,
                            state: guessState(for: choice, in: q)
                        ) {
                            guard selectedChoiceId == nil else { return }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedChoiceId = choice.id
                            }
                        }
                        .opacity(guessOpacity(for: choice, in: q))
                    }
                }

                if let selected = selectedChoiceId {
                    Text(selected == q.correctChoiceId
                         ? "Good instincts. Here\u{2019}s the 20-second version \u{2014}"
                         : "Most people guess that one. Here\u{2019}s the 20-second version \u{2014}")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selected == q.correctChoiceId
                                         ? Theme.Colors.mindTeal : Theme.Colors.deepNavy)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }

    private var shortcutBeat: some View {
        VStack(alignment: .leading, spacing: 16) {
            overline("The 20-second version", color: Theme.Colors.insightText)

            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.insightYellow.opacity(0.3))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Theme.Colors.insightText)
                }
                Text(viewModel.lesson.shortcut)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.insightYellowTint)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
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

            Text("This is the version you\u{2019}ll actually use \u{2014} at the table, on the call, in the aisle.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var exampleBeat: some View {
        VStack(alignment: .leading, spacing: 14) {
            overline("Watch it work", color: accent)

            VStack(spacing: 0) {
                ForEach(Array(exampleLines.prefix(revealedLines).enumerated()), id: \.offset) { i, line in
                    let isFinal = i == exampleLines.count - 1
                    let parts = exampleLineParts(line)

                    HStack {
                        Text(parts.label)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(isFinal ? accent : Theme.Colors.mutedText)
                        Spacer()
                        if !parts.value.isEmpty {
                            Text(parts.value)
                                .font(.system(size: 14, weight: isFinal ? .bold : .regular, design: .monospaced))
                                .foregroundStyle(isFinal ? accent : Theme.Colors.deepNavy)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isFinal ? accent.opacity(0.09) : Color.clear)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                    if i < revealedLines - 1 {
                        Divider().background(Theme.Colors.hairline)
                    }
                }
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .contentShape(Rectangle())
            .onTapGesture { revealNextLine() }

            if revealedLines < exampleLines.count {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Tap for the next step")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Theme.Colors.mutedText)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var ruleBeat: some View {
        VStack(alignment: .leading, spacing: 16) {
            overline("The full picture", color: accent)

            NumindCard {
                Text(viewModel.lesson.concept)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            verifiedStamp
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            VStack(spacing: 10) {
                if beat == .rule, let onShowCalculator,
                   let slug = viewModel.lesson.relatedCalculatorSlug,
                   let name = CalculatorRegistry.name(for: slug) {
                    Button(action: onShowCalculator) {
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

                if let label = footerLabel {
                    PillButton(label) { advance() }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 28)
            .background(Theme.Colors.softBackground)
        }
        .animation(.easeOut(duration: 0.2), value: footerLabel)
    }

    /// nil hides the primary button — used to require engagement first.
    private var footerLabel: String? {
        switch beat {
        case .moment:
            return "Let\u{2019}s find out"
        case .guess:
            return selectedChoiceId == nil ? nil : "Show me"
        case .shortcut:
            return "Watch it work"
        case .example:
            return revealedLines < exampleLines.count ? "Next step" : "Continue"
        case .rule:
            return "Start practice \u{2014} \(questionCount) questions"
        }
    }

    // MARK: - Actions

    private func advance() {
        switch beat {
        case .example where revealedLines < exampleLines.count:
            revealNextLine()
        case .rule:
            onStartQuiz()
        default:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                beatIndex = min(beatIndex + 1, beats.count - 1)
            }
        }
    }

    private func revealNextLine() {
        guard revealedLines < exampleLines.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            revealedLines += 1
        }
    }

    // MARK: - Guess helpers

    private func guessState(for choice: QuizQuestion.Choice, in q: QuizQuestion) -> OptionCardState {
        guard let selected = selectedChoiceId else { return .normal }
        if choice.id == q.correctChoiceId { return .correct }
        if choice.id == selected { return .wrong }
        return .normal
    }

    private func guessOpacity(for choice: QuizQuestion.Choice, in q: QuizQuestion) -> Double {
        guard let selected = selectedChoiceId else { return 1 }
        return (choice.id == q.correctChoiceId || choice.id == selected) ? 1 : 0.45
    }

    // MARK: - Shared bits

    private func overline(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .textCase(.uppercase)
            .kerning(0.8)
    }

    private func exampleLineParts(_ line: String) -> (label: String, value: String) {
        for sep in [" = ", " \u{2248} ", ": "] {
            if let range = line.range(of: sep) {
                return (
                    String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespaces),
                    String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                )
            }
        }
        return (line, "")
    }

    // MARK: - Verified stamp (E-E-A-T trust signal)

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
}
