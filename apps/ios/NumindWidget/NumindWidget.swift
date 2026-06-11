import WidgetKit
import SwiftUI

// MARK: - Timeline

struct NumindEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct NumindProvider: TimelineProvider {

    private var placeholderSnapshot: WidgetSnapshot {
        WidgetSnapshot(ringProgress: 0.6, ringClosed: false, streak: 4,
                       momentTitle: nil, momentSubtitle: nil)
    }

    private var current: NumindEntry {
        NumindEntry(date: Date(), snapshot: WidgetSnapshot.load() ?? placeholderSnapshot)
    }

    func placeholder(in context: Context) -> NumindEntry {
        NumindEntry(date: Date(), snapshot: placeholderSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (NumindEntry) -> Void) {
        completion(current)
    }

    // Single entry; the app reloads timelines on every progress write, so
    // the widget never needs to predict the future.
    func getTimeline(in context: Context, completion: @escaping (Timeline<NumindEntry>) -> Void) {
        completion(Timeline(entries: [current], policy: .atEnd))
    }
}

// MARK: - Palette (self-contained — the app's Theme isn't compiled here)

private enum WidgetPalette {
    static let deepNavy = Color(red: 0x10 / 255.0, green: 0x22 / 255.0, blue: 0x4A / 255.0)
    static let mindTeal = Color(red: 0x2D / 255.0, green: 0xC6 / 255.0, blue: 0xB6 / 255.0)
    static let insightYellow = Color(red: 1.0, green: 0xD8 / 255.0, blue: 0x4D / 255.0)
}

// MARK: - Ring

struct WidgetRing: View {
    let progress: Double
    let closed: Bool
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .stroke(WidgetPalette.mindTeal.opacity(0.25), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.02, min(1, progress)))
                .stroke(closed ? WidgetPalette.insightYellow : WidgetPalette.mindTeal,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if closed {
                Image(systemName: "checkmark")
                    .font(.system(size: lineWidth * 1.8, weight: .bold))
                    .foregroundStyle(WidgetPalette.insightYellow)
            }
        }
    }
}

// MARK: - Views per family

struct NumindWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NumindEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            WidgetRing(progress: entry.snapshot.ringProgress,
                       closed: entry.snapshot.ringClosed, lineWidth: 5)
                .containerBackground(for: .widget) { Color.clear }

        case .accessoryRectangular:
            HStack(spacing: 8) {
                WidgetRing(progress: entry.snapshot.ringProgress,
                           closed: entry.snapshot.ringClosed, lineWidth: 4)
                    .frame(width: 26, height: 26)
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.snapshot.ringClosed ? "Ring closed" : "Today's ring")
                        .font(.system(size: 13, weight: .semibold))
                    if let title = entry.snapshot.momentTitle {
                        Text(title)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    } else if entry.snapshot.streak > 0 {
                        Text("\(entry.snapshot.streak)-day streak")
                            .font(.system(size: 11))
                    }
                }
                Spacer(minLength: 0)
            }
            .containerBackground(for: .widget) { Color.clear }

        default: // systemSmall
            VStack(spacing: 8) {
                WidgetRing(progress: entry.snapshot.ringProgress,
                           closed: entry.snapshot.ringClosed, lineWidth: 7)
                    .frame(width: 56, height: 56)

                if entry.snapshot.streak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WidgetPalette.insightYellow)
                        Text("\(entry.snapshot.streak) days")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WidgetPalette.deepNavy)
                    }
                }

                if let title = entry.snapshot.momentTitle {
                    VStack(spacing: 0) {
                        Text(title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(WidgetPalette.deepNavy)
                            .lineLimit(1)
                        if let subtitle = entry.snapshot.momentSubtitle {
                            Text(subtitle)
                                .font(.system(size: 9))
                                .foregroundStyle(WidgetPalette.deepNavy.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                } else {
                    Text(entry.snapshot.ringClosed ? "Back to sharp" : "5 minutes keeps it sharp")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(WidgetPalette.deepNavy.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .containerBackground(for: .widget) { Color(white: 0.98) }
        }
    }
}

// MARK: - Widget + bundle

struct NumindRingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NumindRingWidget", provider: NumindProvider()) { entry in
            NumindWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily ring")
        .description("Your practice ring, streak, and the next money moment.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}

@main
struct NumindWidgetBundle: WidgetBundle {
    var body: some Widget {
        NumindRingWidget()
    }
}
