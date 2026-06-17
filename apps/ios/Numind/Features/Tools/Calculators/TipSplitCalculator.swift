import SwiftUI

/// Tip + bill split calculator (Phase 7a showcase — built from scratch).
///
/// Handles tax + tip on a pre-tax bill, then splits the grand total either
/// evenly across N people or unevenly across named people who each ordered
/// a different amount (tax + tip allocated proportionally to each subtotal).
/// Includes a "Share" action that exports the per-person breakdown as text.
struct TipSplitCalculator: View {
    private enum SplitMode: String, CaseIterable, Identifiable {
        case even = "Even"
        case uneven = "Uneven"
        var id: String { rawValue }
    }

    private struct PersonEntry: Identifiable {
        let id = UUID()
        var name: String = ""
        var amount: String = ""
    }

    @State private var billText = ""
    @State private var taxPctText = "8"
    @State private var tipPct: Double = 20
    @State private var customTipText = ""
    @State private var usingCustomTip = false
    @State private var splitMode: SplitMode = .even
    @State private var peopleCount = 2
    @State private var entries: [PersonEntry] = [PersonEntry(), PersonEntry()]

    private let tipPresets: [Double] = [15, 18, 20, 22]

    var body: some View {
        CalculatorShell(
            title: "Tip & bill split",
            summary: "Add tip and tax, then split the check — evenly or by what each person ordered.",
            methodology: """
            Tip is calculated on the pre-tax bill (the common US convention). \
            Tax is added on top using the rate you enter. The grand total is \
            bill + tax + tip.

            Even split divides the grand total by the number of people. Uneven \
            split allocates each person their own subtotal plus a share of the \
            tax and tip proportional to what they ordered, so nobody overpays \
            for someone else's entrée. Per-person amounts are rounded to the \
            cent; rounding can leave a few cents of difference from the total.
            """
        ) {
            billCard
            tipCard
            splitCard
            resultCard
        }
    }

    // MARK: - Inputs

    private var billCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Pre-tax bill")
                currencyField(text: $billText, placeholder: "0.00")

                fieldLabel("Sales tax %")
                HStack(spacing: 8) {
                    TextField("8", text: $taxPctText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .frame(maxWidth: 80)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.mutedTint)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text("%")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                }
            }
        }
    }

    private var tipCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                fieldLabel("Tip")
                HStack(spacing: 8) {
                    ForEach(tipPresets, id: \.self) { preset in
                        tipChip(label: "\(Int(preset))%", selected: !usingCustomTip && tipPct == preset) {
                            usingCustomTip = false
                            tipPct = preset
                        }
                    }
                    tipChip(label: "Custom", selected: usingCustomTip) {
                        usingCustomTip = true
                    }
                }
                if usingCustomTip {
                    HStack(spacing: 8) {
                        TextField("e.g. 25", text: $customTipText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .frame(maxWidth: 90)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Theme.Colors.mutedTint)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        Text("%")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.mutedText)
                        Spacer()
                    }
                }
            }
        }
    }

    private var splitCard: some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Split", selection: $splitMode) {
                    ForEach(SplitMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                if splitMode == .even {
                    HStack {
                        fieldLabel("People")
                        Spacer()
                        Stepper("\(peopleCount)", value: $peopleCount, in: 1...30)
                            .fixedSize()
                    }
                } else {
                    VStack(spacing: 10) {
                        ForEach($entries) { $entry in
                            HStack(spacing: 8) {
                                TextField("Name", text: $entry.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .padding(.horizontal, 10).padding(.vertical, 9)
                                    .background(Theme.Colors.mutedTint)
                                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                                currencyField(text: $entry.amount, placeholder: "0.00", compact: true)
                                if entries.count > 1 {
                                    Button { entries.removeAll { $0.id == entry.id } } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Theme.Colors.mutedText.opacity(0.6))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        Button { entries.append(PersonEntry()) } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add person")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.primaryBlue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        if unevenSubtotalSum > 0, abs(unevenSubtotalSum - bill) > 0.01 {
                            CalculatorNote(text: "Heads up: the entered subtotals add up to \(money(unevenSubtotalSum)), but the bill is \(money(bill)). Tax and tip are split by each person's share of the subtotals.")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Result

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.mindTealTint) {
            VStack(alignment: .leading, spacing: 12) {
                totalRow("Bill", money(bill))
                totalRow("Tax (\(pct(taxPct))%)", money(taxAmount))
                totalRow("Tip (\(pct(effectiveTipPct))%)", money(tipAmount))
                Divider().background(Theme.Colors.hairline)
                totalRow("Grand total", money(grandTotal), bold: true)

                Divider().background(Theme.Colors.hairline)

                ForEach(perPersonResults, id: \.label) { row in
                    HStack {
                        Text(row.label)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Text(money(row.amount))
                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.Colors.mindTeal)
                    }
                }

                if !shareText.isEmpty {
                    ShareLink(item: shareText) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share the split")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Theme.Colors.mindTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func totalRow(_ label: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: bold ? 16 : 14, weight: bold ? .bold : .medium))
                .foregroundStyle(bold ? Theme.Colors.deepNavy : Theme.Colors.mutedText)
            Spacer()
            Text(value)
                .font(.system(size: bold ? 18 : 15, weight: bold ? .bold : .semibold, design: .monospaced))
                .foregroundStyle(Theme.Colors.deepNavy)
        }
    }

    // MARK: - Computation

    private var bill: Double { Double(billText) ?? 0 }
    private var taxPct: Double { Double(taxPctText) ?? 0 }
    private var effectiveTipPct: Double {
        usingCustomTip ? (Double(customTipText) ?? 0) : tipPct
    }
    private var taxAmount: Double { bill * taxPct / 100 }
    private var tipAmount: Double { bill * effectiveTipPct / 100 }
    private var grandTotal: Double { bill + taxAmount + tipAmount }
    private var unevenSubtotalSum: Double {
        entries.reduce(0) { $0 + (Double($1.amount) ?? 0) }
    }

    private struct PersonResult { let label: String; let amount: Double }

    private var perPersonResults: [PersonResult] {
        guard grandTotal > 0 else { return [] }
        switch splitMode {
        case .even:
            let n = max(1, peopleCount)
            return [PersonResult(label: "Each of \(n)", amount: grandTotal / Double(n))]
        case .uneven:
            let sum = unevenSubtotalSum
            guard sum > 0 else { return [] }
            let addOn = taxAmount + tipAmount   // distributed proportionally
            return entries.enumerated().compactMap { i, entry in
                let sub = Double(entry.amount) ?? 0
                guard sub > 0 else { return nil }
                let share = sub + addOn * (sub / sum)
                let name = entry.name.trimmingCharacters(in: .whitespaces)
                return PersonResult(label: name.isEmpty ? "Person \(i + 1)" : name, amount: share)
            }
        }
    }

    private var shareText: String {
        let rows = perPersonResults
        guard !rows.isEmpty, grandTotal > 0 else { return "" }
        var lines = ["Bill \(money(bill)) + tax \(money(taxAmount)) + tip \(money(tipAmount)) = \(money(grandTotal))"]
        for r in rows { lines.append("\(r.label): \(money(r.amount))") }
        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private func money(_ v: Double) -> String {
        String(format: "$%.2f", v)
    }

    /// Percent with no trailing zeros: 8.0 -> "8", 8.5 -> "8.5".
    private func pct(_ v: Double) -> String {
        String(format: "%g", v)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.5)
    }

    private func currencyField(text: Binding<String>, placeholder: String, compact: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text("$").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .font(.system(size: 17, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: compact ? 120 : .infinity)
        .background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func tipChip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(selected ? .white : Theme.Colors.deepNavy)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? Theme.Colors.primaryBlue : Theme.Colors.mutedTint)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { TipSplitCalculator() }
}
