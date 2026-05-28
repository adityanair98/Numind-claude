import Foundation

struct Lesson: Codable, Identifiable, Equatable {
    let id: String
    let moduleId: String
    let title: String
    let concept: String
    let shortcut: String
    let example: String
    let quizTemplateIds: [String]
    /// ISO date (yyyy-mm-dd) tracking when this lesson's content was last fact-checked
    /// against primary sources. Optional — older lessons may not have it yet.
    /// Used by the content audit workflow to surface stale entries.
    let lastVerified: String?

    // MARK: - Skill mapping (Phase 5a)
    /// The primary competency axis this lesson develops. Every lesson must
    /// have exactly one primary skill. Drives the Numind Score radar.
    /// - Note: Optional in the Codable so a freshly-checked-out file without
    ///   the mapping field still decodes; production data must have all
    ///   lessons mapped (enforced by `SkillAxisMappingTests`).
    let primarySkill: SkillAxis?

    /// Up to 2 additional competency axes this lesson contributes to.
    /// Question attempts credit the primary at 70% weight and each secondary
    /// at 30% (split evenly if there are multiple secondaries).
    /// - Defaults to empty if missing from JSON.
    let secondarySkills: [SkillAxis]

    /// Whether this lesson is part of the universal money-sense core.
    /// Used by the Daily Workout brand-new-user fallback to ensure breadth
    /// (~25-35 lessons tagged across the 7 axes).
    /// - Defaults to false if missing from JSON.
    let isCore: Bool

    /// Whether any of this lesson's templates carry a `scenarioTemplate` —
    /// derived during the skill-mapping pass and stored explicitly so the
    /// Daily Workout's scenario slot can filter without recomputation.
    /// - Defaults to false if missing from JSON.
    let isScenarioEligible: Bool

    // Custom init for Codable with sensible defaults — keeps unmapped
    // lessons decodable while we roll out the mapping incrementally.
    enum CodingKeys: String, CodingKey {
        case id, moduleId, title, concept, shortcut, example
        case quizTemplateIds, lastVerified
        case primarySkill, secondarySkills, isCore, isScenarioEligible
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id              = try c.decode(String.self, forKey: .id)
        self.moduleId        = try c.decode(String.self, forKey: .moduleId)
        self.title           = try c.decode(String.self, forKey: .title)
        self.concept         = try c.decode(String.self, forKey: .concept)
        self.shortcut        = try c.decode(String.self, forKey: .shortcut)
        self.example         = try c.decode(String.self, forKey: .example)
        self.quizTemplateIds = try c.decode([String].self, forKey: .quizTemplateIds)
        self.lastVerified    = try c.decodeIfPresent(String.self, forKey: .lastVerified)
        self.primarySkill    = try c.decodeIfPresent(SkillAxis.self, forKey: .primarySkill)
        self.secondarySkills = try c.decodeIfPresent([SkillAxis].self, forKey: .secondarySkills) ?? []
        self.isCore          = try c.decodeIfPresent(Bool.self, forKey: .isCore) ?? false
        self.isScenarioEligible = try c.decodeIfPresent(Bool.self, forKey: .isScenarioEligible) ?? false
    }

    // Memberwise init retained for tests / previews
    init(
        id: String,
        moduleId: String,
        title: String,
        concept: String,
        shortcut: String,
        example: String,
        quizTemplateIds: [String],
        lastVerified: String? = nil,
        primarySkill: SkillAxis? = nil,
        secondarySkills: [SkillAxis] = [],
        isCore: Bool = false,
        isScenarioEligible: Bool = false
    ) {
        self.id = id
        self.moduleId = moduleId
        self.title = title
        self.concept = concept
        self.shortcut = shortcut
        self.example = example
        self.quizTemplateIds = quizTemplateIds
        self.lastVerified = lastVerified
        self.primarySkill = primarySkill
        self.secondarySkills = secondarySkills
        self.isCore = isCore
        self.isScenarioEligible = isScenarioEligible
    }
}
