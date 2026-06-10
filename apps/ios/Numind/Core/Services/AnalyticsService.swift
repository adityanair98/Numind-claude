import Foundation
import PostHog
import Sentry

/// Thin analytics seam (Phase 10-D). The whole app talks to this enum, never
/// to PostHog or Sentry directly, so swapping providers or adding consent
/// gating later is a one-file change.
///
/// **No-op without keys**: both SDKs initialise only when their key is
/// present in Info.plist (`NumindPostHogAPIKey` / `NumindSentryDSN`). The
/// placeholders ship empty — local builds and tests never emit network
/// traffic. Real keys land via build-config injection before release.
///
/// Event taxonomy v1 — capability/loop events only, no per-question spam:
/// - `workout_started` / `workout_completed(correct, total)`
/// - `ring_closed` — the daily goal moment
/// - `session_completed(type)` — daily_workout / more_practice / refresh
/// - `lesson_started(lesson_id)` / `lesson_mastered(lesson_id)`
/// - `pack_state_changed(pack_id, state)` — Readiness transitions
/// - `refresh_started(skill_count)`
/// - `teach_card_shown(lesson_id)`
/// - `streak_freeze_used`
enum AnalyticsService {

    enum Event: String {
        case workoutStarted    = "workout_started"
        case workoutCompleted  = "workout_completed"
        case ringClosed        = "ring_closed"
        case sessionCompleted  = "session_completed"
        case lessonStarted     = "lesson_started"
        case lessonMastered    = "lesson_mastered"
        case packStateChanged  = "pack_state_changed"
        case refreshStarted    = "refresh_started"
        case teachCardShown    = "teach_card_shown"
        case streakFreezeUsed  = "streak_freeze_used"
    }

    private static var postHogEnabled = false

    /// Call once at app launch. Reads keys from Info.plist; missing or empty
    /// keys leave the corresponding SDK uninitialised.
    static func configure() {
        let info = Bundle.main.infoDictionary ?? [:]

        if let key = info["NumindPostHogAPIKey"] as? String, !key.isEmpty {
            let config = PostHogConfig(apiKey: key, host: "https://us.i.posthog.com")
            PostHogSDK.shared.setup(config)
            postHogEnabled = true
        }

        if let dsn = info["NumindSentryDSN"] as? String, !dsn.isEmpty {
            SentrySDK.start { options in
                options.dsn = dsn
                options.tracesSampleRate = 0.1
            }
        }
    }

    static func capture(_ event: Event, properties: [String: Any] = [:]) {
        guard postHogEnabled else { return }
        PostHogSDK.shared.capture(event.rawValue, properties: properties)
    }
}
