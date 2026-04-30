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

// MARK: - Theme.Colors

extension Theme {
    enum Colors {

        // ── Brand primaries (brighten slightly in dark so they pop on dark surfaces) ──
        static let primaryBlue   = Color(uiColor: .adaptive(light: 0x2F6BFF, dark: 0x5B8FFF))
        static let deepNavy      = Color(uiColor: .adaptive(light: 0x10224A, dark: 0xE8ECF4))
        static let mindTeal      = Color(uiColor: .adaptive(light: 0x2DC6B6, dark: 0x3DD9C8))
        static let insightYellow = Color(uiColor: .adaptive(light: 0xFFD84D, dark: 0xFFD84D))
        static let warmOrange    = Color(uiColor: .adaptive(light: 0xFF7A3D, dark: 0xFF8E57))
        static let growthGreen   = Color(uiColor: .adaptive(light: 0x22A64A, dark: 0x34D27A))
        static let investIndigo  = Color(uiColor: .adaptive(light: 0x5B5BD6, dark: 0x7B7FF0))
        static let errorSoftRed  = Color(uiColor: .adaptive(light: 0xEF6B6B, dark: 0xF08080))
        static let debtCoral     = Color(uiColor: .adaptive(light: 0xEF5A3A, dark: 0xFF7055))
        static let travelPurple  = Color(uiColor: .adaptive(light: 0x7C4DBC, dark: 0xA070E0))

        // ── Surfaces ──────────────────────────────────────────────────────────────────
        /// Page / scroll background
        static let softBackground = Color(uiColor: .adaptive(light: 0xF6F9FF, dark: 0x0F1726))
        /// Card / elevated surface
        static let cardBackground = Color(uiColor: .adaptive(light: 0xFFFFFF, dark: 0x1A2332))

        // ── Text ──────────────────────────────────────────────────────────────────────
        static let mutedText  = Color(uiColor: .adaptive(light: 0x6B7280, dark: 0x8B95A5))
        /// Dark-amber in light mode, bright yellow in dark (always legible on yellow tint)
        static let insightText = Color(uiColor: .adaptive(light: 0x8A6500, dark: 0xFFD84D))

        // ── Tints (opacity of base — automatically adaptive) ──────────────────────────
        static var primaryBlueTint:   Color { primaryBlue.opacity(0.12) }
        static var mindTealTint:      Color { mindTeal.opacity(0.14) }
        static var insightYellowTint: Color { insightYellow.opacity(0.22) }
        static var warmOrangeTint:    Color { warmOrange.opacity(0.14) }
        static var growthGreenTint:   Color { growthGreen.opacity(0.14) }
        static var investIndigoTint:  Color { investIndigo.opacity(0.12) }
        static var errorSoftRedTint:  Color { errorSoftRed.opacity(0.14) }
        static var debtCoralTint:     Color { debtCoral.opacity(0.13) }
        static var travelPurpleTint:  Color { travelPurple.opacity(0.12) }
        static var mutedTint:         Color { mutedText.opacity(0.12) }

        // ── Lines & shadows ───────────────────────────────────────────────────────────
        static var hairline: Color { mutedText.opacity(0.18) }
        /// Use this for card/view shadows instead of raw .black.opacity()
        static let shadow = Color(uiColor: .adaptive(light: 0x000000, dark: 0x000000))
    }
}
