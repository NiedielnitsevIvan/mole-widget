import Foundation
import Testing
@testable import MoleWidgetCore

struct WidgetSnapshotTests {
    @Test func percentText_value_matchesFmt() {
        #expect(WidgetSnapshot.percentText(0.716) == Fmt.percent(0.716))
    }

    @Test func percentText_nil_isDash() {
        #expect(WidgetSnapshot.percentText(nil) == "—")
    }

    @Test func uptimeText_nil_isDash() {
        let snap = WidgetSnapshot(
            date: .now, healthScore: 100, cpuFraction: nil, memFraction: nil,
            memUsed: nil, memTotal: nil, diskFraction: nil, uptime: nil
        )
        #expect(snap.uptimeText == "—")
    }

    @Test func uptimeText_value_matchesSystemInfoFormat() {
        let snap = WidgetSnapshot(
            date: .now, healthScore: 100, cpuFraction: nil, memFraction: nil,
            memUsed: nil, memTotal: nil, diskFraction: nil, uptime: 3_660
        )
        #expect(snap.uptimeText == SystemInfoSnapshot.formatUptime(3_660))
    }

    @Test func asOfText_containsTime() {
        let date = Calendar.current.date(
            bySettingHour: 14, minute: 5, second: 0, of: .now
        )!
        let snap = WidgetSnapshot(
            date: date, healthScore: 100, cpuFraction: nil, memFraction: nil,
            memUsed: nil, memTotal: nil, diskFraction: nil, uptime: nil
        )
        #expect(snap.asOfText.contains("14:05") || snap.asOfText.contains("2:05"))
    }

    private func makeSnap(
        loadAverage: [Double] = [],
        memUsed: UInt64? = nil,
        memTotal: UInt64? = nil
    ) -> WidgetSnapshot {
        WidgetSnapshot(
            date: .now, healthScore: 100, cpuFraction: nil, memFraction: nil,
            memUsed: memUsed, memTotal: memTotal, diskFraction: nil, uptime: nil,
            loadAverage: loadAverage
        )
    }

    @Test func loadText_threeValues_formatted() {
        #expect(makeSnap(loadAverage: [3.85, 3.51, 3.63]).loadText == "3.85 / 3.51 / 3.63")
    }

    @Test func loadText_tooFewValues_isDash() {
        #expect(makeSnap(loadAverage: [1.0]).loadText == "—")
        #expect(makeSnap().loadText == "—")
    }

    @Test func memTotalText_values_formatted() {
        let snap = makeSnap(memUsed: 11_900_000_000, memTotal: 16_000_000_000)
        #expect(snap.memTotalText == "\(Fmt.gigabytes(11_900_000_000)) / \(Fmt.gigabytes(16_000_000_000))")
    }

    @Test func memTotalText_nil_isDash() {
        #expect(makeSnap().memTotalText == "—")
    }

    @Test func gbText_nil_isDash_value_formats() {
        #expect(WidgetSnapshot.gbText(nil) == "—")
        #expect(WidgetSnapshot.gbText(2_300_000_000) == Fmt.gigabytes(2_300_000_000))
    }
}
