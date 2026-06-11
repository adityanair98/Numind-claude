import SwiftUI

/// Central state machine for the 26-screen onboarding funnel (v2).
///
/// Owns `OnboardingSignals`, manages navigation, and orchestrates the
/// diagnostic-as-demo. Individual screen views call typed setters to
/// accumulate signals.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published state

    @Published var currentScreen: OnboardingScreen = .welcome
    @Published var signals = OnboardingSignals()

    // Diagnostic quiz state
    @Published var diagnosticItems: [DiagnosticQuestionBuilder.TaggedQuestion] = []
    @Published var diagnosticIndex: Int = 0
    /// The post-answer shortcut reveal — the demo beat after every question.
    @Published var diagnosticReveal: DiagnosticReveal? = nil

    /// Tracks whether we're going forward (true) or back (false) for transitions.
    @Published var isForward: Bool = true

    // Insecurity-mirror (screen 4) sub-state
    @Published var mirrorRevealed: Bool = false

    // MARK: - Dependencies

    private var progressStore: ProgressStore
    private(set) var repository: ContentRepository

    // MARK: - Init

    init(progressStore: ProgressStore, repository: ContentRepository) {
        self.progressStore = progressStore
        self.repository = repository

        // Resume from saved signals if the user killed the app mid-onboarding
        if let saved = progressStore.data.onboardingSignals {
            self.signals = saved
        }
    }

    /// Re-bind to the real ProgressStore from the environment.
    func rebind(progressStore: ProgressStore, repository: ContentRepository) {
        self.progressStore = progressStore
        self.repository = repository
        if let saved = progressStore.data.onboardingSignals {
            self.signals = saved
        }
    }

    // MARK: - Navigation

    func advance() {
        isForward = true
        // Handle screen 4 sub-state
        if currentScreen == .insecurityMirror && !mirrorRevealed {
            mirrorRevealed = true
            return
        }
        if currentScreen == .insecurityMirror && mirrorRevealed {
            mirrorRevealed = false
        }
        currentScreen = currentScreen.next
        persistSignals()
        AnalyticsService.capture(.onboardingStepViewed, properties: [
            "step": currentScreen.number
        ])
    }

    func goBack() {
        isForward = false
        guard currentScreen != .welcome,
              !currentScreen.isDiagnosticQuiz,
              currentScreen != .preparingResults else { return }

        if currentScreen == .insecurityMirror && mirrorRevealed {
            mirrorRevealed = false
            return
        }

        currentScreen = currentScreen.previous
    }

    // MARK: - Signal Setters

    func toggleFeltMoment(_ moment: FeltMoment) {
        if moment == .noneYet {
            // "None of these" is exclusive.
            signals.feltMoments = signals.feltMoments.contains(.noneYet) ? [] : [.noneYet]
            return
        }
        signals.feltMoments.remove(.noneYet)
        if signals.feltMoments.contains(moment) {
            signals.feltMoments.remove(moment)
        } else {
            signals.feltMoments.insert(moment)
        }
    }

    func setConfidence(_ level: ConfidenceLevel) {
        signals.confidenceLevel = level
    }

    func toggleMotivation(_ motivation: Motivation) {
        if signals.motivations.contains(motivation) {
            signals.motivations.remove(motivation)
        } else if signals.motivations.count < 3 {
            signals.motivations.insert(motivation)
        }
    }

    /// Moment picker: first tap sets the focus pack; further taps toggle
    /// secondaries (max 2). Tapping the focus pack clears it (promoting the
    /// first secondary, if any).
    func toggleLifeMoment(_ packId: String) {
        if signals.focusPackId == packId {
            signals.focusPackId = signals.secondaryPackIds.sorted().first
            if let promoted = signals.focusPackId {
                signals.secondaryPackIds.remove(promoted)
            }
            return
        }
        if signals.secondaryPackIds.contains(packId) {
            signals.secondaryPackIds.remove(packId)
            return
        }
        if signals.focusPackId == nil {
            signals.focusPackId = packId
        } else if signals.secondaryPackIds.count < 2 {
            signals.secondaryPackIds.insert(packId)
        }
    }

    func setDailyMinutes(_ minutes: Int) {
        signals.dailyMinutes = minutes
    }

    func setADHDStatus(_ status: ADHDStatus) {
        signals.adhdStatus = status
    }

    func setAgeRange(_ range: AgeRange) {
        signals.ageRange = range
    }

    func setStreakGoal(_ days: Int) {
        signals.streakGoal = days
    }

    func setTrialReminder(_ days: Int?) {
        signals.trialReminderDays = days
    }

    // MARK: - Diagnostic (demo mode)

    var focusPack: Pack? {
        guard let id = signals.focusPackId else { return nil }
        return repository.pack(id: id)
    }

    func startDiagnostic() {
        diagnosticItems = DiagnosticQuestionBuilder.build(
            focusPackId: signals.focusPackId,
            secondaryPackIds: signals.secondaryPackIds,
            repository: repository
        )
        diagnosticIndex = 0
        diagnosticReveal = nil
        AnalyticsService.capture(.diagnosticStarted, properties: [
            "focus_pack": signals.focusPackId ?? "none"
        ])
        advance() // Move to diagnostic quiz screen
    }

    func answerDiagnostic(choiceId: UUID) {
        guard diagnosticIndex < diagnosticItems.count, diagnosticReveal == nil else { return }

        let item = diagnosticItems[diagnosticIndex]
        let isCorrect = item.question.correctChoiceId == choiceId

        signals.diagnosticResults.append(DiagnosticResult(
            topicArea: item.moduleId,
            templateId: item.question.templateId,
            isCorrect: isCorrect,
            difficulty: item.question.difficulty.rawValue,
            lessonId: item.lessonId
        ))

        // The demo beat: show the shortcut behind the question.
        diagnosticReveal = DiagnosticReveal(
            correct: isCorrect,
            lessonTitle: item.lessonTitle,
            shortcut: item.shortcut,
            isApplication: item.isApplication
        )
    }

    /// Called from the reveal card's "Next" — advances or finishes.
    func advanceDiagnostic() {
        diagnosticReveal = nil
        if diagnosticIndex + 1 < diagnosticItems.count {
            diagnosticIndex += 1
        } else {
            signals.diagnosticDate = Date()
            advance() // → preparing results
        }
    }

    func finishPreparing() {
        signals.startingDifficulties = DiagnosticCalibrator.calibrate(
            results: signals.diagnosticResults,
            confidenceLevel: signals.confidenceLevel
        )

        // Recommendation priority: topics sorted by weakness.
        let grouped = Dictionary(grouping: signals.diagnosticResults, by: { $0.topicArea })
        signals.recommendationPriority = grouped.sorted { a, b in
            let accA = Double(a.value.filter(\.isCorrect).count) / max(1, Double(a.value.count))
            let accB = Double(b.value.filter(\.isCorrect).count) / max(1, Double(b.value.count))
            return accA < accB
        }.map(\.key)

        persistSignals()
        advance() // → Money Map
    }

    // MARK: - Money Map placement

    enum SkillPlacement {
        case solidStart   // answered correctly
        case shaky        // attempted, missed
        case newToYou     // core skill not yet attempted

        var label: String {
            switch self {
            case .solidStart: return "Solid start"
            case .shaky:      return "Shaky"
            case .newToYou:   return "New to you"
            }
        }

        var beadFill: Int {
            switch self {
            case .solidStart: return 4
            case .shaky:      return 2
            case .newToYou:   return 1
            }
        }
    }

    struct MoneyMapRow: Identifiable {
        var id: String { lessonId }
        let lessonId: String
        let title: String
        let placement: SkillPlacement
    }

    /// Per-core-skill placement for the focus pack, from diagnostic results.
    var moneyMapRows: [MoneyMapRow] {
        guard let pack = focusPack else { return [] }
        let coreIds = pack.coreLessonIds.isEmpty ? Array(pack.lessonIds.prefix(5)) : pack.coreLessonIds
        let byLesson = Dictionary(grouping: signals.diagnosticResults, by: { $0.lessonId ?? "" })

        return coreIds.compactMap { lessonId in
            guard let lesson = repository.lesson(id: lessonId) else { return nil }
            let attempts = byLesson[lessonId] ?? []
            let placement: SkillPlacement
            if attempts.isEmpty {
                placement = .newToYou
            } else if attempts.contains(where: \.isCorrect) {
                placement = .solidStart
            } else {
                placement = .shaky
            }
            return MoneyMapRow(lessonId: lessonId, title: lesson.title, placement: placement)
        }
    }

    // MARK: - Completion

    func completeOnboarding() {
        // The chosen moment becomes the live focus pack on Home.
        if let focusId = signals.focusPackId {
            progressStore.setFocusPack(focusId)
        }
        persistSignals()
        AnalyticsService.capture(.onboardingCompleted, properties: [
            "focus_pack": signals.focusPackId ?? "none",
            "streak_goal": signals.streakGoal ?? 0
        ])
    }

    // MARK: - Computed Properties

    var screenNumber: Int { currentScreen.number }

    var showsBackButton: Bool {
        currentScreen != .welcome
            && !currentScreen.isDiagnosticQuiz
            && currentScreen != .preparingResults
            && currentScreen != .paywall
            && currentScreen != .welcomeConfirm
    }

    var showsProgressBar: Bool {
        OnboardingProgressBar.progress(for: currentScreen.number) != nil
    }

    var progressValue: Double {
        OnboardingProgressBar.progress(for: currentScreen.number) ?? 0
    }

    var isDarkScreen: Bool {
        currentScreen.isDark
    }

    // MARK: - Private

    private func persistSignals() {
        progressStore.saveOnboardingSignals(signals)
    }
}

// MARK: - Screen Enum

enum OnboardingScreen: Int, CaseIterable, Equatable {
    case welcome = 1
    case socialProof = 2
    case momentsFraming = 3
    case insecurityMirror = 4
    case confidence = 5
    case motivation = 6
    case lifeMoment = 7
    case mirroring = 8
    case deadline = 9
    case timeCommitment = 10
    case kaizen = 11
    case adhd = 12
    case nameInput = 13
    case ageRange = 14
    case diagnosticIntro = 15
    case diagnosticQuiz = 16
    case preparingResults = 17
    case moneyMap = 18
    case personalizedPlan = 19
    case notificationPermission = 20
    case paywallPriming = 21
    case streakGoal = 22
    case improvementProjection = 23
    case trialReminder = 24
    case paywall = 25
    case welcomeConfirm = 26

    var number: Int { rawValue }

    var next: OnboardingScreen {
        OnboardingScreen(rawValue: rawValue + 1) ?? .welcomeConfirm
    }

    var previous: OnboardingScreen {
        OnboardingScreen(rawValue: rawValue - 1) ?? .welcome
    }

    var isDark: Bool {
        switch self {
        case .welcome, .socialProof, .deadline, .kaizen, .preparingResults,
             .improvementProjection, .welcomeConfirm:
            return true
        default:
            return false
        }
    }

    var isDiagnosticQuiz: Bool {
        self == .diagnosticQuiz
    }
}

// MARK: - Diagnostic Reveal

/// The shortcut card shown after every diagnostic answer — the demo beat.
struct DiagnosticReveal: Equatable {
    let correct: Bool
    let lessonTitle: String
    let shortcut: String
    let isApplication: Bool
}
