import SwiftUI

enum OptionCardState { case normal, selected, correct, wrong }

struct OptionCard: View {
    let key: String
    let text: String
    let state: OptionCardState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                keyBubble
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if state == .correct {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.Colors.mindTeal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 60)
            .background(cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var keyBubble: some View {
        ZStack {
            Circle().fill(bubbleBackground)
            Text(key)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(bubbleText)
        }
        .frame(width: 28, height: 28)
    }

    private var cardBackground: Color {
        switch state {
        case .normal:   Theme.Colors.cardBackground
        case .selected: Theme.Colors.primaryBlueTint
        case .correct:  Theme.Colors.mindTealTint
        case .wrong:    Theme.Colors.errorSoftRedTint
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal:   Theme.Colors.hairline
        case .selected: Theme.Colors.primaryBlue
        case .correct:  Theme.Colors.mindTeal
        case .wrong:    Theme.Colors.errorSoftRed
        }
    }

    private var bubbleBackground: Color {
        switch state {
        case .normal:   Theme.Colors.mutedTint
        case .selected: Theme.Colors.primaryBlue
        case .correct:  Theme.Colors.mindTeal
        case .wrong:    Theme.Colors.errorSoftRed
        }
    }

    private var bubbleText: Color {
        switch state {
        case .normal: Theme.Colors.deepNavy
        case .selected, .correct, .wrong: .white
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        OptionCard(key: "A", text: "$4.80",  state: .normal,   action: {})
        OptionCard(key: "B", text: "$9.60",  state: .selected, action: {})
        OptionCard(key: "C", text: "$12.00", state: .correct,  action: {})
        OptionCard(key: "D", text: "$24.00", state: .wrong,    action: {})
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
