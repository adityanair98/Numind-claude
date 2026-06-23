import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    private let modules = LocalContentRepository().allModules()
    private let repo = LocalContentRepository()
    private let weekDayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    @State private var showProfile = false

    var body: some View {
        Group {
            if store.totalSessions == 0 {
                emptyState
            } else {
                filledContent
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showProfile = false }
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.primaryBlue)
                        }
                    }
            }
            .environmentObject(store)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Header
    // ═══════════════════════════════════════════════════════════════

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()
                Button {
                    showProfile = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.cardBackground)
                            .frame(width: 36, height: 36)
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .buttonStyle(.plain)
            }

            // H1 + ember streak chip (the streak lives in the glyph — no navy
            // hero, per the Phase 13 streak rule).
            HStack(alignment: .center) {
                Text("Progress")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                if store.streak > 0 { emberStreakChip }
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    private var emberStreakChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.Colors.ember)
            Text("\(store.streak)")
                .font(Theme.Typography.monoSmall)
                .foregroundStyle(Theme.Colors.deepNavy)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(Theme.Colors.emberTint)
        .clipShape(Capsule())
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressHeader
                Spacer(minLength: 80)
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryBlueTint)
                        .frame(width: 96, height: 96)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.Colors.primaryBlue)
                }
                VStack(spacing: 8) {
                    Text("No sessions yet")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Complete your first lesson to\nsee your progress here.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                Spacer(minLength: 100)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Filled content

    private var filledContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                progressHeader

                // This week — practice days as a 7-bar chart (teal active days,
                // today a short bar with a teal ring). Capability framing, not a
                // score. Replaces the navy streak hero + clinical XP charts.
                practiceChartCard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 18)

                // Skills ledger — two cards: Mastered (teal) + To refresh
                // (muted). Mono counts, no Level/XP, no 0–100.
                skillsLedgerRow
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                // "You can now handle:" — plain-language mastered decisions.
                canNowHandleSection

                // Path readiness — the honest, decision-scoped competence
                // signal per pack (Not started → Learning → Almost ready →
                // Ready → Sharp).
                sectionLabel("Path readiness")
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 10)
                packReadinessBoard
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, 22)

                // Paths in progress — packs touched but not finished, each with
                // a thin progress bar. Hidden when nothing is in progress.
                let inProgressPacks = store.inProgressPacks
                if !inProgressPacks.isEmpty {
                    sectionLabel("Paths in progress")
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 10)
                    pathsInProgressCard(packs: inProgressPacks)
                        .padding(.horizontal, Theme.Spacing.screenHorizontal)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - This week (practice chart — Phase 13)
    // ═══════════════════════════════════════════════════════════════

    /// 7 day bars, Mon–Sun: neutral track, teal fill on a completed day,
    /// today a short bar with a teal ring. Mirrors handoff screen 11.
    private var practiceChartCard: some View {
        let comp = store.weeklyCompletions
        let doneDays = comp.prefix(7).filter { $0 }.count
        let todayIndex = Calendar.current.component(.weekday, from: Date())
        let todayMon = (todayIndex + 5) % 7   // Sun=1…Sat=7 → Mon=0…Sun=6
        let barMax: CGFloat = 64

        return NumindCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("This week")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(doneDays)")
                            .font(Theme.Typography.mono)
                            .foregroundStyle(Theme.Colors.mindTeal)
                        Text("of 7 days")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { i in
                        let isDone = comp.indices.contains(i) ? comp[i] : false
                        let isToday = i == todayMon
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Theme.Colors.track)
                                    .frame(height: barMax)
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(isDone ? Theme.Colors.mindTeal : Theme.Colors.track)
                                    .frame(height: isDone ? barMax : (isToday ? 22 : 8))
                            }
                            .frame(height: barMax)
                            .overlay {
                                if isToday {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .strokeBorder(Theme.Colors.mindTeal, lineWidth: 2)
                                }
                            }
                            Text(weekDayLabels[i])
                                .font(.system(size: 10, weight: isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? Theme.Colors.mindTeal : Theme.Colors.mutedText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Skills ledger (Phase 13 — two cards, mono counts)
    // ═══════════════════════════════════════════════════════════════

    private var skillsLedgerRow: some View {
        // masteredLessonIds is already real-curriculum-only (no review_/synthetic
        // ids), so no filtering needed (audit fix #05 — dropped inert filter).
        let mastered = store.masteredLessonIds.count
        let stale = store.staleSkillCount
        return HStack(spacing: 12) {
            NavigationLink(destination: SkillDetailView()) {
                ledgerCard(icon: "checkmark", tint: Theme.Colors.mindTeal,
                           tintBg: Theme.Colors.mindTealTint, value: mastered, label: "Mastered")
            }
            .buttonStyle(.plain)
            ledgerCard(icon: "arrow.counterclockwise", tint: Theme.Colors.refreshNeutral,
                       tintBg: Theme.Colors.track, value: stale, label: "To refresh")
        }
    }

    private func ledgerCard(icon: String, tint: Color, tintBg: Color,
                            value: Int, label: String) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tintBg)
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(value)")
                        .font(Theme.Typography.moneyLarge)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(label)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Path readiness board (Phase 9)
    // ═══════════════════════════════════════════════════════════════

    /// Every pack with its Readiness state + (when Almost ready) the single
    /// next action that would advance it. The decision-scoped competence
    /// surface that replaced the global composite.
    private var packReadinessBoard: some View {
        PackReadinessBoard(rows: repo.allPacks().map {
            PackReadinessBoard.Row(id: $0.id, title: $0.title, state: store.readiness(for: $0))
        })
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - You can now handle (Phase 6c)
    // ═══════════════════════════════════════════════════════════════

    /// Up to 5 plain-language money decisions the user has mastered, pulled
    /// from mastered lessons' realWorldHints (module order keeps it stable).
    private var masteredHandleHints: [String] {
        let mastered = store.masteredLessonIds
        var seen = Set<String>()
        var hints: [String] = []
        for module in modules {
            for lesson in repo.lessons(for: module.id) where mastered.contains(lesson.id) {
                if let h = lesson.realWorldHint, !seen.contains(h) {
                    seen.insert(h); hints.append(h)
                }
            }
        }
        return Array(hints.prefix(5))
    }

    @ViewBuilder
    private var canNowHandleSection: some View {
        let hints = masteredHandleHints
        if !hints.isEmpty {
            NumindCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.Colors.growthGreen)
                        Text("YOU CAN NOW HANDLE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .kerning(0.6)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(hints.enumerated()), id: \.offset) { _, hint in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.growthGreen)
                                    .padding(.top, 1)
                                Text(hint)
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Colors.deepNavy.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, 22)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Paths in progress
    // ═══════════════════════════════════════════════════════════════

    /// Shows each in-progress pack as a row with title + tagline +
    /// `done / total · ▓▓▓░░` progress bar. Read-only; tapping a row is
    /// out of scope here (use Home or the Learn → Paths tab).
    private func pathsInProgressCard(packs: [Pack]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(packs.enumerated()), id: \.element.id) { i, pack in
                pathProgressRow(pack: pack, isLast: i == packs.count - 1)
            }
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }

    private func pathProgressRow(pack: Pack, isLast: Bool) -> some View {
        let progress = store.packProgress(packId: pack.id)
        let isFocus = store.focusPackId == pack.id
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(pack.title)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.deepNavy)
                Spacer()
                if isFocus {
                    Text("FOCUS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.deepNavy)
                        .clipShape(Capsule())
                }
                Text("\(progress.done) of \(progress.total)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
            BeadRail(progress: progress.done, total: progress.total, variant: .chunky)
            if !isLast {
                Divider()
                    .background(Theme.Colors.hairline)
            }
        }
        .padding(Theme.Spacing.cardPadding)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(Theme.Colors.mutedText)
            .tracking(1.2)
    }
}

#Preview {
    NavigationStack {
        ProgressTabView()
            .environmentObject(ProgressStore())
    }
}
