import XCTest
@testable import Numind

/// Phase 12 — moments registry. Locks in the window boundaries, the
/// relevance rules (awareness pack-scoped / active universal), and the
/// no-countdown-outside-windows invariant.
final class MomentsRegistryTests: XCTestCase {

    private let calendar = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func moments(packIds: Set<String>, now: Date,
                         signals: OnboardingSignals? = nil) -> [Moment] {
        MomentsRegistry.currentMoments(signals: signals, packIds: packIds, now: now)
    }

    // MARK: - Open enrollment windows

    func test_openEnrollment_awarenessIsPackScoped() {
        let sept = date(2026, 9, 15)
        // Pack holder sees the upcoming chip…
        let withPack = moments(packIds: ["open_enrollment"], now: sept)
        XCTAssertTrue(withPack.contains { $0.kind == .openEnrollment && $0.copyMode == .upcoming })
        // …a user without the pack sees nothing.
        let withoutPack = moments(packIds: ["car_buying"], now: sept)
        XCTAssertFalse(withoutPack.contains { $0.kind == .openEnrollment })
    }

    func test_openEnrollment_activeIsUniversal() {
        let october = date(2026, 10, 15)
        let withoutPack = moments(packIds: [], now: october)
        let oe = withoutPack.first { $0.kind == .openEnrollment }
        XCTAssertEqual(oe?.copyMode, .active)
        XCTAssertEqual(oe?.weeksAway, 0)
    }

    func test_openEnrollment_silentOutsideWindows() {
        // June: not aware, not active → nothing, even for pack holders.
        let june = date(2026, 6, 15)
        XCTAssertFalse(moments(packIds: ["open_enrollment"], now: june)
            .contains { $0.kind == .openEnrollment })
        // Dec 8: past the active end.
        let dec8 = date(2026, 12, 8)
        XCTAssertFalse(moments(packIds: ["open_enrollment"], now: dec8)
            .contains { $0.kind == .openEnrollment })
    }

    // MARK: - Tax windows

    func test_taxSeason_boundaries() {
        XCTAssertTrue(moments(packIds: [], now: date(2026, 1, 15))
            .contains { $0.kind == .taxSeason })
        XCTAssertTrue(moments(packIds: [], now: date(2026, 4, 15))
            .contains { $0.kind == .taxSeason })
        XCTAssertFalse(moments(packIds: [], now: date(2026, 4, 16))
            .contains { $0.kind == .taxSeason })
    }

    func test_postTaxRegret_isPackScopedAndBounded() {
        let may = date(2026, 5, 10)
        XCTAssertTrue(moments(packIds: ["taxes_without_panic"], now: may)
            .contains { $0.kind == .postTaxRegret && $0.copyMode == .justPassed })
        XCTAssertFalse(moments(packIds: [], now: may)
            .contains { $0.kind == .postTaxRegret })
        XCTAssertFalse(moments(packIds: ["taxes_without_panic"], now: date(2026, 7, 1))
            .contains { $0.kind == .postTaxRegret })
    }

    // MARK: - Priority + personal moments

    func test_activeOutranksRegret_homeShowsTopOne() {
        // Hypothetical overlap can't happen on the calendar; verify priority
        // ordering via FSA (310) vs open enrollment (300/350) in December.
        let dec = date(2026, 12, 3)
        let list = moments(packIds: [], now: dec)
        XCTAssertEqual(list.first?.kind, .fsaUseIt)
    }

    func test_paycheckMoment_appearsOnlyAroundPayday() {
        var signals = OnboardingSignals()
        // Anchor: a payday exactly 14 days before "now" → today is payday.
        let now = date(2026, 6, 19)
        signals.paycheck = PaycheckSchedule(cadence: .biweekly, anchorDate: date(2026, 6, 5))
        let onPayday = moments(packIds: [], now: now, signals: signals)
        XCTAssertTrue(onPayday.contains { $0.kind == .paycheck })

        // A week out → silent.
        let midCycle = moments(packIds: [], now: date(2026, 6, 12), signals: signals)
        XCTAssertFalse(midCycle.contains { $0.kind == .paycheck })
    }

    func test_idsAreYearSalted() {
        let oe = moments(packIds: [], now: date(2026, 10, 15)).first { $0.kind == .openEnrollment }
        XCTAssertEqual(oe?.id, "openEnrollment.2026")
    }
}
