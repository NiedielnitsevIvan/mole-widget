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
            // The running Mole app nudges reloads every 5 s; on our own
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
            // No containerBackground, like Apple's Batteries widget: any custom
            // background, even a clear one, replaces the system's frosted glass.
            SystemStatusView(snapshot: entry.snapshot)
        }
        .configurationDisplayName("Mole System Status")
        .description("CPU, memory and disk at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        // The system glass platter of Apple's own widgets. Public API only gets
        // an opaque platter: glassEffect in containerBackground renders white.
        // ponytail: private WidgetKit API, may change in a future macOS.
        .preferredBackgroundStyle(.blur)
    }
}
