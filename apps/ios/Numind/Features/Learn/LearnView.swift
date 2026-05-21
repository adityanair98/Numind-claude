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

    private let nodeSize:        CGFloat = 70
    private let pathOffset:      CGFloat = 70   // horizontal distance from center
    private let connectorHeight: CGFloat = 56   // vertical height of curved connectors
    private let trailWidth:      CGFloat = 9    // connector stroke width

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                learnHeader
                ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { idx, section in
                    worldBanner(section, sectionIndex: idx)
                    sectionNodes(section)
                    worldConqueredBanner(section)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
    // MARK: - Learn Header
    // ═══════════════════════════════════════════════════════════════

    private var learnHeader: some View {
        // Count only lesson nodes — exclude review/checkpoint nodes so the
        // denominator matches the Practice tab's count.
        let totalMastered = viewModel.sections.reduce(0) { acc, section in
            acc + section.nodes.filter { !$0.isReview && $0.state == .mastered }.count
        }
        let totalLessons = viewModel.sections.reduce(0) { acc, section in
            acc + section.nodes.filter { !$0.isReview }.count
        }
        return LearnHeader(totalMastered: totalMastered, totalLessons: totalLessons)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - World Banner
    // ═══════════════════════════════════════════════════════════════

    private func worldBanner(_ section: LearnViewModel.PathSection, sectionIndex: Int) -> some View {
        let accent   = section.module.color.tintColor
        let tint     = section.module.color.tintBackground
        let lessonNodes = section.nodes.filter { !$0.isReview }
        let mastered = lessonNodes.filter { $0.state == .mastered }.count
        let total    = lessonNodes.count
        let pct      = total > 0 ? CGFloat(mastered) / CGFloat(total) : 0
        let isComplete = mastered == total && total > 0

        return ZStack {
            // Card background with gradient tint
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(accent.opacity(0.18), lineWidth: 1.5)
                )
                .shadow(color: accent.opacity(0.12), radius: 12, y: 4)

            // Decorative drift shapes
            driftShapes(accent: accent)

            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Eyebrow row: "World N" + optional "Conquered"
                HStack(spacing: 8) {
                    worldEyebrow(index: sectionIndex, accent: accent)
                    if isComplete {
                        conqueredBadge
                    }
                }

                HStack(spacing: 14) {
                    // Mascot emoji tile
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(accent)
                            .shadow(color: accent.opacity(0.45), radius: 8, y: 4)
                        Text(section.module.mascot)
                            .font(.system(size: 28))
                            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(section.module.title)
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .lineLimit(1)
                        Text(section.module.subtitle)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }

                    Spacer()

                    // Mini progress ring with fraction
                    miniProgressRing(mastered: mastered, total: total, pct: pct, accent: accent)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, sectionIndex == 0 ? 8 : 32)
        .padding(.bottom, 20)
    }

    private func worldEyebrow(index: Int, accent: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(accent)
            Text("World \(index + 1)")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(accent)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(accent.opacity(0.18))
        .clipShape(Capsule())
    }

    private var conqueredBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.Colors.insightText)
            Text("Conquered")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(Theme.Colors.insightText)
                .textCase(.uppercase)
                .tracking(0.4)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(Theme.Colors.insightYellowTint)
        .clipShape(Capsule())
    }

    private func miniProgressRing(mastered: Int, total: Int, pct: CGFloat, accent: Color) -> some View {
        ZStack {
            Circle()
                .stroke(accent.opacity(0.18), lineWidth: 3.5)
            Circle()
                .trim(from: 0, to: pct)
                .stroke(accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            HStack(spacing: 0) {
                Text("\(mastered)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(accent)
                Text("/\(total)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(accent)
            }
        }
        .frame(width: 38, height: 38)
    }

    private func driftShapes(accent: Color) -> some View {
        ZStack(alignment: .topTrailing) {
            // Top-right drift circle
            Circle()
                .fill(accent.opacity(0.08))
                .frame(width: 60, height: 60)
                .offset(x: 8, y: -12)

            // Bottom-left drift circle
            Circle()
                .fill(accent.opacity(0.06))
                .frame(width: 80, height: 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(x: -20, y: 30)
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .allowsHitTesting(false)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - World Conquered Banner
    // ═══════════════════════════════════════════════════════════════

    @ViewBuilder
    private func worldConqueredBanner(_ section: LearnViewModel.PathSection) -> some View {
        let mastered = section.nodes.filter { $0.state == .mastered }.count
        let total = section.nodes.count
        if mastered == total && total > 0 {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("WORLD CONQUERED")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(0.5)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Theme.Colors.insightYellow, Theme.Colors.warmOrange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Theme.Colors.warmOrange.opacity(0.4), radius: 8, y: 4)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Section Nodes
    // ═══════════════════════════════════════════════════════════════

    private func sectionNodes(_ section: LearnViewModel.PathSection) -> some View {
        ZStack {
            // Floating decorative numbers in margins
            floatingDecorations(module: section.module, nodeCount: section.nodes.count)

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
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Floating Decorations
    // ═══════════════════════════════════════════════════════════════

    private func floatingDecorations(module: Module, nodeCount: Int) -> some View {
        let accent = module.color.tintColor
        let totalH = CGFloat(nodeCount) * (nodeSize + 24 + 30) + CGFloat(max(0, nodeCount - 1)) * connectorHeight
        return ZStack {
            floatingNumber(module.glyph, color: accent, size: 36, x: 20, relY: 0.08)
            floatingNumber("42", color: accent, size: 20, x: UIScreen.main.bounds.width - 50, relY: 0.22)
            floatingNumber("\u{00BD}", color: accent, size: 28, x: 28, relY: 0.48)
            floatingNumber(module.glyph, color: accent, size: 22, x: UIScreen.main.bounds.width - 40, relY: 0.72)
        }
        .frame(height: max(totalH, 200))
        .allowsHitTesting(false)
    }

    private func floatingNumber(_ text: String, color: Color, size: CGFloat, x: CGFloat, relY: CGFloat) -> some View {
        GeometryReader { geo in
            Text(text)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(color.opacity(0.16))
                .position(x: x, y: geo.size.height * relY)
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
                isMastered ? accent.opacity(0.45) : Theme.Colors.mutedTint,
                style: StrokeStyle(
                    lineWidth: trailWidth,
                    lineCap: .round,
                    dash: isMastered ? [] : [2, 14]
                )
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
        .opacity(node.state == .locked ? 0.5 : 1.0)
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
                QuestPulsingRing(color: node.isReview ? Theme.Colors.insightYellow : accent)
                    .frame(width: nodeSize + 30, height: nodeSize + 30)
            }

            // Coloured glow
            if node.state == .mastered || node.state == .current {
                Circle()
                    .fill(fill)
                    .frame(width: nodeSize, height: nodeSize)
                    .blur(radius: 12)
                    .opacity(0.35)
            }

            // Main circle
            Circle()
                .fill(fill)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle().strokeBorder(nodeBorder(node, accent: accent), lineWidth: 3.5)
                )
                .shadow(
                    color: node.state == .locked ? .clear : fill.opacity(0.35),
                    radius: 8, y: 4
                )

            // Icon
            nodeIcon(node, accent: accent)

            // Mastered badge + sparkles
            if node.state == .mastered {
                QuestMasteredBadge()
                QuestSparkles(accent: accent)
            }

            // Review crown badge (non-locked, non-mastered)
            if node.isReview && node.state != .locked && node.state != .mastered {
                QuestCrownBadge()
            }
        }
        .frame(width: nodeSize + 30, height: nodeSize + 30)
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
                QuestStartBadge(
                    accent: node.isReview ? Theme.Colors.insightYellow : accent,
                    label: node.isReview ? "BOSS" : "START",
                    textColor: node.isReview ? Theme.Colors.insightText : .white
                )
            } else {
                Text(nodeSubtitle(for: node))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(subtitleColor(for: node, accent: accent))
                    .textCase(.uppercase)
                    .tracking(0.4)
            }
        }
        .frame(width: 130)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Node Icon
    // ═══════════════════════════════════════════════════════════════

    @ViewBuilder
    private func nodeIcon(_ node: LearnViewModel.PathNode, accent: Color) -> some View {
        switch node.state {
        case .mastered:
            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        case .attempted:
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        case .current:
            if node.isReview {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
        case .available:
            if node.isReview {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent)
            } else {
                Text("\(node.lessonIndexInModule + 1)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
            }
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 20, weight: .semibold))
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
        case .mastered:  return "Mastered \u{2713}"
        case .attempted: return "Retry for \u{2B50}"
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
        ZStack {
            Circle()
                .stroke(color.opacity(animating ? 0 : 0.55), lineWidth: animating ? 2 : 3)
                .scaleEffect(animating ? 1.5 : 1.0)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: animating
                )
            Circle()
                .stroke(color.opacity(animating ? 0 : 0.35), lineWidth: animating ? 2 : 2)
                .scaleEffect(animating ? 1.5 : 1.0)
                .animation(
                    .easeOut(duration: 1.6).delay(0.4).repeatForever(autoreverses: false),
                    value: animating
                )
        }
        .onAppear { animating = true }
    }
}

/// Golden star badge shown on mastered nodes.
private struct QuestMasteredBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.insightYellow)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )
                .shadow(color: Theme.Colors.insightYellow.opacity(0.5), radius: 4, y: 2)
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .offset(x: 24, y: -24)
    }
}

/// Crown badge shown on review nodes that are available/current.
private struct QuestCrownBadge: View {
    var body: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Theme.Colors.insightYellow)
            .offset(y: -44)
    }
}

/// Small sparkle particles scattered near mastered nodes.
private struct QuestSparkles: View {
    let accent: Color

    var body: some View {
        Group {
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow.opacity(0.7))
                .offset(x: -32, y: -14)
            Image(systemName: "sparkle")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(accent.opacity(0.45))
                .offset(x: 32, y: 16)
            Image(systemName: "sparkle")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Theme.Colors.insightYellow.opacity(0.5))
                .offset(x: -28, y: 22)
        }
    }
}

/// Bouncing badge shown below the current node.
private struct QuestStartBadge: View {
    let accent: Color
    let label: String
    let textColor: Color
    @State private var bouncing = false

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(accent)
            .clipShape(Capsule())
            .shadow(color: accent.opacity(0.4), radius: 6, y: 3)
            .offset(y: bouncing ? -3 : 0)
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
