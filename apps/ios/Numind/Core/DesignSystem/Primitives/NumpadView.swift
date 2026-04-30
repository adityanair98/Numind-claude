import SwiftUI

/// Full-width number pad used for free-entry quiz questions.
/// Callers own the display strip; this component only renders the keys.
struct NumpadView: View {
    let onDigit:   (String) -> Void
    let onDecimal: () -> Void
    let onDelete:  () -> Void

    private let rows: [[NumpadKey]] = [
        [.digit("7"), .digit("8"), .digit("9")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("1"), .digit("2"), .digit("3")],
        [.decimal,    .digit("0"), .delete    ],
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: 10) {
                    ForEach(rows[r].indices, id: \.self) { c in
                        numpadButton(rows[r][c])
                    }
                }
            }
        }
    }

    // MARK: - Key

    private enum NumpadKey {
        case digit(String), decimal, delete
    }

    @ViewBuilder
    private func numpadButton(_ key: NumpadKey) -> some View {
        let label: String = {
            switch key {
            case .digit(let d): return d
            case .decimal:      return "."
            case .delete:       return "⌫"
            }
        }()
        let isDelete = if case .delete = key { true } else { false }

        Button {
            switch key {
            case .digit(let d): onDigit(d)
            case .decimal:      onDecimal()
            case .delete:       onDelete()
            }
        } label: {
            Text(label)
                .font(.system(size: isDelete ? 22 : 24, weight: .semibold, design: .rounded))
                .foregroundStyle(isDelete ? Theme.Colors.mutedText : Theme.Colors.deepNavy)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NumpadView(
        onDigit:   { _ in },
        onDecimal: {},
        onDelete:  {}
    )
    .padding()
    .background(Theme.Colors.softBackground)
}
