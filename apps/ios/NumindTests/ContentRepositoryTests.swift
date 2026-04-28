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

    func test_tipsModule_exists() {
        XCTAssertNotNil(repo.module(id: "tips"))
    }

    func test_tipsModule_fieldsDecodeCorrectly() {
        let m = repo.module(id: "tips")
        XCTAssertEqual(m?.title,     "Tips, Tax & Bill Split")
        XCTAssertEqual(m?.icon,      "percent")
        XCTAssertEqual(m?.color,     "primaryBlue")
        XCTAssertEqual(m?.lessonIds, ["tip_18_percent"])
    }

    func test_unknownModule_returnsNil() {
        XCTAssertNil(repo.module(id: "does_not_exist"))
    }

    // MARK: - Lessons

    func test_tipsLesson_exists() {
        XCTAssertNotNil(repo.lesson(id: "tip_18_percent"))
    }

    func test_tipsLesson_fieldsDecodeCorrectly() {
        let l = repo.lesson(id: "tip_18_percent")
        XCTAssertEqual(l?.moduleId, "tips")
        XCTAssertEqual(l?.title,    "Calculate an 18% tip")
        XCTAssertFalse(l?.concept.isEmpty  ?? true)
        XCTAssertFalse(l?.shortcut.isEmpty ?? true)
        XCTAssertFalse(l?.example.isEmpty  ?? true)
    }

    func test_tipsLesson_referencesThreeTemplates() {
        let l = repo.lesson(id: "tip_18_percent")
        XCTAssertEqual(l?.quizTemplateIds.count, 3)
    }

    func test_lessonsForModule_returnsTipsLesson() {
        let lessons = repo.lessons(for: "tips")
        XCTAssertEqual(lessons.count, 1)
        XCTAssertEqual(lessons.first?.id, "tip_18_percent")
    }

    func test_unknownLesson_returnsNil() {
        XCTAssertNil(repo.lesson(id: "does_not_exist"))
    }

    // MARK: - Templates

    func test_templatesForLesson_returnsThree() {
        let templates = repo.templates(for: "tip_18_percent")
        XCTAssertEqual(templates.count, 3)
    }

    func test_templatesForLesson_respectsDeclarationOrder() {
        let templates = repo.templates(for: "tip_18_percent")
        XCTAssertEqual(templates.map(\.id), ["tip_percent_basic", "tip_bill_total", "tip_split_tip"])
    }

    func test_tipPercentBasic_decodesCorrectly() {
        let t = repo.template(id: "tip_percent_basic")
        XCTAssertNotNil(t)
        XCTAssertEqual(t?.moduleId,           "tips")
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
