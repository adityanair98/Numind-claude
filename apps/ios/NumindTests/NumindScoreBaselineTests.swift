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
