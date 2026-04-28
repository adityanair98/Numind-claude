import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                sectionLabel("Modules")
                moduleList
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.sectionSpacing)
        }
        .background(Theme.Colors.softBackground.ignoresSafeArea())
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
    }

    private var moduleList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.modules.enumerated()), id: \.element.id) { index, module in
                NavigationLink(destination: ModuleDetailView(
                    module: module,
                    moduleIndex: index,
                    totalModules: viewModel.modules.count
                )) {
                    moduleCard(module)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func moduleCard(_ module: Module) -> some View {
        NumindCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    IconTile(systemName: module.icon, tintColor: module.color.tintColor)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(module.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.deepNavy)
                        Text(module.subtitle)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.mutedText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.mutedText)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Colors.mutedTint)
                        Capsule()
                            .fill(module.color.tintColor)
                            .frame(width: 0) // M7: replace with real progress
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(module.lessonIds.count) lessons")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                    Text("Not started")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Colors.mutedText)
            .kerning(0.8)
    }
}

#Preview {
    NavigationStack {
        LearnView()
    }
}
