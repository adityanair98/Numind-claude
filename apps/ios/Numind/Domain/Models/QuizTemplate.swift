import Foundation

struct QuizTemplate: Codable, Identifiable, Equatable {
    let id: String
    let moduleId: String
    let difficulty: Int             // 1 = easy, 2 = medium, 3 = hard
    let inputMode: InputMode?       // nil → defaults to .multipleChoice
    let scenarioTemplate: String?   // optional context sentence rendered before the prompt
    let promptTemplate: String      // e.g. "What is {{tipPercent}}% of ${{billAmount}}?"
    let variableRules: [VariableRule]
    let answerFormula: String?      // named formula key (numerical templates); nil for concept templates
    let answerFormat: AnswerFormat
    let distractorStrategy: DistractorStrategy
    let explanationTemplate: String
    // ── Concept template fields (text-MCQ, no formula evaluation) ──
    let conceptChoices: [String]?           // 4 static text options
    let correctConceptChoice: String?       // exact text of the correct option (must appear in conceptChoices)
    // ── Application / decision flag (Phase 9E) ──
    /// True for scenario/decision items that test "what would you do," not just
    /// "compute X." Feeds the per-pack Readiness *application* gate. Optional so
    /// pre-9E JSON (which omits the key) decodes as nil → not an application item.
    let isApplication: Bool?

    /// Convenience: treats a missing flag as `false`.
    var isApplicationItem: Bool { isApplication ?? false }
}

enum InputMode: String, Codable {
    case multipleChoice  // 4 option cards (default)
    case freeEntry       // number pad — user types the answer
}

struct VariableRule: Codable, Equatable {
    let name: String
    let options: [Double]
}

enum AnswerFormat: String, Codable {
    case currency   // formatted as $X.XX
    case percent    // formatted as X%
    case integer    // formatted as a whole number
}

enum DistractorStrategy: String, Codable {
    case roundedNeighbor  // nearby rounded values — for when people mis-round
    case offByDecimal     // decimal-place shift errors
    case commonMistake    // result of a typical wrong operation
}
