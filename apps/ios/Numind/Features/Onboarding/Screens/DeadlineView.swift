import SwiftUI

/// Screen 9 — The Deadline (DARK).
///
/// Real urgency, not manufactured: for dated moments (open enrollment, tax
/// day) shows the actual calendar countdown; for undated moments shows the
/// cost of waiting. Finance has real deadlines — no language app does.
struct DeadlineView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private var packId: String? { viewModel.signals.focusPackId }
    private var packTitle: String { viewModel.focusPack?.title ?? "your moment" }
    private var deadline: MomentsRegistry.Deadline? {
        guard let id = packId else { return nil }
        return MomentsRegistry.nextDeadline(for: id)
    }

    var body: some View {
        ZStack {
            Theme.Colors.deepNavy.ignoresSafeArea()

            RadialGradient(
                colors: [Theme.Colors.insightYellow.opacity(0.14), .clear],
                center: .center, startRadius: 0, endRadius: 180
            )
            .offset(y: -60)

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let deadline {
                            datedContent(deadline)
                        } else {
                            undatedContent
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: true) {
                    Button(action: onContinue) {
                        Text("Let\u{2019}s get ready")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Spacing.buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Dated moment

    @ViewBuilder
    private func datedContent(_ deadline: MomentsRegistry.Deadline) -> some View {
        let days = MomentsRegistry.daysUntil(deadline.date)

        Text("This one has a real deadline")
            .font(Theme.Typography.small)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.55))
            .padding(.top, 4)

        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(days)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Colors.insightYellow)
            Text("days")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top, 16)

        Text("\(deadline.label) \(deadline.date.formatted(.dateTime.month(.wide).day())).")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.top, 6)

        deadlineCard(
            "Most people open the form, guess, and hope. You\u{2019}ll walk in knowing exactly what the numbers mean \u{2014} a few minutes a day is all it takes."
        )
        .padding(.top, 24)
    }

    // MARK: - Undated moment

    @ViewBuilder
    private var undatedContent: some View {
        Text("Waiting has a price")
            .font(Theme.Typography.small)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.55))
            .padding(.top, 4)

        Text(undatedHeadline)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .lineSpacing(3)
            .padding(.top, 14)

        deadlineCard(undatedBody)
            .padding(.top, 24)
    }

    private var undatedHeadline: String {
        switch packId {
        case "credit_card_cleanup":
            return "Card interest compounds every day you wait."
        case "the_job_offer":
            return "Offers don\u{2019}t announce themselves in advance."
        case "protect_your_money":
            return "Scammers don\u{2019}t wait until you\u{2019}re ready."
        default:
            return "\(packTitle) won\u{2019}t wait until you feel ready."
        }
    }

    private var undatedBody: String {
        switch packId {
        case "credit_card_cleanup":
            return "On a typical balance at today\u{2019}s average APR, every month of \u{201C}I\u{2019}ll deal with it later\u{201D} costs real money. Turning it around takes minutes to learn \u{2014} and works immediately."
        case "the_job_offer":
            return "The call comes, they name a number, and you have seconds to respond. The people who counter well aren\u{2019}t braver \u{2014} they just knew their number before the phone rang."
        case "protect_your_money":
            return "Adults in their 20s and 30s report losing money to scams more often than any other age group. The defense is pattern recognition \u{2014} and patterns are learnable."
        default:
            return "The decision arrives on its own schedule. The preparation is yours to control \u{2014} a few minutes a day, starting today."
        }
    }

    private func deadlineCard(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(.white.opacity(0.85))
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

#Preview {
    DeadlineView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
