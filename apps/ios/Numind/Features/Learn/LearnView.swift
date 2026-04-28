import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    @EnvironmentObject private var progressStore: ProgressStore

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

            Text("More modules arrive soon")
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.mutedText)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }

    private func moduleCard(_ module: Module) -> some View {
        let progress = progressStore.moduleProgress(
            moduleId: module.id,
            totalLessons: module.lessonIds.count
        )
        return NumindCard(background: module.color.tintBackground) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    IconTile(systemName: module.icon, tintColor: module.color.tintColor, size: 56)
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
                        Capsule().fill(Theme.Colors.mutedText.opacity(0.15))
                        Capsule()
                            .fill(module.color.tintColor)
                            .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(module.lessonIds.count) lessons")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                    Text(progress > 0 ? "\(Int(progress * 100))%" : "Not started")
                        .font(Theme.Typography.small)
                        .foregroundStyle(progress > 0 ? module.color.tintColor : Theme.Colors.mutedText)
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
