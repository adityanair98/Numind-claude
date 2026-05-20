import Foundation

/// Maps diagnostic quiz results → per-topic starting difficulties.
///
/// Pure function, no side effects. The ViewModel owns calling this
/// after the diagnostic completes and writing results to OnboardingSignals.
enum DiagnosticCalibrator {

    /// Calibrate starting difficulty for each topic area based on diagnostic results.
    ///
    /// - Parameters:
    ///   - results: The diagnostic quiz results (8 questions across selected topics).
    ///   - confidenceLevel: Optional confidence self-rating from Screen 5.
    /// - Returns: Dictionary mapping module ID → starting difficulty.
    static func calibrate(
        results: [DiagnosticResult],
        confidenceLevel: ConfidenceLevel? = nil
    ) -> [String: StartingDifficulty] {
        // Group results by topic area (module ID)
        let grouped = Dictionary(grouping: results, by: { $0.topicArea })

        var difficulties: [String: StartingDifficulty] = [:]

        for (topicId, topicResults) in grouped {
            let total = topicResults.count
            let correct = topicResults.filter(\.isCorrect).count

            guard total > 0 else {
                difficulties[topicId] = .beginner
                continue
            }

            let accuracy = Double(correct) / Double(total)

            // Base difficulty from diagnostic accuracy
            var difficulty: StartingDifficulty
            if accuracy >= 1.0 {
                // All correct → intermediate (start at d2)
                difficulty = .intermediate
            } else if accuracy >= 0.5 {
                // ~50% correct → foundation (d1, faster d2 unlock)
                difficulty = .foundation
            } else {
                // Below 50% → beginner (d1, standard pace)
                difficulty = .beginner
            }

            // Confidence nudge: if user rated themselves "quick" and diagnostic
            // shows foundation, promote to intermediate.
            if confidenceLevel == .quick && difficulty == .foundation {
                difficulty = .intermediate
            }

            difficulties[topicId] = difficulty
        }

        return difficulties
    }

    /// Determine the overall starting level label for the results screen.
    static func overallLevel(difficulties: [String: StartingDifficulty]) -> String {
        let values = Array(difficulties.values)
        guard !values.isEmpty else { return "Foundations" }

        let intermediateCount = values.filter { $0 == .intermediate }.count
        let beginnerCount = values.filter { $0 == .beginner }.count

        if intermediateCount == values.count {
            return "Strong"
        } else if beginnerCount == values.count {
            return "Beginning"
        } else {
            return "Foundations"
        }
    }

    /// Determine the overall numeric level (1-3) for the badge on Screen 18.
    static func overallLevelNumber(difficulties: [String: StartingDifficulty]) -> Int {
        let values = Array(difficulties.values)
        guard !values.isEmpty else { return 1 }

        let intermediateCount = values.filter { $0 == .intermediate }.count
        if intermediateCount == values.count { return 3 }
        if intermediateCount > 0 { return 2 }
        return 1
    }
}
