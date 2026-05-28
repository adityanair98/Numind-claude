import SwiftUI

/// Rent affordability calculator (Phase 7a). Applies the common 28% rule
/// (rent ≤ 28% of gross monthly income) plus a 36% back-end check that
/// accounts for your existing monthly debt payments.
struct RentAffordabilityCalculator: View {
    @State private var incomeText = ""
    @State private var debtsText = "0"
    @State private var targetPctText = "28"

    var body: some View {
        CalculatorShell(
            title: "Rent affordability",
            summary: "How much rent your income comfortably supports.",
            methodology: """
            The 28% rule caps rent at 28% of gross monthly income — the front-end \
            ratio lenders and budgets use. The 36% back-end rule caps rent + all \
            other monthly debt payments at 36% of income, so we also show the most \
            rent that leaves room for your existing debts. Your real comfort level \
            depends on your other spending, savings goals, and city.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Gross monthly income")
                currencyField(text: $incomeText, placeholder: "0")
                fieldLabel("Monthly debt payments")
                currencyField(text: $debtsText, placeholder: "0")
                fieldLabel("Target rent % of income")
                pctField(text: $targetPctText, placeholder: "28")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.housingRose.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(recommended))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.housingRose)
                    Text("recommended max rent")
                        .font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity).padding(.bottom, 4)
                Divider().background(Theme.Colors.hairline)
                row("\(pct(targetPct))% of income", money(frontEnd))
                row("36% rule (after your debts)", money(backEnd))
                if backEnd < frontEnd && debts > 0 {
                    CalculatorNote(text: "Your existing debt payments pull the safe max down to \(money(backEnd)) — that's the number we recommend.")
                }
            }
        }
    }

    private func row(_ l: String, _ v: String) -> some View {
        HStack {
            Text(l).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
            Text(v).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(Theme.Colors.deepNavy)
        }
    }

    private var income: Double { Double(incomeText) ?? 0 }
    private var debts: Double { Double(debtsText) ?? 0 }
    private var targetPct: Double { Double(targetPctText) ?? 28 }
    private var frontEnd: Double { income * targetPct / 100 }
    private var backEnd: Double { max(0, income * 0.36 - debts) }
    private var recommended: Double { min(frontEnd, backEnd) }

    private func money(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: v.rounded())) ?? String(format: "$%.0f", v)
    }
    private func pct(_ v: Double) -> String { String(format: "%g", v) }
    private func fieldLabel(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.Colors.mutedText).kerning(0.5)
    }
    private func currencyField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 4) {
            Text("$").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    private func pctField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: 90).padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text("%").font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview { NavigationStack { RentAffordabilityCalculator() } }
