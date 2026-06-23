import XCTest
@testable import Numind

/// Phase 10 — teach-card interstitials in the quiz session state machine.
@MainActor
final class QuizSessionTeachTests: XCTestCase {

    private let repo = LocalContentRepository(bundle: .main)

    private func makeQuestions(_ n: Int) -> [QuizQuestion] {
        // Multiple-choice only, so `select(correctChoiceId)` answers them —
        // freeEntry questions are graded through `freeEntryText` instead.
        let templates = repo.allTemplates()
            .filter { $0.answerFormula != nil && $0.inputMode != .freeEntry }
            .prefix(n)
        return templates.enumerated().map { i, t in
            QuizEngine.generate(from: t, seed: UInt64(i + 1))
        }
    }

    private var card: TeachCard {
        TeachCard(id: "net_pay_check", lessonTitle: "Gross vs net",
                  concept: "C", shortcut: "S", example: nil)
    }

    /// Answer the current question correctly and advance out of feedback.
    /// (The engine may generate either input mode, so handle both.)
    private func answerCorrectly(_ vm: QuizSessionViewModel) {
        if vm.currentQuestion.inputMode == .freeEntry {
            vm.freeEntryText = String(vm.currentQuestion.correctValue)
        } else {
            vm.select(vm.currentQuestion.correctChoiceId)
        }
        vm.checkAnswer()
        guard case .feedback = vm.sessionState else {
            return XCTFail("expected feedback after checkAnswer")
        }
        vm.advance()
    }

    func test_indexZeroCard_showsBeforeFirstQuestion_once() {
        let vm = QuizSessionViewModel(questions: makeQuestions(3), title: "T", shortcut: "S",
                                      teachCards: [0: card])
        vm.startSession()
        guard case .teach(let shown) = vm.sessionState else {
            return XCTFail("expected teach state on session start")
        }
        XCTAssertEqual(shown, card)

        vm.advance()
        guard case .question = vm.sessionState else {
            return XCTFail("expected question after dismissing the card")
        }
        XCTAssertEqual(vm.currentIndex, 0)

        // The card never re-shows, even if navigation revisits the index.
        vm.startSession()
        guard case .question = vm.sessionState else {
            return XCTFail("teach card must show only once")
        }
    }

    func test_midSessionCard_showsBeforeItsQuestion() {
        let vm = QuizSessionViewModel(questions: makeQuestions(4), title: "T", shortcut: "S",
                                      teachCards: [1: card])
        vm.startSession()
        guard case .question = vm.sessionState else { return XCTFail("no card at index 0") }

        answerCorrectly(vm)
        // A motivator may legitimately intercept first (capped at one when
        // teach cards exist) — dismiss it and the teach card must follow.
        if case .motivator = vm.sessionState { vm.advance() }
        guard case .teach = vm.sessionState else {
            return XCTFail("expected the teach card before question 1, got \(vm.sessionState)")
        }
        vm.advance()
        XCTAssertEqual(vm.currentIndex, 1)
        guard case .question = vm.sessionState else { return XCTFail() }
    }

    func test_noCards_behavesAsBefore() {
        let vm = QuizSessionViewModel(questions: makeQuestions(2), title: "T", shortcut: "S")
        vm.startSession()
        guard case .question = vm.sessionState else { return XCTFail() }
        XCTAssertNil(vm.currentSegmentLabel)
    }

    func test_segmentLabels_trackCurrentIndex() {
        let vm = QuizSessionViewModel(questions: makeQuestions(3), title: "T", shortcut: "S",
                                      segmentLabels: ["Warm-up", "Focus", "Decision"])
        vm.startSession()
        XCTAssertEqual(vm.currentSegmentLabel, "Warm-up")
        answerCorrectly(vm)
        if case .motivator = vm.sessionState { vm.advance() }
        XCTAssertEqual(vm.currentSegmentLabel, "Focus")
    }

    func test_freeEntryTolerance_isMagnitudeAware() {
        // Audit fix M4: a correct mental estimate on a large/cents answer passes
        // (the old flat ±0.05 demanded cent-precision), while distractor-class
        // values stay wrong.
        let t1750 = QuizSessionViewModel.freeEntryTolerance(for: 1750, format: .currency)
        XCTAssertEqual(t1750, 70, accuracy: 0.001)            // 4% of 1750
        XCTAssertLessThanOrEqual(abs(1748 - 1750), t1750)     // estimate accepted

        let t4 = QuizSessionViewModel.freeEntryTolerance(for: 4.40, format: .currency)
        XCTAssertEqual(t4, 0.25, accuracy: 0.001)             // floor for small answers
        XCTAssertGreaterThan(abs(5.40 - 4.40), t4)            // a $1-off answer is still wrong

        XCTAssertEqual(QuizSessionViewModel.freeEntryTolerance(for: 9, format: .integer), 0.5)
        XCTAssertEqual(QuizSessionViewModel.freeEntryTolerance(for: 22, format: .percent), 0.5)
    }
}
