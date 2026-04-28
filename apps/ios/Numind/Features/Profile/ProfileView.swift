import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                profileCard
                goalsSection
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
                IconTile(systemName: "person.fill", tintColor: Theme.Colors.primaryBlue, size: 56)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alex")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Joined \(joinedDateString)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                    if progressStore.streak > 0 {
                        Text("\(progressStore.streak)-day streak 🔥")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.insightText)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Goals section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Goals")
            NumindCard {
                VStack(spacing: 0) {
                    goalRow(icon: "bolt.fill",    tint: Theme.Colors.primaryBlue,
                            title: "Daily target", value: "5 minutes")
                    Divider().background(Theme.Colors.hairline).padding(.leading, 18 + 36 + 14)
                    goalRow(icon: "trophy.fill",  tint: Theme.Colors.insightYellow,
                            title: "Weekly goal",  value: "5 workouts")
                    Divider().background(Theme.Colors.hairline).padding(.leading, 18 + 36 + 14)
                    goalRow(icon: "bell.fill",    tint: Theme.Colors.mindTeal,
                            title: "Reminders",    value: "Off")
                }
            }
        }
    }

    private func goalRow(icon: String, tint: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            IconTile(systemName: icon, tintColor: tint, size: 36)
            Text(title)
                .font(Theme.Typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.Colors.deepNavy)
            Spacer()
            Text(value)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
    }

    // MARK: - App section

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("App")
            NumindCard {
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        IconTile(systemName: "square.and.arrow.up", tintColor: Theme.Colors.mutedText, size: 36)
                        Text("Share Numind")
                            .font(Theme.Typography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)

                    Divider().background(Theme.Colors.hairline).padding(.leading, 18 + 36 + 14)

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
