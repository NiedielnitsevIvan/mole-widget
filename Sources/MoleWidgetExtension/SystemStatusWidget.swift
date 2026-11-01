import MoleWidgetCore
import SwiftUI
import WidgetKit

struct SystemStatusEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct SystemStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> SystemStatusEntry {
        SystemStatusEntry(date: .now, snapshot: WidgetSampler.instant())
    }

    func getSnapshot(in context: Context, completion: @escaping (SystemStatusEntry) -> Void) {
        completion(SystemStatusEntry(date: .now, snapshot: WidgetSampler.instant()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SystemStatusEntry>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let snapshot = WidgetSampler.full()
            let entry = SystemStatusEntry(date: snapshot.date, snapshot: snapshot)
            // The running Mole app nudges reloads every minute; on our own
            // we ask for a refresh in 5 min and take what the budget gives.
            let timeline = Timeline(
                entries: [entry],
                policy: .after(Date.now.addingTimeInterval(300))
            )
            completion(timeline)
        }
    }
}

struct SystemStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MoleSystemStatus",
            provider: SystemStatusProvider()
        ) { entry in
            SystemStatusView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) { WidgetGlassBackground() }
        }
        .configurationDisplayName("Mole System Status")
        .description("CPU, memory and disk at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Liquid Glass widget background, matching the desktop panel
/// (see WidgetBackground in WidgetRootView). Pre-macOS 26 fallback:
/// a translucent material.
private struct WidgetGlassBackground: View {
    var body: some View {
        if #available(macOS 26, *) {
            Color.clear.glassEffect(.regular, in: .rect)
        } else {
            Rectangle().fill(.regularMaterial)
        }
    }
}
