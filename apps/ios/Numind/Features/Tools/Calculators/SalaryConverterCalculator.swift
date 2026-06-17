import SwiftUI

/// Salary converter (Phase 7b). Converts a pay figure between annual,
/// monthly, biweekly, weekly, and hourly — given hours worked per week.
struct SalaryConverterCalculator: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case annual = "Annual"
        case hourly = "Hourly"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .annual
    @State private var amountText = ""
    @State private var hoursText = "40"

    var body: some View {
        CalculatorShell(
            title: "Salary converter",
            summary: "Translate any pay rate between annual, monthly, biweekly, weekly, and hourly.",
            methodology: """
            Based on 52 weeks/year and the hours-per-week you enter. Hourly = \
            annual ÷ (52 × hours). Weekly = annual ÷ 52, biweekly = annual ÷ 26, \
            monthly = annual ÷ 12. Real take-home is lower after taxes — use the \
            Paycheck calculator for that. This converts gross pay only.
            """
        ) {
            inputCard
            resultCard
        }
    }

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Enter as", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                fieldLabel(mode == .annual ? "Annual salary" : "Hourly rate")
                currencyField(text: $amountText, placeholder: "0")
                fieldLabel("Hours per week")
                pctField(text: $hoursText, placeholder: "40", unit: "hr")
            }
        }
    }

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.mindTealTint) {
            VStack(alignment: .leading, spacing: 12) {
                row("Annual", money(annual))
                row("Monthly", money(annual / 12))
                row("Biweekly", money(annual / 26))
                row("Weekly", money(annual / 52))
                Divider().background(Theme.Colors.hairline)
                row("Hourly", money(hourly), bold: true)
            }
        }
    }

    private func row(_ l: String, _ v: String, bold: Bool = false) -> some View {
        HStack {
            Text(l).font(.system(size: bold ? 15 : 14, weight: bold ? .bold : .medium)).foregroundStyle(bold ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            Spacer()
            Text(v).font(.system(size: bold ? 17 : 15, weight: bold ? .bold : .semibold, design: .monospaced)).foregroundStyle(bold ? Theme.Colors.mindTeal : Theme.Colors.deepNavy)
        }
    }

    private var amount: Double { Double(amountText) ?? 0 }
    private var hours: Double { max(1, Double(hoursText) ?? 40) }
    private var annual: Double { mode == .annual ? amount : amount * 52 * hours }
    private var hourly: Double { annual / (52 * hours) }

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
    private func pctField(text: Binding<String>, placeholder: String, unit: String) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text).keyboardType(.decimalPad).font(.system(size: 17, weight: .semibold, design: .monospaced))
                .frame(maxWidth: 90).padding(.horizontal, 12).padding(.vertical, 10).background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(unit).font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview { NavigationStack { SalaryConverterCalculator() } }
