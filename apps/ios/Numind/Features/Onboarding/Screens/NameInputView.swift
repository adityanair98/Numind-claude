import SwiftUI

/// Screen 13 — Name Collection
struct NameInputView: View {
    @AppStorage("numind.userName") private var userName = ""
    @State private var nameInput: String = ""
    @FocusState private var isFocused: Bool
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.softBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("What should we call you?")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .padding(.top, 8)

                Text("Used for your greeting and profile.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .padding(.top, 8)

                // Text input
                TextField("Your name", text: $nameInput)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                isFocused ? Theme.Colors.primaryBlue : Theme.Colors.hairline,
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isFocused ? Theme.Colors.primaryBlue.opacity(0.12) : .clear, radius: 9, x: 0, y: 3)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { saveName() }
                    .padding(.top, 26)

                Text("You can change this anytime in settings.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.mutedText)
                    .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            VStack {
                Spacer()
                onboardingFooter(dark: false) {
                    PillButton("Continue") { saveName() }
                }
            }
        }
        .onAppear {
            nameInput = userName == "You" ? "" : userName
            isFocused = true
        }
    }

    private func saveName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        userName = trimmed.isEmpty ? "You" : trimmed
        onContinue()
    }
}

#Preview {
    NameInputView(onContinue: {})
}
