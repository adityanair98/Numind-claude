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
                    OnboardingFlowView()
                        .environmentObject(progressStore)
                }
            }

            if showSplash {
                SplashView { showSplash = false }
            }
        }
        .preferredColorScheme(preferredScheme)
        .onChange(of: appearanceRaw) { _ in
            // Push the change to the UIWindow so iOS caches the correct
            // launch screen appearance for the next cold start.
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            let style: UIUserInterfaceStyle
            switch appearanceRaw {
            case "light": style = .light
            case "dark":  style = .dark
            default:      style = .unspecified
            }
            for window in scene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

#Preview {
    RootView()
}
