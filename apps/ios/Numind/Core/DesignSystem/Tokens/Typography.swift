import SwiftUI

extension Theme {
    enum Typography {
        // SF Rounded for display/title keeps the friendly, non-academic tone.
        // Body and below use default SF Pro for legibility.
        static let display  = Font.system(size: 32, weight: .bold,     design: .rounded)
        static let title    = Font.system(size: 24, weight: .semibold,  design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body     = Font.system(size: 16, weight: .regular)
        static let caption  = Font.system(size: 14, weight: .regular)
        static let small    = Font.system(size: 12, weight: .medium)
    }
}
