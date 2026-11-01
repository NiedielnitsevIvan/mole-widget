import Foundation

/// One sampled reading for the Notification Center widget: the numbers plus
/// the formatting the widget views render. Sampling lives in the appex;
/// this type stays pure so it is unit-testable.
public struct WidgetSnapshot {
    public let date: Date
    public let healthScore: Int
    public let cpuFraction: Double?
    public let memFraction: Double?
    public let memUsed: UInt64?
    public let memTotal: UInt64?
    public let diskFraction: Double?
    public let uptime: TimeInterval?
    public let temperature: Double?
    public let topCores: [CoreUsage]
    public let loadAverage: [Double]
    public let cpuHistory: [Double]
    public let memFreeFraction: Double?
    public let memCached: UInt64?
    public let memAvailable: UInt64?

    public init(
        date: Date, healthScore: Int, cpuFraction: Double?, memFraction: Double?,
        memUsed: UInt64?, memTotal: UInt64?, diskFraction: Double?, uptime: TimeInterval?,
        temperature: Double? = nil, topCores: [CoreUsage] = [],
        loadAverage: [Double] = [], cpuHistory: [Double] = [],
        memFreeFraction: Double? = nil, memCached: UInt64? = nil,
        memAvailable: UInt64? = nil
    ) {
        self.date = date
        self.healthScore = healthScore
        self.cpuFraction = cpuFraction
        self.memFraction = memFraction
        self.memUsed = memUsed
        self.memTotal = memTotal
        self.diskFraction = diskFraction
        self.uptime = uptime
        self.temperature = temperature
        self.topCores = topCores
        self.loadAverage = loadAverage
        self.cpuHistory = cpuHistory
        self.memFreeFraction = memFreeFraction
        self.memCached = memCached
        self.memAvailable = memAvailable
    }

    /// "71.6%" for a fraction, "—" for missing data.
    public static func percentText(_ fraction: Double?) -> String {
        fraction.map(Fmt.percent) ?? "—"
    }

    /// Formatted uptime ("up 5h 36m") or "—".
    public var uptimeText: String {
        uptime.map(SystemInfoSnapshot.formatUptime) ?? "—"
    }

    /// Freshness stamp, e.g. "as of 14:05" (locale-aware time).
    public var asOfText: String {
        "as of \(date.formatted(date: .omitted, time: .shortened))"
    }

    /// "3.85 / 3.51 / 3.63" or "—" when fewer than three values.
    public var loadText: String {
        guard loadAverage.count >= 3 else { return "—" }
        return String(format: "%.2f / %.2f / %.2f",
                      loadAverage[0], loadAverage[1], loadAverage[2])
    }

    /// "11.9 GB / 16.0 GB" or "—" when either side is missing.
    public var memTotalText: String {
        guard let memUsed, let memTotal else { return "—" }
        return "\(Fmt.gigabytes(memUsed)) / \(Fmt.gigabytes(memTotal))"
    }

    /// Formatted byte count ("2.3 GB") or "—".
    public static func gbText(_ bytes: UInt64?) -> String {
        bytes.map(Fmt.gigabytes) ?? "—"
    }
}
