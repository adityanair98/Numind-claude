import SwiftUI

/// A custom estimation slider with step snapping, floating value callout,
/// and a correct-answer marker shown during feedback.
struct EstimationSlider: View {
    @Binding var value: Double
    let config: SliderConfig
    let answerFormat: AnswerFormat
    /// Set during feedback to show the correct-answer marker and error band.
    var correctValue: Double? = nil
    var grade: EstimationGrade? = nil
    var isDisabled: Bool = false
    var onDragStarted: (() -> Void)? = nil

    // MARK: - Internal state

    @State private var isDragging = false
    @State private var lastStepIndex: Int? = nil

    // MARK: - Constants

    private let trackHeight: CGFloat = 10
    private let thumbSize: CGFloat = 32
    private let markerHeight: CGFloat = 22

    var body: some View {
        VStack(spacing: 6) {
            sliderTrack
            endpointLabels
        }
    }

    // MARK: - Track + Thumb

    private var sliderTrack: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width - thumbSize
            let fraction = config.max > config.min
                ? (value - config.min) / (config.max - config.min)
                : 0
            let clampedFraction = min(max(fraction, 0), 1)
            let thumbX = thumbSize / 2 + trackWidth * clampedFraction

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Theme.Colors.mutedTint)
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                // Filled track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.insightYellow, Theme.Colors.insightYellow.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(trackHeight, thumbX), height: trackHeight)
                    .padding(.leading, thumbSize / 2)

                // Error band (feedback only)
                if let correct = correctValue, let grade = grade {
                    errorBand(correct: correct, grade: grade, trackWidth: trackWidth)
                }

                // Correct answer marker (feedback only)
                if let correct = correctValue, let grade = grade {
                    correctMarker(correct: correct, grade: grade, trackWidth: trackWidth)
                }

                // Floating callout (above thumb, during drag)
                if isDragging {
                    calloutBubble
                        .position(x: thumbX, y: -28)
                        .transition(.scale.combined(with: .opacity))
                }

                // Thumb
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: Theme.Colors.insightYellow.opacity(0.3), radius: 6, y: 3)
                    .overlay(
                        Circle()
                            .strokeBorder(Theme.Colors.insightYellow, lineWidth: 2.5)
                    )
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .position(x: thumbX, y: geo.size.height / 2)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                isDisabled ? nil : dragGesture(trackWidth: trackWidth, leadingPad: thumbSize / 2)
            )
        }
        .frame(height: max(thumbSize, 44))
    }

    // MARK: - Drag Gesture

    private func dragGesture(trackWidth: CGFloat, leadingPad: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                if !isDragging {
                    isDragging = true
                    onDragStarted?()
                }
                let x = drag.location.x - leadingPad
                let fraction = max(0, min(1, x / trackWidth))
                let raw = config.min + (config.max - config.min) * fraction

                // Snap to nearest step.
                let stepped = (raw / config.step).rounded() * config.step
                let clamped = min(max(stepped, config.min), config.max)
                value = clamped

                // Haptic tick on step boundary crossings.
                let stepIndex = Int((clamped - config.min) / config.step)
                if stepIndex != lastStepIndex {
                    lastStepIndex = stepIndex
                    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.4)
                }
            }
            .onEnded { _ in
                isDragging = false
            }
    }

    // MARK: - Callout Bubble

    private var calloutBubble: some View {
        Text(QuizEngine.format(value, as: answerFormat))
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Theme.Colors.deepNavy
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            )
    }

    // MARK: - Correct Answer Marker

    private func correctMarker(correct: Double, grade: EstimationGrade, trackWidth: CGFloat) -> some View {
        let fraction = (correct - config.min) / (config.max - config.min)
        let clampedFraction = min(max(fraction, 0), 1)
        let x = thumbSize / 2 + trackWidth * clampedFraction

        return VStack(spacing: 2) {
            // Small label
            Text(QuizEngine.format(correct, as: answerFormat))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(gradeColor(grade))

            // Vertical tick
            RoundedRectangle(cornerRadius: 1.5)
                .fill(gradeColor(grade))
                .frame(width: 3, height: markerHeight)
        }
        .position(x: x, y: -10)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Error Band

    private func errorBand(correct: Double, grade: EstimationGrade, trackWidth: CGFloat) -> some View {
        let valueFrac = (value - config.min) / (config.max - config.min)
        let correctFrac = (correct - config.min) / (config.max - config.min)
        let leftFrac = min(valueFrac, correctFrac)
        let rightFrac = max(valueFrac, correctFrac)
        let bandWidth = (rightFrac - leftFrac) * trackWidth
        let bandX = thumbSize / 2 + leftFrac * trackWidth

        return RoundedRectangle(cornerRadius: trackHeight / 2)
            .fill(gradeColor(grade).opacity(0.25))
            .frame(width: max(0, bandWidth), height: trackHeight)
            .position(x: bandX + bandWidth / 2, y: thumbSize / 2)
    }

    // MARK: - Endpoint Labels

    private var endpointLabels: some View {
        HStack {
            Text(QuizEngine.format(config.min, as: answerFormat))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.Colors.mutedText)

            Spacer()

            Text(QuizEngine.format(config.max, as: answerFormat))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.Colors.mutedText)
        }
        .padding(.horizontal, thumbSize / 2)
    }

    // MARK: - Helpers

    private func gradeColor(_ grade: EstimationGrade) -> Color {
        switch grade {
        case .perfect: return Theme.Colors.mindTeal
        case .good:    return Theme.Colors.primaryBlue
        case .okay:    return Theme.Colors.warmOrange
        case .miss:    return Theme.Colors.errorSoftRed
        }
    }
}
