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
}
