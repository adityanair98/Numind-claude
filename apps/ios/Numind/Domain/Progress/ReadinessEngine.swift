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
/// - **application** (Phase 9E) — a correct answer on a scenario/decision item
///   (`isApplication`) among the pack's core lessons. Added only when the pack
///   actually carries application content; otherwise absent (the spec's fallback).
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

        var gates: [(Gate, Bool)] = [(.coverage, coverage), (.depth, depth), (.retention, retention)]

        // Application gate (Phase 9E) — added only when the pack's core lessons
        // actually carry application/decision items; otherwise the spec's
        // fallback applies and the gate is simply absent (no penalty for content
        // that doesn't exist yet).
        let appIds = applicationTemplateIds(core: core, repository: repository)
        if !appIds.isEmpty {
            let application = data.sessions.contains { s in
                s.questionResults.contains { $0.isCorrect && appIds.contains($0.templateId) }
            }
            gates.append((.application, application))
        }

        let unmet = gates.filter { !$0.1 }.map(\.0)

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

    /// Application/decision template IDs across a pack's core lessons (Phase 9E).
    /// Empty when the pack has no application content yet → the application gate
    /// is skipped (the spec's fallback).
    private static func applicationTemplateIds(
        core: [String],
        repository: ContentRepository
    ) -> Set<String> {
        var ids = Set<String>()
        for lessonId in core {
            for t in repository.templates(for: lessonId) where t.isApplicationItem {
                ids.insert(t.id)
            }
        }
        return ids
    }

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
