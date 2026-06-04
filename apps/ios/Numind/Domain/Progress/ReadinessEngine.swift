import Foundation

/// Per-pack **Readiness** — the honest, decision-scoped competence signal
/// (Phase 9). Replaces the global 0–100 composite as the competence headline.
/// Pure over the session log + content repo.
///
/// Gates are layered and depth-gated:
/// - **coverage** — every core lesson attempted
/// - **depth** — every core lesson mastered *with a correct hard question*
/// - **retention** — every core lesson answered correctly on ≥2 distinct days
///   (a hold-out proxy: it survived at least one gap)
///
/// An **application** gate (a correct scenario/decision item) is added in
/// Phase 9E once scenario content + the `isApplication` flag exist; until then
/// it's simply absent (the spec's fallback).
///
/// The claim is scoped to the evidence — see `readyLabel(for:)` — never a bare
/// "you're ready" verdict.
enum ReadinessEngine {

    enum Gate: String {
        case coverage, depth, retention, application
        var nextAction: String {
            switch self {
            case .coverage:    return "Finish the core lessons in this path."
            case .depth:       return "Tackle the harder questions to lock it in."
            case .retention:   return "Come back for one more review so it sticks."
            case .application: return "Try a real-world scenario question."
            }
        }
    }

    enum State: Equatable {
        case notStarted
        case learning
        case almostReady(missing: Gate, nextAction: String)
        case ready
        case sharp
    }

    /// The foundational lessons that define readiness — the tagged subset, or
    /// all of `lessonIds` if a pack hasn't been tagged yet.
    static func coreLessons(for pack: Pack) -> [String] {
        pack.coreLessonIds.isEmpty ? pack.lessonIds : pack.coreLessonIds
    }

    static func state(
        for pack: Pack,
        data: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> State {
        let core = coreLessons(for: pack)
        guard !core.isEmpty else { return .notStarted }
        guard core.contains(where: { data.hasCompletedLesson($0) }) else { return .notStarted }

        let coverage  = core.allSatisfy { data.hasCompletedLesson($0) }
        let depth     = core.allSatisfy { data.masteredWithHard($0) }
        let retention = core.allSatisfy { retained($0, sessions: data.sessions) }

        let unmet = [(Gate.coverage, coverage), (.depth, depth), (.retention, retention)]
            .filter { !$0.1 }
            .map(\.0)

        if unmet.isEmpty {
            // Ready, or Sharp when every core lesson is also currently fresh.
            let fresh = core.allSatisfy {
                !lessonHasOverdue($0, sessions: data.sessions, repository: repository)
            }
            return fresh ? .sharp : .ready
        }
        if unmet.count == 1 {
            let g = unmet[0]
            return .almostReady(missing: g, nextAction: g.nextAction)
        }
        return .learning
    }

    /// Packs at Ready or Sharp — drives the Home headline + the +150 XP milestone.
    static func readyPackCount(
        data: ProgressData,
        repository: ContentRepository = LocalContentRepository()
    ) -> Int {
        repository.allPacks().reduce(0) { acc, pack in
            switch state(for: pack, data: data, repository: repository) {
            case .ready, .sharp: return acc + 1
            default:             return acc
            }
        }
    }

    /// Honest, evidence-scoped label for a Ready pack (claims the essentials,
    /// not a real-world verdict).
    static func readyLabel(for pack: Pack) -> String {
        "You've got the essentials for \(pack.title) down."
    }

    // MARK: - Private

    /// Hold-out retention proxy: correct answers on ≥2 distinct calendar days.
    private static func retained(_ lessonId: String, sessions: [SessionRecord]) -> Bool {
        let cal = Calendar.current
        let days = Set(
            sessions
                .filter { $0.lessonId == lessonId && $0.correctCount > 0 }
                .map { cal.startOfDay(for: $0.date) }
        )
        return days.count >= 2
    }

    private static func lessonHasOverdue(
        _ lessonId: String,
        sessions: [SessionRecord],
        repository: ContentRepository
    ) -> Bool {
        repository.templates(for: lessonId).contains { t in
            let s = SpacedRepetitionEngine.priorityScore(templateId: t.id, in: sessions)
            return s.isFinite && s > 0   // seen (finite) and overdue
        }
    }
}
