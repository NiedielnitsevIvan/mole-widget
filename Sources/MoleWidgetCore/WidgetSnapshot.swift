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

    public init(
        date: Date, healthScore: Int, cpuFraction: Double?, memFraction: Double?,
        memUsed: UInt64?, memTotal: UInt64?, diskFraction: Double?, uptime: TimeInterval?
    ) {
        self.date = date
        self.healthScore = healthScore
        self.cpuFraction = cpuFraction
        self.memFraction = memFraction
        self.memUsed = memUsed
        self.memTotal = memTotal
        self.diskFraction = diskFraction
        self.uptime = uptime
    }

    /// "71.6%" for a fraction, "—" for missing data.
    public static func percentText(_ fraction: Double?) -> String {
        fraction.map(Fmt.percent) ?? "—"
    }

    /// Formatted uptime ("5h 36m") or "—".
    public var uptimeText: String {
        uptime.map(SystemInfoSnapshot.formatUptime) ?? "—"
    }

    /// Freshness stamp, e.g. "as of 14:05" (locale-aware time).
    public var asOfText: String {
        "as of \(date.formatted(date: .omitted, time: .shortened))"
    }
}
