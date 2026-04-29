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
                WelcomePage { page = 1 }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case 1:
                GoalPage(selected: $selectedGoal) {
                    weeklyGoalDays = selectedGoal.days
                    page = 2
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            default:
                NamePage(nameInput: $nameInput, focused: $nameFieldFocused) {
                    userName = nameInput.trimmingCharacters(in: .whitespaces).isEmpty
                        ? "You"
                        : nameInput.trimmingCharacters(in: .whitespaces)
                    hasCompleted = true
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
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
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Colors.deepNavy, Color(red: 0.08, green: 0.28, blue: 0.72)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 36)

                // Brand + tagline
                VStack(spacing: 14) {
                    Text("Numind")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Build real-world\nnumber sense.")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("Tips, tax, discounts, splits —\nconfidence with everyday numbers.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                Spacer()

                // CTA
                Button(action: onContinue) {
                    Text("Get started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Spacing.buttonHeight)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 52)
            }
        }
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
                        .strokeBorder(
                            isSelected ? option.tint : Theme.Colors.hairline,
                            lineWidth: 2
                        )
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
                    .strokeBorder(
                        isSelected ? option.tint.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
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
                        .onSubmit { if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty { onComplete() } }

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
