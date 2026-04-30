import SwiftUI

// View-layer resolution of ModuleColor → Theme.Colors.
// Kept in Core/DesignSystem so Domain models stay free of SwiftUI.
extension ModuleColor {
    var tintColor: Color {
        switch self {
        case .blue:   return Theme.Colors.primaryBlue
        case .teal:   return Theme.Colors.mindTeal
        case .yellow: return Theme.Colors.insightYellow
        case .orange: return Theme.Colors.warmOrange
        case .green:  return Theme.Colors.growthGreen
        case .indigo: return Theme.Colors.investIndigo
        case .coral:  return Theme.Colors.debtCoral
        case .purple: return Theme.Colors.travelPurple
        case .muted:  return Theme.Colors.mutedText
        }
    }

    var tintBackground: Color {
        switch self {
        case .blue:   return Theme.Colors.primaryBlueTint
        case .teal:   return Theme.Colors.mindTealTint
        case .yellow: return Theme.Colors.insightYellowTint
        case .orange: return Theme.Colors.warmOrangeTint
        case .green:  return Theme.Colors.growthGreenTint
        case .indigo: return Theme.Colors.investIndigoTint
        case .coral:  return Theme.Colors.debtCoralTint
        case .purple: return Theme.Colors.travelPurpleTint
        case .muted:  return Theme.Colors.mutedTint
        }
    }
}
