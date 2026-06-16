import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    @EnvironmentObject private var progressStore: ProgressStore

    // MARK: - Presentation state

    /// Top-level segmented tab inside the Learn tab. Explore = module-by-module
    /// topic library (Phase 10: quest framing retired). Paths = curated
    /// Life-Event Packs grid.
    private enum LearnTab: Hashable { case worlds, paths }
    @State private var selectedTab: LearnTab = .worlds

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

    @State private var presentedPack: Pack? = nil

    /// Currently-visible page in the Worlds carousel. 0-indexed across
    /// `viewModel.sections`. Defaults to the section containing the
    /// "current" lesson node so a fresh user lands on the right world.
    @State private var currentWorldIndex: Int = 0
    @State private var carouselInitialized = false

    /// Set when a world's Continue CTA is tapped. While non-nil the carousel
    /// is hidden and the quest map for that world fills the tab. A back
    /// chevron in the header dismisses it back to the carousel. Avoids
    /// extracting all the quest map helpers out of LearnView.
    @State private var openedWorldId: String? = nil

    // MARK: - Layout constants

    private let nodeSize:        CGFloat = 70
    private let pathOffset:      CGFloat = 70   // horizontal distance from center
    private let connectorHeight: CGFloat = 56   // vertical height of curved connectors
    private let trailWidth:      CGFloat = 9    // connector stroke width

    var body: some View {
        VStack(spacing: 0) {
            // When a world is "opened" (Continue tapped from the carousel),
            // hide the header + segmented control to give the quest map
            // full vertical real estate. A floating back chevron lets the
            // user return to the carousel.
            if openedWorldId == nil {
                learnHeader
                tabSegmentedControl
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
            }

            switch selectedTab {
            case .worlds:
                if let id = openedWorldId,
                   let section = viewModel.sections.first(where: { $0.id == id }),
                   let idx = viewModel.sections.firstIndex(where: { $0.id == id }) {
                    openedWorldView(section: section, sectionIndex: idx)
                } else {
                    worldsCarousel
                }
            case .paths:
                pathsScroll
            }
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.refresh(using: progressStore)
            if !carouselInitialized {
                currentWorldIndex = defaultWorldIndex()
                carouselInitialized = true
            }
        }
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
        .sheet(item: $presentedPack) { pack in
            PackDetailView(pack: pack)
                .environmentObject(progressStore)
        }
    }

    // MARK: - Worlds carousel (Brilliant-style page swipe)

    private var worldsCarousel: some View {
        TabView(selection: $currentWorldIndex) {
            ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { idx, section in
                WorldHeroPage(
                    section: section,
                    onContinue: { _ in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            openedWorldId = section.id
                        }
                    }
                )
                .tag(idx)
                .environmentObject(progressStore)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    /// Renders the existing worldBanner + sectionNodes + worldConqueredBanner
    /// for a single section as a full-screen view with a back-chevron row at
    /// the top to return to the carousel. Mirrors the Brilliant world-detail
    /// pattern.
    private func openedWorldView(
        section: LearnViewModel.PathSection,
        sectionIndex: Int
    ) -> some View {
        VStack(spacing: 0) {
            // Back-chevron row — sits ABOVE the scrolling content so it
            // never overlaps the topic banner's eyebrow.
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        openedWorldId = nil
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .frame(width: 40, height: 40)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                }
                .accessibilityLabel("Back to topics")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ScrollView {
                LazyVStack(spacing: 0) {
                    worldBanner(section, sectionIndex: sectionIndex)
                    sectionNodes(section)
                    worldConqueredBanner(section)
                }
                .padding(.bottom, 40)
            }
        }
    }

    /// Default starting page = section containing the .current node;
    /// falls back to the first section.
    private func defaultWorldIndex() -> Int {
        if let idx = viewModel.sections.firstIndex(where: { section in
            section.nodes.contains(where: { $0.state == .current })
        }) { return idx }
        return 0
    }

    private var pathsScroll: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                pathsList
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Tab segmented control

    private var tabSegmentedControl: some View {
        Picker("View", selection: $selectedTab) {
            Text("Explore").tag(LearnTab.worlds)
            Text("Paths").tag(LearnTab.paths)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Paths list

    private var pathsList: some View {
        let repo = LocalContentRepository()
        let packs = repo.allPacks()
        return VStack(spacing: 12) {
            ForEach(packs) { pack in
                pathCard(pack: pack)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func pathCard(pack: Pack) -> some View {
        let progress = progressStore.packProgress(packId: pack.id)
        let isFocus = progressStore.focusPackId == pack.id
        let isComplete = progress.done == progress.total && progress.total > 0
        let isActive = progress.done > 0 && !isComplete

        Button(action: { presentedPack = pack }) {
            NumindCard(background: isFocus ? Theme.Colors.mindTealTint : Theme.Colors.cardBackground) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(pack.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if isFocus {
                            Text("FOCUS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.Colors.deepNavy)
                                .clipShape(Capsule())
                        } else if isComplete {
                            Text("✓")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.Colors.growthGreen)
                        } else if isActive {
                            Text("\(progress.done)/\(progress.total)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.Colors.mindTeal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.Colors.mindTealTint)
                                .clipShape(Capsule())
                        }
                    }
                    Text(pack.tagline)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 10) {
                        Text("\(pack.lessonIds.count) lessons")
                        Text("·")
                        Text("~\(pack.estimatedMinutes) min")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
        .buttonStyle(.plain)
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
                // Eyebrow row: topic name + optional "Complete"
                HStack(spacing: 8) {
                    topicEyebrow(module: section.module, accent: accent)
                    if isComplete {
                        completeBadge
                    }
                }

                HStack(spacing: 14) {
                    // Module icon tile (Phase 10: mascot emoji reserved for
                    // celebration sheets, not the everyday library)
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(accent)
                            .shadow(color: accent.opacity(0.45), radius: 8, y: 4)
                        Image(systemName: section.module.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
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

    private func topicEyebrow(module: Module, accent: Color) -> some View {
        Text(module.shortName)
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(accent)
            .textCase(.uppercase)
            .tracking(0.6)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(accent.opacity(0.18))
            .clipShape(Capsule())
    }

    private var completeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.Colors.insightText)
            Text("Complete")
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
    // MARK: - Topic Complete Banner
    // ═══════════════════════════════════════════════════════════════

    @ViewBuilder
    private func worldConqueredBanner(_ section: LearnViewModel.PathSection) -> some View {
        let mastered = section.nodes.filter { $0.state == .mastered }.count
        let total = section.nodes.count
        if mastered == total && total > 0 {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("TOPIC COMPLETE")
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
        // Phase 5e soft locks: not-yet-suggested lessons render dimmed but
        // remain tappable; only reviews stay gated (handled in presentLesson).
        .opacity(node.state == .notYetSuggested ? 0.55 : 1.0)
        .scaleEffect(node.state == .notYetSuggested ? 0.92 : 1.0)
        .padding(.vertical, 4)
        .contentShape(Rectangle().inset(by: -20))
        .onTapGesture {
            // Review nodes remain gated: a review of unfinished lessons isn't
            // meaningful, so we keep the hard gate. Lessons are always tappable.
            if node.isReview && node.state == .notYetSuggested { return }
            presentLesson(for: node)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Quest Node Circle
    // ═══════════════════════════════════════════════════════════════

    private func questNodeCircle(_ node: LearnViewModel.PathNode, accent: Color) -> some View {
        let fill = nodeFill(node, accent: accent)

        return ZStack {
            // Static halo for the current node (Phase 10: pulsing retired)
            if node.state == .current {
                Circle()
                    .stroke(
                        (node.isReview ? Theme.Colors.insightYellow : accent).opacity(0.35),
                        lineWidth: 3
                    )
                    .frame(width: nodeSize + 18, height: nodeSize + 18)
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
                    color: node.state == .notYetSuggested ? .clear : fill.opacity(0.35),
                    radius: 8, y: 4
                )

            // Icon
            nodeIcon(node, accent: accent)

            // Mastered badge (sparkles dropped in 6c — reserve celebration
            // flourishes for completion sheets, not the everyday quest map)
            if node.state == .mastered {
                QuestMasteredBadge()
            }

            // Review badge (still gated for review nodes — only shown
            // when the review is actually available)
            if node.isReview && node.state != .notYetSuggested && node.state != .mastered {
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
                .foregroundStyle(node.state == .notYetSuggested ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if node.state == .current {
                QuestStartBadge(
                    accent: node.isReview ? Theme.Colors.insightYellow : accent,
                    label: node.isReview ? "REVIEW" : "NEXT",
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
        case .notYetSuggested:
            // Soft lock: show the lesson number/icon dimmed (the parent View
            // applies opacity/scale) rather than a lock icon. The user can
            // still tap to jump ahead.
            if node.isReview {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mutedText)
            } else {
                Text("\(node.lessonIndexInModule + 1)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.mutedText)
            }
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
        case .notYetSuggested: return Theme.Colors.mutedTint
        }
    }

    private func nodeBorder(_ node: LearnViewModel.PathNode, accent: Color) -> Color {
        switch node.state {
        case .mastered:  return node.isReview ? Theme.Colors.insightYellow : accent
        case .current:   return node.isReview ? Theme.Colors.insightYellow : accent
        case .attempted: return Color.orange
        case .available: return node.isReview ? Theme.Colors.insightYellow.opacity(0.5) : accent.opacity(0.4)
        case .notYetSuggested: return Theme.Colors.hairline
        }
    }

    private func nodeSubtitle(for node: LearnViewModel.PathNode) -> String {
        switch node.state {
        case .mastered:  return "Mastered \u{2713}"
        case .attempted: return "Retry for \u{2B50}"
        case .current:   return ""
        case .available: return "Available"
        case .notYetSuggested: return node.isReview ? "Locked" : "Jump ahead"
        }
    }

    private func subtitleColor(for node: LearnViewModel.PathNode, accent: Color) -> Color {
        switch node.state {
        case .mastered:           return accent
        case .attempted:          return Color.orange
        case .current:            return accent
        case .available, .notYetSuggested: return Theme.Colors.mutedText
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

/// Review-affordance badge shown on review nodes that are available/current.
/// (Phase 10: crown retired with the quest framing.)
private struct QuestCrownBadge: View {
    var body: some View {
        Image(systemName: "arrow.counterclockwise.circle.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Theme.Colors.insightYellow)
            .offset(y: -44)
    }
}

/// Static accent-filled badge shown below the current node.
/// (6c: dropped the bouncing animation — steadier, less game-y.)
private struct QuestStartBadge: View {
    let accent: Color
    let label: String
    let textColor: Color

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(accent)
            .clipShape(Capsule())
            .shadow(color: accent.opacity(0.4), radius: 6, y: 3)
    }
}

#Preview {
    NavigationStack {
        LearnView()
            .environmentObject(ProgressStore())
    }
}
