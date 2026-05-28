import SwiftUI

/// Mortgage payment calculator (Phase 7b). Monthly principal + interest on a
/// fixed-rate mortgage, plus optional property tax and insurance for a full
/// "what's the real monthly?" estimate.
struct MortgageCalculator: View {
    @State private var priceText = ""
    @State private var downPctText = "20"
    @State private var aprText = "7"
    @State private var yearsText = "30"
    @State private var taxPctText = "1.1"
    @State private var insuranceText = "1500"

    var body: some View {
        CalculatorShell(
            title: "Mortgage payment",
            summary: "Estimate the real monthly cost of a home — principal, interest, tax, and insurance.",
            methodology: """
            Loan = price − down payment. Principal & interest use standard \
            amortization: P × r ÷ (1 − (1 + r)^−n), r = APR ÷ 12, n = term in \
            months. Property tax is your rate × the home price ÷ 12; insurance is \
            the annual premium ÷ 12. This excludes HOA dues and PMI (often \
            required under 20% down) — add those separately.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Home price")
                currencyField(text: $priceText, placeholder: "0")
                fieldLabel("Down payment %")
                pctField(text: $downPctText, placeholder: "20", unit: "%")
                fieldLabel("APR %")
                pctField(text: $aprText, placeholder: "7", unit: "%")
                fieldLabel("Term")
                pctField(text: $yearsText, placeholder: "30", unit: "yr")
                fieldLabel("Property tax %")
                pctField(text: $taxPctText, placeholder: "1.1", unit: "%")
                fieldLabel("Insurance (per year)")
                currencyField(text: $insuranceText, placeholder: "0")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.housingRose.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(monthlyTotal))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.housingRose)
                    Text("estimated monthly payment")
                        .font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity).padding(.bottom, 4)
                Divider().background(Theme.Colors.hairline)
                row("Loan amount", money(loan))
                row("Principal & interest", money(pi))
                row("Property tax", money(monthlyTax))
                row("Insurance", money(monthlyInsurance))
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

    private var price: Double { Double(priceText) ?? 0 }
    private var loan: Double { max(0, price * (1 - (Double(downPctText) ?? 0) / 100)) }
    private var months: Double { max(1, (Double(yearsText) ?? 0) * 12) }
    private var pi: Double {
        let r = (Double(aprText) ?? 0) / 100 / 12
        guard loan > 0 else { return 0 }
        if r == 0 { return loan / months }
        return loan * r / (1 - pow(1 + r, -months))
    }
    private var monthlyTax: Double { price * (Double(taxPctText) ?? 0) / 100 / 12 }
    private var monthlyInsurance: Double { (Double(insuranceText) ?? 0) / 12 }
    private var monthlyTotal: Double { pi + monthlyTax + monthlyInsurance }

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
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    private func pctField(text: Binding<String>, placeholder: String, unit: String) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: 90).padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(unit).font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview { NavigationStack { MortgageCalculator() } }
