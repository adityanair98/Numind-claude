import Foundation

/// One completed monthly sharpness check (Phase 12).
///
/// The check is the manufactured "exam" the category lacks: a 2-minute,
/// diagnostic-shaped session whose results are stored HERE, never in the
/// session log — the same honesty rule as the onboarding diagnostic, so
/// Readiness/mastery stay earned through real practice only.
struct SharpnessCheckRecord: Codable, Equatable, Identifiable {
    let date: Date
    let correct: Int
    let total: Int
    /// Median answer seconds across the check — the speed half of the delta.
    let medianSeconds: Double

    var id: Date { date }
}

/// A self-reported real-world use of a skill ("tipped without my phone").
/// The end state of compounding is using it in the wild — this ledger is
/// where that gets witnessed.
struct RealWorldSave: Codable, Equatable, Identifiable {
    let id: UUID
    let date: Date
    /// Chip label the user picked (fixed set, no free text in v1).
    let label: String
}

/// Pure gating + chip derivation for the check and the saves prompt.
enum SharpnessCheckGate {

    static let checkIntervalDays = 28
    static let savePromptIntervalDays = 7

    /// Due when 28+ days have passed since the last check — or, before any
    /// check exists, since the anchor (day-1 diagnostic / first session).
    static func isCheckDue(lastCheck: Date?, anchor: Date?,
                           now: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let reference = lastCheck ?? anchor else { return false }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: reference),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        return days >= checkIntervalDays
    }

    /// The weekly saves prompt: at most once per 7 days, and only once the
    /// user has some practice to report against.
    static func isSavePromptDue(lastPrompt: Date?, sessionCount: Int,
                                now: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard sessionCount >= 5 else { return false }
        guard let last = lastPrompt else { return true }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: last),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        return days >= savePromptIntervalDays
    }

    /// Chip labels derived from the modules practiced in the last 7 days.
    static func saveChips(sessions: [SessionRecord],
                          now: Date = Date(), calendar: Calendar = .current) -> [String] {
        let cutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let recentModules = Set(sessions.filter { $0.date >= cutoff }.map(\.moduleId))

        let labels: [(String, String)] = [
            ("smart_shopping", "Tipped or split a bill without my phone"),
            ("money_math",     "Caught a price or subscription creeping"),
            ("salary",         "Read a paycheck or offer with confidence"),
            ("taxes",          "Made sense of withholding or a tax form"),
            ("debt",           "Spotted interest or a fee before it bit"),
            ("insurance",      "Made sense of a bill, plan, or benefit"),
            ("housing",        "Ran the numbers on rent or housing"),
            ("investing",      "Made an investing or 401(k) move"),
            ("car",            "Checked the numbers on a car or loan"),
            ("money_safety",   "Spotted a scam or checked a charge"),
        ]
        return labels.filter { recentModules.contains($0.0) }.prefix(3).map(\.1)
    }
}
