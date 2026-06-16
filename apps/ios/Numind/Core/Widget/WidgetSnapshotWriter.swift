import Foundation
import WidgetKit

/// Builds and persists the widget snapshot after every progress write.
/// Main-app only — the widget never computes ring or moment state itself.
enum WidgetSnapshotWriter {

    static func write(from data: ProgressData, now: Date = Date()) {
        let signals = data.onboardingSignals
        var packIds = Set(signals?.selectedPackIds ?? [])
        if let focus = data.focusPackId { packIds.insert(focus) }

        let moment = MomentsRegistry.currentMoments(
            signals: signals, packIds: packIds, now: now
        ).first

        WidgetSnapshot(
            ringProgress: DailyRingEngine.progress(on: now, data: data),
            ringClosed: DailyRingEngine.isClosed(on: now, data: data),
            streak: data.computeStreak(),
            momentTitle: moment?.title,
            momentSubtitle: moment.map(subtitle(for:))
        ).save()

        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func subtitle(for moment: Moment) -> String {
        switch moment.copyMode {
        case .active:     return "Happening now"
        case .justPassed: return "Worth a look back"
        case .upcoming:
            return moment.weeksAway <= 1
                ? "About a week away"
                : "About \(moment.weeksAway) weeks away"
        }
    }
}
