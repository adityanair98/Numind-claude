import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    private let modules = LocalContentRepository().allModules()
    private let weekDayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                overviewSection
                weeklyGoalSection
                moduleProgressSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Overview

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("This week")
            NumindCard {
                HStack(spacing: 0) {
                    statCell(
                        value: store.streak > 0 ? "\(store.streak)" : "—",
                        label: "Streak",
                        color: store.streak > 0 ? Theme.Colors.insightYellow : Theme.Colors.deepNavy
                    )
                    vrule
                    statCell(
                        value: store.totalSessions > 0 ? "\(store.totalSessions)" : "—",
                        label: "Sessions",
                        color: Theme.Colors.deepNavy
                    )
                    vrule
                    statCell(
                        value: store.totalSessions > 0 ? "\(Int(store.accuracy * 100))%" : "—",
                        label: "Accuracy",
                        color: store.accuracy >= 0.8 ? Theme.Colors.mindTeal : Theme.Colors.deepNavy
                    )
                }
            }
        }
    }

    private func statCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.6)
        }
        .frame(maxWidth: .infinity)
    }

    private var vrule: some View {
        Rectangle()
            .fill(Theme.Colors.hairline)
            .frame(width: 1, height: 32)
    }

    // MARK: - Weekly goal

    private var weeklyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Weekly goal")
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

    // MARK: - Module progress

    private var moduleProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("By module")
            NumindCard {
                VStack(spacing: 0) {
                    ForEach(Array(modules.enumerated()), id: \.element.id) { i, module in
                        moduleRow(module: module, isLast: i == modules.count - 1)
                    }
                }
            }
        }
    }

    private func moduleRow(module: Module, isLast: Bool) -> some View {
        let progress = store.moduleProgress(
            moduleId: module.id,
            totalLessons: module.lessonIds.count
        )
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(module.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Spacer()
                    Text(progress > 0 ? "\(Int(progress * 100))%" : "Not started")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Colors.mutedTint)
                        Capsule()
                            .fill(module.color.tintColor)
                            .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                    }
                }
                .frame(height: 6)
            }
            .padding(.vertical, 14)
            if !isLast {
                Divider().background(Theme.Colors.hairline)
            }
        }
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
