import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: NumindTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomePlaceholderView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(NumindTab.home)

            NavigationStack {
                LearnPlaceholderView()
            }
            .tabItem { Label("Learn", systemImage: "book.fill") }
            .tag(NumindTab.learn)

            NavigationStack {
                ProgressPlaceholderView()
            }
            .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            .tag(NumindTab.progress)

            NavigationStack {
                ProfilePlaceholderView()
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(NumindTab.profile)
        }
        .tint(Theme.Colors.primaryBlue)
    }
}

enum NumindTab: Hashable {
    case home, learn, progress, profile
}

#Preview {
    RootTabView()
}
