import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sectionSpacing) {
                Text("Pick a module and start building your number sense.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.mutedText)
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
        let lessonCount = module.lessonIds.count
        let completedCount = Int((progress * Double(lessonCount)).rounded())

        return VStack(spacing: 0) {
            // ── Illustration header ──────────────────────────────────────
            ZStack {
                module.color.tintBackground

                // Decorative blobs (illustration placeholder)
                Circle()
                    .fill(module.color.tintColor.opacity(0.18))
                    .frame(width: 110, height: 110)
                    .offset(x: 90, y: -30)
                Circle()
                    .fill(module.color.tintColor.opacity(0.12))
                    .frame(width: 70, height: 70)
                    .offset(x: -90, y: 35)
                Circle()
                    .fill(module.color.tintColor.opacity(0.10))
                    .frame(width: 40, height: 40)
                    .offset(x: 30, y: 36)

                // Large centered icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.55))
                        .frame(width: 68, height: 68)
                    Image(systemName: module.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(module.color.tintColor)
                }

                // Lesson count badge — top trailing
                VStack {
                    HStack {
                        Spacer()
                        Text("\(lessonCount) lessons")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(module.color.tintColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.7))
                            .clipShape(Capsule())
                            .padding(14)
                    }
                    Spacer()
                }

                // Chevron — bottom trailing
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(module.color.tintColor.opacity(0.6))
                            .padding(14)
                    }
                }
            }
            .frame(height: 110)
            .clipped()

            // ── Content section ──────────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(module.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.deepNavy)
                    Text(module.subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.mutedText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Colors.mutedText.opacity(0.12))
                        Capsule()
                            .fill(module.color.tintColor)
                            .frame(width: geo.size.width * CGFloat(min(progress, 1)))
                    }
                }
                .frame(height: 5)

                HStack {
                    Text(completedCount > 0
                         ? "\(completedCount) of \(lessonCount) done"
                         : "Not started")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Colors.mutedText)
                    Spacer()
                    if progress > 0 {
                        Text("\(Int((progress * 100).rounded()))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(module.color.tintColor)
                    }
                }
            }
            .padding(16)
            .background(Theme.Colors.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }

}

#Preview {
    NavigationStack {
        LearnView()
    }
}
