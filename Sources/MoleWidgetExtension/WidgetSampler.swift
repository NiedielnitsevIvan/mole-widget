import Foundation
import MoleWidgetCore

/// Samples system metrics for one timeline entry. CPU needs two tick
/// readings to compute a delta; `full()` blocks ~1 s for that and must not
/// run on the main thread. `instant()` is cheap (no CPU/core values) and
/// safe anywhere — used for gallery placeholders/snapshots.
enum WidgetSampler {
    /// Rolling CPU history persisted between short-lived appex launches.
    private static let historyKey = "widgetCPUHistory"
    private static let historyCap = 40

    static func instant() -> WidgetSnapshot {
        make(cpuFraction: nil, topCores: [], history: storedHistory())
    }

    static func full() -> WidgetSnapshot {
        let collector = CPUCollector()
        var cpu: Double?
        var topCores: [CoreUsage] = []
        if let first = collector.sampleTicks() {
            Thread.sleep(forTimeInterval: 1.0)
            if let second = collector.sampleTicks() {
                cpu = CPUUsage.total(previous: first, current: second)
                let perCore = CPUUsage.perCore(previous: first, current: second)
                topCores = CPUUsage.topCores(perCore, count: 3)
            }
        }
        var history = storedHistory()
        if let cpu {
            history.append(cpu)
            history = Array(history.suffix(historyCap))
            UserDefaults.standard.set(history, forKey: historyKey)
        }
        return make(cpuFraction: cpu, topCores: topCores, history: history)
    }

    private static func storedHistory() -> [Double] {
        (UserDefaults.standard.array(forKey: historyKey) as? [Double]) ?? []
    }

    private static func make(
        cpuFraction: Double?, topCores: [CoreUsage], history: [Double]
    ) -> WidgetSnapshot {
        let mem = MemoryCollector().sample()
        let disk = DiskCollector().usage(path: "/")
        let info = SystemInfoCollector().sample()
        // Denied by the sandbox unless the IOKit exception applies — nil hides the row.
        let temperature = SMCTemperature().cpuTemperature()
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
            uptime: info?.uptime,
            temperature: temperature,
            topCores: topCores,
            loadAverage: CPUCollector().loadAverage(),
            cpuHistory: history,
            memFreeFraction: mem?.freeFraction,
            memCached: mem?.cached,
            memAvailable: mem?.available
        )
    }
}
