import Foundation

struct QuizTemplate: Codable, Identifiable, Equatable {
    let id: String
    let moduleId: String
    let difficulty: Int             // 1 = easy, 2 = medium, 3 = hard
    let scenarioTemplate: String?   // optional context sentence rendered before the prompt
    let promptTemplate: String      // e.g. "What is {{tipPercent}}% of ${{billAmount}}?"
    let variableRules: [VariableRule]
    let answerFormula: String       // named formula key, evaluated by QuizEngine in M4
    let answerFormat: AnswerFormat
    let distractorStrategy: DistractorStrategy
    let explanationTemplate: String
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
