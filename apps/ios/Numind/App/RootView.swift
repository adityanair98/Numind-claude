import SwiftUI

struct RootView: View {
    @StateObject private var progressStore = ProgressStore()
    @AppStorage("numind.hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            RootTabView()
                .environmentObject(progressStore)
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    RootView()
}
