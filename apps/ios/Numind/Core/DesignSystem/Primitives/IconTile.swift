import SwiftUI

struct IconTile: View {
    private let systemName: String
    private let tintColor: Color
    private let size: CGFloat

    init(systemName: String, tintColor: Color = Theme.Colors.primaryBlue, size: CGFloat = 48) {
        self.systemName = systemName
        self.tintColor  = tintColor
        self.size       = size
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tintColor)
            .frame(width: size, height: size)
            .background(tintColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.iconTile, style: .continuous))
    }
}

#Preview {
    HStack(spacing: 16) {
        IconTile(systemName: "graduationcap.fill", tintColor: Theme.Colors.primaryBlue)
        IconTile(systemName: "bolt.fill",          tintColor: Theme.Colors.mindTeal)
        IconTile(systemName: "star.fill",          tintColor: Theme.Colors.insightYellow)
        IconTile(systemName: "xmark.circle.fill",  tintColor: Theme.Colors.errorSoftRed)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
