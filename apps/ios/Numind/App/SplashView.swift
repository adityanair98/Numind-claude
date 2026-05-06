import SwiftUI

/// Branded splash screen shown on cold launch.
///
/// The native launch screen (Info.plist `UILaunchScreen`) shows
/// `LaunchBackground` immediately. This SwiftUI view takes over
/// seamlessly and shows the logo centered with the wordmark at the
/// bottom (Meta/LinkedIn style). After a brief hold the splash
/// fades out to reveal the app.
struct SplashView: View {
    let onFinished: () -> Void

    @State private var dismissing = false

    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Logo — centered, transparent background symbol
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Spacer()

                // Wordmark — bottom center, like Meta/LinkedIn/Facebook
                Image("LaunchWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
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
