import SwiftUI

/// High-yield savings growth calculator (Phase 7a). Projects a starting
/// balance + recurring monthly contributions compounding at a given APY
/// over a number of years.
struct HYSAGrowthCalculator: View {
    @State private var startText = ""
    @State private var monthlyText = "0"
    @State private var apyText = "4"
    @State private var yearsText = "5"

    var body: some View {
        CalculatorShell(
            title: "Savings growth",
            summary: "What a high-yield savings account earns over time.",
            methodology: """
            We compound monthly. The starting balance grows by the APY each year; \
            monthly contributions are added and compounded from the month they go \
            in. Ending balance = future value of the starting balance + future \
            value of the contributions. Interest earned = ending balance − \
            everything you put in. Real APYs change over time and interest in a \
            taxable account is taxable — treat this as a projection.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Starting balance")
                currencyField(text: $startText, placeholder: "0")
                fieldLabel("Monthly contribution")
                currencyField(text: $monthlyText, placeholder: "0")
                fieldLabel("APY %")
                pctField(text: $apyText, placeholder: "4")
                fieldLabel("Years")
                pctField(text: $yearsText, placeholder: "5", unit: "yr")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.growthGreen.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(ending))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.Colors.growthGreen)
                    Text("in \(pct(years)) years")
                        .font(Theme.Typography.small).foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity).padding(.bottom, 4)
                Divider().background(Theme.Colors.hairline)
                row("You contribute", money(totalContributed))
                row("Interest earned", money(interest), tint: Theme.Colors.growthGreen)
                Divider().background(Theme.Colors.hairline)
                row("Ending balance", money(ending), bold: true)
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

    // MARK: - Computation

    private var start: Double { Double(startText) ?? 0 }
    private var monthly: Double { Double(monthlyText) ?? 0 }
    private var apy: Double { Double(apyText) ?? 0 }
    private var years: Double { Double(yearsText) ?? 0 }
    private var months: Int { Int((years * 12).rounded()) }
    /// Monthly growth factor derived from APY (APY already includes compounding).
    private var monthlyRate: Double { pow(1 + apy / 100, 1.0 / 12.0) - 1 }

    private var ending: Double {
        let n = Double(months)
        let fvStart = start * pow(1 + monthlyRate, n)
        let fvContrib = monthlyRate == 0 ? monthly * n
            : monthly * ((pow(1 + monthlyRate, n) - 1) / monthlyRate)
        return fvStart + fvContrib
    }
    private var totalContributed: Double { start + monthly * Double(months) }
    private var interest: Double { max(0, ending - totalContributed) }

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
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    private func pctField(text: Binding<String>, placeholder: String, unit: String = "%") -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .monospaced))
                .frame(maxWidth: 90).padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(unit).font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview { NavigationStack { HYSAGrowthCalculator() } }
