import SwiftUI

/// Three faces, three jobs (Phase 13, `design-language-spec.md`):
/// **sans** (SF Pro) is the default interface register, **serif** (New York) is
/// the bounded teaching voice (lesson/pack/paywall headlines + shortcut callout
/// only), and **mono** (SF Mono, tabular) carries EVERY money figure.
extension Theme {
    enum Typography {
        // ── Sans (default interface register) ──────────────────────────────
        static let display      = Font.system(size: 32, weight: .semibold)
        static let largeDisplay = Font.system(size: 28, weight: .semibold)
        static let title    = Font.system(size: 24, weight: .semibold)
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body     = Font.system(size: 16, weight: .regular)
        static let caption  = Font.system(size: 14, weight: .regular)
        static let small    = Font.system(size: 12, weight: .medium)
        /// 10pt bold — pair with `.textCase(.uppercase)` + tracking for eyebrow labels.
        static let overline = Font.system(size: 10, weight: .bold)

        // ── Serif (teaching voice — upright, never italic) ─────────────────
        static let serifDisplay = Font.system(size: 30, weight: .medium, design: .serif)
        static let serifTitle   = Font.system(size: 24, weight: .medium, design: .serif)
        static let serifBody    = Font.system(size: 16, weight: .regular, design: .serif)

        // ── Mono (every money figure — tabular) ────────────────────────────
        static let moneyHero  = Font.system(size: 36, weight: .semibold, design: .monospaced)
        static let moneyLarge = Font.system(size: 22, weight: .semibold, design: .monospaced)
        static let mono       = Font.system(size: 16, weight: .medium,   design: .monospaced)
        static let monoSmall  = Font.system(size: 13, weight: .medium,   design: .monospaced)
    }
}
