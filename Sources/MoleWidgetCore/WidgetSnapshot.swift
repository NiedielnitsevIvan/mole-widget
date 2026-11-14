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
    public let cpuHistory: [Double]
    public let memFreeFraction: Double?
    public let memCached: UInt64?
    public let memAvailable: UInt64?
    public let topProcesses: [ProcessUsage]

    public init(
        date: Date, healthScore: Int, cpuFraction: Double?, memFraction: Double?,
        memUsed: UInt64?, memTotal: UInt64?, diskFraction: Double?, uptime: TimeInterval?,
        temperature: Double? = nil, topCores: [CoreUsage] = [],
        cpuHistory: [Double] = [],
        memFreeFraction: Double? = nil, memCached: UInt64? = nil,
        memAvailable: UInt64? = nil, topProcesses: [ProcessUsage] = []
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
        self.cpuHistory = cpuHistory
        self.memFreeFraction = memFreeFraction
        self.memCached = memCached
        self.memAvailable = memAvailable
        self.topProcesses = topProcesses
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

    /// "11.9/16.0 GB" (compact to fit a widget column) or "—" when either side is missing.
    public var memTotalText: String {
        guard let memUsed, let memTotal else { return "—" }
        return "\(Fmt.gigabytesNumber(memUsed))/\(Fmt.gigabytes(memTotal))"
    }

    /// Formatted byte count ("2.3 GB") or "—".
    public static func gbText(_ bytes: UInt64?) -> String {
        bytes.map(Fmt.gigabytes) ?? "—"
    }
}
