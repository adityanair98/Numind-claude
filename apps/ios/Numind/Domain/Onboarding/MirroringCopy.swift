import Foundation

/// Generates personalized NLP mirroring copy for Screen 8.
///
/// Reflects the user's motivation + aspiration selections back with
/// benefit framing to create a "we understand you" moment.
enum MirroringCopy {

    /// Generate the headline for the mirroring screen based on aspiration.
    static func headline(for aspiration: Aspiration?) -> String {
        switch aspiration {
        case .tipInstantly:
            return "You want to tip instantly — and that confidence ripples everywhere."
        case .confidentWithMoney:
            return "You want to feel confident with money — and that compounds."
        case .spotGoodDeals:
            return "You want to spot good deals — and that pays dividends."
        case .fasterThanPhone:
            return "You want to be faster than your phone — and that changes everything."
        case nil:
            return "Your goals are clear — and we know exactly how to help."
        }
    }

    /// Generate 3 personalized bullet points based on selected motivations.
    static func bullets(for motivations: Set<Motivation>) -> [String] {
        // Map each motivation to reinforcement copy
        let all: [(Motivation, String)] = [
            (.financialDecisions, "Numind users report making better financial decisions within their first week — tips, budgets, and investments become intuitive."),
            (.buildConfidence, "Daily practice builds automatic recall — the same way athletes train muscle memory."),
            (.careerGrowth, "Numind users in your goal cluster report feeling more confident in salary discussions within 2 weeks."),
            (.staySharp, "Research shows that regular mental math practice strengthens cognitive flexibility — the foundation of staying sharp."),
            (.supportEducation, "Students using gamified math practice show measurably faster skill acquisition than passive study alone."),
            (.appearSharper, "Quick mental math in social settings — splitting bills, estimating costs — signals competence and builds trust."),
            (.boostFocus, "Short, focused challenge sessions train sustained attention — a skill that transfers to everything you do."),
        ]

        // Filter to user's selections, maintaining priority order
        var matched = all.filter { motivations.contains($0.0) }.map { $0.1 }

        // Pad to 3 if the user selected fewer than 3 motivations
        let defaults = [
            "The skills you picked are taught with real-life scenarios, not abstract drills.",
            "Numind makes practice feel like a game — short sessions, daily challenges, and streaks keep you engaged.",
            "Your plan will be personalized to your starting level and goals.",
        ]

        while matched.count < 3 {
            if let next = defaults.first(where: { !matched.contains($0) }) {
                matched.append(next)
            } else {
                break
            }
        }

        return Array(matched.prefix(3))
    }
}
