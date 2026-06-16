import Foundation

/// The user's pay cadence + a known payday — every future payday derives
/// from the anchor (Phase 12). Drives the payday moment chip and the
/// payday-anchored reminders.
///
/// Occurrence rules:
/// - weekly / biweekly: anchor + 7k / 14k days
/// - monthly: the anchor's day-of-month, clamped to each month's length
///   (anchor on the 31st → Feb 28/29)
/// - semimonthly: the anchor's day-of-month and (day + 15) wrapped into the
///   1–28 range, both clamped — deterministic without a second anchor
struct PaycheckSchedule: Codable, Equatable {
    enum Cadence: String, Codable, CaseIterable {
        case weekly, biweekly, semimonthly, monthly

        var displayText: String {
            switch self {
            case .weekly:      return "Weekly"
            case .biweekly:    return "Every 2 weeks"
            case .semimonthly: return "Twice a month"
            case .monthly:     return "Monthly"
            }
        }
    }

    var cadence: Cadence
    /// A payday the user identified; all occurrences derive from it.
    var anchorDate: Date
    /// Semimonthly only: the OTHER payday's day-of-month, asked for
    /// explicitly (e.g. anchor on the 15th, second on the 31st = "last day").
    /// Optional for decode-compat; nil falls back to the +15-day heuristic.
    var secondPaydayDay: Int? = nil

    /// Next `count` paydays strictly after `now`, ascending.
    func nextOccurrences(count: Int, from now: Date = Date(),
                         calendar: Calendar = .current) -> [Date] {
        guard count > 0 else { return [] }
        switch cadence {
        case .weekly, .biweekly:
            return strideOccurrences(stepDays: cadence == .weekly ? 7 : 14,
                                     count: count, from: now, calendar: calendar)
        case .monthly:
            return monthlyOccurrences(days: [anchorDay(calendar)],
                                      count: count, from: now, calendar: calendar)
        case .semimonthly:
            let d1 = anchorDay(calendar)
            // Prefer the explicitly-captured second day; the wrap heuristic
            // only covers schedules saved before it existed.
            let d2 = secondPaydayDay ?? ((d1 + 15 - 1) % 28 + 1)
            return monthlyOccurrences(days: [d1, d2].sorted(),
                                      count: count, from: now, calendar: calendar)
        }
    }

    // MARK: - Private

    private func anchorDay(_ calendar: Calendar) -> Int {
        calendar.component(.day, from: anchorDate)
    }

    private func strideOccurrences(stepDays: Int, count: Int, from now: Date,
                                   calendar: Calendar) -> [Date] {
        let anchor = calendar.startOfDay(for: anchorDate)
        let today = calendar.startOfDay(for: now)
        let elapsed = calendar.dateComponents([.day], from: anchor, to: today).day ?? 0
        // First multiple of stepDays strictly after now.
        var k = elapsed >= 0 ? (elapsed / stepDays + 1) : 0
        if k < 0 { k = 0 }
        var dates: [Date] = []
        while dates.count < count {
            if let d = calendar.date(byAdding: .day, value: k * stepDays, to: anchor), d > now {
                dates.append(d)
            }
            k += 1
        }
        return dates
    }

    private func monthlyOccurrences(days: [Int], count: Int, from now: Date,
                                    calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var cursor = calendar.dateComponents([.year, .month], from: now)
        var safety = 0
        while dates.count < count && safety < 36 {
            for day in days {
                var comps = cursor
                let monthDate = calendar.date(from: comps) ?? now
                let maxDay = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 28
                comps.day = min(day, maxDay)
                if let d = calendar.date(from: comps), d > now {
                    dates.append(d)
                }
            }
            cursor.month = (cursor.month ?? 1) + 1
            safety += 1
        }
        return Array(dates.sorted().prefix(count))
    }
}
