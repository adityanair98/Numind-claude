import XCTest
@testable import Numind

/// Phase 12 — sharpness speed deltas. Locks in the display rule: a delta
/// surfaces ONLY when favorable AND statistically real; unfavorable and
/// unconfident are indistinguishable (nil).
final class SharpnessTests: XCTestCase {

    private let templateId = "tpl_a"

    /// Builds one session per attempt list entry, dated sequentially —
    /// then a split-record variant mirrors HomeView.recordMixedSession.
    private func sessions(_ attempts: [(correct: Bool, seconds: Double)],
                          splitRecords: Bool = false) -> [SessionRecord] {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .day, value: -attempts.count - 1, to: Date())!
        return attempts.enumerated().map { i, a in
            let date = calendar.date(byAdding: .day, value: i, to: base)!
            let result = QuestionResult(templateId: templateId, isCorrect: a.correct,
                                        timeSpentSeconds: a.seconds, difficulty: .medium)
            return SessionRecord(id: UUID(), lessonId: splitRecords ? "daily_challenge" : "lesson_x",
                                 moduleId: splitRecords ? "module_\(i % 2)" : "smart_shopping",
                                 date: date, correctCount: a.correct ? 1 : 0, totalCount: 1,
                                 questionResults: [result])
        }
    }

    // MARK: - Favorable path

    func test_favorableDelta_surfacesWhenAllGatesPass() throws {
        // First exposure (dropped) + 3 correct priors with median 12s.
        let s = sessions([(true, 20), (true, 12), (true, 12), (true, 12)])
        let delta = try XCTUnwrap(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 6, sessions: s
        ))
        XCTAssertEqual(delta.priorMedianSeconds, 12, accuracy: 0.001)
        XCTAssertEqual(delta.currentSeconds, 6, accuracy: 0.001)
        XCTAssertEqual(delta.percentFaster, 50)
    }

    func test_unfavorable_isSilent() {
        let s = sessions([(true, 20), (true, 12), (true, 12)])
        // 10s is faster than 12 but NOT < 0.7 × 12 = 8.4 → silent.
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 10, sessions: s
        ))
        // Slower → silent (never an unfavorable delta).
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 30, sessions: s
        ))
    }

    // MARK: - Confidence gates

    func test_firstExposure_isExcludedFromBaseline() {
        // Only the first-ever attempt exists (slow) + one more → after the
        // dropFirst there is 1 qualifying attempt < minPriorAttempts → nil.
        let s = sessions([(true, 40), (true, 12)])
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 4, sessions: s
        ))
    }

    func test_wrongAnswers_doNotCountAsBaseline() {
        // Priors after first exposure are wrong → no qualifying baseline.
        let s = sessions([(true, 20), (false, 12), (false, 11)])
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 4, sessions: s
        ))
    }

    func test_fastBaseline_neverCelebratesNoise() {
        // Median 4s < 8s floor → silent even on a 2s answer.
        let s = sessions([(true, 5), (true, 4), (true, 4)])
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 2, sessions: s
        ))
    }

    func test_subSecondAnswer_isTreatedAsArtifact() {
        let s = sessions([(true, 20), (true, 14), (true, 14)])
        XCTAssertNil(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 0.4, sessions: s
        ))
    }

    // MARK: - Baselines snapshot

    func test_baselines_omitUnconfidentTemplates() {
        let s = sessions([(true, 20), (true, 12), (true, 12)])
        let map = SharpnessEngine.baselines(for: [templateId, "never_seen"], sessions: s)
        XCTAssertEqual(map[templateId] ?? 0, 12, accuracy: 0.001)
        XCTAssertNil(map["never_seen"])
        // favorableDelta on an omitted template → silent by construction.
        XCTAssertNil(SharpnessEngine.favorableDelta(currentSeconds: 3, priorMedian: map["never_seen"]))
    }

    func test_splitRecords_sameShapeAsDailyWorkout() throws {
        // recordMixedSession splits one workout into per-module records;
        // attempts still flatten in date order across them.
        let s = sessions([(true, 20), (true, 12), (true, 12), (true, 12)], splitRecords: true)
        let delta = try XCTUnwrap(SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 6, sessions: s
        ))
        XCTAssertEqual(delta.priorMedianSeconds, 12, accuracy: 0.001)
    }

    func test_rollingWindow_usesRecentFive() {
        // 1 exposure + 6 priors: oldest qualifying (60s) falls outside the
        // window of 5; median of [12,12,12,12,12] = 12 → favorable at 6s.
        let s = sessions([(true, 9), (true, 60), (true, 12), (true, 12),
                          (true, 12), (true, 12), (true, 12)])
        let delta = SharpnessEngine.speedDelta(
            templateId: templateId, currentSeconds: 6, sessions: s
        )
        XCTAssertEqual(delta?.priorMedianSeconds ?? 0, 12, accuracy: 0.001)
    }
}
