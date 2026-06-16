import SwiftUI

/// A compact pill showing a pack's **Readiness** state (Phase 9). Readiness is
/// the honest, decision-scoped competence signal that replaced the global
/// 0–100 score — it claims only what the evidence supports
/// (Not started → Learning → Almost ready → Ready → Sharp), never a bare
/// "you're ready for real life" verdict.
struct ReadinessBadge: View {
    let state: ReadinessEngine.State
    /// `.pill` = filled chip (boards/cards); `.inline` = icon + text only (rows).
    var style: Style = .pill

    enum Style { case pill, inline }

    var body: some View {
        let d = ReadinessDisplay(state)
        HStack(spacing: 5) {
            Image(systemName: d.icon)
                .font(.system(size: 10, weight: .bold))
            Text(d.label)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(d.tint)
        .padding(.horizontal, style == .pill ? 9 : 0)
        .padding(.vertical, style == .pill ? 4 : 0)
        .background(
            style == .pill
                ? AnyView(Capsule().fill(d.tint.opacity(0.12)))
                : AnyView(Color.clear)
        )
    }
}

/// View-layer display mapping for `ReadinessEngine.State` — keeps the engine
/// pure (no SwiftUI / copy) while giving every Readiness surface one source of
/// truth for label, icon, and tint.
struct ReadinessDisplay {
    let label: String
    let icon: String
    let tint: Color

    init(_ state: ReadinessEngine.State) {
        switch state {
        case .notStarted:
            label = "Not started"; icon = "circle.dashed"; tint = Theme.Colors.mutedText
        case .learning:
            label = "Learning"; icon = "book.fill"; tint = Theme.Colors.primaryBlue
        case .almostReady:
            label = "Almost ready"; icon = "hourglass"; tint = Theme.Colors.warmOrange
        case .ready:
            label = "Ready"; icon = "checkmark.seal.fill"; tint = Theme.Colors.growthGreen
        case .sharp:
            label = "Sharp"; icon = "sparkles"; tint = Theme.Colors.mindTeal
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 14) {
        ReadinessBadge(state: .notStarted)
        ReadinessBadge(state: .learning)
        ReadinessBadge(state: .almostReady(missing: .depth, nextAction: "Tackle the harder questions to lock it in."))
        ReadinessBadge(state: .ready)
        ReadinessBadge(state: .sharp)
        ReadinessBadge(state: .ready, style: .inline)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
