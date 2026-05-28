import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedTab: NumindTab = .home
    @State private var showStreakLoss = false
    @State private var streakLossChecked = false
    @State private var showFreezeUsedToast = false
    @State private var showMilestone = false

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
                ToolsView()
            }
            .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver.fill") }
            .tag(NumindTab.tools)

            NavigationStack {
                ProgressTabView()
            }
            .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            .tag(NumindTab.progress)
        }
        .tint(Theme.Colors.primaryBlue)
        .onAppear { checkStreakLoss() }
        .overlay(alignment: .top) {
            if showFreezeUsedToast {
                freezeToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { showFreezeUsedToast = false }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showFreezeUsedToast)
        .fullScreenCover(isPresented: $showStreakLoss) {
            StreakLossView(
                lostStreak: progressStore.lostStreakCount,
                onRevive: {
                    progressStore.reviveStreak()
                    showStreakLoss = false
                },
                onDismiss: {
                    progressStore.acceptStreakLoss()
                    showStreakLoss = false
                }
            )
        }
        .fullScreenCover(isPresented: $showMilestone) {
            if let milestone = progressStore.pendingMilestone {
                MilestoneCelebrationView(milestone: milestone) {
                    progressStore.markMilestoneShown(milestone)
                    showMilestone = false
                }
            }
        }
        .onChange(of: progressStore.pendingMilestone?.id) { _, newId in
            if newId != nil {
                showMilestone = true
            }
        }
    }

    private func checkStreakLoss() {
        guard !streakLossChecked else { return }
        streakLossChecked = true

        guard progressStore.isStreakLost else { return }

        // Try auto-applying a banked freeze first.
        if progressStore.autoApplyFreeze() {
            withAnimation { showFreezeUsedToast = true }
        } else {
            showStreakLoss = true
        }
    }

    // MARK: - Freeze toast

    private var freezeToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "snowflake")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Streak saved!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("A streak freeze kept your \(progressStore.streak)-day streak alive")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.primaryBlue, Theme.Colors.mindTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 10, y: 4)
        )
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 8)
    }
}

enum NumindTab: Hashable {
    case home, learn, tools, progress
}

#Preview {
    RootTabView()
        .environmentObject(ProgressStore())
}
