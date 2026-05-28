import SwiftUI

/// Common scaffolding for every in-app calculator (Phase 7a).
///
/// Provides the shared chrome so individual calculators only supply their
/// inputs + result panel:
///   • a one-line summary under the nav title
///   • the calculator's own content (`content`)
///   • a collapsible "How this is calculated" methodology block
///   • the global YMYL disclaimer footer
///
/// Per-calculator assumption notes (the "~2-sentence" specific disclosure)
/// are rendered by each calculator next to its result, since they belong
/// with the numbers they qualify.
struct CalculatorShell<Content: View>: View {
    let title: String
    let summary: String
    /// Expanded methodology copy — formulas, assumptions, limitations.
    var methodology: String? = nil
    @ViewBuilder var content: () -> Content

    @State private var showMethodology = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(summary)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)

                content()

                if let methodology {
                    methodologyBlock(methodology)
                }

                disclaimerFooter
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Methodology (collapsible)

    private func methodologyBlock(_ text: String) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showMethodology.toggle() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.Colors.mutedText)
                        Text("How this is calculated")
                            .font(Theme.Typography.small)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Spacer()
                        Image(systemName: showMethodology ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                }
                .buttonStyle(.plain)

                if showMethodology {
                    Text(text)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                }
            }
        }
    }

    // MARK: - Global disclaimer (every calculator)

    private var disclaimerFooter: some View {
        Text("Estimate only. Not financial advice. Actual values vary based on your specific situation.")
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText.opacity(0.85))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}

/// Per-calculator assumption note shown directly above/below a result panel.
/// A thin, muted callout so it reads as a caveat, not a warning.
struct CalculatorNote: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.Colors.mutedText.opacity(0.7))
                .padding(.top, 1)
            Text(text)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.mutedTint)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Temporary destination for Tier-1 calculators not yet built. Replaced
/// commit-by-commit as each calculator lands in 7a.
struct ComingSoonCalculator: View {
    let title: String
    var body: some View {
        CalculatorShell(title: title, summary: "We're putting the finishing touches on this calculator.") {
            VStack(spacing: 14) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.mutedText.opacity(0.5))
                Text("Coming very soon")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.deepNavy)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
}


// MARK: - Calculator registry (Phase 7a)

/// Maps a lesson's `relatedCalculatorSlug` to its display name + view, so
/// lessons can surface a "Try this in […]" pill and present the calculator.
enum CalculatorRegistry {
    static func name(for slug: String) -> String? {
        switch slug {
        case "tip_split":          return "Tip & bill split"
        case "discount_tax":       return "Discount & sales tax"
        case "paycheck":           return "Paycheck"
        case "cc_payoff":          return "Credit card payoff"
        case "rent_affordability": return "Rent affordability"
        case "hysa_growth":        return "Savings growth"
        case "salary_converter":   return "Salary converter"
        case "loan":               return "Loan calculator"
        default:                   return nil
        }
    }

    @ViewBuilder
    static func view(for slug: String) -> some View {
        switch slug {
        case "tip_split":          TipSplitCalculator()
        case "discount_tax":       DiscountTaxCalculator()
        case "paycheck":           PaycheckCalculator()
        case "cc_payoff":          CCPayoffCalculator()
        case "rent_affordability": RentAffordabilityCalculator()
        case "hysa_growth":        HYSAGrowthCalculator()
        case "salary_converter":   SalaryConverterCalculator()
        case "loan":               LoanCalculator()
        default:                   EmptyView()
        }
    }
}
