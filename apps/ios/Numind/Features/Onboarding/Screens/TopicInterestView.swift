import SwiftUI

/// Screen 9 — Topic Interest (multi-select, min 2, max 4, 2-col grid)
struct TopicInterestView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let topics: [(id: String, label: String, glyph: String, color: Color)] = [
        ("tips", "Tipping &\npercentages", "%", Theme.Colors.mindTeal),
        ("discounts", "Shopping &\ndiscounts", "\u{1F3F7}", Theme.Colors.primaryBlue),
        ("salary", "Salary &\nincome", "\u{1F4BC}", Theme.Colors.warmOrange),
        ("investing", "Returns &\ninvesting", "\u{1F4C8}", Theme.Colors.investIndigo),
        ("estimation", "Splitting &\nestimation", "\u{1F465}", Theme.Colors.growthGreen),
        ("debt", "Debt &\ninterest rates", "\u{1F4B3}", Theme.Colors.debtCoral),
    ]

    private var canContinue: Bool {
        viewModel.signals.topicInterests.count >= 2
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Which of these would help you most?")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 8)

                        HStack(spacing: 8) {
                            Text("Pick at least 2")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.mutedText)

                            Text("\(viewModel.signals.topicInterests.count) selected")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.primaryBlueTint)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        // 2-column grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                        ], spacing: 12) {
                            ForEach(topics, id: \.id) { topic in
                                topicCard(topic)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
                .opacity(canContinue ? 1 : 0.5)
                .allowsHitTesting(canContinue)
            }
        }
    }

    private func topicCard(_ topic: (id: String, label: String, glyph: String, color: Color)) -> some View {
        let selected = viewModel.signals.topicInterests.contains(topic.id)
        return Button {
            viewModel.toggleTopicInterest(topic.id)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Icon tile
                Text(topic.glyph)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(topic.color)
                    .frame(width: 44, height: 44)
                    .background(topic.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(topic.label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .padding(.top, 2)
            .background(selected ? topic.color.opacity(0.06) : Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        selected ? topic.color : Theme.Colors.hairline,
                        lineWidth: selected ? 1.5 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                CheckBadge(selected: selected, color: topic.color)
                    .padding(12)
            }
            .shadow(
                color: selected ? topic.color.opacity(0.12) : .black.opacity(0.04),
                radius: selected ? 8 : 3, x: 0, y: 2
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: selected)
    }
}

#Preview {
    TopicInterestView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
