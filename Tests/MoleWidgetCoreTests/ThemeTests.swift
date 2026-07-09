import SwiftUI
import Testing
@testable import MoleWidgetCore

struct ThemeTests {
    @Test func barColor_lowLoad_isSystemGreen() {
        #expect(Theme.barColor(for: 0.0) == .green)
        #expect(Theme.barColor(for: 0.59) == .green)
    }

    @Test func barColor_midLoad_isSystemYellow() {
        #expect(Theme.barColor(for: 0.6) == .yellow)
        #expect(Theme.barColor(for: 0.84) == .yellow)
    }

    @Test func barColor_highLoad_isSystemRed() {
        #expect(Theme.barColor(for: 0.85) == .red)
        #expect(Theme.barColor(for: 1.0) == .red)
    }
}
