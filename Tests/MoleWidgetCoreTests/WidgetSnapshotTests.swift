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
}
