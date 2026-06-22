import XCTest
@testable import Numind

/// Phase 10 — the 3-segment Daily Workout (warm-up / focus + teach card /
/// decision). Runs against the real bundled content via LocalContentRepository.
final class DailyWorkoutEngineTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    private var firstPaycheck: Pack {
        repo.pack(id: "first_paycheck")!
    }

    /// A session that satisfies the mastery rule (100% incl. a correct
    /// medium) using the lesson's REAL template ids, so SRS/freshness see it.
    private func masteredSession(lessonId: String, daysAgo: Int) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let templates = repo.templates(for: lessonId)
        let results = templates.prefix(6).enumerated().map { i, t in
            QuestionResult(templateId: t.id, isCorrect: true,
                           timeSpentSeconds: 5, difficulty: i == 0 ? .medium : .easy)
        }
        let lesson = repo.lesson(id: lessonId)
        return SessionRecord(id: UUID(), lessonId: lessonId,
                             moduleId: lesson?.moduleId ?? "smart_shopping", date: date,
                             correctCount: results.count, totalCount: results.count,
                             questionResults: Array(results))
    }

    /// A completed-but-not-mastered attempt (low score, real template ids).
    private func attemptedSession(lessonId: String, daysAgo: Int = 0) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let templates = repo.templates(for: lessonId)
        let results = templates.prefix(5).enumerated().map { i, t in
            QuestionResult(templateId: t.id, isCorrect: i < 2,
                           timeSpentSeconds: 5, difficulty: .easy)
        }
        let lesson = repo.lesson(id: lessonId)
        return SessionRecord(id: UUID(), lessonId: lessonId,
                             moduleId: lesson?.moduleId ?? "smart_shopping", date: date,
                             correctCount: 2, totalCount: results.count,
                             questionResults: Array(results))
    }

    // MARK: - Shape

    func test_defaultPlan_hasSevenQuestions_inThreeSegments() {
        let plan = DailyWorkoutEngine.plan(from: repo)
        XCTAssertEqual(plan.questions.count, 7)
        XCTAssertEqual(plan.segments.map(\.kind), [.warmup, .focus, .decision])
        XCTAssertEqual(plan.segments[0].questions.count, 3)
        XCTAssertEqual(plan.segments[2].questions.count, 1)
        XCTAssertEqual(plan.mode, .noFocus)
        XCTAssertEqual(plan.segmentLabels.count, plan.questions.count)
    }

    func test_questionCount_respectsOnboardingSize() {
        var data = ProgressData()
        var signals = OnboardingSignals()
        signals.dailyMinutes = 3            // → 5-question workout (3/5/10 options)
        data.onboardingSignals = signals
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: data)
        XCTAssertEqual(plan.questions.count, 5)
        XCTAssertEqual(plan.segments.first?.questions.count, 2)   // warm-up shrinks to 2
    }

    func test_noDuplicateTemplates() {
        let plan = DailyWorkoutEngine.plan(from: repo, focusPack: firstPaycheck)
        let ids = plan.questions.map(\.templateId)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func test_determinism_sameDataSameDay_producesIdenticalPlan() {
        let date = Date()
        let a = DailyWorkoutEngine.plan(from: repo, focusPack: firstPaycheck, date: date)
        let b = DailyWorkoutEngine.plan(from: repo, focusPack: firstPaycheck, date: date)
        XCTAssertEqual(a.questions.map(\.templateId), b.questions.map(\.templateId))
        XCTAssertEqual(a.teachCard, b.teachCard)
    }

    // MARK: - Decision segment

    func test_decisionSegment_isExactlyOneApplicationItem() {
        let plan = DailyWorkoutEngine.plan(from: repo)
        let decision = plan.segments.first { $0.kind == .decision }
        XCTAssertEqual(decision?.questions.count, 1)
        let templateId = decision!.questions[0].templateId
        XCTAssertEqual(repo.template(id: templateId)?.isApplicationItem, true)
    }

    func test_decision_prefersFocusPackLessons() {
        let pack = firstPaycheck
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: ProgressData(), focusPack: pack)
        let decision = plan.segments.first { $0.kind == .decision }!
        let templateId = decision.questions[0].templateId
        let packTemplateIds = Set(pack.lessonIds.flatMap { repo.templates(for: $0).map(\.id) })
        XCTAssertTrue(packTemplateIds.contains(templateId),
                      "decision item should come from the focus pack when one is set")
    }

    // MARK: - Teach card

    func test_learningMode_teachesFirstUnattemptedCoreLesson() {
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: ProgressData(), focusPack: firstPaycheck)
        XCTAssertEqual(plan.mode, .learning)
        XCTAssertEqual(plan.teachCard?.id, "net_pay_check")
        // Card shows at the focus segment's first question.
        XCTAssertEqual(plan.teachCardIndex, plan.segments.first { $0.kind == .warmup }?.questions.count ?? 0)
        XCTAssertEqual(plan.segmentLabels[plan.teachCardIndex!], "Focus")
        // The focus block practices the taught lesson.
        let focus = plan.segments.first { $0.kind == .focus }!
        let netPayTemplates = Set(repo.templates(for: "net_pay_check").map(\.id))
        XCTAssertTrue(netPayTemplates.contains(focus.questions[0].templateId))
    }

    func test_teachCard_absent_onceLessonWasAttempted() {
        var data = ProgressData()
        data.sessions = [attemptedSession(lessonId: "net_pay_check")]
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: data, focusPack: firstPaycheck)
        XCTAssertEqual(plan.mode, .learning)        // attempted ≠ mastered
        XCTAssertNil(plan.teachCard, "no re-teaching of attempted material")
        XCTAssertNil(plan.teachCardIndex)
    }

    func test_teachCard_neverInReviewOnlyMode() {
        // 5 mastered lessons answered 90 days ago → heavy refresh backlog.
        var data = ProgressData()
        let lessons = ["tip_10_percent_trick", "tip_18_percent", "discount_stacked",
                       "sales_tax_quick", "subscription_math"]
        data.sessions = lessons.map { masteredSession(lessonId: $0, daysAgo: 90) }
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: data, focusPack: firstPaycheck)
        XCTAssertEqual(plan.mode, .reviewOnly)
        XCTAssertNil(plan.teachCard)
        XCTAssertNil(plan.segments.first { $0.kind == .warmup },
                     "review-only days have no separate warm-up segment")
        XCTAssertFalse(plan.questions.isEmpty)
    }

    // MARK: - Warm-up

    func test_warmup_drawsFromMasteredLessons_whenAvailable() {
        var data = ProgressData()
        // Recently mastered (not yet overdue → not a refresh backlog).
        data.sessions = [masteredSession(lessonId: "tip_10_percent_trick", daysAgo: 1)]
        let plan = DailyWorkoutEngine.plan(from: repo, progressData: data, focusPack: firstPaycheck)
        guard let warmup = plan.segments.first(where: { $0.kind == .warmup }) else {
            return XCTFail("expected a warm-up segment")
        }
        let masteredTemplateIds = Set(repo.templates(for: "tip_10_percent_trick").map(\.id))
        XCTAssertTrue(warmup.questions.contains { masteredTemplateIds.contains($0.templateId) },
                      "warm-up should pull reps from the mastered skill")
    }
}
