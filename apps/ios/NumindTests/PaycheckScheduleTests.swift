import XCTest
@testable import Numind

/// Phase 12 — paycheck occurrence math across the 4 cadences.
final class PaycheckScheduleTests: XCTestCase {

    private let calendar = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 9))!
    }

    func test_weekly_strideFromAnchor() {
        let s = PaycheckSchedule(cadence: .weekly, anchorDate: date(2026, 6, 5))
        let next = s.nextOccurrences(count: 2, from: date(2026, 6, 10))
        XCTAssertEqual(calendar.component(.day, from: next[0]), 12)
        XCTAssertEqual(calendar.component(.day, from: next[1]), 19)
    }

    func test_biweekly_strideFromAnchor() {
        let s = PaycheckSchedule(cadence: .biweekly, anchorDate: date(2026, 6, 5))
        let next = s.nextOccurrences(count: 2, from: date(2026, 6, 10))
        XCTAssertEqual(calendar.component(.day, from: next[0]), 19)
        XCTAssertEqual(calendar.dateComponents([.month, .day], from: next[1]).day, 3)
    }

    func test_monthly_clampsToShortMonths() {
        // Anchored on the 31st → February pays on the 28th (2026 non-leap).
        let s = PaycheckSchedule(cadence: .monthly, anchorDate: date(2026, 1, 31))
        let next = s.nextOccurrences(count: 1, from: date(2026, 2, 1))
        let comps = calendar.dateComponents([.month, .day], from: next[0])
        XCTAssertEqual(comps.month, 2)
        XCTAssertEqual(comps.day, 28)
    }

    func test_semimonthly_twoPaydaysPerMonth() {
        // Anchor on the 1st → paydays on the 1st and 16th.
        let s = PaycheckSchedule(cadence: .semimonthly, anchorDate: date(2026, 6, 1))
        let next = s.nextOccurrences(count: 3, from: date(2026, 6, 2))
        let days = next.map { calendar.dateComponents([.month, .day], from: $0) }
        XCTAssertEqual(days[0].day, 16)
        XCTAssertEqual(days[1].day, 1)
        XCTAssertEqual(days[1].month, 7)
        XCTAssertEqual(days[2].day, 16)
    }

    func test_occurrences_strictlyAfterNow() {
        let s = PaycheckSchedule(cadence: .weekly, anchorDate: date(2026, 6, 5))
        // "now" exactly on a payday → next is 7 days later, not today.
        let next = s.nextOccurrences(count: 1, from: date(2026, 6, 12))
        XCTAssertEqual(calendar.component(.day, from: next[0]), 19)
    }
}
