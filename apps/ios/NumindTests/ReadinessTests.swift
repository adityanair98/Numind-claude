import XCTest
@testable import Numind

/// Locks in the Phase 9 per-pack Readiness gates (coverage → depth → retention)
/// and the Almost-ready single-missing-gate logic. Uses a synthetic pack so the
/// fixtures are deterministic; real packs are exercised via the live repo.
final class ReadinessTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    // Synthetic 2-core-lesson pack. Its lesson IDs don't exist in the repo, so
    // the freshness (overdue) lookup returns no templates → a fully-gated pack
    // reads as `.sharp` (no overdue work outstanding).
    private func synthPack() -> Pack {
        Pack(id: "test_pack", title: "Test Path", tagline: "t", hook: "h", description: "d",
             lessonIds: ["core_a", "core_b"], coreLessonIds: ["core_a", "core_b"],
             anchorLessonId: "core_a", estimatedMinutes: 10, lastVerified: "2026-01-01")
    }

    private func qr(_ d: QuestionDifficulty?, _ correct: Bool) -> QuestionResult {
        QuestionResult(templateId: "t", isCorrect: correct, timeSpentSeconds: 5, difficulty: d)
    }

    /// Variant pinning a real templateId (so the application gate, which is
    /// template-scoped, can be satisfied with a real lesson's decision item).
    private func qr(_ templateId: String, _ d: QuestionDifficulty?, _ correct: Bool) -> QuestionResult {
        QuestionResult(templateId: templateId, isCorrect: correct, timeSpentSeconds: 5, difficulty: d)
    }

    private func session(lesson: String, daysAgo: Int, results: [QuestionResult]) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return SessionRecord(
            id: UUID(), lessonId: lesson, moduleId: "M", date: date,
            correctCount: results.filter(\.isCorrect).count,
            totalCount: results.count, questionResults: results
        )
    }

    /// Two sessions on distinct days that master-with-hard and retain `lesson`.
    private func fullyGated(_ lesson: String) -> [SessionRecord] {
        [session(lesson: lesson, daysAgo: 3, results: [qr(.hard, true), qr(.medium, true), qr(.easy, true)]),
         session(lesson: lesson, daysAgo: 0, results: [qr(.medium, true), qr(.easy, true)])]
    }

    /// Mastered + retained but with NO hard answer → depth gate fails.
    private func mediumGated(_ lesson: String) -> [SessionRecord] {
        [session(lesson: lesson, daysAgo: 3, results: [qr(.medium, true), qr(.medium, true), qr(.easy, true)]),
         session(lesson: lesson, daysAgo: 0, results: [qr(.medium, true)])]
    }

    private func progress(_ sessions: [SessionRecord]) -> ProgressData {
        var p = ProgressData(); p.sessions = sessions; return p
    }

    private func state(_ sessions: [SessionRecord]) -> ReadinessEngine.State {
        ReadinessEngine.state(for: synthPack(), data: progress(sessions), repository: repo)
    }

    // MARK: - Tests

    func test_notStarted_withNoSessions() {
        XCTAssertEqual(state([]), .notStarted)
    }

    func test_allGatesPass_isReadyOrSharp() {
        let s = state(fullyGated("core_a") + fullyGated("core_b"))
        switch s {
        case .ready, .sharp: break  // synthetic lessons → sharp, but accept either
        default: XCTFail("Expected ready/sharp, got \(s)")
        }
    }

    func test_almostReady_namesTheMissingDepthGate() {
        // Both core lessons mastered + retained, but neither has a hard answer.
        let s = state(mediumGated("core_a") + mediumGated("core_b"))
        guard case .almostReady(let missing, _) = s else {
            return XCTFail("Expected almostReady, got \(s)")
        }
        XCTAssertEqual(missing, .depth)
    }

    func test_almostReady_namesTheMissingRetentionGate() {
        // Both deep-mastered, but core_b was only correct on one day → retention fails.
        let coreA = fullyGated("core_a")
        let coreBOneDay = [session(lesson: "core_b", daysAgo: 0,
                                   results: [qr(.hard, true), qr(.medium, true), qr(.easy, true)])]
        guard case .almostReady(let missing, _) = state(coreA + coreBOneDay) else {
            return XCTFail("Expected almostReady (retention)")
        }
        XCTAssertEqual(missing, .retention)
    }

    func test_learning_whenMultipleGatesFail() {
        // core_a fully gated; core_b attempted once, low score, one day →
        // depth AND retention both fail → learning.
        let coreBWeak = [session(lesson: "core_b", daysAgo: 0,
                                 results: [qr(.easy, true), qr(.medium, false), qr(.hard, false)])]
        XCTAssertEqual(state(fullyGated("core_a") + coreBWeak), .learning)
    }

    func test_readyPackCount_isZero_withNoProgress() {
        XCTAssertEqual(ReadinessEngine.readyPackCount(data: ProgressData(), repository: repo), 0)
    }

    func test_conceptOnlyCoreLesson_reachesReady_viaTopTierMastery() {
        // Audit fix H1: a pure-concept core lesson whose templates top out below
        // hard (concept_insurance_open_enrollment — max static tier 2, so no hard
        // question is ever generable) must satisfy the depth gate via plain
        // mastery. Otherwise its pack's depth gate is mathematically unreachable
        // and the pack can NEVER reach Ready/Sharp for any user.
        let L = "concept_insurance_open_enrollment"
        let pack = Pack(id: "oe_test", title: "OE", tagline: "t", hook: "h", description: "d",
                        lessonIds: [L], coreLessonIds: [L],
                        anchorLessonId: L, estimatedMinutes: 5, lastVerified: "2026-01-01")
        // Two correct days; day 3 includes the lesson's real decision item
        // (ins_decision_qle_d2) so the template-scoped application gate passes.
        let sessions = [
            session(lesson: L, daysAgo: 3, results: [qr("ins_decision_qle_d2", .medium, true),
                                                     qr("concept_oe_when_d1", .easy, true)]),
            session(lesson: L, daysAgo: 0, results: [qr("concept_oe_hdhp_eligibility_d2", .medium, true)])
        ]
        let s = ReadinessEngine.state(for: pack, data: progress(sessions), repository: repo)
        switch s {
        case .ready, .sharp: break  // recent practice → likely sharp; accept either
        default: XCTFail("concept-only core lesson should reach ready/sharp, got \(s)")
        }
    }

    func test_dailyExposure_advancesCoverageRetentionApplication_butNotDepth() {
        // Option C: practicing a core lesson's templates via the Daily Workout
        // (recorded under the synthetic lessonId "daily_challenge", real
        // templateId preserved) advances coverage + retention + application — so
        // the pack moves off .notStarted toward Ready — but the depth gate / the
        // mastery star still require focused lesson work, so it lands at
        // almostReady(.depth): "now lock in the hard ones."
        let L = "concept_insurance_open_enrollment"
        let pack = Pack(id: "oe_test2", title: "OE", tagline: "t", hook: "h", description: "d",
                        lessonIds: [L], coreLessonIds: [L],
                        anchorLessonId: L, estimatedMinutes: 5, lastVerified: "2026-01-01")
        // Two daily sessions on distinct days; day 3 includes the real decision
        // item so the (template-scoped) application gate also passes.
        let daily = [
            session(lesson: "daily_challenge", daysAgo: 3, results: [qr("ins_decision_qle_d2", .medium, true)]),
            session(lesson: "daily_challenge", daysAgo: 0, results: [qr("concept_oe_dcfsa_cap_d2", .medium, true)])
        ]
        guard case .almostReady(let missing, _) = ReadinessEngine.state(
            for: pack, data: progress(daily), repository: repo
        ) else {
            return XCTFail("daily exposure should reach almostReady(.depth)")
        }
        XCTAssertEqual(missing, .depth)
    }

    func test_coreLessons_fallsBackToAllLessonsWhenUntagged() {
        let untagged = Pack(id: "p", title: "P", tagline: "t", hook: "h", description: "d",
                            lessonIds: ["x", "y"], coreLessonIds: [],
                            anchorLessonId: "x", estimatedMinutes: 5, lastVerified: "2026-01-01")
        XCTAssertEqual(ReadinessEngine.coreLessons(for: untagged), ["x", "y"])
    }
}
