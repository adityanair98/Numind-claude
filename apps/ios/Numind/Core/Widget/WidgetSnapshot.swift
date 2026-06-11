import Foundation

/// The single payload the app writes for the widget to read (Phase 12).
///
/// Compiled into BOTH the app and the widget extension. The main app is the
/// only writer (from ProgressStore.persist()); the widget only reads — so
/// the ring on the Home Screen is always whatever the app last knew.
struct WidgetSnapshot: Codable, Equatable {
    var ringProgress: Double
    var ringClosed: Bool
    var streak: Int
    var momentTitle: String?
    var momentSubtitle: String?

    static let appGroupId = "group.com.numind.app"
    static let defaultsKey = "numind.widgetSnapshot"

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let raw = defaults.data(forKey: defaultsKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: raw)
    }

    func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroupId),
              let encoded = try? JSONEncoder().encode(self) else { return }
        defaults.set(encoded, forKey: Self.defaultsKey)
    }
}
