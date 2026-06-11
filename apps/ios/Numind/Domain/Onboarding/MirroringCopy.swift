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
            return "A job offer is coming \u{2014} and the gap between \u{201C}sounds good\u{201D} and a 20-second counter compounds for years."
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

    /// Three personalized reinforcement bullets from motivations + felt moments.
    static func bullets(for motivations: Set<Motivation>,
                        feltMoments: Set<FeltMoment>) -> [String] {
        var matched: [String] = []

        let motivationCopy: [(Motivation, String)] = [
            (.stopLeavingMoney, "One in four employees leaves part of their 401(k) match unclaimed \u{2014} a five-minute check ends that for good."),
            (.stopGettingTaken, "Fees, dealer tactics, and scam patterns all repeat. Once you\u{2019}ve seen the pattern, it stops working on you."),
            (.decideWithConfidence, "Confidence isn\u{2019}t a personality trait here \u{2014} it\u{2019}s knowing the 20-second answer before the moment arrives."),
            (.understandPaycheck, "Your paycheck, your benefits, your withholding \u{2014} each one is a 5-minute skill, not a finance degree."),
            (.getAheadOfDebt, "The same interest that works against you becomes the thing that gets you out \u{2014} once you know how it moves."),
            (.growMoney, "A handful of decisions \u{2014} match, account type, allocation \u{2014} drive most investing outcomes. They\u{2019}re all learnable."),
            (.staySharp, "Skills fade. Numind tracks what\u{2019}s going stale and brings it back in minutes \u{2014} that\u{2019}s how it sticks for good."),
        ]
        matched.append(contentsOf: motivationCopy.filter { motivations.contains($0.0) }.map(\.1))

        // If they admitted a felt moment, mirror it back once.
        if feltMoments.contains(.almostScammed) && matched.count < 3 {
            matched.append("Adults in their 20s and 30s are the MOST-scammed age group by report rate \u{2014} pattern recognition is the defense.")
        }
        if feltMoments.contains(.acceptedWithoutNegotiating) && matched.count < 3 {
            matched.append("Most first offers have room in them. The counter is a script plus one number \u{2014} both learnable in one session.")
        }

        let defaults = [
            "Real scenarios with real numbers \u{2014} not definitions to memorize.",
            "Five-minute sessions built around the decisions you actually face.",
            "Honest progress: we tell you when you\u{2019}re ready \u{2014} and when you\u{2019}re not yet.",
        ]
        for d in defaults where matched.count < 3 {
            matched.append(d)
        }

        return Array(matched.prefix(3))
    }
}
