import SwiftUI

/// Student loan calculator (Phase 7b). Compares the 10-year Standard plan
/// against refinancing at a new rate. Income-driven (RAP/IBR) payments depend
/// on income and aren't quoted here — the user is pointed to the FSA simulator,
/// matching the IDR lesson's YMYL stance.
struct StudentLoanCalculator: View {
    @State private var balanceText = ""
    @State private var aprText = "6.5"
    @State private var refiAprText = "5"

    var body: some View {
        CalculatorShell(
            title: "Student loan payoff",
            summary: "Compare the 10-year Standard plan against refinancing to a lower rate.",
            methodology: """
            Both columns amortize your balance over 120 months (10 years), the \
            Standard plan length — payment = balance × r ÷ (1 − (1 + r)^−120), \
            r = APR ÷ 12. Refinancing uses your new rate. Income-driven plans \
            (the new RAP, or legacy IBR) base payments on your income, not a fixed \
            amortization, so they aren't shown here — run those at studentaid.gov. \
            Note: refinancing federal loans to private permanently forfeits IDR, \
            PSLF, and federal forbearance.
            """
        ) {
            inputCard
            resultCard
            CalculatorNote(text: "Refinancing federal loans to a private lender gives up income-driven repayment, PSLF forgiveness, and federal hardship protections — only refinance if you're sure you won't need them.")
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Loan balance"); currencyField(text: $balanceText, placeholder: "0")
                fieldLabel("Current APR %"); pctField(text: $aprText, placeholder: "6.5")
                fieldLabel("Refinance APR %"); pctField(text: $refiAprText, placeholder: "5")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.warmOrangeTint) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    column("STANDARD", monthly: standardMonthly, total: standardTotal, tint: Theme.Colors.deepNavy)
                    Divider().frame(height: 64).background(Theme.Colors.hairline)
                    column("REFINANCED", monthly: refiMonthly, total: refiTotal, tint: Theme.Colors.growthGreen)
                }
                Divider().background(Theme.Colors.hairline)
                HStack {
                    Text("Refi saves over 10 yr")
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.Colors.deepNavy)
                    Spacer()
                    Text(money(max(0, standardTotal - refiTotal)))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.growthGreen)
                }
            }
        }
    }

    private func column(_ title: String, monthly: Double, total: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 10, weight: .heavy)).foregroundStyle(Theme.Colors.mutedText).tracking(0.6)
            Text(money(monthly)).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(tint)
            Text("per month").font(.system(size: 10)).foregroundStyle(Theme.Colors.mutedText)
            Text("Total \(money(total))").font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var balance: Double { Double(balanceText) ?? 0 }
    private func amortize(_ apr: Double) -> Double {
        let r = apr / 100 / 12, n = 120.0
        guard balance > 0 else { return 0 }
        return r == 0 ? balance / n : balance * r / (1 - pow(1 + r, -n))
    }
    private var standardMonthly: Double { amortize(Double(aprText) ?? 0) }
    private var refiMonthly: Double { amortize(Double(refiAprText) ?? 0) }
    private var standardTotal: Double { standardMonthly * 120 }
    private var refiTotal: Double { refiMonthly * 120 }

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

#Preview { NavigationStack { StudentLoanCalculator() } }
