import Foundation
import UIKit

// MARK: - Slider range configuration

/// The computed slider bounds for a single estimation question.
struct SliderConfig {
    let min: Double
    let max: Double
    let step: Double

    var midpoint: Double { (min + max) / 2 }
    var range: ClosedRange<Double> { min...max }
}

/// Computes adaptive slider ranges from a question's correct value and format.
///
/// The correct answer is deliberately placed away from the center of the slider
/// (in the 15–40% or 60–85% region) so that guessing the midpoint is never a
/// reliable strategy.
enum SliderRange {

    static func compute(correctValue: Double, answerFormat: AnswerFormat) -> SliderConfig {
        // Edge case: correct value is 0 or very close to it.
        if abs(correctValue) < 0.01 {
            let fixedMax: Double
            switch answerFormat {
            case .currency: fixedMax = 10
            case .percent:  fixedMax = 20
            case .integer:  fixedMax = 10
            }
            let step = niceStep(for: fixedMax / 60, format: answerFormat)
            return SliderConfig(min: 0, max: fixedMax, step: step)
        }

        let absCorrect = abs(correctValue)

        // The total range width = spreadFactor × correctValue.
        let spreadFactor: Double = 1.6
        let halfRange = absCorrect * spreadFactor / 2
        let rangeWidth = halfRange * 2

        // Place the correct answer in either the lower band (15–40%) or upper
        // band (60–85%) of the slider — never near the center.
        // Pick a target position within one of those bands.
        let useLowerBand = Bool.random()
        let targetFraction: Double
        if useLowerBand {
            targetFraction = Double.random(in: 0.18...0.38)
        } else {
            targetFraction = Double.random(in: 0.62...0.82)
        }

        // Compute min/max so that correctValue sits at targetFraction.
        var rawMin = correctValue - rangeWidth * targetFraction
        var rawMax = rawMin + rangeWidth

        // Clamp minimum to 0 (no negative money / percentages / counts).
        if rawMin < 0 {
            rawMax += -rawMin
            rawMin = 0
        }

        // Snap to nice boundaries.
        let snappedMin = snapDown(rawMin, magnitude: absCorrect, format: answerFormat)
        let snappedMax = snapUp(rawMax, magnitude: absCorrect, format: answerFormat)

        // Guarantee the correct value sits at least 10% away from each edge.
        var finalMin = snappedMin
        var finalMax = snappedMax
        let finalWidth = finalMax - finalMin
        let margin = finalWidth * 0.10
        if correctValue - finalMin < margin {
            finalMin = max(0, correctValue - margin)
        }
        if finalMax - correctValue < margin {
            finalMax = correctValue + margin
        }

        // Ensure minimum useful range width.
        let minWidth: Double
        switch answerFormat {
        case .currency: minWidth = 5
        case .percent:  minWidth = 10
        case .integer:  minWidth = 5
        }
        if finalMax - finalMin < minWidth {
            finalMax = finalMin + minWidth
        }

        var step = niceStep(for: (finalMax - finalMin) / 60, format: answerFormat)

        // Validate stop count is in a usable range (≤ 120).
        // If too many stops, walk up the step ladder.
        if (finalMax - finalMin) / step > 120 {
            let ladder: [Double] = answerFormat == .percent
                ? [1, 2, 5, 10]
                : [0.5, 1, 5, 10, 50, 100, 500, 1000, 5000]
            for s in ladder where s > step {
                if (finalMax - finalMin) / s <= 120 {
                    step = s
                    break
                }
            }
        }

        return SliderConfig(min: finalMin, max: finalMax, step: step)
    }

    // MARK: - Snapping helpers

    private static func snapDown(_ value: Double, magnitude: Double, format: AnswerFormat) -> Double {
        let unit = snapUnit(for: magnitude, format: format)
        return (value / unit).rounded(.down) * unit
    }

    private static func snapUp(_ value: Double, magnitude: Double, format: AnswerFormat) -> Double {
        let unit = snapUnit(for: magnitude, format: format)
        return (value / unit).rounded(.up) * unit
    }

    private static func snapUnit(for magnitude: Double, format: AnswerFormat) -> Double {
        switch format {
        case .currency:
            if magnitude < 20   { return 1 }
            if magnitude < 100  { return 5 }
            if magnitude < 1000 { return 10 }
            if magnitude < 10000 { return 100 }
            return 1000
        case .percent:
            return 5
        case .integer:
            if magnitude < 20  { return 1 }
            if magnitude < 100 { return 5 }
            if magnitude < 500 { return 10 }
            return 100
        }
    }

    /// Returns a "nice" step size that yields roughly 40–80 discrete stops.
    private static func niceStep(for rawStep: Double, format: AnswerFormat) -> Double {
        switch format {
        case .currency:
            if rawStep < 0.50  { return 0.50 }
            if rawStep < 1     { return 1 }
            if rawStep < 5     { return 1 }
            if rawStep < 10    { return 5 }
            if rawStep < 50    { return 10 }
            if rawStep < 100   { return 50 }
            if rawStep < 500   { return 100 }
            if rawStep < 1000  { return 500 }
            return 1000
        case .percent:
            return 1
        case .integer:
            if rawStep < 1  { return 1 }
            if rawStep < 5  { return 1 }
            if rawStep < 10 { return 5 }
            if rawStep < 50 { return 10 }
            return 50
        }
    }
}

// MARK: - Grading

/// Proximity scoring tier for estimation answers.
/// Thresholds are calibrated for slider input (~50–60 discrete stops).
enum EstimationGrade: Equatable {
    case perfect    // within 5%  — 3 stars
    case good       // within 15% — 2 stars
    case okay       // within 30% — 1 star
    case miss       // beyond 30% — 0 stars

    var stars: Int {
        switch self {
        case .perfect: return 3
        case .good:    return 2
        case .okay:    return 1
        case .miss:    return 0
        }
    }

    var label: String {
        switch self {
        case .perfect: return "Nailed it!"
        case .good:    return "Good estimate"
        case .okay:    return "Close enough"
        case .miss:    return "Off the mark"
        }
    }

    var color: String {
        switch self {
        case .perfect: return "mindTeal"
        case .good:    return "primaryBlue"
        case .okay:    return "warmOrange"
        case .miss:    return "errorSoftRed"
        }
    }

    static func grade(estimate: Double, correct: Double) -> EstimationGrade {
        guard correct != 0 else { return estimate == 0 ? .perfect : .miss }
        let error = abs(estimate - correct) / abs(correct)
        if error <= 0.05 { return .perfect }
        if error <= 0.15 { return .good }
        if error <= 0.30 { return .okay }
        return .miss
    }
}

// MARK: - Item

/// A single estimation question with its slider configuration.
struct EstimationItem: Identifiable {
    let id = UUID()
    let templateId: String
    let prompt: String
    let scenario: String?
    let correctValue: Double
    let answerFormat: AnswerFormat
    let sliderConfig: SliderConfig
}

// MARK: - ViewModel

/// State and logic for an Estimation mode session.
///
/// The user drags a slider to their best estimate under time pressure.
/// A 10-second countdown forces gut-feel estimation over careful calculation.
/// Scored on proximity: 3/2/1/0 stars per question, max 30 stars for 10 questions.
@MainActor
final class EstimationViewModel: ObservableObject, Identifiable {
    let id = UUID()

    enum EstState: Equatable {
        case playing
        case feedback(EstimationGrade)   // showing how close they were
        case motivator(MotivatorCheckpoint)  // mid-session checkpoint
        case complete
    }

    /// Seconds allowed per question.
    static let timeLimit: Double = 10

    // MARK: - Published

    @Published private(set) var state: EstState = .playing
    @Published private(set) var currentIndex: Int = 0
    @Published var sliderValue: Double = 0
    @Published private(set) var totalStars: Int = 0
    @Published private(set) var timeRemaining: Double = EstimationViewModel.timeLimit

    /// Whether the user has moved the slider at least once for the current question.
    @Published private(set) var hasDragged: Bool = false

    // MARK: - Data

    let items: [EstimationItem]
    let previousBest: Int
    private(set) var results: [QuestionResult] = []
    private var questionStartTime: Date = Date()
    private var timerTask: Task<Void, Never>?

    /// Question indices where full-screen motivators were shown.
    private var motivatorsShownAt: [Int] = []

    var currentItem: EstimationItem? {
        currentIndex < items.count ? items[currentIndex] : nil
    }

    var total: Int { items.count }
    var maxStars: Int { items.count * 3 }
    var correctCount: Int { results.filter(\.isCorrect).count }
    var xpEarned: Int { totalStars * 5 }  // 5 XP per star
    var isNewBest: Bool { totalStars > previousBest && totalStars > 0 }

    /// 0–1 fraction of time remaining (for the progress bar).
    var timeFraction: Double {
        max(0, timeRemaining / Self.timeLimit)
    }

    /// The current slider value formatted for display (e.g. "$12.50", "15%").
    var formattedSliderValue: String {
        guard let item = currentItem else { return "" }
        return QuizEngine.format(sliderValue, as: item.answerFormat)
    }

    // MARK: - Init

    init(items: [EstimationItem], previousBest: Int = 0) {
        self.items = items
        self.previousBest = previousBest
        if let first = items.first {
            self.sliderValue = first.sliderConfig.midpoint
        }
    }

    /// Build estimation items from quiz templates.
    /// Filters to medium+ difficulty for a real estimation challenge.
    static func generateItems(
        from templates: [QuizTemplate],
        count: Int = 10
    ) -> [EstimationItem] {
        // Prefer medium/hard templates; fall back to all if not enough.
        let mediumHard = templates.filter { $0.difficulty >= 2 }
        let pool = mediumHard.count >= count ? mediumHard : templates
        let picked = Array(pool.shuffled().prefix(count))
        var usedFingerprints: Set<String> = []
        var items: [EstimationItem] = []

        for template in picked {
            var question = QuizEngine.generate(from: template)
            var fp = question.prompt + "|" + (question.scenario ?? "")
            var attempts = 1
            while usedFingerprints.contains(fp) && attempts < 10 {
                question = QuizEngine.generate(from: template)
                fp = question.prompt + "|" + (question.scenario ?? "")
                attempts += 1
            }
            if usedFingerprints.contains(fp) { continue }
            usedFingerprints.insert(fp)

            let sliderConfig = SliderRange.compute(
                correctValue: question.correctValue,
                answerFormat: template.answerFormat
            )

            items.append(EstimationItem(
                templateId: template.id,
                prompt: question.prompt,
                scenario: question.scenario,
                correctValue: question.correctValue,
                answerFormat: template.answerFormat,
                sliderConfig: sliderConfig
            ))
            if items.count >= count { break }
        }

        return items
    }

    // MARK: - Timer

    /// Starts (or restarts) the countdown timer for the current question.
    func startTimer() {
        timerTask?.cancel()
        timeRemaining = Self.timeLimit
        questionStartTime = Date()

        timerTask = Task { @MainActor [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard !Task.isCancelled else { return }

                let elapsed = Date().timeIntervalSince(self.questionStartTime)
                let remaining = max(0, Self.timeLimit - elapsed)
                self.timeRemaining = remaining

                if remaining <= 0 {
                    self.timeExpired()
                    return
                }
            }
        }
    }

    /// Called when the timer reaches zero — auto-submits.
    private func timeExpired() {
        guard case .playing = state, let item = currentItem else { return }

        let timeSpent = Self.timeLimit
        let grade: EstimationGrade
        if hasDragged {
            grade = EstimationGrade.grade(estimate: sliderValue, correct: item.correctValue)
        } else {
            grade = .miss  // Never moved the slider → miss
        }

        totalStars += grade.stars

        results.append(QuestionResult(
            templateId: item.templateId,
            isCorrect: grade.stars >= 2,
            timeSpentSeconds: timeSpent
        ))

        state = .feedback(grade)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Actions

    /// Called when the user first moves the slider for the current question.
    func markDragged() {
        hasDragged = true
    }

    func submit() {
        guard case .playing = state, let item = currentItem, hasDragged else { return }
        stopTimer()

        let timeSpent = Date().timeIntervalSince(questionStartTime)
        let grade = EstimationGrade.grade(estimate: sliderValue, correct: item.correctValue)

        totalStars += grade.stars

        results.append(QuestionResult(
            templateId: item.templateId,
            isCorrect: grade.stars >= 2,
            timeSpentSeconds: timeSpent
        ))

        state = .feedback(grade)
        if grade.stars >= 2 {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    func advance() {
        // ── Dismissing a motivator → proceed to next question ──
        if case .motivator = state {
            let next = currentIndex + 1
            currentIndex = next
            sliderValue = items[next].sliderConfig.midpoint
            hasDragged = false
            startTimer()
            state = .playing
            return
        }

        let next = currentIndex + 1

        // ── HARD CONSTRAINT: never show motivator after the last question ──
        guard next < items.count else {
            stopTimer()
            state = .complete
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        // ── Evaluate motivator checkpoint ──
        // For estimation, "correct" = 2+ stars (good or perfect grade)
        let correctFlags = results.map(\.isCorrect)
        if let type = MotivatorEngine.evaluate(
            correctFlags: correctFlags,
            totalQuestions: items.count,
            justAnsweredIndex: currentIndex,
            motivatorsShownAt: motivatorsShownAt
        ) {
            let checkpoint = buildEstimationCheckpoint(type: type)
            motivatorsShownAt.append(currentIndex)
            state = .motivator(checkpoint)
            return
        }

        // Normal advance
        currentIndex = next
        sliderValue = items[next].sliderConfig.midpoint
        hasDragged = false
        startTimer()
        state = .playing
    }

    // MARK: - Motivator checkpoint builder

    private func buildEstimationCheckpoint(type: MotivatorType) -> MotivatorCheckpoint {
        var cp = MotivatorCheckpoint(type: type)
        let answeredCount = results.count
        let correctCount = results.filter(\.isCorrect).count
        cp.accuracy = answeredCount > 0 ? Double(correctCount) / Double(answeredCount) : 0
        cp.total = items.count
        cp.completed = answeredCount

        switch type {
        case .momentum:
            // Count consecutive "correct" (2+ stars) from end
            var streak = 0
            for r in results.reversed() {
                if r.isCorrect { streak += 1 } else { break }
            }
            cp.streak = streak
            let avgTime = results.suffix(streak).map(\.timeSpentSeconds).reduce(0, +) / Double(streak)
            cp.avgTimeLastN = avgTime
            let sessionAvg = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)
            cp.paceImproving = avgTime < sessionAvg
            let copy = MotivatorCopy.momentum(streak: streak)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta

        case .coaching:
            // Use generic estimation tips
            let tip = MotivatorCopy.estimationTips.randomElement()!
            cp.tipTitle = tip.title
            cp.tipBody = tip.body
            let copy = MotivatorCopy.coaching()
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.ctaLabel = "Keep going"

        case .progress:
            let copy = MotivatorCopy.progress(completed: answeredCount, total: items.count)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta
            cp.avgTime = results.map(\.timeSpentSeconds).reduce(0, +) / Double(results.count)

        case .nearFinish:
            let remaining = items.count - answeredCount
            let copy = MotivatorCopy.nearFinish(remaining: remaining)
            cp.headline = copy.headline
            cp.subtitle = copy.subtitle
            cp.bodyText = copy.body
            cp.ctaLabel = copy.cta
        }

        return cp
    }
}
