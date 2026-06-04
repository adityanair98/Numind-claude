import Foundation

/// Per-axis competency diagnostic across the 7 skill axes (Phase 9: the global
/// 0–100 composite, subtitle, and score history were retired — competence is
/// now expressed via per-pack Readiness; this engine survives only as an
/// internal diagnostic feeding the coverage radar, the "focus next"
/// recommendation, and the Daily Insight session radar).
///
/// ## Per-axis score (0–100)
///   Each question result is split between the lesson's primary skill axis
///   (70%) and any secondary axes (30%, split evenly across up to 2). Within
///   an axis, attempt points = correctness × difficulty × review × speed
///   multipliers (see `SkillAxis.QuestionMultiplier`). Per-axis normalization
///   uses the axis's `WeightingProfile` to combine accuracy, speed, retention,
///   and scenario components.
enum NumindScoreEngine {

    // MARK: - Public types

    /// Per-axis result: 0–100 score + evidence level.
    struct AxisResult: Equatable {
        let axis: SkillAxis
        let score: Int
        let evidence: EvidenceLevel
        /// Number of distinct question-answers attributed to this axis.
        let questionCount: Int
        /// Days with at least one question attributed to this axis.
        let distinctDays: Int
        /// Number of scenario-eligible questions attributed.
        let scenarioCount: Int
    }

    // MARK: - Configuration

    static let maxScore: Int = 100

    /// Speed component thresholds (seconds per question).
    private static let fastThreshold: Double = 5
    private static let goodThreshold: Double = 10
    private static let okThreshold:   Double = 15

    // MARK: - Public API (axis-based)

    /// Computes per-axis results for the user across all sessions.
    /// - Parameter sessions: All recorded sessions (post-drill-attribution).
    /// - Parameter repository: Content lookup for templateId → lesson → axes.
    /// - Returns: One AxisResult per SkillAxis case.
    static func axisResults(
        sessions: [SessionRecord],
        repository: ContentRepository
    ) -> [AxisResult] {
        // Walk every question, attribute weighted attempt points to axes.
        var perAxis: [SkillAxis: AxisAccumulator] = [:]
        for axis in SkillAxis.allCases { perAxis[axis] = AxisAccumulator() }

        // For retention: track last attempt time per template per user.
        // For speed: count prior attempts per template before each new one.
        var templateAttempts: [String: [(date: Date, seconds: Double)]] = [:]

        // Walk sessions in chronological order so retention multipliers see
        // the correct prior-attempt history.
        let chronological = sessions.sorted { $0.date < $1.date }

        let cal = Calendar.current
        let now = Date()

        for session in chronological {
            // Phase 6a — recency decay. Older attempts contribute less to
            // both earnedPoints AND maxPoints, so the per-axis score tracks
            // *current* competency rather than lifetime accumulation.
            // 0.95^days means ~50% weight at 14 days, ~20% at 30 days,
            // ~5% at 60 days. A user nailing today after historically
            // bombing sees their score rise; the reverse drops it.
            let daysAgo = max(0.0, now.timeIntervalSince(session.date) / 86400)
            let recencyWeight = pow(0.95, daysAgo)

            for qr in session.questionResults {
                guard let lesson = repository.lesson(forTemplateId: qr.templateId)
                else { continue }

                // Look up axis attribution
                guard let primary = lesson.primarySkill else { continue }
                let secondaries = lesson.secondarySkills

                // Difficulty multiplier
                let diffMult: Double
                if let d = qr.difficulty {
                    diffMult = QuestionMultiplier.difficulty(d)
                } else {
                    diffMult = 1.0
                }

                // Retention multiplier (days since last attempt on this template)
                let history = templateAttempts[qr.templateId] ?? []
                let daysSince: Double
                if let lastAttempt = history.last {
                    let interval = session.date.timeIntervalSince(lastAttempt.date)
                    daysSince = max(0, interval / 86400)
                } else {
                    daysSince = 0
                }
                let reviewMult = QuestionMultiplier.review(daysSinceLastAttempt: daysSince)

                // Speed multiplier (only after 3+ prior attempts)
                let speedMult = QuestionMultiplier.speed(
                    priorAttempts: history.count,
                    seconds: qr.timeSpentSeconds
                )

                // Aggregate points (recency-weighted — see comment above the loop).
                let isCorrect = qr.isCorrect ? 1.0 : 0.0
                let combined = diffMult * reviewMult * speedMult * recencyWeight
                let earnedAttempt = isCorrect * combined
                let maxAttempt = combined  // Max if perfectly correct

                // Primary axis: 70%
                let primaryShare = 0.70
                perAxis[primary]?.add(
                    earned: earnedAttempt * primaryShare,
                    max: maxAttempt * primaryShare,
                    seconds: qr.timeSpentSeconds * primaryShare,
                    isCorrect: qr.isCorrect,
                    date: session.date,
                    isScenario: lesson.isScenarioEligible,
                    daysSinceLast: daysSince,
                    weightShare: primaryShare,
                    calendar: cal
                )

                // Secondary axes: 30% split evenly across up to 2 secondaries
                if !secondaries.isEmpty {
                    let secShare = 0.30 / Double(secondaries.count)
                    for sec in secondaries {
                        perAxis[sec]?.add(
                            earned: earnedAttempt * secShare,
                            max: maxAttempt * secShare,
                            seconds: qr.timeSpentSeconds * secShare,
                            isCorrect: qr.isCorrect,
                            date: session.date,
                            isScenario: lesson.isScenarioEligible,
                            daysSinceLast: daysSince,
                            weightShare: secShare,
                            calendar: cal
                        )
                    }
                }

                // Track for next iteration.
                templateAttempts[qr.templateId, default: []].append(
                    (date: session.date, seconds: qr.timeSpentSeconds)
                )
            }
        }

        // Materialize results.
        return SkillAxis.allCases.map { axis in
            let acc = perAxis[axis] ?? AxisAccumulator()
            let score = computeAxisScore(profile: axis.weightingProfile, acc: acc)
            let evidence = evidenceLevel(
                questionCount: acc.attemptCount,
                distinctDays: acc.distinctDays.count,
                scenarioCount: acc.scenarioCount
            )
            return AxisResult(
                axis: axis,
                score: score,
                evidence: evidence,
                questionCount: acc.attemptCount,
                distinctDays: acc.distinctDays.count,
                scenarioCount: acc.scenarioCount
            )
        }
    }

    // MARK: - Legacy per-module API (compat shim)

    /// Returns a 0–100 score for a module by averaging the axis scores of the
    /// axes most associated with that module's lessons. Kept for
    /// back-compat with existing UI surfaces; new code should use axisResults.
    static func score(for moduleId: String, sessions: [SessionRecord]) -> Int {
        let repo = LocalContentRepository()
        let lessons = repo.lessons(for: moduleId)
        let primaryAxes = Set(lessons.compactMap { $0.primarySkill })
        guard !primaryAxes.isEmpty else { return 0 }
        let results = axisResults(sessions: sessions, repository: repo)
        let relevant = results.filter { primaryAxes.contains($0.axis) && $0.evidence != .notStarted }
        guard !relevant.isEmpty else { return 0 }
        let avg = relevant.reduce(0) { $0 + $1.score } / relevant.count
        return avg
    }

    // MARK: - Component computation

    private static func computeAxisScore(
        profile: WeightingProfile,
        acc: AxisAccumulator
    ) -> Int {
        // Accuracy component: weighted correctness, 0..100
        let accuracy: Double = {
            guard acc.maxPoints > 0 else { return 0 }
            return (acc.earnedPoints / acc.maxPoints) * 100
        }()

        // Speed component: avg per-question time bucketed.
        // (Use the share-weighted average so partial credit makes sense.)
        let avgSec: Double = {
            guard acc.weightedTimeShare > 0 else { return goodThreshold }
            return acc.weightedTimeShare > 0
                ? acc.totalSeconds / acc.weightedTimeShare
                : goodThreshold
        }()
        let speed: Double
        switch avgSec {
        case ..<fastThreshold: speed = 100
        case ..<goodThreshold: speed = 75
        case ..<okThreshold:   speed = 50
        default:               speed = 25
        }

        // Retention component: avg review-multiplier-derived score.
        // We track avg daysSinceLast across all attempts (share-weighted). The
        // longer the gap users still get right, the higher the retention.
        let retention: Double = {
            guard acc.attemptCount > 0 else { return 0 }
            let avgDaysSince = acc.totalDaysSince / Double(acc.attemptCount)
            switch avgDaysSince {
            case 11...:    return 100
            case 4...:     return 80
            case 1...:     return 60
            default:       return 40
            }
        }()

        // Scenario component: scenario correctness rate.
        let scenario: Double = {
            guard acc.scenarioCount > 0 else { return 0 }
            return Double(acc.scenarioCorrect) / Double(acc.scenarioCount) * 100
        }()

        // Combine via the axis's weighting profile. If scenario count is 0,
        // reweight the scenario share across the other components so users
        // aren't penalized for content that doesn't generate scenarios.
        let effectiveProfile: WeightingProfile = {
            guard acc.scenarioCount == 0 else { return profile }
            let bump = profile.scenario / 3.0
            return WeightingProfile(
                accuracy:  profile.accuracy + bump,
                speed:     profile.speed + bump,
                retention: profile.retention + bump,
                scenario:  0.0
            )
        }()

        let combined =
            accuracy  * effectiveProfile.accuracy +
            speed     * effectiveProfile.speed +
            retention * effectiveProfile.retention +
            scenario  * effectiveProfile.scenario

        return Int(min(Double(maxScore), max(0, combined)).rounded())
    }

    // MARK: - Evidence level

    private static func evidenceLevel(
        questionCount: Int,
        distinctDays: Int,
        scenarioCount: Int
    ) -> EvidenceLevel {
        switch questionCount {
        case 30... where distinctDays >= 3 && scenarioCount >= 2:
            return .reliable
        case 15... where distinctDays >= 2:
            return .developing
        case 5...:
            return .warmingUp
        default:
            return .notStarted
        }
    }
}

/// Internal accumulator used while walking question results.
private struct AxisAccumulator {
    var earnedPoints: Double = 0
    var maxPoints: Double = 0
    var totalSeconds: Double = 0
    var weightedTimeShare: Double = 0  // sum of weightShare for time normalization
    var attemptCount: Int = 0
    var totalDaysSince: Double = 0
    var scenarioCount: Int = 0
    var scenarioCorrect: Int = 0
    var distinctDays: Set<Date> = []

    mutating func add(
        earned: Double,
        max: Double,
        seconds: Double,
        isCorrect: Bool,
        date: Date,
        isScenario: Bool,
        daysSinceLast: Double,
        weightShare: Double,
        calendar: Calendar
    ) {
        earnedPoints += earned
        maxPoints += max
        totalSeconds += seconds
        weightedTimeShare += weightShare
        attemptCount += 1
        totalDaysSince += daysSinceLast
        if isScenario {
            scenarioCount += 1
            if isCorrect { scenarioCorrect += 1 }
        }
        distinctDays.insert(calendar.startOfDay(for: date))
    }
}
