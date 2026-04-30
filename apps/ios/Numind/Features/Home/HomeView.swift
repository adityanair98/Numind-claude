import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var launchCard: HomeViewModel.LessonCard?
    @State private var dailyVM: QuizSessionViewModel? = nil
    @AppStorage("numind.userName") private var userName = "You"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                greetingHeader
                streakWeekCard
                dailyChallengeSection
                workoutSection
                if let card = viewModel.continueCard {
                    continueSection(card)
                }
                if !viewModel.upNextCards.isEmpty {
                    upNextSection
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $launchCard) { card in
            LessonView(viewModel: LessonViewModel(
                lesson: card.lesson,
                moduleTitle: card.module.title,
                lessonIndex: card.lessonIndex,
                totalLessons: card.totalLessons,
                moduleColor: card.module.color
            ))
        }
        .fullScreenCover(item: $dailyVM) { vm in
            NavigationStack {
                QuizSessionView(viewModel: vm) {
                    let correct = vm.correctCount
                    let total   = vm.total
                    progressStore.recordSession(SessionRecord(
                        id: UUID(),
                        lessonId: "daily_challenge",
                        moduleId: "mixed",
                        date: Date(),
                        correctCount: correct,
                        totalCount: total
                    ))
                    progressStore.markDailyChallengeCompleted()
                    dailyVM = nil
                }
            }
        }
        .onAppear { viewModel.refresh(using: progressStore) }
        .onChange(of: progressStore.totalSessions) { _, _ in
            viewModel.refresh(using: progressStore)
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.Colors.primaryBlueTint)
                Text(String(userName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.primaryBlue)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(timeBasedGreeting)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Ready for your daily workout?")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            Spacer()
        }
    }

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "there" : userName
        if hour < 12 { return "👋 Good morning, \(name)!" }
        if hour < 17 { return "👋 Good afternoon, \(name)!" }
        return "👋 Good evening, \(name)!"
    }

    // MARK: - Streak + weekly strip

    private var streakWeekCard: some View {
        let completions = progressStore.weeklyCompletions
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        return NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.Colors.insightYellow)
                    Text("\(progressStore.streak)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("day streak")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                        Text(progressStore.streak > 0 ? "Keep it going!" : "Start your streak today!")
                            .font(Theme.Typography.small)
                            .foregroundStyle(progressStore.streak > 0 ? Theme.Colors.insightText : Theme.Colors.mutedText)
                    }
                    Spacer()
                }

                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(completions[i] ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                                    .frame(width: 28, height: 28)
                                if completions[i] {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            Text(dayLabels[i])
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: - Workout section

    @ViewBuilder
    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Today's workout")
            if let card = viewModel.todayCard {
                workoutCard(card)
            } else {
                allDoneCard
            }
        }
    }

    private func workoutCard(_ card: HomeViewModel.LessonCard) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                // Header row: module icon + title/concept + duration pill
                HStack(alignment: .top, spacing: 14) {
                    IconTile(systemName: card.module.icon,
                             tintColor: card.module.color.tintColor, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 6) {
                            Text(card.module.title.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(card.module.color.tintColor)
                                .kerning(0.6)
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10, weight: .medium))
                                Text("5–7 min")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.Colors.mutedTint)
                            .clipShape(Capsule())
                        }
                        Text(card.lesson.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(card.lesson.concept)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack {
                    BeadRail(progress: 0, total: card.questionCount, variant: .chunky)
                    Spacer()
                    Text("+\(card.xpReward) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Colors.insightYellowTint)
                        .clipShape(Capsule())
                }

                PillButton("Start workout") { launchCard = card }
            }
        }
    }

    private var allDoneCard: some View {
        NumindCard {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.Colors.mindTeal)
                Text("All done for today!")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("Come back tomorrow to keep your streak going.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Daily challenge

    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Daily challenge")
            NumindCard(background: Theme.Colors.primaryBlueTint) {
                VStack(alignment: .leading, spacing: 14) {
                    // Header: icon + title + done badge
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(progressStore.isDailyChallengeCompleted
                                      ? Theme.Colors.mindTeal
                                      : Theme.Colors.primaryBlue)
                                .frame(width: 44, height: 44)
                            Image(systemName: progressStore.isDailyChallengeCompleted
                                  ? "checkmark" : "bolt.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("5 questions · All modules")
                                .font(Theme.Typography.headline)
                                .foregroundStyle(Theme.Colors.deepNavy)
                            Text(progressStore.isDailyChallengeCompleted
                                 ? "Completed today"
                                 : "New questions every day")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(progressStore.isDailyChallengeCompleted
                                                 ? Theme.Colors.mindTeal : Theme.Colors.mutedText)
                        }
                        Spacer()
                    }

                    // Bead rail + XP badge
                    HStack {
                        BeadRail(
                            progress: progressStore.isDailyChallengeCompleted ? 5 : 0,
                            total: 5,
                            variant: .chunky
                        )
                        Spacer()
                        Text("+50 XP max")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.insightText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.Colors.insightYellowTint)
                            .clipShape(Capsule())
                    }

                    // CTA
                    if progressStore.isDailyChallengeCompleted {
                        Text("✓ Come back tomorrow for new questions")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        PillButton("Start challenge") { startDailyChallenge() }
                    }
                }
            }
        }
    }

    private func startDailyChallenge() {
        let repo = LocalContentRepository()
        let questions = DailyChallengeEngine.dailyQuestions(from: repo)
        dailyVM = QuizSessionViewModel(
            questions: questions,
            title: "Daily Challenge",
            shortcut: "Draw on all the skills you've built — tips, discounts, salary math, and more.",
            moduleColor: .blue
        )
    }

    // MARK: - Continue learning

    private func continueSection(_ card: HomeViewModel.LessonCard) -> some View {
        let repo = LocalContentRepository()
        let lessons = repo.lessons(for: card.module.id)
        let completed = progressStore.completedLessonCount(moduleId: card.module.id)
        let progress: Double = lessons.isEmpty ? 0 : Double(completed) / Double(lessons.count)

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Continue learning")
            NumindCard {
                Button { launchCard = card } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            IconTile(systemName: card.module.icon,
                                     tintColor: card.module.color.tintColor)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(card.module.title)
                                    .font(Theme.Typography.small)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(card.module.color.tintColor)
                                    .textCase(.uppercase)
                                    .kerning(0.5)
                                Text(card.lesson.title)
                                    .font(Theme.Typography.headline)
                                    .foregroundStyle(Theme.Colors.deepNavy)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mutedText)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Theme.Colors.mutedTint)
                                Capsule()
                                    .fill(card.module.color.tintColor)
                                    .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                            }
                        }
                        .frame(height: 6)

                        Text("\(completed) of \(lessons.count) lessons · Resume")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Up next

    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Up next")
            NumindCard {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.upNextCards.enumerated()), id: \.element.id) { i, card in
                        Button { launchCard = card } label: {
                            HStack(spacing: 14) {
                                IconTile(systemName: card.module.icon,
                                         tintColor: card.module.color.tintColor,
                                         size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.lesson.title)
                                        .font(Theme.Typography.body)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Theme.Colors.deepNavy)
                                    Text(card.module.title)
                                        .font(Theme.Typography.small)
                                        .foregroundStyle(Theme.Colors.mutedText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.mutedText)
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        if i < viewModel.upNextCards.count - 1 {
                            Divider().background(Theme.Colors.hairline)
                        }
                    }
                }
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
        HomeView()
            .environmentObject(ProgressStore())
    }
}
