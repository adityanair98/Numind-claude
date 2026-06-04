import SwiftUI

/// A card listing each Life-Event Pack with its **Readiness** state (Phase 9) —
/// the decision-scoped competence surface that replaced the global 0–100 score.
/// Presentation-only: callers map their packs + `ProgressStore.readiness(for:)`
/// into `Row`s, so this view stays pure and reusable (Home sheet + Progress tab).
struct PackReadinessBoard: View {
    struct Row: Identifiable {
        let id: String
        let title: String
        let state: ReadinessEngine.State
    }

    let rows: [Row]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { i, row in
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.deepNavy)
                                .lineLimit(1)
                            if case .almostReady(_, let nextAction) = row.state {
                                Text(nextAction)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.Colors.mutedText)
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 8)
                        ReadinessBadge(state: row.state)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    if i < rows.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 7, y: 3)
    }
}

#Preview {
    PackReadinessBoard(rows: [
        .init(id: "a", title: "First Paycheck", state: .sharp),
        .init(id: "b", title: "First Apartment", state: .ready),
        .init(id: "c", title: "Credit Card Cleanup",
              state: .almostReady(missing: .retention, nextAction: "Come back for one more review so it sticks.")),
        .init(id: "d", title: "Buying a Home", state: .learning),
        .init(id: "e", title: "Investing Starter", state: .notStarted),
    ])
    .padding()
    .background(Theme.Colors.softBackground)
}
