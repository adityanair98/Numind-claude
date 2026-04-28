#if DEBUG
import SwiftUI

struct DesignSystemPreviewView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                    colorsSection
                    typographySection
                    cardSection
                    buttonsSection
                    iconTilesSection
                    beadRailSection
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.sectionSpacing)
            }
            .background(Theme.Colors.softBackground)
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Sections

    private var colorsSection: some View {
        section("Colors") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                colorSwatch("Primary Blue",    Theme.Colors.primaryBlue)
                colorSwatch("Deep Navy",       Theme.Colors.deepNavy)
                colorSwatch("Mind Teal",       Theme.Colors.mindTeal)
                colorSwatch("Insight Yellow",  Theme.Colors.insightYellow)
                colorSwatch("Soft Background", Theme.Colors.softBackground)
                colorSwatch("Card Background", Theme.Colors.cardBackground)
                colorSwatch("Muted Text",      Theme.Colors.mutedText)
                colorSwatch("Error Soft Red",  Theme.Colors.errorSoftRed)
            }
        }
    }

    private var typographySection: some View {
        section("Typography") {
            NumindCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Display — 32 Bold Rounded").font(Theme.Typography.display)
                    Text("Title — 24 Semibold Rounded").font(Theme.Typography.title)
                    Text("Headline — 18 Semibold").font(Theme.Typography.headline)
                    Text("Body — 16 Regular").font(Theme.Typography.body)
                    Text("Caption — 14 Regular").font(Theme.Typography.caption)
                    Text("Small — 12 Medium").font(Theme.Typography.small)
                }
                .foregroundStyle(Theme.Colors.deepNavy)
            }
        }
    }

    private var cardSection: some View {
        section("NumindCard") {
            NumindCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Card Title")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text("Large rounded card with soft shadow and card background fill.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
    }

    private var buttonsSection: some View {
        section("PillButton") {
            VStack(spacing: 12) {
                PillButton("Primary Action") { }
                PillButton("Secondary Action", variant: .secondary) { }
            }
        }
    }

    private var iconTilesSection: some View {
        section("IconTile") {
            HStack(spacing: 16) {
                IconTile(systemName: "graduationcap.fill", tintColor: Theme.Colors.primaryBlue)
                IconTile(systemName: "bolt.fill",          tintColor: Theme.Colors.mindTeal)
                IconTile(systemName: "star.fill",          tintColor: Theme.Colors.insightYellow)
                IconTile(systemName: "xmark.circle.fill",  tintColor: Theme.Colors.errorSoftRed)
            }
        }
    }

    private var beadRailSection: some View {
        section("BeadRail (placeholder)") {
            NumindCard {
                VStack(alignment: .leading, spacing: 14) {
                    labeledRail("3 / 5", progress: 3, total: 5)
                    labeledRail("0 / 5", progress: 0, total: 5)
                    labeledRail("5 / 5", progress: 5, total: 5)
                }
            }
        }
    }

    // MARK: - Helpers

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .kerning(0.8)
            content()
        }
    }

    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Theme.Colors.mutedText.opacity(0.15), lineWidth: 1)
                }
            Text(name)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
        }
    }

    private func labeledRail(_ label: String, progress: Int, total: Int) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.mutedText)
                .frame(width: 36, alignment: .leading)
            BeadRail(progress: progress, total: total)
        }
    }
}

#Preview {
    DesignSystemPreviewView()
}
#endif
