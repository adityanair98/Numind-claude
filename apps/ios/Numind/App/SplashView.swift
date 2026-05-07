import SwiftUI

/// Branded splash screen shown on cold launch.
///
/// The LaunchScreen.storyboard shows `LaunchLogo` centered and
/// `LaunchWordmark` at the bottom on `LaunchBackground` immediately.
/// This SwiftUI view takes over seamlessly with the same layout,
/// then fades out to reveal the app.
struct SplashView: View {
    let onFinished: () -> Void

    @State private var dismissing = false

    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()

            // Logo — exact center, matching storyboard centerX/centerY
            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            // Wordmark — bottom center, matching storyboard constraint
            VStack {
                Spacer()
                Image("LaunchWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .padding(.bottom, 36)
            }
        }
        .opacity(dismissing ? 0 : 1)
        .scaleEffect(dismissing ? 1.06 : 1)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    dismissing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinished()
                }
            }
        }
        .allowsHitTesting(false)
    }
}
