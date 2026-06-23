import Foundation

/// Per-pack **Readiness** — the honest, decision-scoped competence signal
/// (Phase 9). Replaces the global 0–100 composite as the competence headline.
/// Pure over the session log + content repo.
///
/// Gates are layered and depth-gated. **coverage / retention / application** are
/// *exposure*-scoped — they count practice of a core lesson's templates on ANY
/// surface (a focused lesson session OR Daily Workout / Refresh / Bonus, which
/// record under a synthetic lessonId but keep the real templateId). **depth** and
/// the mastery star are *focused*-scoped — earned only by deliberate lesson work.
/// So the daily loop visibly moves a pack toward Ready, while "prove the hard
/// ones" still requires sitting the lesson (Option C — exposure counts, mastery
/// earned).
/// - **coverage** — every core lesson practiced (any surface)
/// - **depth** — every core lesson mastered *with a correct hard question*
///   (focused lesson sessions only)
/// - **retention** — every core lesson answered correctly on ≥2 distinct days
///   (any surface; a hold-out proxy — it survived at least one gap)
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
        guard core.contains(where: { attempted($0, sessions: data.sessions, repository: repository) })
        else { return .notStarted }

        // Coverage + retention count practice of a core lesson's templates on ANY
        // surface — a focused lesson session OR Daily Workout / Refresh / Bonus
        // (which record under a synthetic lessonId but keep the real templateId).
        // The depth gate + the mastery star stay focused-session-only: exposure
        // moves a pack toward Ready, but "prove the hard ones" is still earned by
        // deliberate lesson work (Option C — exposure counts, mastery earned).
        let coverage  = core.allSatisfy { attempted($0, sessions: data.sessions, repository: repository) }
        // Depth gate: "prove the hard ones." For a lesson that *can* produce a
        // hard question we require mastered-with-hard; for a pure-concept lesson
        // whose templates top out below hard (no hard question is generable —
        // e.g. concept_insurance_open_enrollment), the hardest available evidence
        // IS top-tier mastery, so we accept plain mastery. Without this carve-out
        // such a lesson makes its pack's depth gate mathematically unreachable.
        let depth     = core.allSatisfy { lessonId in
            hardCapable(lessonId, repository: repository)
                ? data.masteredWithHard(lessonId)
                : data.hasMasteredLesson(lessonId)
        }
        let retention = core.allSatisfy { retained($0, sessions: data.sessions, repository: repository) }

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

    /// Whether a lesson can ever generate a HARD question. A numerical template
    /// is hard-capable (difficulty is assessed at runtime and can reach hard); a
    /// concept template is hard-capable only when its static tier is hard (≥3).
    /// A lesson the repo doesn't know (no templates — e.g. a synthetic test pack)
    /// defaults to hard-capable, preserving the strict depth gate.
    private static func hardCapable(
        _ lessonId: String,
        repository: ContentRepository
    ) -> Bool {
        let templates = repository.templates(for: lessonId)
        guard !templates.isEmpty else { return true }
        return templates.contains { $0.conceptChoices == nil || $0.difficulty >= 3 }
    }

    /// Template IDs belonging to a lesson. Cheap repo lookup, bounded by the
    /// lesson's template count.
    private static func templateIds(_ lessonId: String, repository: ContentRepository) -> Set<String> {
        Set(repository.templates(for: lessonId).map(\.id))
    }

    /// Coverage proxy — has the user practiced this lesson on ANY surface?
    /// A focused lesson session (lessonId match, incl. legacy sessions with no
    /// per-question results) OR Daily/Refresh/Bonus practice of one of the
    /// lesson's templates (Option C — exposure counts).
    private static func attempted(
        _ lessonId: String, sessions: [SessionRecord], repository: ContentRepository
    ) -> Bool {
        if sessions.contains(where: { $0.lessonId == lessonId }) { return true }
        let ids = templateIds(lessonId, repository: repository)
        guard !ids.isEmpty else { return false }
        return sessions.contains { $0.questionResults.contains { ids.contains($0.templateId) } }
    }

    /// Hold-out retention proxy: a correct answer attributable to this lesson on
    /// ≥2 distinct calendar days — counting a focused lesson session (lessonId
    /// match) OR Daily/Refresh/Bonus practice of the lesson's templates
    /// (Option C). The lessonId path also covers legacy sessions that predate
    /// per-question results.
    private static func retained(
        _ lessonId: String, sessions: [SessionRecord], repository: ContentRepository
    ) -> Bool {
        let cal = Calendar.current
        let ids = templateIds(lessonId, repository: repository)
        var days = Set<Date>()
        for s in sessions {
            let focusedCorrect = s.lessonId == lessonId && s.correctCount > 0
            let exposureCorrect = s.questionResults.contains { ids.contains($0.templateId) && $0.isCorrect }
            if focusedCorrect || exposureCorrect {
                days.insert(cal.startOfDay(for: s.date))
            }
        }
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
