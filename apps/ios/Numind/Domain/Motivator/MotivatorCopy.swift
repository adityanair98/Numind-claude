import Foundation

/// Static copy bank for mid-session motivators.
///
/// Each type has 4-5 headline/subtitle/body variants, picked at random to prevent
/// staleness across sessions. Copy is warm, encouraging, and action-oriented.
enum MotivatorCopy {

    // MARK: - Momentum

    private static let momentumVariants: [(headline: String, subtitle: String, body: String)] = [
        (
            "You're on a roll",
            "{N} correct in a row",
            "You're getting faster at these shortcuts."
        ),
        (
            "Nailing it",
            "That's a {N}-answer streak",
            "The patterns are clicking into place."
        ),
        (
            "Locked in",
            "{N} in a row — keep it up",
            "You're finding your rhythm."
        ),
        (
            "In the zone",
            "{N} straight",
            "The shortcuts are becoming automatic."
        ),
    ]

    static func momentum(streak: Int) -> (headline: String, subtitle: String, body: String, cta: String) {
        let v = momentumVariants.randomElement()!
        return (
            v.headline,
            v.subtitle.replacingOccurrences(of: "{N}", with: "\(streak)"),
            v.body,
            "Keep going"
        )
    }

    // MARK: - Coaching

    private static let coachingVariants: [(headline: String, subtitle: String)] = [
        ("Quick reset",    "Smart learners pause to plan."),
        ("Take a breath",  "A quick tip can change everything."),
        ("Let's regroup",  "One technique can unlock this."),
        ("Try a new angle", "Here's a shortcut to try."),
    ]

    static func coaching() -> (headline: String, subtitle: String) {
        coachingVariants.randomElement()!
    }

    // MARK: - Progress

    private static let progressVariants: [(headline: String, subtitle: String, body: String)] = [
        ("Halfway there",  "Great momentum!",          "You've completed"),
        ("Right on track",  "Solid progress so far.",   "You've completed"),
        ("Nice pace",       "You're cruising through.", "You've completed"),
    ]

    static func progress(completed: Int, total: Int) -> (headline: String, subtitle: String, body: String, cta: String) {
        let v = progressVariants.randomElement()!
        return (v.headline, v.subtitle, v.body, "Continue")
    }

    // MARK: - Near Finish

    private static let nearFinishVariants: [(headline: String, subtitle: String, body: String)] = [
        (
            "Almost done",
            "{N} questions left!",
            "You're so close to crushing this workout."
        ),
        (
            "Final stretch",
            "Just {N} more to go!",
            "Bring it home strong."
        ),
        (
            "Nearly there",
            "Just {N} left — you've got this.",
            "One last push and you're done."
        ),
        (
            "Bring it home",
            "{N} to go!",
            "Finish strong — you're almost there."
        ),
    ]

    static func nearFinish(remaining: Int) -> (headline: String, subtitle: String, body: String, cta: String) {
        let v = nearFinishVariants.randomElement()!
        return (
            v.headline,
            v.subtitle.replacingOccurrences(of: "{N}", with: "\(remaining)"),
            v.body,
            "Finish strong"
        )
    }

    // MARK: - Inline encouragement

    private static let inlineVariants: [(headline: String, subtitle: String)] = [
        ("Nice pattern recognition", "You're spotting the shortcut."),
        ("Quick thinking!",          "That shortcut's becoming automatic."),
        ("Sharp!",                   "You didn't even need to think twice."),
        ("Getting faster",           "Your instincts are sharpening."),
        ("Smooth!",                  "That one came naturally."),
    ]

    static func inlineEncouragement() -> (headline: String, subtitle: String) {
        inlineVariants.randomElement()!
    }

    // MARK: - Estimation coaching (generic tips, not lesson-specific)

    static let estimationTips: [(title: String, body: String)] = [
        ("Start with a round number",  "Pick the nearest round number and adjust from there."),
        ("Trust your first instinct",  "Don't overthink — your gut estimate is often close."),
        ("Eliminate the extremes",     "Rule out values that are obviously too high or too low."),
        ("Break it into parts",        "Split the calculation into simpler pieces you can estimate."),
    ]
}
