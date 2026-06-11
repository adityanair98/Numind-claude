import SwiftUI

/// Result sheet for the monthly sharpness check (Phase 12).
///
/// Frames the delta against day 1 (and the previous check) in capability
/// words. Declines render as PLANS, never grades: decay always arrives
/// pre-paired with its 5-minute remedy.
struct SharpnessCheckResultView: View {
    @Environment(\.dismiss) private var dismiss

    let record: SharpnessCheckRecord
    /// Day-1 diagnostic accuracy (correct, total), when available.
    let dayOne: (correct: Int, total: Int)?
    /// The previous check, for the speed comparison.
    let previousCheck: SharpnessCheckRecord?
    /// Skills currently flagged stale — drives the plan framing on declines.
    let staleCount: Int
    let onStartRefresh: () -> Void

    private var improvedOnDayOne: Bool {
        guard let dayOne, dayOne.total > 0, record.total > 0 else { return false }
        return Double(record.correct) / Double(record.total)
            >= Double(dayOne.correct) / Double(dayOne.total)
    }

    private var fasterThanLastCheck: Bool {
        guard let previousCheck, previousCheck.medianSeconds > 0 else { return false }
        return record.medianSeconds < previousCheck.medianSeconds
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.sectionSpacing) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Theme.Colors.mindTeal)

                Text("Sharpness check")
                    .font(Theme.Typography.small)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.mutedText)

                Text("\(record.correct) of \(record.total)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.deepNavy)

                // Day-1 comparison (capability words, favorable-forward).
                if let dayOne {
                    Text(improvedOnDayOne
                         ? "Day 1: \(dayOne.correct) of \(dayOne.total). Today: \(record.correct) of \(record.total)\(fasterThanLastCheck ? " \u{2014} and faster" : "")."
                         : "A few skills went quiet since day 1 \u{2014} normal, and quick to bring back.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.deepNavy)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                }

                // Decline → plan, never a grade.
                if staleCount > 0 {
                    Button {
                        dismiss()
                        onStartRefresh()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 13, weight: .bold))
                            Text("\(staleCount) skill\(staleCount == 1 ? "" : "s") went quiet \u{2014} about \(staleCount * 3) min brings them back")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(Theme.Colors.mindTeal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.mindTealTint)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Spacing.buttonHeight)
                    .background(Theme.Colors.deepNavy)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
    }
}
