import AppKit
import SwiftUI
import Testing
@testable import MoleWidgetCore

@MainActor
struct BarViewTests {
    /// In dark mode the label over a full yellow fill must be drawn dark:
    /// primary (white) text on yellow is unreadable.
    @Test func labelOverFill_inDarkMode_isDark() throws {
        let bar = BarView(fraction: 1, color: .yellow, label: "88.8%")
            .frame(width: 120)
            .environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: bar)
        renderer.scale = 4
        let image = try #require(renderer.cgImage)
        let rep = NSBitmapImageRep(cgImage: image)

        var darkPixels = 0
        for x in 0..<rep.pixelsWide {
            for y in 0..<rep.pixelsHigh {
                guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.sRGB),
                      c.alphaComponent > 0.9 else { continue }
                let luminance = 0.2126 * c.redComponent + 0.7152 * c.greenComponent + 0.0722 * c.blueComponent
                if luminance < 0.35 { darkPixels += 1 }
            }
        }
        #expect(darkPixels > 50)
    }
}
