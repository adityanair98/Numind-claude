import SwiftUI

// MARK: - Internal helpers (this file only)

private extension UIColor {
    /// Convenience initialiser for hex literals. Only used inside Colors.swift.
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >>  8) & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// Returns an adaptive UIColor that picks a different hex in dark mode.
    static func adaptive(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        }
    }
}

// MARK: - Theme.Colors  (Phase 13 — "Warm-Premium Money Tool")

/// The palette is governed by `docs/brand/design-language-spec.md`. The legacy
/// semantic token NAMES are kept (so ~200 call sites keep compiling) but their
/// VALUES are repointed to the warm-premium palette. Dark mode is warm charcoal,
/// not blue-black. New tokens (ember, cta*, topic accents, refreshNeutral) are
/// added below the legacy block.
extension Theme {
    enum Colors {

        // ── Surfaces ──────────────────────────────────────────────────────────────────
        /// Page / scroll background — warm off-white / warm charcoal
        static let softBackground = Color(uiColor: .adaptive(light: 0xFAF8F3, dark: 0x1A1611))
        /// Card / elevated surface
        static let cardBackground = Color(uiColor: .adaptive(light: 0xFFFFFF, dark: 0x24201A))

        // ── Text ──────────────────────────────────────────────────────────────────────
        /// Primary text ("ink"); cream in dark. (Legacy name `deepNavy`.)
        static let deepNavy   = Color(uiColor: .adaptive(light: 0x1A2236, dark: 0xF1EADD))
        static let mutedText  = Color(uiColor: .adaptive(light: 0x8A8578, dark: 0xA89E8C))
        /// Dark-amber on gold tint in light; bright gold in dark — always legible.
        static let insightText = Color(uiColor: .adaptive(light: 0x8A6500, dark: 0xFFD84D))

        // ── The four accents (each = ONE job) ──────────────────────────────────────────
        /// Primary action surface ("ink"). Legacy name `primaryBlue`.
        static let primaryBlue   = Color(uiColor: .adaptive(light: 0x1A2236, dark: 0xF1EADD))
        /// Correct · ready · verified · positive. Legacy name `mindTeal`.
        static let mindTeal      = Color(uiColor: .adaptive(light: 0x15A18C, dark: 0x34D2BE))
        /// Positive/ready also routes through green name → repointed to teal.
        static let growthGreen   = Color(uiColor: .adaptive(light: 0x15A18C, dark: 0x34D2BE))
        /// Insight / the "shortcut" only. Legacy name `insightYellow`.
        static let insightYellow = Color(uiColor: .adaptive(light: 0xFFD84D, dark: 0xFFD84D))
        /// Wrong answers only (warm amber, NOT alarm-red). Legacy name `warmOrange`.
        static let warmOrange    = Color(uiColor: .adaptive(light: 0xE0632E, dark: 0xFF8E57))
        static let errorSoftRed  = Color(uiColor: .adaptive(light: 0xE0632E, dark: 0xFF8E57))

        // ── NEW: streak flame ("ember" — warm, never teal, distinct from wrong) ────────
        static let ember = Color(uiColor: .adaptive(light: 0xF0851B, dark: 0xFF9A3D))

        // ── NEW: CTA (ink pill + cream label, inverts in dark) ─────────────────────────
        static let ctaFill  = Color(uiColor: .adaptive(light: 0x1A2236, dark: 0xF1EADD))
        static let ctaLabel = Color(uiColor: .adaptive(light: 0xF1EADD, dark: 0x1A1611))

        // ── NEW: neutrals the design names explicitly ──────────────────────────────────
        /// "To refresh" indicator — deliberately a muted neutral, NOT gold.
        static let refreshNeutral = Color(uiColor: .adaptive(light: 0xB8B2A4, dark: 0x6F695C))
        /// Empty track / progress background.
        static let track = Color(uiColor: .adaptive(light: 0xEDE8DD, dark: 0x332E25))
        /// Disabled CTA fill.
        static let disabledFill = Color(uiColor: .adaptive(light: 0xE7E3DA, dark: 0x2A251E))
        static let placeholderText = Color(uiColor: .adaptive(light: 0xA39E91, dark: 0x7C7466))

        // ── Topic accents (the demoted module rainbow — chips/strips only) ─────────────
        static let topicEveryday  = Color(uiColor: .adaptive(light: 0x15A18C, dark: 0x15A18C))
        static let topicPaycheck  = Color(uiColor: .adaptive(light: 0x5E63B6, dark: 0x6E73C6))
        static let topicHousing   = Color(uiColor: .adaptive(light: 0xB5577A, dark: 0xC56A8B))
        static let topicProtect   = Color(uiColor: .adaptive(light: 0xC0573A, dark: 0xCF6A4D))
        static let topicTaxes     = Color(uiColor: .adaptive(light: 0x4A7C8A, dark: 0x5B8E9C))
        static let topicInvesting = Color(uiColor: .adaptive(light: 0x3B8A55, dark: 0x479C68))

        // ── Legacy module-hue names → repointed onto the desaturated topic set ─────────
        static let investIndigo     = Color(uiColor: .adaptive(light: 0x5E63B6, dark: 0x6E73C6))
        static let debtCoral        = Color(uiColor: .adaptive(light: 0xC0573A, dark: 0xCF6A4D))
        static let insurancePurple  = Color(uiColor: .adaptive(light: 0x5E63B6, dark: 0x6E73C6))
        static let housingRose      = Color(uiColor: .adaptive(light: 0xB5577A, dark: 0xC56A8B))
        static let taxSlate         = Color(uiColor: .adaptive(light: 0x4A7C8A, dark: 0x5B8E9C))
        static let safetyCrimson    = Color(uiColor: .adaptive(light: 0xC0573A, dark: 0xCF6A4D))

        // ── Tints (state surfaces — never full body fills) ─────────────────────────────
        static let mindTealTint      = Color(uiColor: .adaptive(light: 0xE3F6F1, dark: 0x15302B))
        static let insightYellowTint = Color(uiColor: .adaptive(light: 0xFFF6D9, dark: 0x2E2814))
        static let warmOrangeTint    = Color(uiColor: .adaptive(light: 0xFFEDE4, dark: 0x2E1B12))
        static let emberTint         = Color(uiColor: .adaptive(light: 0xFFF1DA, dark: 0x2E2012))
        static var growthGreenTint:  Color { mindTealTint }
        static var primaryBlueTint:  Color { mindTealTint }   // selection → teal tint
        static var errorSoftRedTint: Color { warmOrangeTint }
        static var debtCoralTint:        Color { topicProtect.opacity(0.13) }
        static var insurancePurpleTint:  Color { topicPaycheck.opacity(0.12) }
        static var housingRoseTint:      Color { topicHousing.opacity(0.12) }
        static var taxSlateTint:         Color { topicTaxes.opacity(0.12) }
        static var safetyCrimsonTint:    Color { topicProtect.opacity(0.12) }
        static var investIndigoTint:     Color { topicPaycheck.opacity(0.12) }
        static var mutedTint:            Color { mutedText.opacity(0.12) }

        // ── Lines & shadows ───────────────────────────────────────────────────────────
        /// 0.5px warm hairline (used for dividers and dark-mode card borders).
        static var hairline: Color { Color(uiColor: .adaptive(light: 0x1A2236, dark: 0xF1EADD)).opacity(0.10) }
        static let shadow = Color(uiColor: .adaptive(light: 0x1A2236, dark: 0x000000))
    }
}
