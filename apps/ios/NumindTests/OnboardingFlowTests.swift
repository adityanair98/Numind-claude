import XCTest
@testable import Numind

/// Locks the "Walk In Ready" onboarding restructure: the Confidence↔Mirror
/// reorder and the lane-aware screen skipping (the riskiest new logic, and
/// the part that's conversion-critical).
@MainActor
final class OnboardingFlowTests: XCTestCase {

    /// Fresh VM with isolated signals (ProgressStore reads persisted state, so
    /// we reset to a clean OnboardingSignals and set the lane explicitly).
    private func makeVM(focus: String? = nil,
                        motivations: Set<Motivation> = []) -> OnboardingViewModel {
        let vm = OnboardingViewModel(progressStore: ProgressStore(),
                                     repository: LocalContentRepository())
        vm.signals = OnboardingSignals()
        vm.signals.focusPackId = focus
        vm.signals.motivations = motivations
        return vm
    }

    // MARK: - Reorder

    func testConfidencePrecedesInsecurityMirror() {
        XCTAssertEqual(OnboardingScreen.confidence.rawValue, 4)
        XCTAssertEqual(OnboardingScreen.insecurityMirror.rawValue, 5)
        XCTAssertEqual(OnboardingScreen.momentsFraming.next, .confidence)
        XCTAssertEqual(OnboardingScreen.confidence.next, .insecurityMirror)
        XCTAssertEqual(OnboardingScreen.insecurityMirror.next, .motivation)
    }

    // MARK: - Lane-aware skipping

    /// Dated/decision lane (a moment is coming): keep the Deadline, skip Payday.
    func testDatedLaneKeepsDeadlineSkipsPayday() {
        let vm = makeVM(focus: "the_job_offer")
        XCTAssertFalse(vm.isHabitBuyer)
        XCTAssertFalse(vm.shouldSkip(.deadline))
        XCTAssertTrue(vm.shouldSkip(.paydayCapture))
    }

    /// Habit lane (everyday spending): skip the Deadline, keep Payday.
    func testHabitLaneSkipsDeadlineKeepsPayday() {
        let vm = makeVM(focus: "everyday_spending")
        XCTAssertTrue(vm.isHabitBuyer)
        XCTAssertTrue(vm.shouldSkip(.deadline))
        XCTAssertFalse(vm.shouldSkip(.paydayCapture))
    }

    /// "Stay sharp" motivation also routes into the habit lane.
    func testStaySharpMotivationIsHabitLane() {
        let vm = makeVM(focus: "the_job_offer", motivations: [.staySharp])
        XCTAssertTrue(vm.isHabitBuyer)
        XCTAssertTrue(vm.shouldSkip(.deadline))
    }

    /// First Paycheck is a decision pack but IS about payday — keep both.
    func testFirstPaycheckKeepsPayday() {
        let vm = makeVM(focus: "first_paycheck")
        XCTAssertFalse(vm.isHabitBuyer)
        XCTAssertFalse(vm.shouldSkip(.deadline))
        XCTAssertFalse(vm.shouldSkip(.paydayCapture))
    }

    // MARK: - advance() loops over skipped screens

    func testAdvanceSkipsDeadlineForHabitLane() {
        let vm = makeVM(focus: "everyday_spending")
        vm.currentScreen = .mirroring          // screen 8
        vm.advance()                            // 9 (deadline) is skipped
        XCTAssertEqual(vm.currentScreen, .timeCommitment)
    }

    func testAdvanceSkipsPaydayForDatedLane() {
        let vm = makeVM(focus: "the_job_offer")
        vm.currentScreen = .personalizedPlan   // screen 19
        vm.advance()                            // 20 (payday) is skipped
        XCTAssertEqual(vm.currentScreen, .notificationPermission)
    }
}
