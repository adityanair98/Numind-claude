import SwiftUI

/// Modal sheet that lists all available Life-Event Paths with a status
/// badge (FOCUS / ACTIVE / COMPLETE / NEW). Tap any pack to open its
/// `PackDetailView`. Pack focus is a deliberate commitment, so tapping a
/// non-focus pack first prompts the user to decide between "Make focus"
/// and "Just take next lesson" — the latter opens the pack detail without
/// disturbing the existing focus.
struct PackPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore

    @State private var presented: Pack?
    @State private var pendingPack: Pack?

    private let repo = LocalContentRepository()
    private var packs: [Pack] { repo.allPacks() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(packs) { pack in
                        packCard(pack)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.sectionSpacing)
            }
            .background(Theme.Colors.softBackground.ignoresSafeArea())
            .navigationTitle("Pick a path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
            }
        }
        .sheet(item: $presented) { pack in
            PackDetailView(pack: pack)
                .environmentObject(progressStore)
        }
        .confirmationDialog(
            pendingPack.map { "Switch focus to \($0.title)?" } ?? "Switch focus?",
            isPresented: Binding(
                get: { pendingPack != nil },
                set: { if !$0 { pendingPack = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Make this my focus") {
                if let pack = pendingPack {
                    progressStore.setFocusPack(pack.id)
                    presented = pack
                    pendingPack = nil
                }
            }
            Button("Just take next lesson") {
                if let pack = pendingPack {
                    presented = pack
                    pendingPack = nil
                }
            }
            Button("Cancel", role: .cancel) { pendingPack = nil }
        } message: {
            Text("Your current focus stays put. Switching focus changes which path drives your daily workout.")
        }
    }

    private func packCard(_ pack: Pack) -> some View {
        let progress = progressStore.packProgress(packId: pack.id)
        let isFocus = progressStore.focusPackId == pack.id
        let isComplete = progress.done == progress.total && progress.total > 0
        let isActive = progress.done > 0 && !isComplete
        let badge: PackBadge =
            isFocus ? .focus :
            isComplete ? .complete :
            isActive ? .active(done: progress.done, total: progress.total) :
            .new

        return Button(action: { tap(pack: pack) }) {
            NumindCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(pack.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        badgeView(badge)
                    }
                    Text(pack.tagline)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 10) {
                        chip("\(pack.lessonIds.count) lessons")
                        chip("~\(pack.estimatedMinutes) min")
                    }
                    .padding(.top, 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func tap(pack: Pack) {
        let isFocus = progressStore.focusPackId == pack.id
        let focusIsSet = progressStore.focusPackId != nil
        if isFocus || !focusIsSet {
            // No competing focus — just open.
            if !focusIsSet {
                // Make this the focus if the user has none yet.
                progressStore.setFocusPack(pack.id)
            }
            presented = pack
        } else {
            // There's already a different focus — ask first.
            pendingPack = pack
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.Colors.mutedTint)
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func badgeView(_ badge: PackBadge) -> some View {
        switch badge {
        case .focus:
            badgePill(text: "FOCUS", fg: .white, bg: Theme.Colors.deepNavy)
        case .complete:
            badgePill(text: "COMPLETE ✓", fg: Theme.Colors.growthGreen, bg: Theme.Colors.growthGreenTint)
        case .active(let done, let total):
            badgePill(text: "ACTIVE \(done)/\(total)", fg: Theme.Colors.mindTeal, bg: Theme.Colors.mindTealTint)
        case .new:
            badgePill(text: "NEW", fg: Theme.Colors.insightText, bg: Theme.Colors.insightYellowTint)
        }
    }

    private func badgePill(text: String, fg: Color, bg: Color) -> some View {
        Text(text)
            .font(Theme.Typography.small)
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .clipShape(Capsule())
    }
}

private enum PackBadge {
    case focus
    case complete
    case active(done: Int, total: Int)
    case new
}
