import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @AppStorage("numind.userName") private var userName = "You"
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                profileCard
                statsSection
                appSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset progress?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { progressStore.reset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears all completed lessons and quiz history. This cannot be undone.")
        }
    }

    // MARK: - Profile card

    private var profileCard: some View {
        NumindCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryBlueTint)
                        .frame(width: 56, height: 56)
                    Text(String(userName.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryBlue)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Member since \(joinedDateString)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
                if progressStore.streak > 0 {
                    VStack(spacing: 2) {
                        Text("🔥")
                            .font(.system(size: 22))
                        Text("\(progressStore.streak)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.insightText)
                    }
                }
            }
        }
    }

    // MARK: - Stats section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Your numbers")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statTile(
                    icon: "bolt.fill",
                    tint: Theme.Colors.primaryBlue,
                    value: "\(progressStore.totalSessions)",
                    label: "Sessions"
                )
                statTile(
                    icon: "star.fill",
                    tint: Theme.Colors.insightYellow,
                    value: "\(progressStore.totalXP)",
                    label: "Total XP"
                )
                statTile(
                    icon: "scope",
                    tint: Theme.Colors.mindTeal,
                    value: progressStore.totalSessions > 0
                        ? "\(Int(progressStore.accuracy * 100))%"
                        : "—",
                    label: "Accuracy"
                )
                statTile(
                    icon: "flame.fill",
                    tint: Theme.Colors.errorSoftRed,
                    value: progressStore.bestStreak > 0 ? "\(progressStore.bestStreak)" : "—",
                    label: "Best streak"
                )
            }
        }
    }

    private func statTile(icon: String, tint: Color, value: String, label: String) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 10) {
                IconTile(systemName: icon, tintColor: tint, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(label)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - App section

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("App")
            NumindCard {
                Button { showResetAlert = true } label: {
                    HStack(spacing: 14) {
                        IconTile(systemName: "arrow.counterclockwise", tintColor: Theme.Colors.errorSoftRed, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reset progress")
                                .font(Theme.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.errorSoftRed)
                            Text("Clears all local lesson and quiz history")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private var joinedDateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(ProgressStore())
    }
}
