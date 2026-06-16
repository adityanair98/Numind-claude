import Foundation

/// A "Life-Event Pack" — a curated sequence of existing lessons that maps to a
/// canonical real-world decision the user is making (e.g. "First Paycheck",
/// "Buying a Home", "Open Enrollment").
///
/// Packs are a PACKAGING layer on top of modules. A lesson can appear in
/// multiple packs (e.g. `investing_401k_match` shows up in both
/// "First Paycheck" and "Investing Starter"). Modules remain the canonical
/// taxonomy in the app's Learn surface; packs are the search-intent /
/// marketing-aligned surface that maps directly to high-volume queries
/// like "first apartment checklist" or "how to pay off credit card debt".
struct Pack: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    /// Short marketing-friendly subtitle (~10 words).
    let tagline: String
    /// One-sentence framing of the user moment. Used on landing pages.
    let hook: String
    /// Longer description (~50-80 words) used on the pack page above the lesson list.
    let description: String
    /// Ordered list of lesson IDs in the pack. Order matters for the suggested
    /// learning sequence; the first item is the natural entry point unless
    /// `anchorLessonId` overrides it.
    let lessonIds: [String]
    /// The foundational subset of `lessonIds` that defines readiness for this
    /// pack's decision (Phase 9). Empty = treat all `lessonIds` as core.
    let coreLessonIds: [String]
    /// The single lesson that best frames the decision. Surfaced visually
    /// (e.g. as a "Start here" anchor on the pack page). Must be present in
    /// `lessonIds`.
    let anchorLessonId: String
    /// Rough total reading + quiz time across all lessons (minutes).
    let estimatedMinutes: Int
    /// ISO date (yyyy-mm-dd) the pack's lesson selection + framing was last
    /// re-validated. Bumped any time the pack composition changes.
    let lastVerified: String

    // MARK: - Skill axis mapping (Phase 5a)
    /// The primary competency axis this pack improves most. Used by the
    /// "Recommended next pack" engine to match a user's weakest measured axis.
    /// - Note: Optional in Codable for backwards compat while we roll out
    ///   the mapping; production data must have all packs mapped.
    let primarySkillAxis: SkillAxis?

    /// Up to 2 additional axes the pack meaningfully touches (e.g. First
    /// Paycheck primary = Income & Paycheck, secondary = Cash Flow + Investing).
    /// - Defaults to empty if missing from JSON.
    let secondarySkillAxes: [SkillAxis]

    enum CodingKeys: String, CodingKey {
        case id, title, tagline, hook, description, lessonIds, coreLessonIds, anchorLessonId
        case estimatedMinutes, lastVerified
        case primarySkillAxis, secondarySkillAxes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id               = try c.decode(String.self, forKey: .id)
        self.title            = try c.decode(String.self, forKey: .title)
        self.tagline          = try c.decode(String.self, forKey: .tagline)
        self.hook             = try c.decode(String.self, forKey: .hook)
        self.description      = try c.decode(String.self, forKey: .description)
        self.lessonIds        = try c.decode([String].self, forKey: .lessonIds)
        self.coreLessonIds    = try c.decodeIfPresent([String].self, forKey: .coreLessonIds) ?? []
        self.anchorLessonId   = try c.decode(String.self, forKey: .anchorLessonId)
        self.estimatedMinutes = try c.decode(Int.self, forKey: .estimatedMinutes)
        self.lastVerified     = try c.decode(String.self, forKey: .lastVerified)
        self.primarySkillAxis   = try c.decodeIfPresent(SkillAxis.self, forKey: .primarySkillAxis)
        self.secondarySkillAxes = try c.decodeIfPresent([SkillAxis].self, forKey: .secondarySkillAxes) ?? []
    }

    init(
        id: String,
        title: String,
        tagline: String,
        hook: String,
        description: String,
        lessonIds: [String],
        coreLessonIds: [String] = [],
        anchorLessonId: String,
        estimatedMinutes: Int,
        lastVerified: String,
        primarySkillAxis: SkillAxis? = nil,
        secondarySkillAxes: [SkillAxis] = []
    ) {
        self.id = id
        self.title = title
        self.tagline = tagline
        self.hook = hook
        self.description = description
        self.lessonIds = lessonIds
        self.coreLessonIds = coreLessonIds
        self.anchorLessonId = anchorLessonId
        self.estimatedMinutes = estimatedMinutes
        self.lastVerified = lastVerified
        self.primarySkillAxis = primarySkillAxis
        self.secondarySkillAxes = secondarySkillAxes
    }
}
