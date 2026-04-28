import SwiftUI

struct ProgressPlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                statsSection
                moduleProgressSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Overview")
            NumindCard {
                HStack(spacing: 0) {
                    statCell(value: "—", label: "Streak")
                    divider
                    statCell(value: "—", label: "Lessons")
                    divider
                    statCell(value: "—", label: "Accuracy")
                }
            }
        }
    }

    private var moduleProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("By module")
            NumindCard {
                VStack(alignment: .leading, spacing: 16) {
                    moduleProgressRow("Tips, Tax & Bill Split",   tint: Theme.Colors.primaryBlue)
                    moduleProgressRow("Discounts & Shopping",     tint: Theme.Colors.mindTeal)
                    moduleProgressRow("Everyday Money Math",      tint: Theme.Colors.insightYellow)
                    moduleProgressRow("Estimation & Number Sense", tint: Theme.Colors.mutedText)
                }
            }
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Typography.title)
                .foregroundStyle(Theme.Colors.deepNavy)
            Text(label)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.Colors.mutedText.opacity(0.15))
            .frame(width: 1, height: 40)
    }

    private func moduleProgressRow(_ title: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                Text("—")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.15)).frame(height: 6)
                    Capsule().fill(tint).frame(width: 0, height: 6)
                }
            }
            .frame(height: 6)
        }
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
        ProgressPlaceholderView()
    }
}
