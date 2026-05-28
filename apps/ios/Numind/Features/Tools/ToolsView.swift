import SwiftUI

/// The Tools tab — a one-stop home for Numind's in-app calculators (Phase 7a).
///
/// Replaces the retired Practice tab. Calculators are grouped into "Everyday"
/// (quick at-the-register math) and "Money decisions" (bigger one-off choices).
/// A first-launch welcome sheet sets the YMYL framing once.
struct ToolsView: View {
    @AppStorage("numind.tools.welcomeShown") private var welcomeShown = false
    @State private var showWelcome = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                group("Everyday") {
                    row(icon: "fork.knife", tint: Theme.Colors.primaryBlue,
                        name: "Tip & bill split",
                        desc: "Tip, tax, and split any check — even or uneven") {
                        TipSplitCalculator()
                    }
                    row(icon: "tag.fill", tint: Theme.Colors.warmOrange,
                        name: "Discount & sales tax",
                        desc: "What you'll actually pay after a sale") {
                        DiscountTaxCalculator()
                    }
                }

                group("Money decisions") {
                    row(icon: "creditcard.fill", tint: Theme.Colors.mindTeal,
                        name: "Paycheck",
                        desc: "Estimate your real take-home pay") {
                        PaycheckCalculator()
                    }
                    row(icon: "creditcard.trianglebadge.exclamationmark", tint: Theme.Colors.debtCoral,
                        name: "Credit card payoff",
                        desc: "Months to debt-free + total interest") {
                        ComingSoonCalculator(title: "Credit card payoff")
                    }
                    row(icon: "house.fill", tint: Theme.Colors.housingRose,
                        name: "Rent affordability",
                        desc: "How much rent your income supports") {
                        ComingSoonCalculator(title: "Rent affordability")
                    }
                    row(icon: "banknote.fill", tint: Theme.Colors.growthGreen,
                        name: "Savings growth",
                        desc: "What a high-yield account earns over time") {
                        ComingSoonCalculator(title: "Savings growth")
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Tools")
        .onAppear {
            if !welcomeShown { showWelcome = true }
        }
        .sheet(isPresented: $showWelcome, onDismiss: { welcomeShown = true }) {
            welcomeSheet
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Run your real numbers")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.deepNavy)
            Text("Quick calculators for the moment a money decision actually happens.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Group + row

    private func group<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Theme.Colors.mutedText)
                .tracking(1.2)
            VStack(spacing: 10) { content() }
        }
    }

    private func row<Destination: View>(
        icon: String, tint: Color, name: String, desc: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            NumindCard {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 46, height: 46)
                        .background(tint.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(desc)
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Colors.mutedText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Welcome sheet

    private var welcomeSheet: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.Colors.primaryBlue)
                .frame(width: 96, height: 96)
                .background(Theme.Colors.primaryBlueTint)
                .clipShape(Circle())
            Text("Welcome to Tools")
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.deepNavy)
            Text("Plug in your own numbers to settle a money decision on the spot — at the restaurant, the dealership, or the open-enrollment portal.\n\nThese are quick estimates to help you think, not financial, tax, or legal advice. Actual values depend on your specific situation.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 8)
            Spacer()
            PillButton("Got it") { showWelcome = false }
                .padding(.bottom, 8)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.vertical, 24)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack { ToolsView() }
}
