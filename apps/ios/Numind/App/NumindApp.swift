import SwiftUI

@main
struct NumindApp: App {
    init() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "numind.hasCompletedOnboarding")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
