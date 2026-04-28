import SwiftUI

// Hex literals are only allowed in this file.
private extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >>  8) & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}

extension Theme {
    enum Colors {
        static let primaryBlue    = Color(hex: 0x2F6BFF)
        static let deepNavy       = Color(hex: 0x10224A)
        static let mindTeal       = Color(hex: 0x2DC6B6)
        static let insightYellow  = Color(hex: 0xFFD84D)
        static let softBackground = Color(hex: 0xF6F9FF)
        static let cardBackground = Color(hex: 0xFFFFFF)
        static let mutedText      = Color(hex: 0x6B7280)
        static let errorSoftRed   = Color(hex: 0xEF6B6B)
    }
}
