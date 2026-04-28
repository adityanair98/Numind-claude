import SwiftUI

struct RootView: View {
    @StateObject private var progressStore = ProgressStore()

    var body: some View {
        RootTabView()
            .environmentObject(progressStore)
    }
}

#Preview {
    RootView()
}
