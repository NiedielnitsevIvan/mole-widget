import Foundation
import Testing
@testable import MoleWidgetCore

struct SharedProcessesTests {
    @Test func read_returnsFreshList_emptyWhenMissingOrStale() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("top-processes.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let shared = SharedProcesses(fileURL: url)
        #expect(shared.read().isEmpty)

        let processes = [ProcessUsage(pid: 42, name: "Safari", cpuFraction: 0.5, memoryBytes: 1_000)]
        let written = Date(timeIntervalSince1970: 1_000)
        shared.write(processes, at: written)
        #expect(shared.read(now: written.addingTimeInterval(10)) == processes)
        #expect(shared.read(now: written.addingTimeInterval(31)).isEmpty)
        #expect(shared.read(now: written.addingTimeInterval(-60)).isEmpty)
    }
}
