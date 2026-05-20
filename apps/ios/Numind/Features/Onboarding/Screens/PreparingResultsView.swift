import SwiftUI

/// Screen 17 — "Preparing your results..." loading animation (DARK)
/// Shows orbiting loader + sequential status messages, auto-advances.
struct PreparingResultsView: View {
    let onFinish: () -> Void

    @State private var step = 0

    private let steps = [
        "Analyzing your strengths",
        "Setting your starting level",
        "Building your plan",
    ]

    var body: some View {
        ZStack {
            Theme.Colors.deepNavy.ignoresSafeArea()

            // Blue halo
            RadialGradient(
                colors: [Theme.Colors.primaryBlue.opacity(0.30), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 140
            )
            .frame(width: 280, height: 280)
            .offset(y: -60)

            VStack(spacing: 0) {
                Spacer()

                // Orbiting loader
                OrbitingLoader()
                    .padding(.bottom, 40)

                // Status list
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, text in
                        loadingRow(
                            text: text,
                            done: index < step,
                            loading: index == step
                        )
                    }
                }
                .padding(.horizontal, 28)

                Text("This usually takes about 2 seconds.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.top, 36)

                Spacer()
                Spacer()
            }
        }
        .onAppear { startSequence() }
    }

    private func loadingRow(text: String, done: Bool, loading: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                if done {
                    Circle()
                        .fill(Theme.Colors.mindTeal)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                } else if loading {
                    Circle()
                        .strokeBorder(.white.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(Theme.Colors.insightYellow)
                        .frame(width: 8, height: 8)
                        .shadow(color: Theme.Colors.insightYellow.opacity(0.8), radius: 5)
                } else {
                    Circle()
                        .strokeBorder(.white.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .frame(width: 22, height: 22)

            Text(text + (loading ? "\u{2026}" : ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(done ? .white.opacity(0.55) : .white)
        }
        .animation(.easeOut(duration: 0.3), value: step)
    }

    private func startSequence() {
        // Step through the 3 phases with delays
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            step = 1
            try? await Task.sleep(for: .milliseconds(800))
            step = 2
            try? await Task.sleep(for: .milliseconds(800))
            step = 3
            try? await Task.sleep(for: .milliseconds(400))
            onFinish()
        }
    }
}

#Preview {
    PreparingResultsView(onFinish: {})
}
