import Foundation

/// Real deadlines for dated life moments (Phase 11 onboarding v2).
///
/// Finance has actual calendar pressure — open enrollment closes, tax day
/// arrives — and real deadlines beat manufactured urgency. Packs without a
/// fixed national date return nil; the Deadline screen falls back to a
/// cost-of-waiting framing instead.
enum MomentCalendar {

    struct Deadline: Equatable {
        let label: String      // "Open enrollment closes"
        let date: Date
    }

    /// The next national deadline tied to a pack, or nil for undated moments.
    /// Open enrollment: Nov 1 (typical employer window opens; marketplace
    /// opens Nov 1 nationally). Taxes: April 15.
    static func nextDeadline(for packId: String, from now: Date = Date(),
                             calendar: Calendar = .current) -> Deadline? {
        switch packId {
        case "open_enrollment":
            guard let date = nextOccurrence(month: 11, day: 1, from: now, calendar: calendar) else { return nil }
            return Deadline(label: "Open enrollment opens", date: date)
        case "taxes_without_panic":
            guard let date = nextOccurrence(month: 4, day: 15, from: now, calendar: calendar) else { return nil }
            return Deadline(label: "Tax day", date: date)
        default:
            return nil
        }
    }

    /// Rough "Ready by" estimate: ~2 days per core skill plus one retention
    /// interval (7 days). Honest framing only — "on track to Ready", never a
    /// granted state.
    static func readyEstimate(coreSkillCount: Int, from now: Date = Date(),
                              calendar: Calendar = .current) -> Date {
        let days = coreSkillCount * 2 + 7
        return calendar.date(byAdding: .day, value: days, to: now) ?? now
    }

    static func daysUntil(_ date: Date, from now: Date = Date(),
                          calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    // MARK: - Private

    private static func nextOccurrence(month: Int, day: Int, from now: Date,
                                       calendar: Calendar) -> Date? {
        let year = calendar.component(.year, from: now)
        var components = DateComponents(year: year, month: month, day: day)
        if let thisYear = calendar.date(from: components), thisYear > now {
            return thisYear
        }
        components.year = year + 1
        return calendar.date(from: components)
    }
}
