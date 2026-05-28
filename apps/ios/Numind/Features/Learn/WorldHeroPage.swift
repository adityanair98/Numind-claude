import SwiftUI

/// A single full-screen "world hero" page in the Learn → Worlds carousel.
///
/// Inspired by Brilliant's course carousel: each world fills the screen with
/// a themed illustration, title, world-N label, and a "Continue" card at
/// the bottom showing the user's next undone lesson. Swipe left/right (via
/// the parent TabView page style) to switch worlds. Tap Continue to push
/// into that world's quest map.
struct WorldHeroPage: View {
    @EnvironmentObject private var progressStore: ProgressStore
    let section: LearnViewModel.PathSection
    let worldNumber: Int
    /// Action invoked when the user taps the Continue CTA. Parent owns the
    /// navigation so the carousel stays in one place.
    let onContinue: (LearnViewModel.PathNode) -> Void

    private var module: Module { section.module }
    private var accent: Color { module.color.tintColor }

    private var lessonNodes: [LearnViewModel.PathNode] {
        section.nodes.filter { !$0.isReview }
    }
    private var masteredCount: Int {
        lessonNodes.filter { $0.state == .mastered }.count
    }
    private var totalLessons: Int { lessonNodes.count }
    private var isConquered: Bool {
        totalLessons > 0 && masteredCount == totalLessons
    }

    /// The lesson the Continue CTA should launch:
    /// 1. The `.current` node if present (Recommendation Engine's pick)
    /// 2. Otherwise the first non-mastered lesson
    /// 3. Falls back to the first lesson (for a fully-conquered world,
    ///    so the CTA still works as a "revisit" path)
    private var continueNode: LearnViewModel.PathNode? {
        if let current = section.nodes.first(where: { $0.state == .current }) {
            return current
        }
        if let next = lessonNodes.first(where: { $0.state != .mastered }) {
            return next
        }
        return lessonNodes.first
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            heroSection
            Spacer(minLength: 0)
            continueCard
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    accent.opacity(0.18),
                    accent.opacity(0.04),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 18) {
            Text("WORLD \(worldNumber)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(accent)
                .kerning(1.2)

            Text(module.title)
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.deepNavy)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(module.subtitle)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)

            // Themed illustration — composed from Module fields rather than
            // bespoke artwork: a tinted accent circle + the module's SF Symbol.
            // (Phase 6c: dropped the math-coded glyph watermark + mascot
            // overlay; mascot/glyph are reserved for celebration sheets now.)
            illustration
                .frame(width: 240, height: 240)
                .padding(.top, 4)
        }
    }

    private var illustration: some View {
        ZStack {
            // Outer ring + tinted fill
            Circle()
                .fill(accent.opacity(0.14))
                .overlay(
                    Circle()
                        .strokeBorder(accent.opacity(0.28), lineWidth: 2)
                )

            // Module SF Symbol
            Image(systemName: module.icon)
                .font(.system(size: 92, weight: .semibold))
                .foregroundStyle(accent)
        }
    }

    // MARK: - Continue card

    @ViewBuilder
    private var continueCard: some View {
        if isConquered {
            conqueredCard
        } else if let node = continueNode, let lesson = node.lesson {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.14))
                            .frame(width: 36, height: 36)
                        Image(systemName: node.state == .mastered
                              ? "checkmark"
                              : "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(continueLabel(for: node))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                            .kerning(0.6)
                        Text(lesson.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(masteredCount)/\(totalLessons)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                Button(action: { onContinue(node) }) {
                    Text(node.state == .current || node.state == .attempted
                         ? "Continue world"
                         : "Start world")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        }
    }

    private func continueLabel(for node: LearnViewModel.PathNode) -> String {
        switch node.state {
        case .current:        return "PICK UP HERE"
        case .attempted:      return "RESUME"
        case .available:      return "UP NEXT"
        case .mastered:       return "REVISIT"
        case .notYetSuggested: return "JUMP AHEAD"
        }
    }

    private var conqueredCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Colors.insightYellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("WORLD CONQUERED")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.Colors.insightText)
                        .kerning(0.6)
                    Text("Every lesson at 75%+")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                }
                Spacer()
                Text("\(masteredCount)/\(totalLessons)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.insightText)
            }

            // "Review this world" — opens the quest map to revisit any lesson.
            // 7a upgrades this to fire an 8Q quiz scoped to mastered lessons
            // (shared machinery with the "Practice this world" quest-map pill).
            if let node = continueNode {
                Button(action: { onContinue(node) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                        Text("Review this world")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Theme.Colors.insightYellowTint)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
