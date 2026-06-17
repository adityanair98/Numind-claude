import SwiftUI

/// Screen 4 — Insecurity Mirror (question + reveal sub-states).
///
/// "Which of these have happened to you?" — the user names the moments
/// they felt unprepared for, then the reveal shows the verified cost of
/// exactly those moments and that each has a 5-minute version of the math.
/// Replaces the old screen-time/opportunity-cost device with one that is
/// specific to money decisions.
struct InsecurityMirrorView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            if viewModel.mirrorRevealed {
                revealState
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                questionState
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.mirrorRevealed)
    }

    // MARK: - Question State

    private var questionState: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Which of these have happened to you?")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .padding(.top, 8)

                    Text("Pick any that ring true \u{2014} most people have at least one.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(FeltMoment.allCases, id: \.self) { moment in
                            OnboardingSelectCard(
                                label: moment.displayText,
                                selected: viewModel.signals.feltMoments.contains(moment)
                            ) {
                                viewModel.toggleFeltMoment(moment)
                            }
                        }
                    }
                    .padding(.top, 22)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 120)
            }

            onboardingFooter(dark: false) {
                PillButton("Continue") { onContinue() }
            }
            .opacity(viewModel.signals.feltMoments.isEmpty ? 0.5 : 1)
            .allowsHitTesting(!viewModel.signals.feltMoments.isEmpty)
        }
    }

    // MARK: - Reveal State

    private var hasRealMoment: Bool {
        !viewModel.signals.feltMoments.subtracting([.noneYet]).isEmpty
    }

    /// One verified cost stat per felt moment — the reveal mirrors EXACTLY
    /// what the user just admitted to, in their own words.
    private static let momentStats: [FeltMoment: (stat: String, text: String, source: String)] = [
        .acceptedWithoutNegotiating: (
            "10 min",
            "is what a negotiation conversation takes \u{2014} and its payoff repeats every year you hold the job. Most people skip it.",
            "Numind curriculum \u{00B7} verified 2026"
        ),
        .guessedHealthPlan: (
            "$4.5B",
            "in FSA money is forfeited annually \u{2014} benefits chosen by guessing leak money all year",
            "EBRI"
        ),
        .carriedCardBalance: (
            "~22%",
            "is the typical card APR \u{2014} interest that compounds against a carried balance every single day",
            "CFPB"
        ),
        .almostScammed: (
            "44%",
            "of fraud reports from people in their 20s involved lost money \u{2014} the most-scammed cohort by frequency",
            "FTC Consumer Sentinel"
        ),
        .signedLeaseBlind: (
            "3\u{2013}4\u{00D7}",
            "monthly rent is what move-in actually costs before you get keys \u{2014} most renters find out at signing",
            "Numind curriculum \u{00B7} verified 2026"
        ),
    ]

    /// Stats for what they selected, in their own words; padded with the
    /// remaining moments (framed as "coming") when fewer than 2 picked.
    private var selectedStats: [(moment: FeltMoment, isYours: Bool)] {
        let picked = FeltMoment.allCases.filter {
            $0 != .noneYet && viewModel.signals.feltMoments.contains($0)
        }
        var rows = picked.map { (moment: $0, isYours: true) }
        if rows.count < 2 {
            let fillers: [FeltMoment] = [.almostScammed, .guessedHealthPlan, .carriedCardBalance]
            for f in fillers where !picked.contains(f) && rows.count < 3 {
                rows.append((moment: f, isYours: false))
            }
        }
        return rows
    }

    private var revealState: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(hasRealMoment ? "You\u{2019}re in good company" : "You\u{2019}re ahead of most")
                        .font(Theme.Typography.small)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .padding(.top, 4)

                    Text(hasRealMoment
                         ? "Every one of these has a 5-minute fix."
                         : "These moments are coming \u{2014} and each has a 5-minute fix.")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(2)
                        .padding(.top, 12)

                    // Verified cost stats — driven by the user's selections.
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(selectedStats, id: \.moment) { row in
                            if let s = Self.momentStats[row.moment] {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(row.isYours
                                         ? "You said \u{00B7} \(row.moment.displayText)"
                                         : "Also coming for most people")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(row.isYours
                                                         ? Theme.Colors.mindTeal
                                                         : Theme.Colors.mutedText)
                                        .padding(.leading, 4)
                                    costRow(stat: s.stat, text: s.text, source: s.source)
                                }
                            }
                        }
                    }
                    .padding(.top, 22)

                    Text("Not because people are careless \u{2014} because nobody showed them what to look for before the moment arrived.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .lineSpacing(3)
                        .padding(.top, 18)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 120)
            }

            onboardingFooter(dark: false) {
                PillButton("Show me how") { onContinue() }
            }
        }
    }

    private func costRow(stat: String, text: String, source: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(stat)
                .font(.system(size: 22, weight: .heavy, design: .monospaced))
                .foregroundStyle(Theme.Colors.warmOrange)
                .frame(width: 72, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .lineSpacing(3)
                Text(source)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    InsecurityMirrorView(
        viewModel: OnboardingViewModel(
            progressStore: ProgressStore(),
            repository: LocalContentRepository()
        ),
        onContinue: {}
    )
}
