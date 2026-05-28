import XCTest
@testable import Numind

/// Phase-2 Batch 2i diagnostic: snapshots the NumindScoreEngine output across
/// the post-Phase-2 curriculum to check whether the concept-vs-numerical
/// score spread is wide enough to warrant recalibration.
///
/// The simulator uses a synthetic user with:
///   - constant 80% accuracy
///   - constant 8-second answer time
///   - 10 simulated sessions per lesson, 5 questions per session
///
/// The "gate" question: at any module, does the average score of concept-only
/// lessons differ from numerical-only lessons by more than ~10 points? If yes,
/// proceed to WS-G.2 recalibration. If no, no engine change is needed.
///
/// This test is descriptive — it dumps a per-module table to stdout and
/// fails iff the spread exceeds the engineering tolerance (15pts hard fail,
/// to leave headroom above the 10pt recommendation gate so noise doesn't
/// flake the build).
final class NumindScoreBaselineTests: XCTestCase {

    // MARK: - Synthetic user parameters

    /// Fraction of questions the synthetic user answers correctly.
    private static let syntheticAccuracy: Double = 0.80
    /// Seconds spent on each question by the synthetic user.
    private static let syntheticTimeSeconds: Double = 8.0
    /// How many simulated sessions to record per lesson (matches the engine's
    /// sessionWindow constant).
    private static let sessionsPerLesson: Int = 10
    /// How many questions per simulated session.
    private static let questionsPerSession: Int = 5

    /// Hard-fail threshold for the spread (concept-avg vs numerical-avg, in
    /// any one module). The plan's softer gate is 10 — we fail at 15 to allow
    /// some headroom for noise without flaking CI.
    private static let hardFailSpreadThreshold: Double = 15.0

    // MARK: - The test

    func test_numindScore_conceptVsNumericalSpread() throws {
        let repo = LocalContentRepository(bundle: .main)
        let modules = repo.allModules()
        XCTAssertFalse(modules.isEmpty, "No modules loaded — content bundle is empty?")

        var perLesson: [(moduleId: String, lessonId: String, kind: LessonKind, score: Int)] = []

        for module in modules {
            for lesson in repo.lessons(for: module.id) {
                let kind = classify(lesson: lesson, repo: repo)
                let sessions = simulateSessions(
                    for: lesson,
                    in: module,
                    repo: repo
                )
                let score = NumindScoreEngine.score(for: module.id, sessions: sessions)
                perLesson.append((module.id, lesson.id, kind, score))
            }
        }

        // Per-module concept vs numerical averages
        struct ModuleSummary {
            let moduleId: String
            let moduleTitle: String
            let conceptAvg: Double?
            let numericalAvg: Double?
            let conceptCount: Int
            let numericalCount: Int
            var spread: Double {
                guard let c = conceptAvg, let n = numericalAvg else { return 0 }
                return abs(c - n)
            }
        }

        var summaries: [ModuleSummary] = []
        for module in modules {
            let rows = perLesson.filter { $0.moduleId == module.id }
            let conceptRows = rows.filter { $0.kind == .concept }
            let numericalRows = rows.filter { $0.kind == .numerical }
            let conceptAvg = conceptRows.isEmpty
                ? nil
                : Double(conceptRows.map(\.score).reduce(0, +)) / Double(conceptRows.count)
            let numericalAvg = numericalRows.isEmpty
                ? nil
                : Double(numericalRows.map(\.score).reduce(0, +)) / Double(numericalRows.count)
            summaries.append(ModuleSummary(
                moduleId: module.id,
                moduleTitle: module.title,
                conceptAvg: conceptAvg,
                numericalAvg: numericalAvg,
                conceptCount: conceptRows.count,
                numericalCount: numericalRows.count
            ))
        }

        // Dump table for archival.
        // Use Swift's padding helpers (not String(format:)) because %s only works
        // with C strings — Swift Strings round-trip as %@ which corrupts width.
        func padR(_ s: String, _ w: Int) -> String {
            s.count >= w ? s : s + String(repeating: " ", count: w - s.count)
        }
        func padL(_ s: String, _ w: Int) -> String {
            s.count >= w ? s : String(repeating: " ", count: w - s.count) + s
        }

        print("\n=== Numind Score Baseline (2026-05) ===")
        print("\(padR("module", 26)) | \(padL("n_num", 5)) | \(padL("n_con", 5)) | \(padL("num", 5)) | \(padL("con", 5)) | \(padL("spread", 6))")
        print(String(repeating: "-", count: 70))
        for s in summaries {
            let numStr = s.numericalAvg.map { String(format: "%.1f", $0) } ?? "  —  "
            let conStr = s.conceptAvg.map { String(format: "%.1f", $0) } ?? "  —  "
            let spreadStr = (s.conceptAvg != nil && s.numericalAvg != nil)
                ? String(format: "%.1f", s.spread)
                : "  —  "
            print("\(padR(s.moduleTitle, 26)) | \(padL(String(s.numericalCount), 5)) | \(padL(String(s.conceptCount), 5)) | \(padL(numStr, 5)) | \(padL(conStr, 5)) | \(padL(spreadStr, 6))")
        }

        // Curriculum-wide concept vs numerical averages
        let allConcept = perLesson.filter { $0.kind == .concept }
        let allNumerical = perLesson.filter { $0.kind == .numerical }
        if !allConcept.isEmpty && !allNumerical.isEmpty {
            let conceptAvg = Double(allConcept.map(\.score).reduce(0, +)) / Double(allConcept.count)
            let numericalAvg = Double(allNumerical.map(\.score).reduce(0, +)) / Double(allNumerical.count)
            print(String(repeating: "-", count: 70))
            print("\(padR("OVERALL", 26)) | \(padL(String(allNumerical.count), 5)) | \(padL(String(allConcept.count), 5)) | \(padL(String(format: "%.1f", numericalAvg), 5)) | \(padL(String(format: "%.1f", conceptAvg), 5)) | \(padL(String(format: "%.1f", abs(conceptAvg - numericalAvg)), 6))")
        }
        print("")

        // Hard-fail gate: if any module's spread exceeds the threshold, fail.
        for s in summaries where s.conceptAvg != nil && s.numericalAvg != nil {
            XCTAssertLessThanOrEqual(
                s.spread,
                Self.hardFailSpreadThreshold,
                "Module '\(s.moduleTitle)' concept-vs-numerical spread is \(String(format: "%.1f", s.spread)) — exceeds hard-fail tolerance of \(Self.hardFailSpreadThreshold). Recalibration likely needed."
            )
        }
    }

    // MARK: - Lesson classification

    private enum LessonKind {
        /// Lesson where every quiz template uses a numerical answerFormula.
        case numerical
        /// Lesson where every quiz template uses conceptChoices.
        case concept
        /// Lesson with a mix — rare; excluded from spread math.
        case mixed
    }

    private func classify(lesson: Lesson, repo: LocalContentRepository) -> LessonKind {
        let templates = repo.templates(for: lesson.id)
        guard !templates.isEmpty else { return .numerical }   // unreachable in real data; conservative default
        let conceptCount = templates.filter { $0.conceptChoices != nil }.count
        if conceptCount == templates.count { return .concept }
        if conceptCount == 0 { return .numerical }
        return .mixed
    }

    // MARK: - Phase 5g: 7-axis baseline

    /// Phase 5g re-snapshot: drives synthetic sessions across all lessons and
    /// checks that the 7-axis engine produces a reasonable distribution under
    /// uniform 80% accuracy. The expected outcome is that every axis lands
    /// in a similar band (≤ 25 pt spread) and that no axis falls below
    /// "Developing" evidence given the per-lesson session volume.
    func test_axisBaseline_underUniformBehavior() throws {
        let repo = LocalContentRepository(bundle: .main)
        let modules = repo.allModules()

        // Build synthetic sessions for every lesson, then aggregate.
        var allSessions: [SessionRecord] = []
        for module in modules {
            for lesson in repo.lessons(for: module.id) {
                allSessions.append(contentsOf:
                    simulateSessions(for: lesson, in: module, repo: repo))
            }
        }

        let results = NumindScoreEngine.axisResults(
            sessions: allSessions,
            repository: repo
        )

        // Dump table for archival in docs/ops/numind-score-baseline-2026-XX.md.
        func padR(_ s: String, _ w: Int) -> String {
            s.count >= w ? s : s + String(repeating: " ", count: w - s.count)
        }
        func padL(_ s: String, _ w: Int) -> String {
            s.count >= w ? s : String(repeating: " ", count: w - s.count) + s
        }
        print("\n=== Numind Score Baseline — 7 Axes (Phase 5g) ===")
        print("\(padR("axis", 26)) | \(padL("q", 5)) | \(padL("days", 5)) | \(padL("scen", 5)) | \(padL("score", 5)) | evidence")
        print(String(repeating: "-", count: 75))
        for r in results {
            print("\(padR(r.axis.displayName, 26)) | \(padL(String(r.questionCount), 5)) | \(padL(String(r.distinctDays), 5)) | \(padL(String(r.scenarioCount), 5)) | \(padL(String(r.score), 5)) | \(r.evidence.label)")
        }
        print(String(repeating: "-", count: 75))
        let composite = NumindScoreEngine.composite(results)
        print("Composite: \(composite)")
        print("Subtitle: \(NumindScoreEngine.subtitle(results, composite: composite))")
        print("")

        // Assertion 1: every axis has at least Early Read evidence under
        // uniform full-curriculum coverage.
        for r in results {
            XCTAssertNotEqual(
                r.evidence, .notStarted,
                "Axis \(r.axis.displayName) is Untested despite uniform synthetic coverage."
            )
        }

        // Assertion 2: per-axis spread ≤ 25 points under uniform 80%
        // accuracy. Larger spreads indicate weighting-profile bugs.
        let scores = results.map { Double($0.score) }
        if let maxS = scores.max(), let minS = scores.min() {
            let spread = maxS - minS
            XCTAssertLessThanOrEqual(
                spread, 25,
                "Per-axis spread \(spread) exceeds 25-pt tolerance under uniform behavior."
            )
        }

        // Assertion 3: composite landing in a defensible band for uniform
        // 80% accuracy — expect at least 50 (band: "On your way" or above).
        XCTAssertGreaterThanOrEqual(
            composite, 50,
            "Composite \(composite) too low under uniform 80% accuracy — expect ≥ 50."
        )
    }

    // MARK: - Phase 6a — recency decay

    /// Proves the recency-weighted score reflects current behavior, not
    /// lifetime accumulation. Inject 100 OLD correct attempts on a single
    /// template + 5 RECENT wrong attempts. The axis score should drop
    /// materially (>10 pts) vs the same-axis baseline with 100 old correct
    /// attempts alone.
    func test_recencyDecay_recentBehaviorDominates() throws {
        let repo = LocalContentRepository(bundle: .main)
        let cal = Calendar.current
        let now = Date()

        // Pick the first lesson with a primarySkill — that's the axis we'll
        // hammer. Use the lesson's first template.
        guard let lesson = repo.allModules()
            .flatMap({ repo.lessons(for: $0.id) })
            .first(where: { $0.primarySkill != nil && !$0.quizTemplateIds.isEmpty }),
              let axis = lesson.primarySkill,
              let template = repo.template(id: lesson.quizTemplateIds[0])
        else {
            XCTFail("Need at least one lesson with a primarySkill and a template")
            return
        }

        // Helper to build a session N days ago with N correct/wrong results.
        func session(daysAgo: Int, correctCount: Int, totalCount: Int) -> SessionRecord {
            let date = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            let results: [QuestionResult] = (0..<totalCount).map { i in
                QuestionResult(
                    templateId: template.id,
                    isCorrect: i < correctCount,
                    timeSpentSeconds: 8.0,
                    difficulty: .medium
                )
            }
            return SessionRecord(
                id: UUID(),
                lessonId: lesson.id,
                moduleId: lesson.moduleId,
                date: date,
                correctCount: correctCount,
                totalCount: totalCount,
                questionResults: results,
                bonusXP: 0
            )
        }

        // Baseline: 100 correct attempts ~90 days ago.
        let oldCorrect = session(daysAgo: 90, correctCount: 100, totalCount: 100)
        let baselineResults = NumindScoreEngine.axisResults(
            sessions: [oldCorrect],
            repository: repo
        )
        let baselineScore = baselineResults.first(where: { $0.axis == axis })?.score ?? 0

        // With recent wrong: same 100 old correct + 5 recent wrong (today).
        let recentWrong = session(daysAgo: 0, correctCount: 0, totalCount: 5)
        let withRecentResults = NumindScoreEngine.axisResults(
            sessions: [oldCorrect, recentWrong],
            repository: repo
        )
        let withRecentScore = withRecentResults.first(where: { $0.axis == axis })?.score ?? 0

        print("\n=== Recency decay test ===")
        print("Axis: \(axis.displayName)")
        print("Baseline (100 correct, 90 days ago): \(baselineScore)")
        print("With recent wrong (+5 wrong today):   \(withRecentScore)")
        print("Drop: \(baselineScore - withRecentScore) pts\n")

        // Recent behavior dominates: the 5 wrong today should drop the
        // axis score by more than 10 points despite the user having
        // historically nailed 100 in a row.
        XCTAssertGreaterThan(
            baselineScore - withRecentScore, 10,
            "Recent wrong attempts should drop the axis score by >10 pts; got \(baselineScore - withRecentScore)"
        )
    }

    /// Proves the exploration bonus rewards breadth (not punishes it).
    /// One synthetic axis at 70 → composite low. Same data spread across
    /// all 7 axes at 70 each → composite materially higher.
    func test_explorationBonus_replacesImbalancePenalty() throws {
        let repo = LocalContentRepository(bundle: .main)

        // Build a "single axis covered" scenario: simulate sessions only
        // for lessons whose primarySkill is Debt & Credit.
        let debtLessons = repo.allModules()
            .flatMap { repo.lessons(for: $0.id) }
            .filter { $0.primarySkill == .debtAndCredit }
        var singleAxisSessions: [SessionRecord] = []
        for lesson in debtLessons {
            guard let module = repo.allModules().first(where: { $0.id == lesson.moduleId }) else { continue }
            singleAxisSessions.append(contentsOf:
                simulateSessions(for: lesson, in: module, repo: repo))
        }
        let singleAxisComposite = NumindScoreEngine.composite(
            NumindScoreEngine.axisResults(sessions: singleAxisSessions, repository: repo)
        )

        // "All axes covered" — simulate across the whole curriculum.
        var allAxesSessions: [SessionRecord] = []
        for module in repo.allModules() {
            for lesson in repo.lessons(for: module.id) {
                allAxesSessions.append(contentsOf:
                    simulateSessions(for: lesson, in: module, repo: repo))
            }
        }
        let allAxesComposite = NumindScoreEngine.composite(
            NumindScoreEngine.axisResults(sessions: allAxesSessions, repository: repo)
        )

        print("\n=== Exploration bonus test ===")
        print("Single-axis (Debt only) composite:  \(singleAxisComposite)")
        print("All-axes composite:                 \(allAxesComposite)")
        print("Bonus delta: \(allAxesComposite - singleAxisComposite) pts\n")

        // Breadth should be rewarded by at least 10pts vs. depth-only.
        XCTAssertGreaterThan(
            allAxesComposite - singleAxisComposite, 10,
            "Exploration bonus should reward breadth by >10 pts; got \(allAxesComposite - singleAxisComposite)"
        )
    }

    // MARK: - Session simulation

    /// Builds `sessionsPerLesson` deterministic SessionRecords for the lesson.
    /// Each session has `questionsPerSession` `QuestionResult`s generated from
    /// the lesson's templates (rotating through them). Correctness uses a
    /// deterministic 80%-true pattern so the test is reproducible.
    private func simulateSessions(
        for lesson: Lesson,
        in module: Module,
        repo: LocalContentRepository
    ) -> [SessionRecord] {
        let templates = repo.templates(for: lesson.id)
        guard !templates.isEmpty else { return [] }

        var sessions: [SessionRecord] = []
        var seed: UInt64 = 1
        var correctnessCounter = 0

        for sessionIndex in 0..<Self.sessionsPerLesson {
            var results: [QuestionResult] = []
            var correctCount = 0

            for qIndex in 0..<Self.questionsPerSession {
                let template = templates[(sessionIndex * Self.questionsPerSession + qIndex) % templates.count]
                let q = QuizEngine.generate(from: template, seed: seed)
                seed &+= 1

                // Deterministic 80%-correct: 8 out of every 10 questions are correct.
                let isCorrect = correctnessCounter % 10 < 8
                correctnessCounter += 1
                if isCorrect { correctCount += 1 }

                results.append(QuestionResult(
                    templateId: template.id,
                    isCorrect: isCorrect,
                    timeSpentSeconds: Self.syntheticTimeSeconds,
                    difficulty: q.difficulty
                ))
            }

            sessions.append(SessionRecord(
                id: UUID(),
                lessonId: lesson.id,
                moduleId: module.id,
                date: Date(timeIntervalSinceNow: TimeInterval(-3600 * (Self.sessionsPerLesson - sessionIndex))),
                correctCount: correctCount,
                totalCount: Self.questionsPerSession,
                questionResults: results,
                bonusXP: 0
            ))
        }

        return sessions
    }
}
