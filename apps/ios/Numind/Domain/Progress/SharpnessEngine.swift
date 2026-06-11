import Foundation

/// **Sharpness** — speed deltas on repeat material (Phase 12).
///
/// Automaticity is the product promise ("comes to you quickly"), and answer
/// speed is its honest, visceral metric. Display rule: **honest status,
/// asymmetric celebration** — a delta is surfaced ONLY when it is favorable
/// AND statistically real. Unfavorable and unconfident are indistinguishable
/// (nil): slowing down is what Freshness exists to catch, and it is framed
/// there as decay-and-rescue, never as a failed metric.
///
/// Gates (all must pass):
/// - the template's first-ever exposure is excluded (reading-the-format time
///   is not a baseline)
/// - correct prior attempts only (a fast wrong answer is not competence)
/// - ≥ 2 qualifying prior attempts, most recent 5 considered
/// - prior median ≥ 8s (consonant with SpacedRepetitionEngine's fast-recall
///   threshold — no celebrating 3s → 2s noise)
/// - current ≥ 1s (double-tap artifact guard)
/// - favorable iff current < 0.7 × prior median
///
/// Known limitation (accepted v1): baselines snapshot at session start, so a
/// template repeated within one session compares against pre-session history
/// only; and `timeSpentSeconds` includes any hint-reading time (prior
/// attempts had the same affordance).
enum SharpnessEngine {

    struct SpeedDelta: Equatable {
        let priorMedianSeconds: Double
        let currentSeconds: Double

        var percentFaster: Int {
            guard priorMedianSeconds > 0 else { return 0 }
            return Int(((priorMedianSeconds - currentSeconds) / priorMedianSeconds * 100).rounded())
        }
    }

    static let minPriorAttempts = 2
    static let minPriorMedianSeconds = 8.0
    static let improvementFactor = 0.7
    static let rollingWindow = 5
    static let minCurrentSeconds = 1.0

    // MARK: - Public

    /// Favorable, confident delta for a single answer — or nil (silent).
    static func speedDelta(
        templateId: String,
        currentSeconds: Double,
        sessions: [SessionRecord]
    ) -> SpeedDelta? {
        favorableDelta(
            currentSeconds: currentSeconds,
            priorMedian: priorMedian(templateId: templateId, sessions: sessions)
        )
    }

    /// Session-start snapshot: templateId → prior rolling median, ONLY for
    /// templates that clear the confidence gates. Templates omitted from the
    /// map can never show a delta — silence by construction.
    static func baselines(
        for templateIds: [String],
        sessions: [SessionRecord]
    ) -> [String: Double] {
        var map: [String: Double] = [:]
        for id in Set(templateIds) {
            if let median = priorMedian(templateId: id, sessions: sessions) {
                map[id] = median
            }
        }
        return map
    }

    /// Pure favorability check against a precomputed baseline.
    static func favorableDelta(
        currentSeconds: Double,
        priorMedian: Double?
    ) -> SpeedDelta? {
        guard let median = priorMedian,
              currentSeconds >= minCurrentSeconds,
              currentSeconds < improvementFactor * median else { return nil }
        return SpeedDelta(priorMedianSeconds: median, currentSeconds: currentSeconds)
    }

    // MARK: - Private

    /// Rolling median of qualifying prior attempts, or nil when the gates
    /// don't clear. Flattening mirrors `SpacedRepetitionEngine.priorityScore`
    /// (sessions in date order; in-session array order preserved).
    private static func priorMedian(
        templateId: String,
        sessions: [SessionRecord]
    ) -> Double? {
        let attempts = sessions
            .sorted { $0.date < $1.date }
            .flatMap { session -> [(isCorrect: Bool, seconds: Double)] in
                session.questionResults
                    .filter { $0.templateId == templateId }
                    .map { ($0.isCorrect, $0.timeSpentSeconds) }
            }

        // Drop the first-ever exposure, then keep correct attempts only.
        let qualifying = attempts.dropFirst().filter(\.isCorrect).map(\.seconds)
        let recent = Array(qualifying.suffix(rollingWindow))
        guard recent.count >= minPriorAttempts else { return nil }

        let median = Self.median(recent)
        guard median >= minPriorMedianSeconds else { return nil }
        return median
    }

    private static func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 0 {
            return (sorted[mid - 1] + sorted[mid]) / 2
        }
        return sorted[mid]
    }
}
