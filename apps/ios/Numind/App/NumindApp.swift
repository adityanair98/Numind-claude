import SwiftUI

@main
struct NumindApp: App {
    init() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "numind.hasCompletedOnboarding")
        #endif
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
