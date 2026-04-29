import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: NumindTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(NumindTab.home)

            NavigationStack {
                LearnView()
            }
            .tabItem { Label("Learn", systemImage: "book.fill") }
            .tag(NumindTab.learn)

            NavigationStack {
                PracticeView()
            }
            .tabItem { Label("Practice", systemImage: "dumbbell.fill") }
            .tag(NumindTab.practice)

            NavigationStack {
                ProgressTabView()
            }
            .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            .tag(NumindTab.progress)
        }
        .tint(Theme.Colors.primaryBlue)
    }
}

enum NumindTab: Hashable {
    case home, learn, practice, progress
}

#Preview {
    RootTabView()
        .environmentObject(ProgressStore())
}
