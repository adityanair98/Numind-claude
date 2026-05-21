import XCTest
@testable import Numind

final class ContentRepositoryTests: XCTestCase {
    private var repo: ContentRepository!

    override func setUp() {
        super.setUp()
        // Bundle.main is the host app's bundle during unit tests — JSON lives there.
        repo = LocalContentRepository(bundle: .main)
    }

    // MARK: - Modules

    func test_allModules_isNotEmpty() {
        XCTAssertFalse(repo.allModules().isEmpty)
    }

    func test_smartShoppingModule_exists() {
        XCTAssertNotNil(repo.module(id: "smart_shopping"))
    }

    func test_smartShoppingModule_fieldsDecodeCorrectly() {
        let m = repo.module(id: "smart_shopping")
        XCTAssertEqual(m?.title,     "Smart Shopping")
        XCTAssertEqual(m?.icon,      "cart.fill")
        XCTAssertEqual(m?.color,     .blue)
        XCTAssertEqual(m?.lessonIds, [
            "tip_18_percent", "tip_10_percent_trick", "tip_20_double",
            "tip_pre_or_post_tax", "tip_split_bill",
            "discount_25_percent", "discount_10_percent", "discount_bogo",
            "discount_stacked", "discount_unit_price"
        ])
    }

    func test_unknownModule_returnsNil() {
        XCTAssertNil(repo.module(id: "does_not_exist"))
    }

    // MARK: - Lessons

    func test_smartShoppingLesson_exists() {
        XCTAssertNotNil(repo.lesson(id: "tip_18_percent"))
    }

    func test_smartShoppingLesson_fieldsDecodeCorrectly() {
        let l = repo.lesson(id: "tip_18_percent")
        XCTAssertEqual(l?.moduleId, "smart_shopping")
        XCTAssertEqual(l?.title,    "Calculate an 18% tip")
        XCTAssertFalse(l?.concept.isEmpty  ?? true)
        XCTAssertFalse(l?.shortcut.isEmpty ?? true)
        XCTAssertFalse(l?.example.isEmpty  ?? true)
    }

    func test_smartShoppingLesson_referencesFiveTemplates() {
        let l = repo.lesson(id: "tip_18_percent")
        XCTAssertEqual(l?.quizTemplateIds.count, 5)
    }

    func test_lessonsForModule_returnsSmartShoppingLessons() {
        let lessons = repo.lessons(for: "smart_shopping")
        XCTAssertEqual(lessons.count, 10)
        XCTAssertEqual(lessons.first?.id, "tip_18_percent")
    }

    func test_unknownLesson_returnsNil() {
        XCTAssertNil(repo.lesson(id: "does_not_exist"))
    }

    // MARK: - Templates

    func test_templatesForLesson_returnsFive() {
        let templates = repo.templates(for: "tip_18_percent")
        XCTAssertEqual(templates.count, 5)
    }

    func test_templatesForLesson_respectsDeclarationOrder() {
        let templates = repo.templates(for: "tip_18_percent")
        XCTAssertEqual(templates.map(\.id), [
            "tip_percent_basic", "tip_bill_total", "tip_split_tip",
            "tip_18_d2", "tip_hotel_service_d2"
        ])
    }

    func test_tipPercentBasic_decodesCorrectly() {
        let t = repo.template(id: "tip_percent_basic")
        XCTAssertNotNil(t)
        XCTAssertEqual(t?.moduleId,           "smart_shopping")
        XCTAssertEqual(t?.difficulty,         1)
        XCTAssertEqual(t?.answerFormula,      "tipAmount")
        XCTAssertEqual(t?.answerFormat,       .currency)
        XCTAssertEqual(t?.distractorStrategy, .roundedNeighbor)
        XCTAssertEqual(t?.variableRules.count, 2)
    }

    func test_allTemplates_haveNonEmptyVariableRules() {
        for template in repo.templates(for: "tip_18_percent") {
            XCTAssertFalse(
                template.variableRules.isEmpty,
                "\(template.id) has no variable rules"
            )
            for rule in template.variableRules {
                XCTAssertFalse(
                    rule.options.isEmpty,
                    "Variable '\(rule.name)' in \(template.id) has no options"
                )
            }
        }
    }

    func test_allTemplates_haveNonEmptyPromptAndExplanation() {
        for template in repo.templates(for: "tip_18_percent") {
            XCTAssertFalse(template.promptTemplate.isEmpty,      "\(template.id) promptTemplate is empty")
            XCTAssertFalse(template.explanationTemplate.isEmpty, "\(template.id) explanationTemplate is empty")
        }
    }

    func test_unknownTemplate_returnsNil() {
        XCTAssertNil(repo.template(id: "does_not_exist"))
    }
}
