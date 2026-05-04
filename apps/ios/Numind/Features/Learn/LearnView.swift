import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    @EnvironmentObject private var progressStore: ProgressStore

    // MARK: - Presentation state

    private struct LessonCard: Identifiable {
        let id: String
        let vm: LessonViewModel
    }
    @State private var selectedCard: LessonCard? = nil

    private struct ReviewCard: Identifiable {
        let id: String          // reviewId
        let lessonIds: [String]
        let module: Module
    }
    @State private var selectedReview: ReviewCard? = nil

    // MARK: - Layout constants

    private let nodeSize:        CGFloat = 64
    private let pathOffset:      CGFloat = 56   // horizontal distance from center
    private let connectorHeight: CGFloat = 48   // vertical height of curved connectors
    private let trailWidth:      CGFloat = 8    // connector stroke width

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections) { section in
                    worldBanner(section)
                    sectionNodes(section)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.refresh(using: progressStore) }
        .onChange(of: progressStore.totalSessions) {
            viewModel.refresh(using: progressStore)
        }
        .fullScreenCover(item: $selectedCard) { card in
            LessonView(viewModel: card.vm)
                .environmentObject(progressStore)
        }
        .fullScreenCover(item: $selectedReview) { review in
            CheckpointView(
                reviewId:        review.id,
                reviewLessonIds: review.lessonIds,
                module:          review.module
            )
            .environmentObject(progressStore)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - World Banner
    // ═══════════════════════════════════════════════════════════════

    private func worldBanner(_ section: LearnViewModel.PathSection) -> some View {
        let accent   = section.module.color.tintColor
        let tint     = section.module.color.tintBackground
        let mastered = section.nodes.filter { $0.state == .mastered }.count
        let total    = section.nodes.count

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent)
                    .frame(width: 48, height: 48)
                Image(systemName: section.module.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(section.module.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                Text("\(mastered)/\(total) completed")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accent.opacity(0.8))
            }
            Spacer()

            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: total > 0 ? CGFloat(mastered) / CGFloat(total) : 0)
                    .stroke(accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(tint)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(accent.opacity(0.15), lineWidth: 1.5)
        )
        .shadow(color: accent.opacity(0.12), radius: 12, y: 4)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Section Nodes
    // ═══════════════════════════════════════════════════════════════

    private func sectionNodes(_ section: LearnViewModel.PathSection) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(section.nodes.enumerated()), id: \.element.id) { i, node in
                VStack(spacing: 0) {
                    if i > 0 {
                        let prev = section.nodes[i - 1]
                        trailConnector(
                            fromLeft:   prev.isLeft,
                            toLeft:     node.isLeft,
                            isMastered: prev.state == .mastered,
                            accent:     node.module.color.tintColor
                        )
                    }
                    questNodeRow(node)
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Trail Connector (curved path)
    // ═══════════════════════════════════════════════════════════════

    private func trailConnector(
        fromLeft: Bool,
        toLeft: Bool,
        isMastered: Bool,
        accent: Color
    ) -> some View {
        GeometryReader { geo in
            let midX   = geo.size.width / 2
            let startX = midX + (fromLeft ? -pathOffset : pathOffset)
            let endX   = midX + (toLeft   ? -pathOffset : pathOffset)
            let h      = geo.size.height

            Path { path in
                path.move(to: CGPoint(x: startX, y: 0))
                path.addCurve(
                    to: CGPoint(x: endX, y: h),
                    control1: CGPoint(x: startX, y: h * 0.4),
                    control2: CGPoint(x: endX,   y: h * 0.6)
                )
            }
            .stroke(
                isMastered ? accent.opacity(0.35) : Theme.Colors.mutedTint,
                style: StrokeStyle(lineWidth: trailWidth, lineCap: .round)
            )
        }
        .frame(height: connectorHeight)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Quest Node Row
    // ═══════════════════════════════════════════════════════════════

    private func questNodeRow(_ node: LearnViewModel.PathNode) -> some View {
        let accent  = node.module.color.tintColor
        let xOffset = node.isLeft ? -pathOffset : pathOffset

        return VStack(spacing: 6) {
            questNodeCircle(node, accent: accent)
            questNodeLabel(node, accent: accent)
        }
        .offset(x: xOffset)
        .opacity(node.state == .locked ? 0.45 : 1.0)
        .padding(.vertical, 4)
        .contentShape(Rectangle().inset(by: -20))
        .onTapGesture {
            guard node.state != .locked else { return }
            presentLesson(for: node)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Quest Node Circle
    // ═══════════════════════════════════════════════════════════════

    private func questNodeCircle(_ node: LearnViewModel.PathNode, accent: Color) -> some View {
        let fill = nodeFill(node, accent: accent)

        return ZStack {
            // Pulsing ring for current node
            if node.state == .current {
                QuestPulsingRing(color: accent)
                    .frame(width: nodeSize + 22, height: nodeSize + 22)
            }

            // Coloured glow
            if node.state == .mastered || node.state == .current {
                Circle()
                    .fill(fill)
                    .frame(width: nodeSize, height: nodeSize)
                    .blur(radius: 10)
                    .opacity(0.3)
            }

            // Main circle
            Circle()
                .fill(fill)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle().strokeBorder(nodeBorder(node, accent: accent), lineWidth: 3)
                )
                .shadow(
                    color: node.state == .locked ? .clear : fill.opacity(0.2),
                    radius: 8, y: 4
                )

            // Icon
            nodeIcon(node, accent: accent)

            // Mastered badge + sparkles
            if node.state == .mastered {
                QuestMasteredBadge()
                QuestSparkles(accent: accent)
            }
        }
        .frame(width: nodeSize + 24, height: nodeSize + 24)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Quest Node Label
    // ═══════════════════════════════════════════════════════════════

    private func questNodeLabel(_ node: LearnViewModel.PathNode, accent: Color) -> some View {
        VStack(spacing: 3) {
            Text(node.displayTitle)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(node.state == .locked ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if node.state == .current {
                QuestStartBadge(accent: accent)
            } else {
                Text(nodeSubtitle(for: node))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(subtitleColor(for: node, accent: accent))
            }
        }
        .frame(width: 110)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Node Icon
    // ═══════════════════════════════════════════════════════════════

    @ViewBuilder
    private func nodeIcon(_ node: LearnViewModel.PathNode, accent: Color) -> some View {
        switch node.state {
        case .mastered:
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        case .attempted:
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        case .current:
            Image(systemName: node.isReview ? "books.vertical.fill" : node.module.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
        case .available:
            if node.isReview {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
            } else {
                Text("\(node.lessonIndexInModule + 1)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
            }
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Style Helpers
    // ═══════════════════════════════════════════════════════════════

    private func nodeFill(_ node: LearnViewModel.PathNode, accent: Color) -> Color {
        switch node.state {
        case .mastered:  return node.isReview ? Theme.Colors.insightYellow : accent
        case .current:   return node.isReview ? Theme.Colors.insightYellow : accent
        case .attempted: return Color.orange
        case .available: return Theme.Colors.cardBackground
        case .locked:    return Theme.Colors.mutedTint
        }
    }

    private func nodeBorder(_ node: LearnViewModel.PathNode, accent: Color) -> Color {
        switch node.state {
        case .mastered:  return node.isReview ? Theme.Colors.insightYellow : accent
        case .current:   return node.isReview ? Theme.Colors.insightYellow : accent
        case .attempted: return Color.orange
        case .available: return node.isReview ? Theme.Colors.insightYellow.opacity(0.5) : accent.opacity(0.4)
        case .locked:    return Theme.Colors.hairline
        }
    }

    private func nodeSubtitle(for node: LearnViewModel.PathNode) -> String {
        switch node.state {
        case .mastered:  return "Mastered ✓"
        case .attempted: return "Retry — need 75%"
        case .current:   return ""
        case .available: return "Available"
        case .locked:    return "Locked"
        }
    }

    private func subtitleColor(for node: LearnViewModel.PathNode, accent: Color) -> Color {
        switch node.state {
        case .mastered:           return accent
        case .attempted:          return Color.orange
        case .current:            return accent
        case .available, .locked: return Theme.Colors.mutedText
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Present Lesson / Review
    // ═══════════════════════════════════════════════════════════════

    private func presentLesson(for node: LearnViewModel.PathNode) {
        switch node.kind {
        case .lesson(let lesson):
            let repo = LocalContentRepository()
            let totalInModule = repo.lessons(for: node.module.id).count
            selectedCard = LessonCard(
                id: node.id,
                vm: LessonViewModel(
                    lesson: lesson,
                    moduleTitle: node.module.title,
                    lessonIndex: node.lessonIndexInModule,
                    totalLessons: totalInModule,
                    moduleColor: node.module.color
                )
            )
        case .review(let lessonIds):
            selectedReview = ReviewCard(
                id: node.id,
                lessonIds: lessonIds,
                module: node.module
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Supporting Views
// ═══════════════════════════════════════════════════════════════════

/// Pulsing ring animation behind the current quest node.
private struct QuestPulsingRing: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        Circle()
            .stroke(color.opacity(animating ? 0 : 0.35), lineWidth: animating ? 2 : 10)
            .scaleEffect(animating ? 1.45 : 1.0)
            .animation(
                .easeOut(duration: 1.1).repeatForever(autoreverses: false),
                value: animating
            )
            .onAppear { animating = true }
    }
}

/// Golden star badge shown on mastered nodes.
private struct QuestMasteredBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.insightYellow)
                .frame(width: 22, height: 22)
                .shadow(color: Theme.Colors.insightYellow.opacity(0.4), radius: 4, y: 2)
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
        }
        .offset(x: 22, y: -22)
    }
}

/// Small sparkle particles scattered near mastered nodes.
private struct QuestSparkles: View {
    let accent: Color

    var body: some View {
        Group {
            Image(systemName: "sparkle")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow.opacity(0.7))
                .offset(x: -30, y: -14)
            Image(systemName: "sparkle")
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(accent.opacity(0.45))
                .offset(x: 30, y: 16)
            Image(systemName: "sparkle")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow.opacity(0.5))
                .offset(x: -26, y: 20)
        }
    }
}

/// Bouncing "START" badge shown below the current node.
private struct QuestStartBadge: View {
    let accent: Color
    @State private var bouncing = false

    var body: some View {
        Text("START")
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(accent)
            .clipShape(Capsule())
            .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
            .offset(y: bouncing ? -2 : 2)
            .animation(
                .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                value: bouncing
            )
            .onAppear { bouncing = true }
    }
}

#Preview {
    NavigationStack {
        LearnView()
            .environmentObject(ProgressStore())
    }
}
