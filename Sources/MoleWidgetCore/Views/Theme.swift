import SwiftUI

/// System-semantic palette — the widget follows the macOS appearance
/// (Liquid Glass chrome, light/dark adaptive) instead of a fixed theme.
public enum Theme {
    /// Legacy fixed-dark panel color; deleted with its last caller.
    public static let background = Color(red: 0.118, green: 0.133, blue: 0.188)

    public static let header = Color.primary
    public static let accent = Color.green
    public static let warning = Color.yellow
    public static let danger = Color.red
    public static let text = Color.primary
    public static let dim = Color.secondary

    /// Second data-series color (memory chart line, upload sparkline) —
    /// the adaptive relative of the old lavender.
    public static let accentSecondary = Color.purple

    /// Base widget font. Size and style are user-configurable; the monospaced
    /// style keeps column alignment, the system style reads more natively while
    /// `.monospacedDigit()` still stops numbers from jittering as they tick.
    public static func font(size: Double, style: WidgetSettings.FontStyle) -> Font {
        switch style {
        case .monospaced: Font.system(size: size, design: .monospaced).weight(.medium)
        case .system:     Font.system(size: size).weight(.medium).monospacedDigit()
        }
    }

    public static let font = font(size: WidgetSettings.defaultFontSize, style: WidgetSettings.defaultFontStyle)

    /// Higher load maps to a more alarming color.
    public static func barColor(for fraction: Double) -> Color {
        switch fraction {
        case ..<0.6: accent
        case ..<0.85: warning
        default: danger
        }
    }
}
