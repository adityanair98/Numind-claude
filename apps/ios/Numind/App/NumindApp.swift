import SwiftUI

@main
struct NumindApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Record first-install date once; persists across launches.
        if UserDefaults.standard.object(forKey: "numind.installDate") == nil {
            UserDefaults.standard.set(Date(), forKey: "numind.installDate")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - AppDelegate + SceneDelegate

/// Bridges into UIKit lifecycle so we can set `overrideUserInterfaceStyle`
/// on the window BEFORE the launch screen is dismissed — matching how
/// WhatsApp/Facebook handle appearance-aware launch screens.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        applyAppearanceOverride(to: windowScene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Re-apply on every foreground in case the user changed the setting
        guard let windowScene = scene as? UIWindowScene else { return }
        applyAppearanceOverride(to: windowScene)
    }

    private func applyAppearanceOverride(to scene: UIWindowScene) {
        let raw = UserDefaults.standard.string(forKey: "numind.appearance") ?? "system"
        let style: UIUserInterfaceStyle
        switch raw {
        case "light": style = .light
        case "dark":  style = .dark
        default:      style = .unspecified
        }
        for window in scene.windows {
            window.overrideUserInterfaceStyle = style
        }
    }
}
