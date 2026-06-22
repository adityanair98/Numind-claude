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

    /// The reveal's closing reassurance branches on the confidence answer
    /// (collected on the prior screen): relief for the avoider lane (no
    /// blame, never their fault), edge for the confident lane.
    private var revealClosingLine: String {
        switch viewModel.signals.confidenceLevel {
        case .struggle, .getBy:
            return "None of this was ever yours to figure out alone \u{2014} it was never explained. That changes now."
        default:
            return "You can feel these coming. After this, you\u{2019}ll name them before they land \u{2014} every time."
        }
    }

    /// One verified cost stat per felt moment — the reveal mirrors EXACTLY
    /// what the user just admitted to, in their own words.
    // Every figure verified against a credible primary source (June 2026
    // adversarial source-check) — no "Numind curriculum" self-citations.
    private static let momentStats: [FeltMoment: (stat: String, text: String, source: String)] = [
        .acceptedWithoutNegotiating: (
            "~70%",
            "of people never negotiate their starting pay \u{2014} yet most who do come away with more. The counter is a script, not a talent.",
            "Pew Research, 2023"
        ),
        // Reframed to the verified payday finding (Gelman et al.): the spike is
        // real but mostly recurring bills, not impulse — so no number; the
        // empty `stat` renders a spike glyph via `costRow`.
        .spentToFeelBetter: (
            "",
            "spending jumps the day you\u{2019}re paid \u{2014} but a lot of it is just bills landing at once. The skill is spotting what\u{2019}s actually a choice.",
            "Gelman et al., Science, 2014"
        ),
        .guessedHealthPlan: (
            "$4.5B",
            "in FSA money was forfeited in 2023 \u{2014} benefits picked by guessing leak money all year",
            "EBRI data via Money, 2025"
        ),
        .carriedCardBalance: (
            "~22%",
            "is the going credit-card APR \u{2014} interest that compounds against a carried balance every single day",
            "Federal Reserve, 2024"
        ),
        .almostScammed: (
            "44%",
            "of fraud reports from people in their 20s involved a money loss \u{2014} a higher rate than any older age group",
            "FTC Consumer Sentinel, 2024"
        ),
        .signedLeaseBlind: (
            "2.5\u{2013}3\u{00D7}",
            "your monthly rent is what move-in really costs up front \u{2014} deposit, first month, fees \u{2014} and most find out at signing",
            "Harvard JCHS, 2026"
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
                         ? "Every one of these has a move you can learn."
                         : "These moments are coming \u{2014} and each has a move you can learn first.")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .lineSpacing(2)
                        .padding(.top, 12)

                    // Verified cost cards — driven by the user's selections, but
                    // no verbatim "You said ·" playback: the content is already
                    // theirs, so the personalization stays implicit.
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(selectedStats, id: \.moment) { row in
                            if let s = Self.momentStats[row.moment] {
                                costRow(stat: s.stat, text: s.text, source: s.source)
                            }
                        }
                    }
                    .padding(.top, 22)

                    Text(revealClosingLine)
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
            Group {
                // A sourced figure renders as the mono stat; a not-yet-sourced
                // row (empty stat) renders a spike glyph instead of a fake number.
                if stat.isEmpty {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.Colors.warmOrange)
                } else {
                    Text(stat)
                        .font(.system(size: 22, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Theme.Colors.warmOrange)
                }
            }
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
