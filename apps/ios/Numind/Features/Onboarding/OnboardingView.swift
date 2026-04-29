import SwiftUI

// MARK: - Coordinator

struct OnboardingView: View {
    @AppStorage("numind.hasCompletedOnboarding") private var hasCompleted = false
    @AppStorage("numind.userName") private var userName = ""
    @AppStorage("numind.weeklyGoalDays") private var weeklyGoalDays = 5

    @State private var page: Int = 0
    @State private var selectedGoal: GoalOption = .fivePerWeek
    @State private var nameInput: String = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            switch page {
            case 0:
                WelcomePage(
                    onGetStarted: { page = 1 },
                    onAlreadyHaveAccount: {
                        userName = "You"
                        hasCompleted = true
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 1:
                GoalPage(selected: $selectedGoal) {
                    weeklyGoalDays = selectedGoal.days
                    page = 2
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            default:
                NamePage(nameInput: $nameInput, focused: $nameFieldFocused) {
                    userName = nameInput.trimmingCharacters(in: .whitespaces).isEmpty
                        ? "You"
                        : nameInput.trimmingCharacters(in: .whitespaces)
                    hasCompleted = true
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.32), value: page)
    }
}

// MARK: - Goal option model

enum GoalOption: CaseIterable, Identifiable {
    case daily, fivePerWeek, weekendsOnly

    var id: Self { self }
    var label: String {
        switch self {
        case .daily:        return "Every day"
        case .fivePerWeek:  return "A few times a week"
        case .weekendsOnly: return "Weekends only"
        }
    }
    var detail: String {
        switch self {
        case .daily:        return "7 days a week — build the habit fast"
        case .fivePerWeek:  return "5 days a week — steady and sustainable"
        case .weekendsOnly: return "2 days a week — low commitment start"
        }
    }
    var icon: String {
        switch self {
        case .daily:        return "bolt.fill"
        case .fivePerWeek:  return "calendar.badge.checkmark"
        case .weekendsOnly: return "leaf.fill"
        }
    }
    var tint: Color {
        switch self {
        case .daily:        return Theme.Colors.primaryBlue
        case .fivePerWeek:  return Theme.Colors.mindTeal
        case .weekendsOnly: return Theme.Colors.insightYellow
        }
    }
    var days: Int {
        switch self {
        case .daily:        return 7
        case .fivePerWeek:  return 5
        case .weekendsOnly: return 2
        }
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    let onGetStarted: () -> Void
    let onAlreadyHaveAccount: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Theme.Colors.deepNavy, Color(red: 0.08, green: 0.28, blue: 0.72)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 32)

                // Wordmark — always force dark (white) variant on the navy gradient
                Image("NumindWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
                    .environment(\.colorScheme, .dark)
                    .padding(.bottom, 24)

                // Abstract hero illustration
                HeroGraphic()
                    .padding(.bottom, 36)

                // Headline
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text("Real math.")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Text("Real life.")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Colors.insightYellow)
                        Spacer()
                    }

                    Text("Build everyday math skills that help you\nmake smarter decisions — every day.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(3)
                        .padding(.top, 8)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

                // Value props
                VStack(spacing: 16) {
                    valueProp(
                        icon: "bolt.fill",
                        tint: Theme.Colors.primaryBlue,
                        title: "Short, focused workouts",
                        detail: "5–10 minutes to build momentum"
                    )
                    valueProp(
                        icon: "cart.fill",
                        tint: Theme.Colors.mindTeal,
                        title: "Practical & relevant",
                        detail: "Learn skills you can use today"
                    )
                    valueProp(
                        icon: "chart.bar.fill",
                        tint: Theme.Colors.insightYellow,
                        title: "Track progress, build habits",
                        detail: "Streaks, goals, and rewards"
                    )
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, 28)

                Spacer(minLength: 24)

                // CTAs
                VStack(spacing: 14) {
                    Button(action: onGetStarted) {
                        Text("Get started")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                    }

                    Button(action: onAlreadyHaveAccount) {
                        Text("I already have an account")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(height: 36)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 48)
            }
        }
    }

    private func valueProp(icon: String, tint: Color, title: String, detail: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(detail)
                    .font(Theme.Typography.small)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
    }
}

// MARK: - Abstract hero graphic

private struct HeroGraphic: View {
    @State private var floatA = false
    @State private var floatB = false
    @State private var floatC = false

    var body: some View {
        ZStack {
            // Background blobs
            Circle()
                .fill(Theme.Colors.primaryBlue.opacity(0.28))
                .frame(width: 170, height: 170)
                .offset(x: -50, y: 8)
                .blur(radius: 2)

            Circle()
                .fill(Theme.Colors.mindTeal.opacity(0.22))
                .frame(width: 110, height: 110)
                .offset(x: 85, y: -18)
                .blur(radius: 1)

            // Receipt card (main element)
            receiptCard
                .rotationEffect(.degrees(-7))
                .offset(x: -8, y: floatA ? -4 : 4)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: floatA)

            // Percentage coin (top-right)
            ZStack {
                Circle()
                    .fill(Theme.Colors.insightYellow)
                    .frame(width: 54, height: 54)
                    .shadow(color: Theme.Colors.insightYellow.opacity(0.45), radius: 10, x: 0, y: 5)
                Text("%")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
            }
            .offset(x: 105, y: floatB ? 28 : 36)
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatB)

            // Cart badge (bottom-left)
            ZStack {
                Circle()
                    .fill(Theme.Colors.mindTeal)
                    .frame(width: 44, height: 44)
                    .shadow(color: Theme.Colors.mindTeal.opacity(0.4), radius: 8, x: 0, y: 4)
                Image(systemName: "cart.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .offset(x: -100, y: floatC ? 38 : 44)
            .animation(.easeInOut(duration: 2.9).repeatForever(autoreverses: true), value: floatC)

            // Dollar pill (overlapping card, bottom)
            Text("$23.47")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1))
                .offset(x: 30, y: 44)

            // Decorative accent dots
            Circle().fill(.white.opacity(0.25)).frame(width: 8, height: 8).offset(x: 75, y: -52)
            Circle().fill(Theme.Colors.insightYellow.opacity(0.5)).frame(width: 6, height: 6).offset(x: -85, y: -28)
            Circle().fill(Theme.Colors.mindTeal.opacity(0.6)).frame(width: 5, height: 5).offset(x: 110, y: -8)
        }
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .onAppear {
            floatA = true
            floatB = true
            floatC = true
        }
    }

    private var receiptCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            // Header line
            Capsule()
                .fill(.white.opacity(0.55))
                .frame(width: 90, height: 8)
            // Sub line
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 64, height: 6)

            Spacer().frame(height: 2)

            // Item rows
            ForEach(0..<2, id: \.self) { _ in
                HStack {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(width: 56, height: 5)
                    Spacer()
                    Capsule()
                        .fill(.white.opacity(0.35))
                        .frame(width: 32, height: 5)
                }
            }

            // Divider
            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 2)

            // Total row
            HStack {
                Capsule()
                    .fill(.white.opacity(0.45))
                    .frame(width: 40, height: 7)
                Spacer()
                Text("$46.80")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .frame(width: 162)
        .background(.white.opacity(0.11))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Page 2: Goal

private struct GoalPage: View {
    @Binding var selected: GoalOption
    let onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                progressStrip(current: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How often do you\nwant to practice?")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .lineSpacing(2)
                            Text("You can change this any time.")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)
                        }
                        .padding(.top, 32)

                        VStack(spacing: 12) {
                            ForEach(GoalOption.allCases) { option in
                                GoalCard(option: option, isSelected: selected == option) {
                                    selected = option
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }
            }

            footerButton("Continue") { onContinue() }
        }
    }
}

private struct GoalCard: View {
    let option: GoalOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                        .fill(isSelected ? option.tint.opacity(0.14) : Theme.Colors.mutedTint)
                    Image(systemName: option.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? option.tint : Theme.Colors.mutedText)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.label)
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(option.detail)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? option.tint : Theme.Colors.hairline, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(option.tint)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(18)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(isSelected ? option.tint.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: isSelected ? option.tint.opacity(0.12) : .black.opacity(0.04),
                    radius: isSelected ? 10 : 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Page 3: Name

private struct NamePage: View {
    @Binding var nameInput: String
    var focused: FocusState<Bool>.Binding
    let onComplete: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                progressStrip(current: 2)

                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What should we\ncall you?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(2)
                        Text("Used only for your greeting.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    .padding(.top, 32)

                    TextField("Your name", text: $nameInput)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                                .strokeBorder(
                                    focused.wrappedValue
                                        ? Theme.Colors.primaryBlue.opacity(0.5)
                                        : Theme.Colors.hairline,
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .focused(focused)
                        .submitLabel(.done)
                        .onSubmit {
                            if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty { onComplete() }
                        }

                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
            }

            footerButton("Start learning") { onComplete() }
        }
        .onAppear { focused.wrappedValue = true }
    }
}

// MARK: - Shared helpers

private func progressStrip(current: Int) -> some View {
    HStack(spacing: 6) {
        ForEach(0..<3, id: \.self) { i in
            Capsule()
                .fill(i <= current ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                .frame(height: 4)
                .animation(.easeOut(duration: 0.25), value: current)
        }
    }
    .padding(.horizontal, Theme.Spacing.screenHorizontal)
    .padding(.top, 16)
    .padding(.bottom, 8)
}

private func footerButton(_ title: String, action: @escaping () -> Void) -> some View {
    VStack(spacing: 0) {
        LinearGradient(
            colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
            startPoint: .top, endPoint: .bottom
        )
        .frame(height: 24)
        .allowsHitTesting(false)

        PillButton(title, action: action)
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 44)
            .background(Theme.Colors.softBackground)
    }
}

#Preview {
    OnboardingView()
}
