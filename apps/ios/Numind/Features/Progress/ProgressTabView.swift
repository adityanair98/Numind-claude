import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    private let modules = LocalContentRepository().allModules()
    private let repo = LocalContentRepository()
    private let weekDayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    // Drives the streak ring sweep-in animation
    @State private var ringProgress: Double = 0
    @State private var showProfile = false

    var body: some View {
        Group {
            if store.totalSessions == 0 {
                emptyState
            } else {
                filledContent
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showProfile = false }
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                        }
                    }
            }
            .environmentObject(store)
        }
        .onAppear {
            let target = min(Double(store.streak), 7) / 7.0
            withAnimation(.easeOut(duration: 0.9)) {
                ringProgress = target
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryBlueTint)
                    .frame(width: 96, height: 96)
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.primaryBlue)
            }
            VStack(spacing: 8) {
                Text("No sessions yet")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Complete your first lesson to\nsee your progress here.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
    }

    // MARK: - Filled content

    private var filledContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                sectionLabel("This week")
                overviewCard
                sectionLabel("Weekly goal")
                weeklyGoalCard

                // Skill mastery with "See all" link
                HStack(alignment: .firstTextBaseline) {
                    sectionLabel("Skill mastery")
                    Spacer()
                    NavigationLink(destination: SkillDetailView()) {
                        Text("See all")
                            .font(Theme.Typography.small)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.primaryBlue)
                    }
                }
                skillMasteryCard

                // Recent activity (only when sessions exist)
                let recent = store.recentSessions(limit: 5)
                if !recent.isEmpty {
                    sectionLabel("Recent activity")
                    recentActivityCard(sessions: recent)
                }

                totalXPCard
                sectionLabel("Badges")
                badgesGrid
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
    }

    // MARK: - Overview (streak ring + mini stats)

    private var overviewCard: some View {
        NumindCard {
            HStack(alignment: .center, spacing: 20) {
                streakRing
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(store.streak)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Colors.deepNavy)
                            Text("day streak")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                        Text("Best: \(store.bestStreak) days")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    HStack(spacing: 16) {
                        miniStat(
                            value: store.totalSessions > 0 ? "\(store.totalSessions)" : "—",
                            label: "Sessions"
                        )
                        Rectangle()
                            .fill(Theme.Colors.hairline)
                            .frame(width: 1, height: 24)
                        miniStat(
                            value: store.totalSessions > 0 ? "\(Int(store.accuracy * 100))%" : "—",
                            label: "Accuracy"
                        )
                    }
                }
                Spacer()
            }
        }
    }

    private var streakRing: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: 8)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    Theme.Colors.insightYellow,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.insightYellow)
                Text("\(store.streak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("days")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
        }
        .frame(width: 84, height: 84)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.5)
        }
    }

    // MARK: - Weekly goal

    private var weeklyGoalCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(store.weeklyWorkouts) of \(store.weeklyGoal) workouts")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(store.weeklyWorkouts >= store.weeklyGoal
                             ? "Goal reached — great work!"
                             : "\(store.weeklyGoal - store.weeklyWorkouts) more to hit your goal")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    Spacer()
                    IconTile(systemName: "trophy.fill", tintColor: Theme.Colors.insightYellow)
                }

                HStack(spacing: 0) {
                    ForEach(Array(weekDayLabels.enumerated()), id: \.offset) { i, label in
                        let done = store.weeklyCompletions.indices.contains(i)
                            ? store.weeklyCompletions[i] : false
                        dayCircle(label: label, isCompleted: done)
                    }
                }
            }
        }
    }

    private func dayCircle(label: String, isCompleted: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                    .frame(width: 28, height: 28)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            Text(label)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Skill mastery

    private var skillMasteryCard: some View {
        NumindCard {
            VStack(spacing: 0) {
                ForEach(Array(modules.enumerated()), id: \.element.id) { i, module in
                    skillMasteryRow(module: module, isLast: i == modules.count - 1)
                }
            }
        }
    }

    private func skillMasteryRow(module: Module, isLast: Bool) -> some View {
        let level = store.skillLevel(moduleId: module.id)
        let progress = store.skillLevelProgress(moduleId: module.id)

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                IconTile(systemName: module.icon, tintColor: module.color.tintColor, size: 36)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(module.title)
                            .font(Theme.Typography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Text(level > 0 ? "Lvl \(level)" : "—")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(level > 0 ? module.color.tintColor : Theme.Colors.mutedText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(level > 0 ? module.color.tintBackground : Theme.Colors.mutedTint)
                            .clipShape(Capsule())
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.Colors.mutedTint)
                            Capsule()
                                .fill(module.color.tintColor)
                                .frame(width: geo.size.width * CGFloat(progress))
                        }
                    }
                    .frame(height: 5)
                    Text(level == 0 ? "Not started" : "Level \(level) of 5")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .padding(.vertical, 14)
            if !isLast {
                Divider().background(Theme.Colors.hairline)
            }
        }
    }

    // MARK: - Total XP

    private var totalXPCard: some View {
        NumindCard(background: Theme.Colors.insightYellowTint) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total XP")
                        .font(Theme.Typography.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.insightText)
                        .textCase(.uppercase)
                        .kerning(0.6)
                    Text("\(store.totalXP)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
                Spacer()
                IconTile(systemName: "trophy.fill", tintColor: Theme.Colors.insightYellow, size: 48)
            }
        }
    }

    // MARK: - Badges grid

    private var badgesGrid: some View {
        let earned = store.data.earnedBadgeIds
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(earned.count) of \(BadgeCatalog.all.count) unlocked")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.mutedText)
                Spacer()
            }
            NumindCard {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(BadgeCatalog.all) { badge in
                        badgeCell(badge, isEarned: earned.contains(badge.id))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func badgeCell(_ badge: Badge, isEarned: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isEarned ? badgeTierBackground(badge.tier) : Theme.Colors.mutedTint)
                    .frame(width: 48, height: 48)
                Image(systemName: isEarned ? badge.icon : "lock.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(isEarned ? badgeTierColor(badge.tier) : Theme.Colors.mutedText.opacity(0.5))
            }
            Text(badge.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isEarned ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func badgeTierColor(_ tier: BadgeTier) -> Color {
        switch tier {
        case .bronze: return Color(red: 0.78, green: 0.50, blue: 0.20)
        case .silver: return Theme.Colors.mindTeal
        case .gold:   return Theme.Colors.insightYellow
        }
    }

    private func badgeTierBackground(_ tier: BadgeTier) -> Color {
        badgeTierColor(tier).opacity(0.15)
    }

    // MARK: - Recent activity

    private func recentActivityCard(sessions: [SessionRecord]) -> some View {
        NumindCard {
            VStack(spacing: 0) {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { i, session in
                    recentRow(session, isLast: i == sessions.count - 1)
                }
            }
        }
    }

    private func recentRow(_ session: SessionRecord, isLast: Bool) -> some View {
        // Look up module + lesson for display info
        let module = modules.first { $0.id == session.moduleId }
        let lesson  = repo.lessons(for: session.moduleId).first { $0.id == session.lessonId }
        let accuracy = Int(Double(session.correctCount) / Double(max(session.totalCount, 1)) * 100)

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                IconTile(
                    systemName: module?.icon ?? "book.fill",
                    tintColor: module?.color.tintColor ?? Theme.Colors.primaryBlue,
                    size: 36
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson?.title ?? session.lessonId)
                        .font(Theme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineLimit(1)
                    Text(relativeDate(session.date))
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(session.correctCount)/\(session.totalCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("\(accuracy)%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(accuracy >= 80
                                         ? Theme.Colors.mindTeal
                                         : Theme.Colors.mutedText)
                }
            }
            .padding(.vertical, 12)
            if !isLast {
                Divider().background(Theme.Colors.hairline)
            }
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date)     { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

#Preview {
    NavigationStack {
        ProgressTabView()
            .environmentObject(ProgressStore())
    }
}
