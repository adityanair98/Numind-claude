import SwiftUI

// View-layer resolution of ModuleColor → Theme.Colors.
// Kept in Core/DesignSystem so Domain models stay free of SwiftUI.
extension ModuleColor {
    var tintColor: Color {
        switch self {
        case .blue:   return Theme.Colors.primaryBlue
        case .teal:   return Theme.Colors.mindTeal
        case .yellow: return Theme.Colors.insightYellow
        case .muted:  return Theme.Colors.mutedText
        }
    }

    var tintBackground: Color {
        switch self {
        case .blue:   return Theme.Colors.primaryBlueTint
        case .teal:   return Theme.Colors.mindTealTint
        case .yellow: return Theme.Colors.insightYellowTint
        case .muted:  return Theme.Colors.mutedTint
        }
    }
}
