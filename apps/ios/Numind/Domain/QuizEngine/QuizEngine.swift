import Foundation

struct QuizEngine {

    // MARK: - Public API

    static func generate(from template: QuizTemplate, seed: UInt64 = .random(in: 1...UInt64.max)) -> QuizQuestion {
        var rng = SeededRandomGenerator(seed: seed)

        let variables = resolveVariables(template.variableRules, using: &rng)

        guard let correctRaw = compute(formula: template.answerFormula, variables: variables) else {
            fatalError("QuizEngine: unknown formula '\(template.answerFormula)'")
        }
        let correctValue = correctRaw.rounded2dp

        let distractorValues = distractors(
            correct: correctValue,
            strategy: template.distractorStrategy,
            variables: variables,
            using: &rng
        )

        let correctChoice = QuizQuestion.Choice(id: UUID(), text: format(correctValue, as: template.answerFormat))
        let distractorChoices = distractorValues.map {
            QuizQuestion.Choice(id: UUID(), text: format($0, as: template.answerFormat))
        }

        let allChoices = ([correctChoice] + distractorChoices).shuffled(using: &rng)

        return QuizQuestion(
            id: UUID(),
            templateId: template.id,
            prompt: render(template.promptTemplate, variables: variables),
            choices: allChoices,
            correctChoiceId: correctChoice.id,
            explanation: render(template.explanationTemplate, variables: variables)
        )
    }

    // MARK: - Answer formatting (internal + exposed for UI)

    static func format(_ value: Double, as answerFormat: AnswerFormat) -> String {
        switch answerFormat {
        case .currency: return String(format: "$%.2f", value)
        case .percent:  return String(format: "%.0f%%", value)
        case .integer:  return String(Int(value.rounded()))
        }
    }

    // MARK: - Variable resolution

    private static func resolveVariables(_ rules: [VariableRule], using rng: inout SeededRandomGenerator) -> [String: Double] {
        var result: [String: Double] = [:]
        for rule in rules where !rule.options.isEmpty {
            let idx = Int(rng.next() % UInt64(rule.options.count))
            result[rule.name] = rule.options[idx]
        }
        return result
    }

    // MARK: - Formula registry

    private static let formulas: [String: ([String: Double]) -> Double?] = [
        "tipAmount": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"] else { return nil }
            return bill * pct / 100
        },
        "billWithTip": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"] else { return nil }
            return bill * (1 + pct / 100)
        },
        "tipPerPerson": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"],
                  let n = vars["numPeople"], n > 0 else { return nil }
            return bill * pct / 100 / n
        },
        "discountAmount": { vars in
            guard let price = vars["originalPrice"], let pct = vars["discountPercent"] else { return nil }
            return price * pct / 100
        },
        "salePrice": { vars in
            guard let price = vars["originalPrice"], let pct = vars["discountPercent"] else { return nil }
            return price * (1 - pct / 100)
        },
    ]

    private static func compute(formula: String, variables: [String: Double]) -> Double? {
        formulas[formula]?(variables)
    }

    // MARK: - Distractor generation

    private static func distractors(
        correct: Double,
        strategy: DistractorStrategy,
        variables: [String: Double],
        using rng: inout SeededRandomGenerator
    ) -> [Double] {
        var candidates: [Double] = []

        switch strategy {
        case .roundedNeighbor:
            for delta in [0.5, 1.0, 1.5, 2.0, -0.5, -1.0, -1.5, -2.0, 2.5, -2.5, 3.0] {
                candidates.append((correct + delta).rounded2dp)
            }

        case .offByDecimal:
            candidates += [
                (correct * 10).rounded2dp,
                (correct / 10).rounded2dp,
                (correct + 1.0).rounded2dp,
                (correct - 1.0).rounded2dp,
                (correct + 0.5).rounded2dp,
                (correct - 0.5).rounded2dp,
            ]

        case .commonMistake:
            if let bill = variables["billAmount"] {
                candidates.append(bill.rounded2dp)
                if let pct = variables["tipPercent"] {
                    candidates.append((bill * 0.10).rounded2dp)           // wrong percent (10%)
                    candidates.append((bill * pct / 100 * 2).rounded2dp)  // doubled tip
                    candidates.append((bill * pct / 100).rounded2dp)      // full tip (forgot to split)
                }
                if let n = variables["numPeople"] {
                    candidates.append((bill / n).rounded2dp)              // share with no tip
                }
            }
            // Neighbors as fallback
            for delta in [0.5, 1.0, -0.5, -1.0, 1.5, -1.5] {
                candidates.append((correct + delta).rounded2dp)
            }
        }

        // Deduplicate, remove the correct answer and non-positive values
        var seen = Set<Double>([correct])
        var unique: [Double] = []
        for c in candidates where c > 0 && !seen.contains(c) {
            seen.insert(c)
            unique.append(c)
        }

        // Pick 3 using rng
        var result: [Double] = []
        while result.count < 3 && !unique.isEmpty {
            let idx = Int(rng.next() % UInt64(unique.count))
            result.append(unique[idx])
            unique.remove(at: idx)
        }

        // Fallback: walk outward until we have 3
        var fallbackDelta = 0.25
        while result.count < 3 {
            let candidate = (correct + fallbackDelta).rounded2dp
            if candidate > 0 && !result.contains(candidate) {
                result.append(candidate)
            }
            fallbackDelta += 0.25
        }

        return result
    }

    // MARK: - Template rendering

    private static func render(_ template: String, variables: [String: Double]) -> String {
        var result = template
        for (key, value) in variables {
            let text = value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value))
                : String(format: "%.2f", value)
            result = result.replacingOccurrences(of: "{{\(key)}}", with: text)
        }
        return result
    }
}

private extension Double {
    var rounded2dp: Double { (self * 100).rounded() / 100 }
}
