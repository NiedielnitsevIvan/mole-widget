import Foundation

/// Top processes handed from the app to the widget: the widget's sandbox
/// denies listing other processes (`process-info-listpids`). The app writes
/// the list on every widget reload; the widget reads it while it is fresh.
public struct SharedProcesses {
    private struct Payload: Codable {
        let date: Date
        let processes: [ProcessUsage]
    }

    /// Older lists mean the app is not running.
    private static let maxAge: TimeInterval = 30

    private let fileURL: URL

    public init(
        fileURL: URL = UsageHistoryPersistence.defaultDirectory.appendingPathComponent("top-processes.json")
    ) {
        self.fileURL = fileURL
    }

    /// Best-effort: a failed write only leaves the widget's list stale.
    public func write(_ processes: [ProcessUsage], at date: Date = .now) {
        guard let data = try? JSONEncoder().encode(Payload(date: date, processes: processes)) else { return }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? data.write(to: fileURL, options: .atomic)
    }

    /// The written list, or empty when it is missing or stale.
    public func read(now: Date = .now) -> [ProcessUsage] {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data),
              // A future date (clock moved back) is not fresh either.
              (0...Self.maxAge).contains(now.timeIntervalSince(payload.date))
        else { return [] }
        return payload.processes
    }
}
