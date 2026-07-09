import Foundation
import MoleWidgetCore

/// Samples system metrics for one timeline entry. CPU needs two tick
/// readings to compute a delta; `full()` blocks ~1 s for that and must not
/// run on the main thread. `instant()` is cheap (no CPU value) and safe
/// anywhere — used for gallery placeholders/snapshots.
enum WidgetSampler {
    static func instant() -> WidgetSnapshot {
        make(cpuFraction: nil)
    }

    static func full() -> WidgetSnapshot {
        let collector = CPUCollector()
        var cpu: Double?
        if let first = collector.sampleTicks() {
            Thread.sleep(forTimeInterval: 1.0)
            if let second = collector.sampleTicks() {
                cpu = CPUUsage.total(previous: first, current: second)
            }
        }
        return make(cpuFraction: cpu)
    }

    private static func make(cpuFraction: Double?) -> WidgetSnapshot {
        let mem = MemoryCollector().sample()
        let disk = DiskCollector().usage(path: "/")
        let info = SystemInfoCollector().sample()
        let health = HealthScore.compute(
            cpu: cpuFraction,
            memUsedFraction: mem?.usedFraction,
            diskUsedFraction: disk?.usedFraction,
            batteryHealth: nil,
            batteryLevel: nil,
            isCharging: false
        )
        return WidgetSnapshot(
            date: .now,
            healthScore: health,
            cpuFraction: cpuFraction,
            memFraction: mem?.usedFraction,
            memUsed: mem?.used,
            memTotal: mem?.total,
            diskFraction: disk?.usedFraction,
            uptime: info?.uptime
        )
    }
}
