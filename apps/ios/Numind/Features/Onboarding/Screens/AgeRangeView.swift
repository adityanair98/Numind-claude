import SwiftUI

/// Screen 14 — Age Range (3x2 pill chip grid)
struct AgeRangeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("What\u{2019}s your age range?")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .padding(.top, 8)

                Text("This helps us personalize your experience.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AgeRange.allCases, id: \.self) { range in
                        let selected = viewModel.signals.ageRange == range
                        Button {
                            viewModel.setAgeRange(range)
                        } label: {
                            Text(range.displayText)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(selected ? Theme.Colors.primaryBlue : Theme.Colors.deepNavy)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(selected ? Theme.Colors.cardBackground : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            selected ? Theme.Colors.primaryBlue : Theme.Colors.hairline,
                                            lineWidth: selected ? 1.5 : 1
                                        )
                                )
                                .shadow(
                                    color: selected ? Theme.Colors.primaryBlueTint : .black.opacity(0.04),
                                    radius: selected ? 8 : 3, x: 0, y: 2
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeOut(duration: 0.18), value: selected)
                    }
                }
                .padding(.top, 28)

                Text("\u{1F512} We never share this with anyone.")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            VStack {
                Spacer()
                onboardingFooter(dark: false) {
                    PillButton("Continue") { onContinue() }
                }
            }
            .opacity(viewModel.signals.ageRange != nil ? 1 : 0.5)
            .allowsHitTesting(viewModel.signals.ageRange != nil)
        }
    }
}

#Preview {
    AgeRangeView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
