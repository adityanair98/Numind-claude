import SwiftUI

struct RootView: View {
    @StateObject private var progressStore = ProgressStore()
    @AppStorage("numind.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("numind.appearance") private var appearanceRaw = "system"
    @AppStorage("numind.paydayReminderEnabled") private var paydayReminderEnabled = false
    @AppStorage("numind.reminderHour") private var reminderHour = 20
    @AppStorage("numind.reminderMinute") private var reminderMinute = 0
    @Environment(\.scenePhase) private var scenePhase
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
        // Keep payday + moment notifications in sync (idempotent; never prompts).
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, hasCompletedOnboarding else { return }
            syncNotifications()
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if completed { syncNotifications() }
        }
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

    private func syncNotifications() {
        let signals = progressStore.data.onboardingSignals
        var packIds = Set(signals?.selectedPackIds ?? [])
        packIds.formUnion(progressStore.inProgressPacks.map(\.id))
        if let focus = progressStore.focusPackId { packIds.insert(focus) }
        NotificationScheduler.sync(
            signals: signals,
            packIds: packIds,
            paydayEnabled: paydayReminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute
        )
    }
}

#Preview {
    RootView()
}
