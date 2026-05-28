import SwiftUI

/// Generic loan calculator (Phase 7b). Standard amortized monthly payment
/// for any fixed-rate loan, plus total interest over the term.
struct LoanCalculator: View {
    @State private var amountText = ""
    @State private var aprText = "7"
    @State private var yearsText = "5"

    var body: some View {
        CalculatorShell(
            title: "Loan calculator",
            summary: "Monthly payment and total interest on any fixed-rate loan.",
            methodology: """
            Standard amortization: payment = P × r ÷ (1 − (1 + r)^−n), where P is \
            the amount, r is the monthly rate (APR ÷ 12), and n is the number of \
            months. Total paid = payment × n; interest = total − amount. Assumes a \
            fixed rate and no fees; a real loan may add origination or other costs.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Loan amount")
                currencyField(text: $amountText, placeholder: "0")
                fieldLabel("APR %")
                pctField(text: $aprText, placeholder: "7", unit: "%")
                fieldLabel("Term")
                pctField(text: $yearsText, placeholder: "5", unit: "yr")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.primaryBlueTint) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(payment))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryBlue)
                    Text("per month")
                        .font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity).padding(.bottom, 4)
                Divider().background(Theme.Colors.hairline)
                row("Loan amount", money(amount))
                row("Total interest", money(totalInterest), tint: Theme.Colors.warmOrange)
                Divider().background(Theme.Colors.hairline)
                row("Total of payments", money(amount + totalInterest), bold: true)
            }
        }
    }

    private func row(_ l: String, _ v: String, tint: Color? = nil, bold: Bool = false) -> some View {
        HStack {
            Text(l).font(.system(size: bold ? 15 : 14, weight: bold ? .bold : .medium)).foregroundStyle(bold ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            Spacer()
            Text(v).font(.system(size: bold ? 16 : 15, weight: bold ? .bold : .semibold, design: .rounded)).foregroundStyle(tint ?? Theme.Colors.deepNavy)
        }
    }

    private var amount: Double { Double(amountText) ?? 0 }
    private var apr: Double { Double(aprText) ?? 0 }
    private var months: Double { max(1, (Double(yearsText) ?? 0) * 12) }
    private var payment: Double {
        let r = apr / 100 / 12
        guard amount > 0 else { return 0 }
        if r == 0 { return amount / months }
        return amount * r / (1 - pow(1 + r, -months))
    }
    private var totalInterest: Double { max(0, payment * months - amount) }

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

#Preview { NavigationStack { LoanCalculator() } }
