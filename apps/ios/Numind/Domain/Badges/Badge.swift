import Foundation

// MARK: - Tier

enum BadgeTier {
    case bronze
    case silver
    case gold
}

// MARK: - Badge

struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String        // SF Symbol name
    let tier: BadgeTier
}

// MARK: - Catalog (20 badges)

enum BadgeCatalog {
    static let all: [Badge] = [

        // MARK: Starter
        Badge(id: "first_session",     name: "First Rep",         description: "Complete your first quiz session",                   icon: "figure.run",               tier: .bronze),
        Badge(id: "first_perfect",     name: "Flawless",          description: "Score 100% in a session (3+ questions)",             icon: "star.fill",                tier: .silver),
        Badge(id: "first_speed_bonus", name: "Quick Draw",        description: "Earn your first speed bonus",                        icon: "bolt.fill",                tier: .bronze),

        // MARK: Streak
        Badge(id: "streak_3",          name: "On a Roll",         description: "Keep a 3-day streak",                                icon: "flame.fill",               tier: .bronze),
        Badge(id: "streak_7",          name: "Week Warrior",      description: "Keep a 7-day streak",                                icon: "flame.fill",               tier: .silver),
        Badge(id: "streak_14",         name: "Fortnight",         description: "Keep a 14-day streak",                               icon: "flame.fill",               tier: .gold),

        // MARK: Accuracy
        Badge(id: "accuracy_80",       name: "Sharp Eye",         description: "Reach 80% overall accuracy (20+ questions)",         icon: "target",                   tier: .silver),
        Badge(id: "accuracy_90",       name: "Laser Focus",       description: "Reach 90% overall accuracy (20+ questions)",         icon: "scope",                    tier: .gold),

        // MARK: Volume
        Badge(id: "questions_100",     name: "The Century",       description: "Answer 100 questions total",                         icon: "checkmark.circle.fill",    tier: .bronze),
        Badge(id: "questions_500",     name: "Grinder",           description: "Answer 500 questions total",                         icon: "dumbbell.fill",            tier: .silver),
        Badge(id: "sessions_10",       name: "Dedicated",         description: "Complete 10 sessions",                               icon: "calendar.badge.checkmark", tier: .bronze),
        Badge(id: "sessions_25",       name: "Regular",           description: "Complete 25 sessions",                               icon: "calendar.badge.checkmark", tier: .silver),

        // MARK: XP
        Badge(id: "xp_100",            name: "XP Rising",         description: "Earn 100 total XP",                                  icon: "arrow.up.circle.fill",     tier: .bronze),
        Badge(id: "xp_500",            name: "High Scorer",       description: "Earn 500 total XP",                                  icon: "trophy.fill",              tier: .silver),
        Badge(id: "xp_1000",           name: "XP Machine",        description: "Earn 1,000 total XP",                               icon: "trophy.fill",              tier: .gold),

        // MARK: Speed
        Badge(id: "speed_5_sessions",  name: "Speed Freak",       description: "Earn speed bonuses in 5 different sessions",         icon: "bolt.fill",                tier: .silver),
        Badge(id: "fast_five",         name: "Flash Five",        description: "Answer 5 questions in under 5 s in one session",     icon: "bolt.circle.fill",         tier: .gold),

        // MARK: Breadth
        Badge(id: "lessons_5",         name: "Knowledge Builder", description: "Complete 5 different lessons",                       icon: "book.fill",                tier: .bronze),
        Badge(id: "multi_module",      name: "Curious Mind",      description: "Play in 3 or more modules",                         icon: "brain.fill",               tier: .silver),

        // MARK: Perfection
        Badge(id: "triple_perfect",    name: "Hat Trick",         description: "Score 100% in 3 different sessions",                 icon: "crown.fill",               tier: .gold),
    ]

    static func badge(for id: String) -> Badge? {
        all.first { $0.id == id }
    }
}
