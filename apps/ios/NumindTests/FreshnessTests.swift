import XCTest
@testable import Numind

/// Locks in the Phase 9 Freshness invariants: refresh targets are finite,
/// bounded by the limit, scoped to mastered lessons, and never include
/// never-seen templates. Freshness is the only currency that decays.
final class FreshnessTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    /// A real lesson with templates, so the SRS overdue lookup has something to score.
    /// `tip_18_percent` is a stable Smart Shopping lesson.
    private let realLesson = "tip_18_percent"

    private func oldSession(lesson: String, templateIds: [String], daysAgo: Int) -> SessionRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let results = templateIds.map {
            QuestionResult(templateId: $0, isCorrect: true, timeSpentSeconds: 5, difficulty: .medium)
        }
        return SessionRecord(id: UUID(), lessonId: lesson, moduleId: "smart_shopping", date: date,
                             correctCount: results.count, totalCount: results.count, questionResults: results)
    }

    // MARK: - Empty / scoping

    func test_noMasteredLessons_yieldsNoTargets() {
        XCTAssertTrue(FreshnessEngine.refreshTargets(masteredLessonIds: [], sessions: []).isEmpty)
        XCTAssertEqual(FreshnessEngine.staleCount(masteredLessonIds: [], sessions: []), 0)
    }

    func test_freshnessPercent_isOneWhenNothingMastered() {
        XCTAssertEqual(FreshnessEngine.freshnessPercent(masteredLessonIds: [], sessions: []), 1.0, accuracy: 0.001)
    }

    func test_neverSeenTemplates_areNotStale() {
        // Lesson is "mastered" but its templates were never attempted → never-seen
        // (+∞ priority) → excluded from refresh targets.
        let targets = FreshnessEngine.refreshTargets(
            masteredLessonIds: [realLesson], sessions: [], repository: repo
        )
        XCTAssertTrue(targets.isEmpty)
    }

    // MARK: - Overdue detection

    func test_oldAttempt_becomesStaleAndRefreshable() {
        guard let templateId = repo.templates(for: realLesson).first?.id else {
            return XCTFail("expected templates for \(realLesson)")
        }
        // Attempted 60 days ago → well past any SRS interval → overdue.
        let sessions = [oldSession(lesson: realLesson, templateIds: [templateId], daysAgo: 60)]
        let targets = FreshnessEngine.refreshTargets(
            masteredLessonIds: [realLesson], sessions: sessions, repository: repo
        )
        XCTAssertTrue(targets.contains(templateId))
        XCTAssertEqual(FreshnessEngine.staleCount(masteredLessonIds: [realLesson], sessions: sessions, repository: repo), 1)
    }

    func test_refreshTargets_respectLimit() throws {
        let ids = Array(repo.templates(for: realLesson).map(\.id).prefix(3))
        guard ids.count >= 2 else { throw XCTSkip("need ≥2 templates") }
        let sessions = [oldSession(lesson: realLesson, templateIds: ids, daysAgo: 90)]
        let limited = FreshnessEngine.refreshTargets(
            masteredLessonIds: [realLesson], sessions: sessions, repository: repo, limit: 1
        )
        XCTAssertLessThanOrEqual(limited.count, 1)
    }

    func test_refreshTargets_areFinite() {
        let ids = repo.templates(for: realLesson).map(\.id)
        let sessions = [oldSession(lesson: realLesson, templateIds: ids, daysAgo: 120)]
        let targets = FreshnessEngine.refreshTargets(
            masteredLessonIds: [realLesson], sessions: sessions, repository: repo
        )
        // Bounded by the lesson's template count — never unbounded/infinite.
        XCTAssertLessThanOrEqual(targets.count, ids.count)
    }
}
