import SwiftUI

/// Screen 2 — Social Proof: "1 in 3"
/// Dark navy background, large stat in insightYellow, citation.
struct SocialProofView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.deepNavy.ignoresSafeArea()

            // Yellow halo
            RadialGradient(
                colors: [Theme.Colors.insightYellow.opacity(0.18), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 160
            )
            .frame(width: 320, height: 320)
            .offset(y: -40)

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text("The reality")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.5))

                // Big "2 in 3"
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("2")
                        .font(.system(size: 128, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Colors.insightYellow)
                    Text("in")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.insightYellow.opacity(0.7))
                    Text("3")
                        .font(.system(size: 128, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Colors.insightYellow)
                }
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.top, -8)

                Text("adults say money is a significant source of stress")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 40)

                // Accent bar
                Capsule()
                    .fill(Theme.Colors.insightYellow)
                    .frame(width: 32, height: 3)
                    .padding(.top, 16)

                Text("Not because they\u{2019}re bad with money \u{2014} because nobody ever showed them the 20-second version.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)

                Text("Source: APA Stress in America")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 18)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 28)

            // Footer
            VStack {
                Spacer()
                onboardingFooter(dark: true) {
                    PillButton("Continue") { onContinue() }
                }
            }
        }
    }
}

#Preview {
    SocialProofView(onContinue: {})
}
