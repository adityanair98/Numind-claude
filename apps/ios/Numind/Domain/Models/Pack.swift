import Foundation

/// A "Life-Event Pack" — a curated sequence of existing lessons that maps to a
/// canonical real-world decision the user is making (e.g. "First Paycheck",
/// "Buying a Home", "Open Enrollment").
///
/// Packs are a PACKAGING layer on top of modules. A lesson can appear in
/// multiple packs (e.g. `investing_401k_match` shows up in both
/// "First Paycheck" and "Investing Starter"). Modules remain the canonical
/// taxonomy in the app's Learn surface; packs are the search-intent /
/// marketing-aligned surface that maps directly to high-volume queries
/// like "first apartment checklist" or "how to pay off credit card debt".
struct Pack: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    /// Short marketing-friendly subtitle (~10 words).
    let tagline: String
    /// One-sentence framing of the user moment. Used on landing pages.
    let hook: String
    /// Longer description (~50-80 words) used on the pack page above the lesson list.
    let description: String
    /// Ordered list of lesson IDs in the pack. Order matters for the suggested
    /// learning sequence; the first item is the natural entry point unless
    /// `anchorLessonId` overrides it.
    let lessonIds: [String]
    /// The single lesson that best frames the decision. Surfaced visually
    /// (e.g. as a "Start here" anchor on the pack page). Must be present in
    /// `lessonIds`.
    let anchorLessonId: String
    /// Rough total reading + quiz time across all lessons (minutes).
    let estimatedMinutes: Int
    /// ISO date (yyyy-mm-dd) the pack's lesson selection + framing was last
    /// re-validated. Bumped any time the pack composition changes.
    let lastVerified: String
}
