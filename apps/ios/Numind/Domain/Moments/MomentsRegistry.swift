import Foundation

/// Real money moments with honest time windows (Phase 12).
///
/// Finance has actual calendar pressure — open enrollment closes, tax day
/// arrives, payday lands. The registry resolves which moments are live for
/// a user *right now*, with three copy modes and "about N weeks" granularity.
/// Rule: no countdown ever renders outside a genuine window — awareness-phase
/// moments are pack-scoped (only users who chose the moment get the early
/// heads-up); active national windows are universal.
enum MomentCopyMode: Equatable {
    case upcoming    // inside the awareness window, before the active span
    case active      // the window is live now
    case justPassed  // the regret window (e.g. post-tax-filing)
}

struct Moment: Identifiable, Equatable {
    enum Kind: String {
        case openEnrollment, fsaUseIt, taxSeason, postTaxRegret,
             irsLimits, paycheck, leaseRenewal
    }

    let kind: Kind
    /// Pack this moment routes to (chip tap target, PackDetail header).
    let packId: String?
    /// Shown to every user during its active span, regardless of pack choice.
    let isUniversal: Bool
    let title: String
    let detail: String
    let copyMode: MomentCopyMode
    /// "About N weeks" granularity; 0 while active/justPassed. Never days.
    let weeksAway: Int
    /// Higher = shown first; Home renders only the top moment.
    let priority: Int
    /// Stable per window instance — also the notification dedup key
    /// (e.g. "openEnrollment.2026", "paycheck.2026-06-12").
    let id: String
}

enum MomentsRegistry {

    struct Deadline: Equatable {
        let label: String
        let date: Date
    }

    // MARK: - Current moments

    /// All live moments for this user, priority-descending. Home shows the
    /// first; notifications and PackDetail consume the full list.
    static func currentMoments(
        signals: OnboardingSignals?,
        packIds: Set<String>,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Moment] {
        var moments: [Moment] = []
        let year = calendar.component(.year, from: now)
        // All window comparisons are day-granular: "active through Apr 15"
        // includes the whole of Apr 15.
        let today = calendar.startOfDay(for: now)

        func date(_ month: Int, _ day: Int, _ y: Int = 0) -> Date? {
            calendar.date(from: DateComponents(year: y == 0 ? year : y, month: month, day: day))
        }
        func weeks(until target: Date) -> Int {
            max(0, Int((Double(daysUntil(target, from: now, calendar: calendar)) / 7.0).rounded()))
        }

        // ── Open enrollment: aware Sep 1, active Oct 1 – Dec 7 ──
        if let aware = date(9, 1), let start = date(10, 1), let end = date(12, 7) {
            if today >= start && today <= end {
                moments.append(Moment(
                    kind: .openEnrollment, packId: "open_enrollment", isUniversal: true,
                    title: "Open enrollment is open",
                    detail: "Benefits lock in for a year \u{2014} a few sessions gets you choosing, not guessing.",
                    copyMode: .active, weeksAway: 0,
                    priority: 300 + (packIds.contains("open_enrollment") ? 50 : 0),
                    id: "openEnrollment.\(year)"
                ))
            } else if today >= aware && today < start && packIds.contains("open_enrollment") {
                moments.append(Moment(
                    kind: .openEnrollment, packId: "open_enrollment", isUniversal: false,
                    title: "Open enrollment is about \(weeks(until: start)) weeks out",
                    detail: "Time to get Ready before the forms arrive.",
                    copyMode: .upcoming, weeksAway: weeks(until: start),
                    priority: 250 - weeks(until: start),
                    id: "openEnrollment.\(year)"
                ))
            }
        }

        // ── FSA use-it-or-lose-it: aware Nov 15, active Dec 1–31 ──
        if let aware = date(11, 15), let start = date(12, 1), let end = date(12, 31) {
            if today >= start && today <= end {
                moments.append(Moment(
                    kind: .fsaUseIt, packId: "open_enrollment", isUniversal: true,
                    title: "FSA money expires this month",
                    detail: "Unspent FSA dollars vanish Dec 31 \u{2014} check yours before the holidays eat the calendar.",
                    copyMode: .active, weeksAway: 0,
                    priority: 310,
                    id: "fsaUseIt.\(year)"
                ))
            } else if today >= aware && today < start && packIds.contains("open_enrollment") {
                moments.append(Moment(
                    kind: .fsaUseIt, packId: "open_enrollment", isUniversal: false,
                    title: "FSA deadline is about \(weeks(until: start)) weeks out",
                    detail: "Use-it-or-lose-it season \u{2014} a 5-minute check saves real money.",
                    copyMode: .upcoming, weeksAway: weeks(until: start),
                    priority: 200 - weeks(until: start),
                    id: "fsaUseIt.\(year)"
                ))
            }
        }

        // ── Tax season: active Jan 15 – Apr 15 ──
        if let start = date(1, 15), let end = date(4, 15), today >= start && today <= end {
            moments.append(Moment(
                kind: .taxSeason, packId: "taxes_without_panic", isUniversal: true,
                title: "Tax season is here",
                detail: "Refund shock has an explanation \u{2014} a few sessions and your return makes sense.",
                copyMode: .active, weeksAway: 0,
                priority: 300 + (packIds.contains("taxes_without_panic") ? 50 : 0),
                id: "taxSeason.\(year)"
            ))
        }

        // ── Post-tax regret window: Apr 16 – Jun 30, pack-scoped ──
        if let start = date(4, 16), let end = date(6, 30),
           today >= start && today <= end && packIds.contains("taxes_without_panic") {
            moments.append(Moment(
                kind: .postTaxRegret, packId: "taxes_without_panic", isUniversal: false,
                title: "Next year\u{2019}s refund is being decided now",
                detail: "The W-4 and withholding moves that fix next April happen mid-year \u{2014} not in March.",
                copyMode: .justPassed, weeksAway: 0,
                priority: 150,
                id: "postTaxRegret.\(year)"
            ))
        }

        // ── IRS limits announcement: active Nov ──
        if let start = date(11, 1), let end = date(11, 30), today >= start && today <= end {
            moments.append(Moment(
                kind: .irsLimits, packId: nil, isUniversal: true,
                title: "New IRS limits are out",
                detail: "Next year\u{2019}s 401(k) and IRA limits just landed \u{2014} worth a 2-minute look.",
                copyMode: .active, weeksAway: 0,
                priority: 120,
                id: "irsLimits.\(year)"
            ))
        }

        // ── Payday: payday−1 … payday (personal; needs the signal) ──
        if let schedule = signals?.paycheck,
           let next = schedule.nextOccurrences(count: 1, from: calendar.date(byAdding: .day, value: -1, to: now) ?? now, calendar: calendar).first {
            let days = daysUntil(next, from: now, calendar: calendar)
            if days >= 0 && days <= 1 {
                let stamp = next.formatted(.iso8601.year().month().day())
                moments.append(Moment(
                    kind: .paycheck, packId: "first_paycheck", isUniversal: false,
                    title: days == 0 ? "It\u{2019}s payday" : "Payday is tomorrow",
                    detail: "The best 2 minutes you\u{2019}ll spend on this check \u{2014} a quick look before it disappears into the month.",
                    copyMode: .active, weeksAway: 0,
                    priority: 150,
                    id: "paycheck.\(stamp)"
                ))
            }
        }

        // ── Lease renewal: aware 90 days before renewal month (personal) ──
        if let month = signals?.leaseRenewalMonth, (1...12).contains(month) {
            var comps = DateComponents(year: year, month: month, day: 1)
            var renewal = calendar.date(from: comps)
            if let r = renewal, r < now {
                comps.year = year + 1
                renewal = calendar.date(from: comps)
            }
            if let renewal {
                let days = daysUntil(renewal, from: now, calendar: calendar)
                if days >= 0 && days <= 90 {
                    let w = weeks(until: renewal)
                    moments.append(Moment(
                        kind: .leaseRenewal, packId: "first_apartment", isUniversal: false,
                        title: w == 0 ? "Your lease renews this month" : "Lease renewal is about \(w) weeks out",
                        detail: "Renew, renegotiate, or move \u{2014} the comparison is learnable before the letter arrives.",
                        copyMode: w == 0 ? .active : .upcoming, weeksAway: w,
                        priority: w == 0 ? 280 : 220 - w,
                        id: "leaseRenewal.\(calendar.component(.year, from: renewal))"
                    ))
                }
            }
        }

        return moments.sorted { $0.priority > $1.priority }
    }

    /// Awareness/active window entries in the next `horizonDays` — feeds
    /// notification scheduling. Returns future fire dates only.
    static func upcomingAwarenessEntries(
        signals: OnboardingSignals?,
        packIds: Set<String>,
        now: Date = Date(),
        horizonDays: Int = 90,
        calendar: Calendar = .current
    ) -> [(moment: Moment, fireDate: Date)] {
        guard let horizon = calendar.date(byAdding: .day, value: horizonDays, to: now) else { return [] }
        var entries: [(Moment, Date)] = []
        let year = calendar.component(.year, from: now)

        func candidate(month: Int, day: Int) -> Date? {
            var c = DateComponents(year: year, month: month, day: day, hour: 10)
            if let d = calendar.date(from: c), d > now { return d }
            c.year = year + 1
            guard let d = calendar.date(from: c), d <= horizon else { return nil }
            return d
        }

        // National windows — fire at the awareness/active entry, scoped the
        // same way the chips are.
        if packIds.contains("open_enrollment"), let fire = candidate(month: 9, day: 1), fire <= horizon {
            if let moment = currentMoments(signals: signals, packIds: packIds, now: fire, calendar: calendar)
                .first(where: { $0.kind == .openEnrollment }) {
                entries.append((moment, fire))
            }
        }
        if let fire = candidate(month: 10, day: 1), fire <= horizon {
            if let moment = currentMoments(signals: signals, packIds: packIds, now: fire, calendar: calendar)
                .first(where: { $0.kind == .openEnrollment }) {
                entries.append((moment, fire))
            }
        }
        if let fire = candidate(month: 12, day: 1), fire <= horizon {
            if let moment = currentMoments(signals: signals, packIds: packIds, now: fire, calendar: calendar)
                .first(where: { $0.kind == .fsaUseIt }) {
                entries.append((moment, fire))
            }
        }
        if let fire = candidate(month: 1, day: 15), fire <= horizon {
            if let moment = currentMoments(signals: signals, packIds: packIds, now: fire, calendar: calendar)
                .first(where: { $0.kind == .taxSeason }) {
                entries.append((moment, fire))
            }
        }
        return entries
    }

    // MARK: - Onboarding shims (migrated from MomentCalendar)

    /// The next national deadline tied to a pack — used by the onboarding
    /// Deadline screen (the one-time sales-screen day-countdown carve-out).
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

    /// Rough "Ready by" estimate: ~2 days per core skill + one retention
    /// interval. Honest framing only — "on track to Ready", never granted.
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
