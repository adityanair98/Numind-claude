import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @AppStorage("numind.userName") private var userName = "You"
    @AppStorage("numind.reminderEnabled") private var reminderEnabled = false
    @AppStorage("numind.reminderHour") private var reminderHour = 20
    @AppStorage("numind.reminderMinute") private var reminderMinute = 0

    @State private var showResetAlert = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showPermissionDeniedAlert = false
    @State private var reminderTime = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                profileCard
                statsSection
                remindersSection
                appSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { syncReminderTime(); checkNotificationStatus() }
        .alert("Reset progress?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { progressStore.reset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears all completed lessons and quiz history. This cannot be undone.")
        }
        .alert("Notifications blocked", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") { openSettings() }
            Button("Cancel", role: .cancel) { reminderEnabled = false }
        } message: {
            Text("Allow Numind to send notifications in Settings to enable daily reminders.")
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
                statTile(icon: "bolt.fill",   tint: Theme.Colors.primaryBlue,
                         value: "\(progressStore.totalSessions)", label: "Sessions")
                statTile(icon: "star.fill",   tint: Theme.Colors.insightYellow,
                         value: "\(progressStore.totalXP)", label: "Total XP")
                statTile(icon: "scope",       tint: Theme.Colors.mindTeal,
                         value: progressStore.totalSessions > 0
                             ? "\(Int(progressStore.accuracy * 100))%" : "—",
                         label: "Accuracy")
                statTile(icon: "flame.fill",  tint: Theme.Colors.errorSoftRed,
                         value: progressStore.bestStreak > 0 ? "\(progressStore.bestStreak)" : "—",
                         label: "Best streak")
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

    // MARK: - Reminders section

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Reminders")
            NumindCard {
                VStack(spacing: 0) {
                    // Toggle row
                    HStack(spacing: 14) {
                        IconTile(systemName: "bell.fill", tintColor: Theme.Colors.mindTeal, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily reminder")
                                .font(Theme.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.deepNavy)
                            Text(reminderEnabled ? "You'll get a nudge each day" : "Off")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { reminderEnabled },
                            set: { newValue in toggleReminder(newValue) }
                        ))
                        .labelsHidden()
                        .tint(Theme.Colors.mindTeal)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)

                    // Time picker (only when enabled)
                    if reminderEnabled {
                        Divider()
                            .background(Theme.Colors.hairline)
                            .padding(.leading, 18 + 36 + 14)

                        HStack(spacing: 14) {
                            IconTile(systemName: "clock", tintColor: Theme.Colors.mutedText, size: 36)
                            Text("Remind me at")
                                .font(Theme.Typography.body)
                                .foregroundStyle(Theme.Colors.deepNavy)
                            Spacer()
                            DatePicker(
                                "",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .onChange(of: reminderTime) { _, newTime in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                                reminderHour = comps.hour ?? 20
                                reminderMinute = comps.minute ?? 0
                                NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .animation(.easeOut(duration: 0.22), value: reminderEnabled)
        }
    }

    // MARK: - App section

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("App")
            NumindCard {
                Button { showResetAlert = true } label: {
                    HStack(spacing: 14) {
                        IconTile(systemName: "arrow.counterclockwise",
                                 tintColor: Theme.Colors.errorSoftRed, size: 36)
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

    // MARK: - Notification helpers

    private func toggleReminder(_ on: Bool) {
        if on {
            NotificationManager.checkPermission { status in
                switch status {
                case .authorized, .provisional, .ephemeral:
                    reminderEnabled = true
                    NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                case .notDetermined:
                    NotificationManager.requestPermission { granted in
                        if granted {
                            reminderEnabled = true
                            NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                        } else {
                            reminderEnabled = false
                        }
                    }
                case .denied:
                    showPermissionDeniedAlert = true
                @unknown default:
                    reminderEnabled = false
                }
            }
        } else {
            reminderEnabled = false
            NotificationManager.cancel()
        }
    }

    private func checkNotificationStatus() {
        NotificationManager.checkPermission { status in
            notificationStatus = status
            // If permission was revoked externally, turn off the toggle.
            if status == .denied && reminderEnabled {
                reminderEnabled = false
            }
        }
    }

    private func syncReminderTime() {
        var comps = DateComponents()
        comps.hour = reminderHour
        comps.minute = reminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? Date()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
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
