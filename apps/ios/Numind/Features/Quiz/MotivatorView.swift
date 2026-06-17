import SwiftUI

/// Full-screen mid-session motivator checkpoint.
///
/// Shown between quiz questions to celebrate momentum, coach through struggle,
/// mark progress milestones, or encourage a strong finish. Matches the
/// Duolingo-style checkpoint design with large illustrations, stats cards,
/// and a prominent CTA.
struct MotivatorView: View {
    let checkpoint: MotivatorCheckpoint
    let onDismiss: () -> Void

    @State private var iconAppeared = false
    @State private var contentAppeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            scrollContent
            footer
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                iconAppeared = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                contentAppeared = true
            }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 48)

                // ── Illustration ──
                illustration
                    .scaleEffect(iconAppeared ? 1 : 0.6)
                    .opacity(iconAppeared ? 1 : 0)

                Spacer().frame(height: 20)

                // ── Headlines ──
                VStack(spacing: 6) {
                    Text(checkpoint.headline)
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .multilineTextAlignment(.center)

                    Text(checkpoint.subtitle)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(accentColor)
                        .multilineTextAlignment(.center)

                    if !checkpoint.bodyText.isEmpty {
                        Text(checkpoint.bodyText)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 12)

                Spacer().frame(height: 28)

                // ── Type-specific content ──
                typeContent
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 16)

                Spacer().frame(height: Theme.Spacing.buttonHeight + 80)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
    }

    // MARK: - Illustration

    private var illustration: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [illustrationTint.opacity(0.7), illustrationTint.opacity(0)],
                        center: .center,
                        startRadius: 25,
                        endRadius: 72
                    )
                )
                .frame(width: 150, height: 150)

            // Main circle
            Circle()
                .fill(illustrationTint)
                .frame(width: 96, height: 96)

            Image(systemName: illustrationIcon)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(illustrationColor)

            // Decorative floating particles
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(illustrationColor.opacity([0.35, 0.25, 0.4, 0.2, 0.3][i]))
                    .frame(
                        width: CGFloat([8, 6, 10, 7, 5][i]),
                        height: CGFloat([8, 6, 10, 7, 5][i])
                    )
                    .offset(
                        x: CGFloat([-44, 50, -38, 46, -12][i]),
                        y: CGFloat([-36, -26, 32, 30, -48][i])
                    )
            }
        }
    }

    private var illustrationIcon: String {
        switch checkpoint.type {
        case .momentum:  return "star.fill"
        case .coaching:  return "lightbulb.fill"
        case .progress:  return "mountain.2.fill"
        case .nearFinish: return "trophy.fill"
        }
    }

    private var illustrationColor: Color {
        switch checkpoint.type {
        case .momentum:  return Theme.Colors.insightYellow
        case .coaching:  return Theme.Colors.insightYellow
        case .progress:  return Theme.Colors.mindTeal
        case .nearFinish: return Theme.Colors.insightYellow
        }
    }

    private var illustrationTint: Color {
        switch checkpoint.type {
        case .momentum:  return Theme.Colors.insightYellowTint
        case .coaching:  return Theme.Colors.insightYellowTint
        case .progress:  return Theme.Colors.mindTealTint
        case .nearFinish: return Theme.Colors.insightYellowTint
        }
    }

    private var accentColor: Color {
        switch checkpoint.type {
        case .momentum:  return Theme.Colors.mindTeal
        case .coaching:  return Theme.Colors.mutedText
        case .progress:  return Theme.Colors.mindTeal
        case .nearFinish: return Theme.Colors.deepNavy
        }
    }

    // MARK: - Type-specific content

    @ViewBuilder
    private var typeContent: some View {
        switch checkpoint.type {
        case .momentum:  momentumContent
        case .coaching:  coachingContent
        case .progress:  progressContent
        case .nearFinish: nearFinishContent
        }
    }

    // MARK: - Momentum

    private var momentumContent: some View {
        VStack(spacing: 16) {
            // Streak visualization — checkmarks for correct, dots for remaining
            HStack(spacing: 10) {
                ForEach(0..<checkpoint.streak, id: \.self) { _ in
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.mindTealTint)
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }
                }
                // Remaining dots (up to total - completed to show what's left)
                let remaining = max(0, checkpoint.total - checkpoint.completed)
                ForEach(0..<min(remaining, 3), id: \.self) { _ in
                    Circle()
                        .fill(Theme.Colors.mutedTint)
                        .frame(width: 32, height: 32)
                }
            }

            // Pace stats card
            if let avgTime = checkpoint.avgTimeLastN {
                NumindCard {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.mindTealTint)
                                .frame(width: 40, height: 40)
                            Image(systemName: "clock.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(checkpoint.paceImproving ? "Your pace is improving!" : "Avg. time")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.deepNavy)

                            HStack(spacing: 4) {
                                Text("Avg. time: \(Int(avgTime))s")
                                    .font(Theme.Typography.body)
                                    .foregroundStyle(Theme.Colors.mutedText)
                                if checkpoint.paceImproving {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.Colors.mindTeal)
                                }
                            }

                            Text("Last \(checkpoint.streak) questions")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.mutedText)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Coaching

    private var coachingContent: some View {
        VStack(spacing: 14) {
            // Tip card with left accent bar
            NumindCard(background: Theme.Colors.mindTealTint) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.mindTeal.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "brain.head.profile.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                        }
                        Text("Try this tip")
                            .font(Theme.Typography.small)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .textCase(.uppercase)
                            .kerning(0.6)
                    }

                    Text(checkpoint.tipTitle)
                        .font(Theme.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Colors.deepNavy)

                    if !checkpoint.tipBody.isEmpty {
                        Text(checkpoint.tipBody)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.deepNavy.opacity(0.8))
                            .lineSpacing(2)
                    }
                }
            }
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(
                    topLeadingRadius: Theme.Radius.card,
                    bottomLeadingRadius: Theme.Radius.card,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(Theme.Colors.mindTeal)
                .frame(width: 5)
            }

            // Example card with accent bar
            if let example = checkpoint.example, !example.isEmpty {
                NumindCard(background: Theme.Colors.insightYellowTint.opacity(0.6)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "function")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.Colors.insightText)
                            Text("Example")
                                .font(Theme.Typography.small)
                                .fontWeight(.bold)
                                .foregroundStyle(Theme.Colors.insightText)
                                .textCase(.uppercase)
                                .kerning(0.6)
                        }

                        Text(example)
                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineSpacing(4)
                    }
                }
                .overlay(alignment: .leading) {
                    UnevenRoundedRectangle(
                        topLeadingRadius: Theme.Radius.card,
                        bottomLeadingRadius: Theme.Radius.card,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                    .fill(Theme.Colors.insightYellow)
                    .frame(width: 5)
                }
            }

            // Encouragement footer card
            NumindCard {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.mindTealTint)
                            .frame(width: 40, height: 40)
                        Image(systemName: "brain")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("You've got this!")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text("Every step counts.")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
    }

    // MARK: - Progress

    private var progressContent: some View {
        VStack(spacing: 16) {
            // Completion count
            VStack(spacing: 4) {
                Text("You've completed")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)

                Text("\(checkpoint.completed) of \(checkpoint.total) questions")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.mindTeal)
            }

            // Bead rail
            BeadRail(
                progress: checkpoint.completed,
                total: checkpoint.total,
                variant: .dot,
                filledColor: Theme.Colors.mindTeal
            )
            .frame(maxWidth: .infinity, alignment: .center)

            // Stats card
            NumindCard {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.mindTealTint)
                            .frame(width: 40, height: 40)
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("You're staying sharp")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)

                        HStack(spacing: 12) {
                            Text("Accuracy: \(Int(checkpoint.accuracy * 100))%")
                                .font(Theme.Typography.body)
                                .foregroundStyle(Theme.Colors.mutedText)

                            if let avgTime = checkpoint.avgTime {
                                Text("Avg. time: \(Int(avgTime))s")
                                    .font(Theme.Typography.body)
                                    .foregroundStyle(Theme.Colors.mutedText)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Near Finish

    private var nearFinishContent: some View {
        VStack(spacing: 14) {
            // Accuracy card
            NumindCard {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.insightYellowTint)
                            .frame(width: 40, height: 40)
                        Image(systemName: "star.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.Colors.insightYellow)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Great work!")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.Colors.deepNavy)

                        Text("Accuracy: \(Int(checkpoint.accuracy * 100))%")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.mindTeal)

                        Text("Keep it up!")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }

                    Spacer()
                }
            }

            // Daily streak card
            if checkpoint.dailyStreak > 0 {
                NumindCard {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.emberTint)
                                .frame(width: 40, height: 40)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.Colors.ember)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily streak")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.deepNavy)
                        }

                        Spacer()

                        Text("\(checkpoint.dailyStreak) days")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.ember)
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Theme.Colors.softBackground.opacity(0), Theme.Colors.softBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            VStack(spacing: 8) {
                PillButton(checkpoint.ctaLabel) {
                    onDismiss()
                }

                if let secondary = checkpoint.secondaryLabel {
                    Button {
                        // Future: deep link to progress
                        onDismiss()
                    } label: {
                        Text(secondary)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 28)
            .background(Theme.Colors.softBackground)
        }
    }
}
