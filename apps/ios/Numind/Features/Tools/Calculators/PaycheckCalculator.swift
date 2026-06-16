import SwiftUI

/// Paycheck take-home estimator (Phase 7a). Single-filer estimate using the
/// 2026 federal brackets + standard deduction, FICA (with the SS wage cap),
/// a flat state-rate input, and pre-tax 401(k) % + HSA $. Deliberately a
/// rough planning estimate — real withholding depends on your W-4, filing
/// status, local taxes, and many credits.
struct PaycheckCalculator: View {
    private enum Frequency: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case biweekly = "Biweekly"
        case semimonthly = "Semimonthly"
        case monthly = "Monthly"
        var id: String { rawValue }
        var periods: Double {
            switch self {
            case .weekly: return 52
            case .biweekly: return 26
            case .semimonthly: return 24
            case .monthly: return 12
            }
        }
    }

    // 2026 single-filer brackets (taxable income) — IRS Rev Proc 2025-32.
    private static let brackets: [(cap: Double, rate: Double)] = [
        (12_400, 0.10), (50_400, 0.12), (105_700, 0.22), (201_775, 0.24),
        (256_225, 0.32), (640_600, 0.35), (.infinity, 0.37)
    ]
    private static let stdDeduction = 16_100.0
    private static let ssWageBase = 184_500.0

    @State private var grossText = ""
    @State private var frequency: Frequency = .biweekly
    @State private var contrib401kText = "0"
    @State private var hsaText = "0"
    @State private var statePctText = "0"

    var body: some View {
        CalculatorShell(
            title: "Paycheck",
            summary: "Estimate your real take-home pay after taxes and pre-tax deductions.",
            methodology: """
            Single-filer estimate for 2026. Federal tax uses the IRS Rev Proc \
            2025-32 brackets on taxable income (gross − 401(k) − HSA − the \
            $16,100 standard deduction). FICA is 6.2% Social Security up to the \
            $184,500 wage base + 1.45% Medicare (HSA via Section 125 lowers FICA \
            wages; 401(k) does not). State tax is a flat rate you supply, applied \
            to income after pre-tax deductions. Take-home = gross − federal − \
            FICA − state − 401(k) − HSA. This is a planning estimate, not your \
            exact paycheck — your W-4, filing status, local taxes, and credits \
            all change the real number.
            """
        ) {
            inputCard
            resultCard
        }
    }

    // MARK: - Inputs

    private var inputCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Gross pay (per year)")
                currencyField(text: $grossText, placeholder: "0")

                fieldLabel("Pay frequency")
                Picker("Frequency", selection: $frequency) {
                    ForEach(Frequency.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.Colors.primaryBlue)
                .frame(maxWidth: .infinity, alignment: .leading)

                fieldLabel("401(k) contribution %")
                pctField(text: $contrib401kText, placeholder: "0")

                fieldLabel("HSA (per year)")
                currencyField(text: $hsaText, placeholder: "0")

                fieldLabel("State income tax % (estimate)")
                pctField(text: $statePctText, placeholder: "0")
            }
        }
    }

    // MARK: - Result

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.mindTealTint) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 2) {
                    Text(money(takeHomePerCheck))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.mindTeal)
                    Text("per \(frequency.rawValue.lowercased()) paycheck")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)

                Divider().background(Theme.Colors.hairline)

                row("Gross (annual)", money(gross))
                row("Federal tax", "−\(money(federalTax))")
                row("FICA (SS + Medicare)", "−\(money(fica))")
                row("State tax", "−\(money(stateTax))")
                row("401(k) (to your account)", "−\(money(pretax401k))")
                row("HSA (to your account)", "−\(money(hsa))")
                Divider().background(Theme.Colors.hairline)
                row("Take-home (annual)", money(annualTakeHome), bold: true)
            }
        }
    }

    private func row(_ label: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: bold ? 15 : 14, weight: bold ? .bold : .medium))
                .foregroundStyle(bold ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            Spacer()
            Text(value)
                .font(.system(size: bold ? 16 : 14, weight: bold ? .bold : .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
    }

    // MARK: - Computation

    private var gross: Double { Double(grossText) ?? 0 }
    private var pretax401k: Double { gross * (Double(contrib401kText) ?? 0) / 100 }
    private var hsa: Double { Double(hsaText) ?? 0 }
    private var statePct: Double { Double(statePctText) ?? 0 }

    private var federalTaxable: Double {
        max(0, gross - pretax401k - hsa - Self.stdDeduction)
    }
    private var federalTax: Double {
        var tax = 0.0
        var lower = 0.0
        for b in Self.brackets {
            if federalTaxable > lower {
                let slice = min(federalTaxable, b.cap) - lower
                tax += slice * b.rate
                lower = b.cap
            } else { break }
        }
        return tax
    }
    private var ficaWages: Double { max(0, gross - hsa) }   // HSA pre-FICA; 401k is not
    private var fica: Double {
        let ss = min(ficaWages, Self.ssWageBase) * 0.062
        let medicare = ficaWages * 0.0145
        return ss + medicare
    }
    private var stateTax: Double { max(0, gross - pretax401k - hsa) * statePct / 100 }
    private var annualTakeHome: Double {
        max(0, gross - federalTax - fica - stateTax - pretax401k - hsa)
    }
    private var takeHomePerCheck: Double { annualTakeHome / frequency.periods }

    // MARK: - Helpers

    private func money(_ v: Double) -> String {
        let n = NSNumber(value: v.rounded())
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = 0
        return f.string(from: n) ?? String(format: "$%.0f", v)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.5)
    }

    private func currencyField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 4) {
            Text("$").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func pctField(text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: 90)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text("%").font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack { PaycheckCalculator() }
}
