import SwiftUI

/// Central state machine for the 26-screen onboarding funnel.
///
/// Owns `OnboardingSignals`, manages navigation, and orchestrates
/// the diagnostic quiz. Individual screen views call typed setters
/// to accumulate signals.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published state

    @Published var currentScreen: OnboardingScreen = .welcome
    @Published var signals = OnboardingSignals()

    // Diagnostic quiz state
    @Published var diagnosticQuestions: [QuizQuestion] = []
    /// Parallel array: moduleId for each diagnostic question.
    @Published var diagnosticModuleIds: [String] = []
    @Published var diagnosticIndex: Int = 0
    @Published var diagnosticFlash: DiagnosticFlash? = nil

    /// Tracks whether we're going forward (true) or back (false) for transitions.
    @Published var isForward: Bool = true

    // Screen 4 sub-state
    @Published var screenTimeRevealed: Bool = false

    // MARK: - Dependencies

    private var progressStore: ProgressStore
    private var repository: ContentRepository

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
    /// Called from OnboardingFlowView.onAppear so the coordinator
    /// can inject the environment-provided store.
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
        let next = currentScreen.next
        // Handle screen 4 sub-state
        if currentScreen == .screenTime && !screenTimeRevealed {
            screenTimeRevealed = true
            return
        }
        if currentScreen == .screenTime && screenTimeRevealed {
            screenTimeRevealed = false
        }
        currentScreen = next
        persistSignals()
    }

    func goBack() {
        isForward = false
        // Can't go back past welcome or during diagnostic
        guard currentScreen != .welcome,
              !currentScreen.isDiagnosticQuiz,
              currentScreen != .preparingResults else { return }

        if currentScreen == .screenTime && screenTimeRevealed {
            screenTimeRevealed = false
            return
        }

        currentScreen = currentScreen.previous
    }

    // MARK: - Signal Setters

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

    func setAspiration(_ aspiration: Aspiration) {
        signals.aspiration = aspiration
    }

    func toggleTopicInterest(_ moduleId: String) {
        if signals.topicInterests.contains(moduleId) {
            signals.topicInterests.remove(moduleId)
        } else if signals.topicInterests.count < 4 {
            signals.topicInterests.insert(moduleId)
        }
    }

    func setDailyMinutes(_ minutes: Int) {
        signals.dailyMinutes = minutes
    }

    func setSocialMediaMinutes(_ minutes: Int) {
        signals.socialMediaMinutes = minutes
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

    // MARK: - Diagnostic Quiz

    func startDiagnostic() {
        let result = DiagnosticQuestionBuilder.buildQuestionsWithModuleIds(
            topicInterests: signals.topicInterests,
            repository: repository
        )
        diagnosticQuestions = result.map(\.question)
        diagnosticModuleIds = result.map(\.moduleId)
        diagnosticIndex = 0
        advance() // Move to diagnostic quiz screen
    }

    func answerDiagnostic(choiceId: UUID) {
        guard diagnosticIndex < diagnosticQuestions.count else { return }

        let question = diagnosticQuestions[diagnosticIndex]
        let isCorrect = question.correctChoiceId == choiceId
        let moduleId = diagnosticIndex < diagnosticModuleIds.count
            ? diagnosticModuleIds[diagnosticIndex]
            : "unknown"

        // Record result
        let result = DiagnosticResult(
            topicArea: moduleId,
            templateId: question.templateId,
            isCorrect: isCorrect,
            difficulty: question.difficulty.rawValue
        )
        signals.diagnosticResults.append(result)

        // Flash feedback
        diagnosticFlash = DiagnosticFlash(correct: isCorrect)

        // After flash, advance to next question or finish
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            diagnosticFlash = nil

            if diagnosticIndex + 1 < diagnosticQuestions.count {
                diagnosticIndex += 1
            } else {
                // Diagnostic complete — advance to preparing results
                signals.diagnosticDate = Date()
                advance()
            }
        }
    }

    func finishPreparing() {
        // Run calibration
        signals.startingDifficulties = DiagnosticCalibrator.calibrate(
            results: signals.diagnosticResults,
            confidenceLevel: signals.confidenceLevel
        )

        // Set recommendation priority (topics sorted by weakness)
        let grouped = Dictionary(grouping: signals.diagnosticResults, by: { $0.topicArea })
        signals.recommendationPriority = grouped.sorted { a, b in
            let accA = Double(a.value.filter(\.isCorrect).count) / max(1, Double(a.value.count))
            let accB = Double(b.value.filter(\.isCorrect).count) / max(1, Double(b.value.count))
            return accA < accB // Weaker topics first
        }.map(\.key)

        persistSignals()
        advance() // Move to diagnostic results
    }

    // MARK: - Completion

    func completeOnboarding() {
        persistSignals()
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
    case dailyMicro = 3
    case screenTime = 4
    case confidence = 5
    case motivation = 6
    case aspiration = 7
    case mirroring = 8
    case topicInterest = 9
    case timeCommitment = 10
    case kaizen = 11
    case adhd = 12
    case nameInput = 13
    case ageRange = 14
    case diagnosticIntro = 15
    case diagnosticQuiz = 16
    case preparingResults = 17
    case diagnosticResults = 18
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
        case .welcome, .socialProof, .kaizen, .preparingResults,
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

// MARK: - Diagnostic Flash

struct DiagnosticFlash: Equatable {
    let correct: Bool
}
