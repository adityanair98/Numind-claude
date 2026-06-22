import Foundation

/// Generates personalized mirroring copy for the reinforcement screen
/// (Phase 11 v2 — keyed on the chosen life moment, not a math aspiration).
///
/// Reflects the user's moment + motivations back with stakes framing to
/// create the "we understand exactly what you're facing" beat.
enum MirroringCopy {

    /// Headline keyed on the focus pack (the chosen life moment).
    static func headline(forPackId packId: String?) -> String {
        switch packId {
        case "the_job_offer":
            return "A job offer is coming \u{2014} and the difference between \u{201C}sounds good\u{201D} and \u{201C}here\u{2019}s my counter\u{201D} compounds for years."
        case "open_enrollment":
            return "Open enrollment is one form \u{2014} and most people guess. You won\u{2019}t."
        case "first_apartment":
            return "A lease is the biggest check you sign all year. You\u{2019}ll know exactly what you\u{2019}re signing."
        case "credit_card_cleanup":
            return "Card interest works against you every single day \u{2014} until you know exactly how to turn it off."
        case "buying_a_home":
            return "A home is the biggest number of your life. You\u{2019}ll walk in knowing yours."
        case "student_loan_repayment":
            return "Your loans have rules most borrowers never learn \u{2014} and the rules are where the money is."
        case "investing_starter":
            return "Four decisions drive almost everything in investing. You\u{2019}ll own all four."
        case "car_buying":
            return "The dealership runs on numbers they hope you won\u{2019}t check. You\u{2019}ll check them in your head."
        case "everyday_spending":
            return "Small money decisions happen every day \u{2014} sharp instincts turn them all your way."
        case "taxes_without_panic":
            return "Taxes feel like a black box \u{2014} until you've seen the three numbers that actually matter."
        case "protect_your_money":
            return "Scammers count on you not knowing the patterns. After this, you\u{2019}ll see them coming."
        case "first_paycheck":
            return "Your paycheck has a story in it \u{2014} you\u{2019}re about to read every line of it."
        default:
            return "You know the moment you\u{2019}re preparing for \u{2014} and we know the numbers behind it."
        }
    }

    /// One reinforcement bullet, optionally tagged with the user's own
    /// selection text so the mirroring is visibly derived from their answers.
    struct Bullet: Equatable {
        let tag: String?    // "You picked · Get ahead of my debt" — nil for defaults
        let text: String
    }

    /// Three personalized reinforcement bullets from motivations + felt moments.
    /// Every matched bullet carries the user's own words as its tag — the
    /// screen must never read as static boilerplate after a personal question.
    static func bullets(for motivations: Set<Motivation>,
                        feltMoments: Set<FeltMoment>,
                        confidence: ConfidenceLevel? = nil) -> [Bullet] {

        let motivationCopy: [(Motivation, String)] = [
            (.fillTheGapSchoolLeft, "None of this was ever your job to already know \u{2014} school skipped it. Five minutes a day is how you catch up for good."),
            (.decideWithConfidence, "Calm isn\u{2019}t a personality trait here \u{2014} it\u{2019}s walking into the moment already knowing the move."),
            (.stopLeavingMoney, "One in four employees leaves part of their 401(k) match unclaimed \u{2014} a five-minute check ends that for good."),
            (.stopGettingTaken, "Fees, dealer tactics, and scam patterns all repeat. Once you\u{2019}ve seen the pattern, it stops working on you."),
            (.understandPaycheck, "Your paycheck, your benefits, your withholding \u{2014} each one is a 5-minute skill, not a finance degree."),
            (.getAheadOfDebt, "The same interest that works against you becomes the thing that gets you out \u{2014} once you know how it moves."),
            (.growMoney, "A handful of decisions \u{2014} match, account type, allocation \u{2014} drive most investing outcomes. They\u{2019}re all learnable."),
            (.staySharp, "Skills fade. Numind tracks what\u{2019}s going stale and brings it back in minutes \u{2014} that\u{2019}s how it sticks for good."),
        ]
        // No "You picked ·" / "You said ·" tags — the bullets are already keyed
        // to their answers, so the echo stays implicit (it read as parroting).
        let motivationBullets = motivationCopy
            .filter { motivations.contains($0.0) }
            .map { Bullet(tag: nil, text: $0.1) }

        // Every felt moment now mirrors back — relief-framed (system-caused),
        // never shame. Order here is the avoider-lane lead order.
        let feltCopy: [(FeltMoment, String)] = [
            (.spentToFeelBetter, "Spending to feel better isn\u{2019}t weakness \u{2014} it\u{2019}s wiring. The skill is catching the difference between a real choice and a reflex, in the moment."),
            (.guessedHealthPlan, "\u{201C}Just re-pick last year\u{2019}s plan\u{201D} is the most common move \u{2014} and often the most expensive. You\u{2019}ll pick the one that actually wins."),
            (.carriedCardBalance, "A card balance isn\u{2019}t a character flaw \u{2014} it\u{2019}s a math trick nobody explained. You\u{2019}ll know exactly how to switch it off."),
            (.acceptedWithoutNegotiating, "Most first offers have room in them. The counter is a script plus one number \u{2014} both learnable in one session."),
            (.signedLeaseBlind, "Move-in runs about 2.5\u{2013}3\u{00D7} the rent, and the lease hides the rest. You\u{2019}ll read every line before you sign."),
            (.almostScammed, "Adults in their 20s report losing money to fraud more often than any older age group \u{2014} pattern recognition is the defense."),
        ]
        let feltBullets = feltCopy
            .filter { feltMoments.contains($0.0) }
            .map { Bullet(tag: nil, text: $0.1) }

        // Avoider lane (low confidence): lead with THEIR moment, in relief —
        // their own words must be the first thing they see. Everyone else:
        // motivations first.
        let leadWithFelt = confidence == .struggle || confidence == .getBy
        var matched = leadWithFelt
            ? feltBullets + motivationBullets
            : motivationBullets + feltBullets

        let defaults = [
            "Real scenarios with real numbers \u{2014} not definitions to memorize.",
            "Five-minute sessions built around the decisions you actually face.",
            "Honest progress: we tell you when you\u{2019}re ready \u{2014} and when you\u{2019}re not yet.",
        ]
        for d in defaults where matched.count < 3 {
            matched.append(Bullet(tag: nil, text: d))
        }

        return Array(matched.prefix(3))
    }

    // MARK: - Micro-reflections
    //
    // One short line shown the moment after a personal input — the funnel
    // acknowledging what it just heard before asking the next thing.

    static func reflection(forConfidence level: ConfidenceLevel) -> String {
        switch level {
        case .struggle: return "Freezing isn\u{2019}t a flaw \u{2014} it\u{2019}s what happens when nobody ever showed you the move."
        case .getBy:    return "Muddling through is most people. We\u{2019}ll turn it into muscle memory."
        case .decent:   return "That second-guess fades fast once you\u{2019}ve made the move a few times."
        case .quick:    return "Good \u{2014} let\u{2019}s make sure it holds up when it actually counts."
        }
    }

    static func reflection(forMomentPackId packId: String?) -> String {
        switch packId {
        case "the_job_offer", "buying_a_home", "first_apartment", "car_buying":
            return "One of the big ones \u{2014} and almost everyone walks in cold. Not you."
        case "credit_card_cleanup", "student_loan_repayment":
            return "This one quietly costs people for years. We\u{2019}ll shut that off."
        case "everyday_spending":
            return "The small ones add up fastest \u{2014} sharp instincts turn them all your way."
        default:
            return "Good pick. That\u{2019}s the moment we\u{2019}ll get you ready for."
        }
    }

    static func reflection(forMotivations motivations: Set<Motivation>) -> String? {
        guard !motivations.isEmpty else { return nil }
        if motivations.contains(.fillTheGapSchoolLeft) || motivations.contains(.decideWithConfidence) {
            return "That\u{2019}s exactly what this is for. Let\u{2019}s close the gap."
        }
        return "Then let\u{2019}s make you the calm, un-bluffable one in the room."
    }
}
