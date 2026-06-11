import SwiftUI

/// Screen 18 — Money Map (v2; the old LVL 1–3 badge is retired with the
/// rest of the level language).
///
/// Shows the focus pack's core skills with honest placement words
/// (Solid start / Shaky / New to you), the secondary moments as chips, and
/// the honesty line that doubles as positioning: nothing is "Ready" yet —
/// Ready is earned by proving and holding skills, never granted by a
/// diagnostic.
struct DiagnosticResultsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    private var packTitle: String { viewModel.focusPack?.title ?? "Your focus" }

    private var rows: [OnboardingViewModel.MoneyMapRow] { viewModel.moneyMapRows }

    private var solidCount: Int {
        rows.filter { $0.placement == .solidStart }.count
    }

    private var summaryLine: String {
        let total = rows.count
        guard total > 0 else { return "Your starting picture is ready." }
        if solidCount == 0 {
            return "\(total) core skills stand between you and Ready \u{2014} all of them learnable in days."
        }
        return "\(total) core skills stand between you and Ready. You\u{2019}re starting strong on \(solidCount) of them."
    }

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your Money Map")
                            .font(Theme.Typography.small)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.mindTeal)
                            .padding(.top, 4)

                        Text("Here\u{2019}s where you stand")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .padding(.top, 10)

                        Text("A starting picture \u{2014} not a verdict.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .padding(.top, 8)

                        // Focus pack card
                        focusCard
                            .padding(.top, 22)

                        // Core skill placement rows
                        VStack(spacing: 10) {
                            ForEach(rows) { row in
                                skillRow(row)
                            }
                        }
                        .padding(.top, 12)

                        // Secondary moments
                        if !secondaryChips.isEmpty {
                            Text("Also on your map")
                                .font(Theme.Typography.small)
                                .textCase(.uppercase)
                                .tracking(1.5)
                                .foregroundStyle(Theme.Colors.mutedText)
                                .padding(.top, 22)

                            HStack(spacing: 8) {
                                ForEach(secondaryChips, id: \.title) { chip in
                                    secondaryChipView(chip)
                                }
                            }
                            .padding(.top, 10)
                        }

                        // The honesty line — positioning as copy.
                        honestyCard
                            .padding(.top, 22)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 120)
                }

                onboardingFooter(dark: false) {
                    PillButton("Show me the plan") { onContinue() }
                }
            }
        }
    }

    // MARK: - Focus card

    private var focusCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(packTitle.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(Theme.Colors.mindTeal)
            Text(summaryLine)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.Colors.cardBackground, Theme.Colors.mindTealTint],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Skill rows

    private func placementColor(_ p: OnboardingViewModel.SkillPlacement) -> Color {
        switch p {
        case .solidStart: return Theme.Colors.growthGreen
        case .shaky:      return Theme.Colors.warmOrange
        case .newToYou:   return Theme.Colors.primaryBlue
        }
    }

    private func skillRow(_ row: OnboardingViewModel.MoneyMapRow) -> some View {
        let color = placementColor(row.placement)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text(row.placement.label)
                    .font(Theme.Typography.small)
                    .foregroundStyle(color)
            }

            Spacer()

            // Placement beads (a starting picture, not a score)
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < row.placement.beadFill ? color : Theme.Colors.mutedTint)
                        .frame(width: 8, height: 16)
                }
            }
        }
        .padding(14)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    // MARK: - Secondary chips

    private struct SecondaryChip {
        let title: String
        let note: String
    }

    private var secondaryChips: [SecondaryChip] {
        viewModel.signals.secondaryPackIds.sorted().compactMap { packId in
            guard let pack = viewModel.repository.pack(id: packId) else { return nil }
            let results = viewModel.signals.diagnosticResults.filter { result in
                guard let lessonId = result.lessonId else { return false }
                return pack.lessonIds.contains(lessonId)
            }
            let note: String
            if results.contains(where: \.isCorrect) {
                note = "Solid start"
            } else if results.isEmpty {
                note = "Up next"
            } else {
                note = "Worth the reps"
            }
            return SecondaryChip(title: pack.title, note: note)
        }
    }

    private func secondaryChipView(_ chip: SecondaryChip) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(chip.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineLimit(1)
            Text(chip.note)
                .font(.system(size: 11))
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
    }

    // MARK: - Honesty card

    private var honestyCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Colors.mindTeal)
                .padding(.top, 1)

            Text("Nothing here is \u{201C}Ready\u{201D} yet \u{2014} Ready is earned by proving skills and holding them over time. Most apps hand out badges. We don\u{2019}t.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.Colors.deepNavy)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Theme.Colors.mindTealTint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    DiagnosticResultsView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
