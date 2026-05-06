import SwiftUI

struct RootView: View {
    @StateObject private var progressStore = ProgressStore()
    @AppStorage("numind.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("numind.appearance") private var appearanceRaw = "system"
    @State private var showSplash = true

    private var preferredScheme: ColorScheme? {
        switch appearanceRaw {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil   // nil = follow system
        }
    }

    var body: some View {
        ZStack {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                        .environmentObject(progressStore)
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(preferredScheme)

            if showSplash {
                SplashView { showSplash = false }
            }
        }
    }
}

#Preview {
    RootView()
}
