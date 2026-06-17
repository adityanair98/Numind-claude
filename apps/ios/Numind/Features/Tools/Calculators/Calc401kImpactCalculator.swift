import SwiftUI

/// 401(k) paycheck-impact calculator (Phase 7b). Shows that a pre-tax
/// contribution costs your take-home less than the amount contributed,
/// because it lowers your taxable income.
struct Calc401kImpactCalculator: View {
    @State private var grossText = ""
    @State private var pctText = "6"
    @State private var marginalText = "22"

    var body: some View {
        CalculatorShell(
            title: "401(k) impact",
            summary: "See what a pre-tax 401(k) contribution actually costs your paycheck.",
            methodology: """
            A pre-tax 401(k) contribution lowers your taxable income, so the hit \
            to your take-home is less than the amount you save. Annual \
            contribution = gross × contribution %. Tax saved ≈ contribution × \
            your marginal rate. Net cost to take-home = contribution − tax saved. \
            This ignores any employer match (free money on top) and assumes the \
            contribution stays within the annual IRS limit.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Gross pay (per year)")
                currencyField(text: $grossText, placeholder: "0")
                fieldLabel("Contribution %")
                pctField(text: $pctText, placeholder: "6")
                fieldLabel("Marginal tax rate %")
                pctField(text: $marginalText, placeholder: "22")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.growthGreen.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(netCost / 26))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.Colors.growthGreen)
                    Text("real cost per biweekly paycheck")
                        .font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity).padding(.bottom, 4)
                Divider().background(Theme.Colors.hairline)
                row("You contribute (annual)", money(contribution))
                row("Tax saved", "−\(money(taxSaved))", tint: Theme.Colors.growthGreen)
                Divider().background(Theme.Colors.hairline)
                row("Net cost to take-home", money(netCost), bold: true)
            }
        }
    }

    private func row(_ l: String, _ v: String, tint: Color? = nil, bold: Bool = false) -> some View {
        HStack {
            Text(l).font(.system(size: bold ? 15 : 14, weight: bold ? .bold : .medium)).foregroundStyle(bold ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            Spacer()
            Text(v).font(.system(size: bold ? 16 : 15, weight: bold ? .bold : .semibold, design: .monospaced)).foregroundStyle(tint ?? Theme.Colors.deepNavy)
        }
    }

    private var gross: Double { Double(grossText) ?? 0 }
    private var contribution: Double { gross * (Double(pctText) ?? 0) / 100 }
    private var taxSaved: Double { contribution * (Double(marginalText) ?? 0) / 100 }
    private var netCost: Double { max(0, contribution - taxSaved) }

    private func money(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = (v < 1000 ? 2 : 0)
        return f.string(from: NSNumber(value: v)) ?? String(format: "$%.2f", v)
    }
    private func fieldLabel(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.Colors.mutedText).kerning(0.5)
    }
    private func currencyField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 4) {
            Text("$").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    private func pctField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .monospaced))
                .frame(maxWidth: 90).padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text("%").font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview { NavigationStack { Calc401kImpactCalculator() } }
