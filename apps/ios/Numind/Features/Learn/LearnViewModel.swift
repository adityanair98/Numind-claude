import Foundation

@MainActor
final class LearnViewModel: ObservableObject {

    // MARK: - Path model

    struct PathNode: Identifiable {

        /// Distinguishes regular lesson nodes from review/checkpoint nodes.
        enum NodeKind {
            case lesson(Lesson)
            /// IDs of the lessons this review covers (used to build questions).
            case review(lessonIds: [String])
        }

        /// - mastered:  quiz passed at ≥ 75% — gold star (aspirational)
        /// - attempted: quiz attempted but < 75% — completed, unlocks next
        /// - current:   first unlocked-unattempted node — pulsing ring
        /// - available: unlocked but not the recommended next
        /// - locked:    previous lesson/review not yet attempted
        enum NodeState { case mastered, attempted, current, available, locked }

        let id: String
        let kind: NodeKind
        let module: Module
        let state: NodeState
        /// true = even global index → node sits on the left side of the path
        let isLeft: Bool
        /// Draw a connector line from this node down to the next one in the section
        var hasTrailingLine: Bool
        /// 0-based lesson position in the module (reviews use review group number)
        let lessonIndexInModule: Int

        // MARK: Convenience

        var lesson: Lesson? {
            guard case .lesson(let l) = kind else { return nil }
            return l
        }
        var reviewLessonIds: [String] {
            guard case .review(let ids) = kind else { return [] }
            return ids
        }
        var isReview: Bool {
            if case .review = kind { return true }
            return false
        }
        var displayTitle: String {
            switch kind {
            case .lesson(let l): return l.title
            case .review:        return "Module Review"
            }
        }
    }

    struct PathSection: Identifiable {
        let id: String
        let module: Module
        let nodes: [PathNode]
    }

    // MARK: - Published

    @Published private(set) var sections: [PathSection] = []

    // MARK: - Private

    private let repo: ContentRepository

    /// How many lessons between review checkpoints.
    static let reviewInterval = 3

    init(repository: ContentRepository = LocalContentRepository()) {
        self.repo = repository
    }

    // MARK: - Build

    func refresh(using store: ProgressStore) {
        let modules = repo.allModules()
        var globalIndex = 0
        var foundCurrent = false
        var built: [PathSection] = []

        for module in modules {
            let lessons = repo.lessons(for: module.id)
            var nodes: [PathNode] = []

            for (i, lesson) in lessons.enumerated() {
                // ── Lesson node ──────────────────────────────────────────
                let mastered     = store.hasMasteredLesson(lesson.id)
                let attempted    = store.hasCompletedLesson(lesson.id)
                // Unlock requires completing (any score), not mastering (≥75%).
                // Mastery is now aspirational (gold star) — SRS handles remediation.
                let prevCompleted = i == 0 || store.hasCompletedLesson(lessons[i - 1].id)

                // Also require the preceding review (if any) to be completed.
                let prevReviewId = reviewId(module: module, beforeLessonIndex: i)
                let prevReviewCompleted = prevReviewId == nil
                    || store.hasCompletedLesson(prevReviewId!)
                let unlocked = prevCompleted && prevReviewCompleted

                let lessonState: PathNode.NodeState
                if mastered {
                    lessonState = .mastered
                } else if attempted {
                    lessonState = .attempted
                } else if unlocked && !foundCurrent {
                    lessonState = .current
                    foundCurrent = true
                } else if unlocked {
                    lessonState = .available
                } else {
                    lessonState = .locked
                }

                nodes.append(PathNode(
                    id: lesson.id,
                    kind: .lesson(lesson),
                    module: module,
                    state: lessonState,
                    isLeft: globalIndex % 2 == 0,
                    hasTrailingLine: true,   // set correctly below
                    lessonIndexInModule: i
                ))
                globalIndex += 1

                // ── Review node after every `reviewInterval` lessons ────
                let isLastLesson = (i == lessons.count - 1)
                let isReviewBoundary = (i + 1) % Self.reviewInterval == 0

                if isReviewBoundary && !isLastLesson {
                    let groupIndex  = (i + 1) / Self.reviewInterval - 1
                    let rId         = "review_\(module.id)_\(groupIndex)"
                    let start       = max(0, i - (Self.reviewInterval - 1))
                    let covered     = Array(lessons[start...i].map(\.id))

                    // Review unlocks when all covered lessons are completed (any score).
                    let allCovered  = covered.allSatisfy { store.hasCompletedLesson($0) }
                    let rMastered   = store.hasMasteredLesson(rId)
                    let rAttempted  = store.hasCompletedLesson(rId)

                    let reviewState: PathNode.NodeState
                    if rMastered {
                        reviewState = .mastered
                    } else if rAttempted {
                        reviewState = .attempted
                    } else if allCovered && !foundCurrent {
                        reviewState = .current
                        foundCurrent = true
                    } else if allCovered {
                        reviewState = .available
                    } else {
                        reviewState = .locked
                    }

                    nodes.append(PathNode(
                        id: rId,
                        kind: .review(lessonIds: covered),
                        module: module,
                        state: reviewState,
                        isLeft: globalIndex % 2 == 0,
                        hasTrailingLine: true,   // set correctly below
                        lessonIndexInModule: groupIndex
                    ))
                    globalIndex += 1
                }
            }

            // Set hasTrailingLine: false for the last node — no connector after the section.
            if !nodes.isEmpty {
                nodes[nodes.count - 1].hasTrailingLine = false
            }

            built.append(PathSection(id: module.id, module: module, nodes: nodes))
        }

        sections = built
    }

    // MARK: - Helpers

    /// Returns the review node ID that must be mastered before lesson at `lessonIndex`
    /// can be unlocked, or nil if no review gates that lesson.
    private func reviewId(module: Module, beforeLessonIndex i: Int) -> String? {
        // A review after lessons [0..(interval-1)] gates lessons [interval..]
        guard i > 0, i % Self.reviewInterval == 0 else { return nil }
        let groupIndex = i / Self.reviewInterval - 1
        return "review_\(module.id)_\(groupIndex)"
    }
}
