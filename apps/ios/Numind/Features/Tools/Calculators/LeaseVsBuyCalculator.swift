import SwiftUI

/// Lease vs buy car calculator (Phase 7b). Compares the 3-year out-of-pocket
/// cost of leasing against buying with a 3-year loan, crediting the buyer the
/// car's resale value at the end.
struct LeaseVsBuyCalculator: View {
    // Buy
    @State private var priceText = ""
    @State private var downBuyText = "2000"
    @State private var aprText = "7"
    @State private var resaleText = ""
    // Lease
    @State private var leaseMonthlyText = ""
    @State private var leaseDownText = "2000"

    var body: some View {
        CalculatorShell(
            title: "Lease vs buy",
            summary: "Compare the 3-year cost of leasing a car vs buying it.",
            methodology: """
            Both sides are 3 years (36 months). Buying assumes a 3-year loan: \
            payment amortizes (price − down) at the APR over 36 months, and at \
            the end you own a car worth its resale value — so net buy cost = down \
            + 36 payments − resale value. Leasing has nothing left at the end, so \
            net lease cost = lease down + 36 lease payments. Excludes insurance, \
            maintenance, and mileage-overage fees, which differ by situation.
            """
        ) {
            buyCard
            leaseCard
            resultCard
        }
    }

    private var buyCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("BUYING").font(.system(size: 11, weight: .heavy)).foregroundStyle(Theme.Colors.primaryBlue).tracking(1.0)
                fieldLabel("Car price"); currencyField(text: $priceText, placeholder: "0")
                fieldLabel("Down payment"); currencyField(text: $downBuyText, placeholder: "0")
                fieldLabel("Loan APR %"); pctField(text: $aprText, placeholder: "7")
                fieldLabel("Resale value after 3 yr"); currencyField(text: $resaleText, placeholder: "0")
            }
        }
    }

    private var leaseCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("LEASING").font(.system(size: 11, weight: .heavy)).foregroundStyle(Theme.Colors.mindTeal).tracking(1.0)
                fieldLabel("Monthly lease payment"); currencyField(text: $leaseMonthlyText, placeholder: "0")
                fieldLabel("Due at signing"); currencyField(text: $leaseDownText, placeholder: "0")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: buyCheaper ? Theme.Colors.primaryBlueTint : Theme.Colors.mindTealTint) {
            VStack(alignment: .leading, spacing: 12) {
                Text(verdict)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.Colors.deepNavy)
                    .frame(maxWidth: .infinity, alignment: .center)
                Divider().background(Theme.Colors.hairline)
                row("Buy — 3-yr net cost", money(netBuy), tint: Theme.Colors.primaryBlue)
                row("Lease — 3-yr cost", money(netLease), tint: Theme.Colors.mindTeal)
                Divider().background(Theme.Colors.hairline)
                row("Difference", money(abs(netBuy - netLease)), bold: true)
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

    private var price: Double { Double(priceText) ?? 0 }
    private var downBuy: Double { Double(downBuyText) ?? 0 }
    private var resale: Double { Double(resaleText) ?? 0 }
    private var buyMonthly: Double {
        let p = max(0, price - downBuy), r = (Double(aprText) ?? 0) / 100 / 12, n = 36.0
        guard p > 0 else { return 0 }
        return r == 0 ? p / n : p * r / (1 - pow(1 + r, -n))
    }
    private var netBuy: Double { downBuy + buyMonthly * 36 - resale }
    private var netLease: Double { (Double(leaseDownText) ?? 0) + (Double(leaseMonthlyText) ?? 0) * 36 }
    private var buyCheaper: Bool { netBuy <= netLease }
    private var verdict: String {
        guard netBuy > 0 || netLease > 0 else { return "Enter both options to compare." }
        return buyCheaper ? "Buying is cheaper over 3 years" : "Leasing is cheaper over 3 years"
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

#Preview { NavigationStack { LeaseVsBuyCalculator() } }
