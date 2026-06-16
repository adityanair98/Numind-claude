import SwiftUI

/// Credit-card payoff calculator (Phase 7a). Given a balance, APR, and fixed
/// monthly payment, simulates the amortization month-by-month to show how
/// long until you're debt-free and how much total interest you'll pay.
struct CCPayoffCalculator: View {
    @State private var balanceText = ""
    @State private var aprText = "22"
    @State private var paymentText = ""

    var body: some View {
        CalculatorShell(
            title: "Credit card payoff",
            summary: "See how long a fixed monthly payment takes to clear your balance — and the interest it costs.",
            methodology: """
            Interest is added each month at APR ÷ 12 on the remaining balance, \
            then your payment is subtracted (the standard way a card amortizes). \
            We repeat month by month until the balance hits zero. If your payment \
            doesn't even cover one month's interest, the balance never falls — \
            the calculator flags that. Your issuer's exact daily-balance method \
            varies slightly; this is a close estimate, not your statement.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Balance")
                currencyField(text: $balanceText, placeholder: "0")
                fieldLabel("APR %")
                pctField(text: $aprText, placeholder: "22")
                fieldLabel("Monthly payment")
                currencyField(text: $paymentText, placeholder: "0")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.debtCoral.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                if neverPaysOff {
                    CalculatorNote(text: "At this payment, you're not even covering the monthly interest — the balance will never go down. Increase the payment above \(money(monthlyInterest))/mo.")
                } else if let r = result {
                    VStack(spacing: 2) {
                        Text(monthsLabel(r.months))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.debtCoral)
                        Text("until debt-free")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    .frame(maxWidth: .infinity).padding(.bottom, 4)
                    Divider().background(Theme.Colors.hairline)
                    row("Balance", money(balance))
                    row("Total interest paid", money(r.interest), tint: Theme.Colors.debtCoral)
                    Divider().background(Theme.Colors.hairline)
                    row("Total you'll pay", money(balance + r.interest), bold: true)
                } else {
                    Text("Enter a balance, APR, and payment to see your payoff timeline.")
                        .font(Theme.Typography.caption).foregroundStyle(Theme.Colors.mutedText)
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                }
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

    // MARK: - Computation

    private var balance: Double { Double(balanceText) ?? 0 }
    private var apr: Double { Double(aprText) ?? 0 }
    private var payment: Double { Double(paymentText) ?? 0 }
    private var monthlyInterest: Double { balance * apr / 100 / 12 }
    private var neverPaysOff: Bool { balance > 0 && payment > 0 && payment <= monthlyInterest }

    private var result: (months: Int, interest: Double)? {
        guard balance > 0, payment > 0, !neverPaysOff else { return nil }
        var bal = balance, interest = 0.0, months = 0
        while bal > 0 && months < 1200 {
            let i = bal * apr / 100 / 12
            interest += i
            bal += i - payment
            months += 1
        }
        return (months, interest)
    }

    private func monthsLabel(_ m: Int) -> String {
        if m < 12 { return "\(m) mo" }
        let y = m / 12, mo = m % 12
        return mo == 0 ? "\(y) yr" : "\(y) yr \(mo) mo"
    }

    private func money(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: v.rounded())) ?? String(format: "$%.0f", v)
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

#Preview { NavigationStack { CCPayoffCalculator() } }
