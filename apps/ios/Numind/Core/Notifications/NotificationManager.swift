import UserNotifications
import Foundation

/// Manages local notification scheduling for daily practice reminders.
enum NotificationManager {

    private static let reminderIdentifier = "com.numind.dailyReminder"

    // MARK: - Permission

    /// Request notification authorization. Completion runs on main thread.
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Check current authorization status without prompting.
    static func checkPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Schedule

    /// Cancel any existing reminder and schedule a new one at the given hour + minute (24h).
    static func scheduleDailyReminder(hour: Int, minute: Int) {
        cancel()

        let content = UNMutableNotificationContent()
        content.title = "Time for your daily workout 🧠"
        content.body = "Keep your streak going — just 5 minutes."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminderIdentifier]
        )
    }

    // MARK: - Payday reminders (Phase 12)

    static let paycheckPrefix = "com.numind.paycheck."
    static let momentPrefix   = "com.numind.moment."

    /// Replace-and-reschedule the next `count` payday one-offs (one-off
    /// calendar triggers — a biweekly cadence cannot be expressed as a
    /// repeating UNCalendarNotificationTrigger). Date-in-id makes the
    /// operation idempotent. No-op when `schedule` is nil.
    static func syncPaydayReminders(
        schedule: PaycheckSchedule?,
        hour: Int,
        minute: Int,
        count: Int = 3
    ) {
        removePending(withPrefix: paycheckPrefix) {
            guard let schedule else { return }
            let calendar = Calendar.current
            for payday in schedule.nextOccurrences(count: count) {
                var comps = calendar.dateComponents([.year, .month, .day], from: payday)
                comps.hour = hour
                comps.minute = minute

                let content = UNMutableNotificationContent()
                content.title = "It\u{2019}s payday \u{1F4B5}"
                content.body = "The best 2 minutes you\u{2019}ll spend on this check \u{2014} a quick look before it disappears into the month."
                content.sound = .default

                let stamp = String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
                let request = UNNotificationRequest(
                    identifier: paycheckPrefix + stamp,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                )
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    // MARK: - Moment-window notifications (Phase 12)

    /// One-offs at awareness/active window entries. Future fire dates only;
    /// the year-salted Moment.id means an already-entered window is never
    /// re-scheduled (no delivered-ledger persistence needed). Skips ids
    /// already pending.
    static func syncMomentNotifications(entries: [(moment: Moment, fireDate: Date)]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let pendingIds = Set(pending.map(\.identifier))
            let calendar = Calendar.current
            for (moment, fireDate) in entries where fireDate > Date() {
                let id = momentPrefix + moment.id
                guard !pendingIds.contains(id) else { continue }

                let content = UNMutableNotificationContent()
                content.title = moment.title
                content.body = moment.detail
                content.sound = .default

                let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                center.add(UNNotificationRequest(
                    identifier: id,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                ))
            }
        }
    }

    /// Removes pending requests whose identifier starts with `prefix`,
    /// then runs `completion` (used to replace-and-reschedule atomically-ish).
    static func removePending(withPrefix prefix: String, completion: @escaping () -> Void = {}) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
            DispatchQueue.main.async { completion() }
        }
    }
}
