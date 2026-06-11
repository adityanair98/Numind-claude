import Foundation
import UserNotifications

/// Composes the inputs for payday + moment notifications and keeps them in
/// sync (Phase 12). The ONLY permission interactions are explicit user
/// toggles in Profile/onboarding — this scheduler checks status and bails
/// silently when not authorized; it never prompts.
///
/// Called from RootView on scene-active, after onboarding completes, and
/// after Profile payday changes. All syncs are idempotent (date-salted /
/// year-salted identifiers).
@MainActor
enum NotificationScheduler {

    static func sync(
        signals: OnboardingSignals?,
        packIds: Set<String>,
        paydayEnabled: Bool,
        reminderHour: Int,
        reminderMinute: Int
    ) {
        NotificationManager.checkPermission { status in
            guard status == .authorized || status == .provisional || status == .ephemeral else { return }

            // Payday one-offs (next 3) — only when the toggle is on and a
            // schedule exists; otherwise clear any stale ones.
            NotificationManager.syncPaydayReminders(
                schedule: paydayEnabled ? signals?.paycheck : nil,
                hour: reminderHour,
                minute: reminderMinute
            )

            // Moment-window one-offs (future entries in the next 90 days).
            let entries = MomentsRegistry.upcomingAwarenessEntries(
                signals: signals,
                packIds: packIds
            )
            NotificationManager.syncMomentNotifications(entries: entries)
        }
    }
}
