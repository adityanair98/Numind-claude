import SwiftUI

/// Discount + sales tax calculator (Phase 7a). Answers "what will this
/// actually cost me at the register?" — discount comes off first, then tax
/// is applied to the discounted subtotal (standard US retail order).
struct DiscountTaxCalculator: View {
    private enum DiscountMode: String, CaseIterable, Identifiable {
        case percent = "% off"
        case dollars = "$ off"
        var id: String { rawValue }
    }

    @State private var priceText = ""
    @State private var discountMode: DiscountMode = .percent
    @State private var discountText = ""
    @State private var taxPctText = "8"

    var body: some View {
        CalculatorShell(
            title: "Discount & sales tax",
            summary: "See what you'll actually pay after a sale and tax.",
            methodology: """
            Discount comes off the sticker price first, then sales tax is \
            applied to the discounted subtotal — the standard order at US \
            registers. Final = (price − discount) × (1 + tax%). "% off" takes \
            a percentage of the sticker price; "$ off" subtracts a flat amount \
            (capped at the price).
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
                fieldLabel("Sticker price")
                currencyField(text: $priceText, placeholder: "0.00")

                fieldLabel("Discount")
                Picker("Discount type", selection: $discountMode) {
                    ForEach(DiscountMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                HStack(spacing: 6) {
                    if discountMode == .dollars {
                        Text("$").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.Colors.mutedText)
                    }
                    TextField(discountMode == .percent ? "e.g. 30" : "e.g. 10", text: $discountText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    if discountMode == .percent {
                        Text("%").font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Theme.Colors.mutedTint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                fieldLabel("Sales tax %")
                HStack(spacing: 8) {
                    TextField("8", text: $taxPctText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .frame(maxWidth: 80)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Theme.Colors.mutedTint)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text("%").font(Theme.Typography.body).foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Result

    private var resultCard: some View {
        NumindCard(background: Theme.Colors.warmOrangeTint) {
            VStack(alignment: .leading, spacing: 12) {
                row("Sticker price", money(price))
                row("You save", "−\(money(discount))", tint: Theme.Colors.growthGreen)
                row("Subtotal", money(subtotal))
                row("Sales tax (\(pct(taxPct))%)", money(tax))
                Divider().background(Theme.Colors.hairline)
                HStack {
                    Text("Final price")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Spacer()
                    Text(money(finalPrice))
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.Colors.warmOrange)
                }
            }
        }
    }

    private func row(_ label: String, _ value: String, tint: Color? = nil) -> some View {
        HStack {
            Text(label).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.Colors.mutedText)
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(tint ?? Theme.Colors.deepNavy)
        }
    }

    // MARK: - Computation

    private var price: Double { Double(priceText) ?? 0 }
    private var taxPct: Double { Double(taxPctText) ?? 0 }
    private var discount: Double {
        let v = Double(discountText) ?? 0
        return discountMode == .percent ? price * v / 100 : min(v, price)
    }
    private var subtotal: Double { max(0, price - discount) }
    private var tax: Double { subtotal * taxPct / 100 }
    private var finalPrice: Double { subtotal + tax }

    // MARK: - Helpers

    private func money(_ v: Double) -> String { String(format: "$%.2f", v) }
    private func pct(_ v: Double) -> String { String(format: "%g", v) }

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
                .font(.system(size: 17, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack { DiscountTaxCalculator() }
}
