import XCTest
@testable import Numind

/// Phase 10-A8 — the consolidated Refresh session: stale mastered skills
/// first, then unfixed mistakes (latest attempt wrong), deduped, capped.
final class RefreshBuilderTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    /// Stable Smart Shopping lessons with several templates each.
    private let staleLesson = "tip_18_percent"
    private let mistakeLesson = "discount_stacked"

    private func session(lesson: String, results: [(id: String, correct: Bool)],
                         daysAgo: Int) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let qrs = results.map {
            QuestionResult(templateId: $0.id, isCorrect: $0.correct,
                           timeSpentSeconds: 5, difficulty: .medium)
        }
        return SessionRecord(id: UUID(), lessonId: lesson, moduleId: "smart_shopping",
                             date: date, correctCount: qrs.filter(\.isCorrect).count,
                             totalCount: qrs.count, questionResults: qrs)
    }

    // MARK: - Empty

    func test_emptyHistory_buildsNothing() {
        XCTAssertNil(RefreshSessionBuilder.build(
            masteredLessonIds: [], sessions: [], repository: repo
        ))
        XCTAssertEqual(RefreshSessionBuilder.skillCount(
            masteredLessonIds: [], sessions: [], repository: repo
        ), 0)
    }

    // MARK: - Ordering: stale before mistakes

    func test_staleTargets_precedeMistakeTargets() throws {
        let staleIds = repo.templates(for: staleLesson).map(\.id)
        let mistakeId = try XCTUnwrap(repo.templates(for: mistakeLesson).first?.id)

        let sessions = [
            // Mastered lesson attempted 90 days ago → stale.
            session(lesson: staleLesson,
                    results: staleIds.map { ($0, true) }, daysAgo: 90),
            // Recent miss on a different lesson.
            session(lesson: mistakeLesson,
                    results: [(mistakeId, false)], daysAgo: 1),
        ]
        let inventory = RefreshSessionBuilder.inventory(
            masteredLessonIds: [staleLesson], sessions: sessions, repository: repo
        )
        let stalePos = try XCTUnwrap(inventory.firstIndex(where: { staleIds.contains($0) }))
        if let mistakePos = inventory.firstIndex(of: mistakeId) {
            XCTAssertLessThan(stalePos, mistakePos, "stale targets come first")
        }
        XCTAssertTrue(inventory.contains(mistakeId))
    }

    // MARK: - Mistakes: only the unfixed ones

    func test_mistakeAnsweredCorrectlyLater_isNotReServed() throws {
        let id = try XCTUnwrap(repo.templates(for: mistakeLesson).first?.id)
        let sessions = [
            session(lesson: mistakeLesson, results: [(id, false)], daysAgo: 5),
            // Fixed it yesterday → no longer a refresh target.
            session(lesson: mistakeLesson, results: [(id, true)], daysAgo: 1),
        ]
        let inventory = RefreshSessionBuilder.inventory(
            masteredLessonIds: [], sessions: sessions, repository: repo
        )
        XCTAssertFalse(inventory.contains(id))
    }

    func test_latestAttemptWrong_isServed_evenAfterEarlierCorrect() throws {
        let id = try XCTUnwrap(repo.templates(for: mistakeLesson).first?.id)
        let sessions = [
            session(lesson: mistakeLesson, results: [(id, true)], daysAgo: 5),
            session(lesson: mistakeLesson, results: [(id, false)], daysAgo: 1),
        ]
        let inventory = RefreshSessionBuilder.inventory(
            masteredLessonIds: [], sessions: sessions, repository: repo
        )
        XCTAssertTrue(inventory.contains(id))
    }

    // MARK: - Dedupe + cap

    func test_templateBothStaleAndMissed_appearsOnce() throws {
        let id = try XCTUnwrap(repo.templates(for: staleLesson).first?.id)
        let sessions = [
            session(lesson: staleLesson, results: [(id, true)], daysAgo: 90),
            session(lesson: staleLesson, results: [(id, false)], daysAgo: 60),
        ]
        let inventory = RefreshSessionBuilder.inventory(
            masteredLessonIds: [staleLesson], sessions: sessions, repository: repo
        )
        XCTAssertEqual(inventory.filter { $0 == id }.count, 1)
    }

    func test_inventory_respectsQuestionLimit() {
        // Miss every template in two lessons → way more than the cap.
        let ids = (repo.templates(for: staleLesson) + repo.templates(for: mistakeLesson)).map(\.id)
        let sessions = [
            session(lesson: staleLesson, results: ids.map { ($0, false) }, daysAgo: 1)
        ]
        let inventory = RefreshSessionBuilder.inventory(
            masteredLessonIds: [], sessions: sessions, repository: repo
        )
        XCTAssertLessThanOrEqual(inventory.count, RefreshSessionBuilder.questionLimit)
    }

    // MARK: - Skill count + session

    func test_skillCount_countsDistinctLessons_notTemplates() throws {
        // Two misses in the SAME lesson → 1 skill; add a miss in a second
        // lesson → 2 skills.
        let sameLesson = Array(repo.templates(for: staleLesson).prefix(2)).map(\.id)
        guard sameLesson.count == 2 else { throw XCTSkip("need ≥2 templates") }
        let otherId = try XCTUnwrap(repo.templates(for: mistakeLesson).first?.id)

        let oneLesson = [session(lesson: staleLesson,
                                 results: sameLesson.map { ($0, false) }, daysAgo: 1)]
        XCTAssertEqual(RefreshSessionBuilder.skillCount(
            masteredLessonIds: [], sessions: oneLesson, repository: repo
        ), 1)

        let twoLessons = oneLesson + [session(lesson: mistakeLesson,
                                              results: [(otherId, false)], daysAgo: 1)]
        XCTAssertEqual(RefreshSessionBuilder.skillCount(
            masteredLessonIds: [], sessions: twoLessons, repository: repo
        ), 2)
    }

    func test_build_generatesQuestionsForInventory() throws {
        let id = try XCTUnwrap(repo.templates(for: mistakeLesson).first?.id)
        let sessions = [session(lesson: mistakeLesson, results: [(id, false)], daysAgo: 1)]
        let result = try XCTUnwrap(RefreshSessionBuilder.build(
            masteredLessonIds: [], sessions: sessions, repository: repo
        ))
        XCTAssertEqual(result.questions.count, 1)
        XCTAssertEqual(result.questions.first?.templateId, id)
        XCTAssertEqual(result.skillCount, 1)
    }
}
