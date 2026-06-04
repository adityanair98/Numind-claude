import XCTest
@testable import Numind

final class QuizEngineTests: XCTestCase {
    private var tipBasicTemplate: QuizTemplate!
    private var billTotalTemplate: QuizTemplate!
    private var splitTipTemplate: QuizTemplate!

    override func setUp() {
        super.setUp()
        let repo = LocalContentRepository(bundle: .main)
        tipBasicTemplate  = repo.template(id: "tip_percent_basic")
        billTotalTemplate = repo.template(id: "tip_bill_total")
        splitTipTemplate  = repo.template(id: "tip_split_tip")
    }

    // MARK: - Structure

    func test_generate_returnsFourChoices() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertEqual(q.choices.count, 4)
    }

    func test_generate_correctChoiceIdIsAmongChoices() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertTrue(q.choices.contains { $0.id == q.correctChoiceId })
    }

    func test_generate_promptIsNonEmpty() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertFalse(q.prompt.isEmpty)
    }

    func test_generate_explanationIsNonEmpty() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertFalse(q.explanation.isEmpty)
    }

    func test_generate_promptContainsNoUnresolvedPlaceholders() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertFalse(q.prompt.contains("{{"), "Unresolved placeholder in: \(q.prompt)")
    }

    func test_generate_allChoiceTextsAreDistinct() {
        let q = QuizEngine.generate(from: tipBasicTemplate, seed: 42)
        XCTAssertEqual(q.choices.count, Set(q.choices.map(\.text)).count)
    }

    // MARK: - Determinism

    func test_sameSeed_producesSamePrompt() {
        let q1 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        let q2 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        XCTAssertEqual(q1.prompt, q2.prompt)
    }

    func test_sameSeed_producesSameChoiceTexts() {
        let q1 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        let q2 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        XCTAssertEqual(q1.choices.map(\.text).sorted(), q2.choices.map(\.text).sorted())
    }

    func test_sameSeed_sameCorrectAnswerText() {
        let q1 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        let q2 = QuizEngine.generate(from: tipBasicTemplate, seed: 99)
        let text1 = q1.choices.first { $0.id == q1.correctChoiceId }?.text
        let text2 = q2.choices.first { $0.id == q2.correctChoiceId }?.text
        XCTAssertEqual(text1, text2)
    }

    // MARK: - Formula correctness

    func test_tipAmount_correctAnswerIsFromValidSet() {
        let template = tipBasicTemplate!
        let bills = template.variableRules.first { $0.name == "billAmount" }!.options
        let pcts  = template.variableRules.first { $0.name == "tipPercent" }!.options
        let valid = Set(bills.flatMap { bill in pcts.map { pct in
            String(format: "$%.2f", ((bill * pct / 100) * 100).rounded() / 100)
        }})

        for seed in stride(from: UInt64(1), through: 20, by: 1) {
            let q = QuizEngine.generate(from: template, seed: seed)
            let correct = q.choices.first { $0.id == q.correctChoiceId }!.text
            XCTAssertTrue(valid.contains(correct), "Unexpected tipAmount '\(correct)' for seed \(seed)")
        }
    }

    func test_billWithTip_correctAnswerIsFromValidSet() {
        let template = billTotalTemplate!
        let bills = template.variableRules.first { $0.name == "billAmount" }!.options
        let pcts  = template.variableRules.first { $0.name == "tipPercent" }!.options
        let valid = Set(bills.flatMap { bill in pcts.map { pct in
            String(format: "$%.2f", ((bill * (1 + pct / 100)) * 100).rounded() / 100)
        }})

        for seed in stride(from: UInt64(1), through: 20, by: 1) {
            let q = QuizEngine.generate(from: template, seed: seed)
            let correct = q.choices.first { $0.id == q.correctChoiceId }!.text
            XCTAssertTrue(valid.contains(correct), "Unexpected billWithTip '\(correct)' for seed \(seed)")
        }
    }

    func test_tipPerPerson_correctAnswerIsFromValidSet() {
        let template = splitTipTemplate!
        let bills   = template.variableRules.first { $0.name == "billAmount" }!.options
        let pcts    = template.variableRules.first { $0.name == "tipPercent" }!.options
        let people  = template.variableRules.first { $0.name == "numPeople" }!.options
        let valid = Set(bills.flatMap { bill in pcts.flatMap { pct in people.compactMap { n -> String? in
            guard n > 0 else { return nil }
            return String(format: "$%.2f", ((bill * pct / 100 / n) * 100).rounded() / 100)
        }}})

        for seed in stride(from: UInt64(1), through: 20, by: 1) {
            let q = QuizEngine.generate(from: template, seed: seed)
            let correct = q.choices.first { $0.id == q.correctChoiceId }!.text
            XCTAssertTrue(valid.contains(correct), "Unexpected tipPerPerson '\(correct)' for seed \(seed)")
        }
    }

    // MARK: - Answer formatting

    func test_format_currency() {
        XCTAssertEqual(QuizEngine.format(8.1,  as: .currency), "$8.10")
        XCTAssertEqual(QuizEngine.format(12.0, as: .currency), "$12.00")
        XCTAssertEqual(QuizEngine.format(0.5,  as: .currency), "$0.50")
    }

    func test_format_percent() {
        XCTAssertEqual(QuizEngine.format(18, as: .percent), "18%")
        XCTAssertEqual(QuizEngine.format(20, as: .percent), "20%")
    }

    func test_format_integer() {
        XCTAssertEqual(QuizEngine.format(5,  as: .integer), "5")
        XCTAssertEqual(QuizEngine.format(42, as: .integer), "42")
    }

    // MARK: - All templates pass

    func test_allTemplates_generateValidQuestions() {
        let repo = LocalContentRepository(bundle: .main)
        for template in repo.templates(for: "tip_18_percent") {
            let q = QuizEngine.generate(from: template, seed: 42)
            XCTAssertEqual(q.choices.count, 4,
                "\(template.id): expected 4 choices")
            XCTAssertTrue(q.choices.contains { $0.id == q.correctChoiceId },
                "\(template.id): correctChoiceId not found in choices")
            XCTAssertFalse(q.prompt.contains("{{"),
                "\(template.id): unresolved placeholder in prompt")
            XCTAssertEqual(q.choices.count, Set(q.choices.map(\.text)).count,
                "\(template.id): duplicate choice texts")
        }
    }

    // MARK: - Concept templates

    func test_conceptTemplate_generatesValidQuestion() {
        let template = QuizTemplate(
            id: "test_concept",
            moduleId: "test",
            difficulty: 2,
            inputMode: .multipleChoice,
            scenarioTemplate: nil,
            promptTemplate: "Which is the largest single factor in your FICO score?",
            variableRules: [],
            answerFormula: nil,
            answerFormat: .integer,
            distractorStrategy: .roundedNeighbor,
            explanationTemplate: "Payment history accounts for 35% — the largest factor.",
            conceptChoices: [
                "Payment history",
                "Credit utilization",
                "Length of credit history",
                "Number of inquiries"
            ],
            correctConceptChoice: "Payment history",
            isApplication: nil
        )
        let q = QuizEngine.generate(from: template, seed: 42)
        XCTAssertEqual(q.choices.count, 4)
        XCTAssertTrue(q.choices.contains(where: { $0.id == q.correctChoiceId && $0.text == "Payment history" }))
        XCTAssertEqual(q.prompt, "Which is the largest single factor in your FICO score?")
        XCTAssertFalse(q.explanation.isEmpty)
        // Choices should be shuffled but always include all 4
        XCTAssertEqual(Set(q.choices.map(\.text)), Set(["Payment history", "Credit utilization", "Length of credit history", "Number of inquiries"]))
    }

    func test_conceptTemplate_sameSeedProducesSameOrder() {
        let template = QuizTemplate(
            id: "test_concept_seed",
            moduleId: "test",
            difficulty: 2,
            inputMode: .multipleChoice,
            scenarioTemplate: nil,
            promptTemplate: "Pick A.",
            variableRules: [],
            answerFormula: nil,
            answerFormat: .integer,
            distractorStrategy: .roundedNeighbor,
            explanationTemplate: "Always A.",
            conceptChoices: ["A", "B", "C", "D"],
            correctConceptChoice: "A",
            isApplication: nil
        )
        let q1 = QuizEngine.generate(from: template, seed: 42)
        let q2 = QuizEngine.generate(from: template, seed: 42)
        XCTAssertEqual(q1.choices.map(\.text), q2.choices.map(\.text))
    }

    // MARK: - Formula dispatch error distinction

    func test_compute_unknownFormula_returnsFormulaNotRegistered() {
        let result = QuizEngine.compute(
            formula: "thisFormulaDoesNotExist",
            variables: ["billAmount": 50, "tipPercent": 18]
        )
        XCTAssertEqual(result, .formulaNotRegistered)
    }

    func test_compute_registeredFormulaWithMissingVariable_returnsFormulaReturnedNil() {
        // tipAmount requires both billAmount and tipPercent. Passing only one
        // forces the formula's `guard let` to fail and return nil — the data
        // error case (variable-name mismatch in a real template).
        let result = QuizEngine.compute(
            formula: "tipAmount",
            variables: ["billAmount": 50]
        )
        XCTAssertEqual(result, .formulaReturnedNil)
    }

    func test_compute_registeredFormulaWithAllVariables_returnsOk() {
        let result = QuizEngine.compute(
            formula: "tipAmount",
            variables: ["billAmount": 50, "tipPercent": 18]
        )
        XCTAssertEqual(result, .ok(9))
    }
}
