import MoleWidgetCore
import SwiftUI
import WidgetKit

/// Sidebar widget content. Small: health + CPU/MEM/disk bars.
/// Medium: CPU + Memory columns. Large: the same columns, bigger, plus a
/// full-width Processes section.
struct SystemStatusView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot

    private var healthColor: Color {
        if snapshot.healthScore >= 80 { return Theme.accent }
        if snapshot.healthScore >= 50 { return Theme.warning }
        return Theme.danger
    }

    private var sizes: Sizes {
        switch family {
        case .systemMedium: .medium
        case .systemLarge: .large
        default: .small
        }
    }

    var body: some View {
        Group {
            switch family {
            case .systemMedium, .systemLarge: detailed
            default: small
            }
        }
        // Row labels, text rows, section titles and process rows.
        .font(.dot(sizes.label))
    }

    // MARK: - Small

    private var small: some View {
        VStack(alignment: .leading, spacing: sizes.spacing) {
            healthScore
            barRow("CPU", snapshot.cpuFraction)
            barRow("Memory", snapshot.memFraction)
            barRow("Disk", snapshot.diskFraction)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Medium and large

    private var detailed: some View {
        VStack(alignment: .leading, spacing: sizes.spacing) {
            HStack(spacing: 4) {
                healthScore
                Spacer()
                Text("\(snapshot.uptimeText) · \(snapshot.asOfText)")
                    .font(.dot(sizes.subheader))
                    .foregroundStyle(Theme.dim)
            }
            HStack(alignment: .top, spacing: 12) {
                cpuColumn.frame(maxWidth: .infinity, alignment: .leading)
                memoryColumn.frame(maxWidth: .infinity, alignment: .leading)
            }
            if family == .systemLarge {
                ProcessesSectionView(processes: snapshot.topProcesses, limit: 5)
            }
            Spacer(minLength: 0)
        }
    }

    /// "Health ● 100".
    private var healthScore: some View {
        HStack(spacing: 4) {
            Text("Health")
            Circle().fill(healthColor).frame(width: sizes.header / 2, height: sizes.header / 2)
            Text("\(snapshot.healthScore)")
        }
        .font(.dot(sizes.header))
    }

    private var cpuColumn: some View {
        SectionView(icon: "◉", title: "CPU") {
            barRow("Total", snapshot.cpuFraction)
            if let temp = snapshot.temperature {
                barRow("Temp", min(temp / 100, 1.0), value: String(format: "%.0f°C", temp))
            }
            ForEach(snapshot.topCores, id: \.index) { core in
                barRow("Core\(core.index + 1)", core.usage)
            }
            HStack(spacing: sizes.gap) {
                rowLabel("Trend")
                SparklineView(values: snapshot.cpuHistory, color: Theme.accent)
                    .frame(height: sizes.trend)
            }
        }
    }

    private var memoryColumn: some View {
        SectionView(icon: "▥", title: "Memory") {
            barRow("Used", snapshot.memFraction)
            barRow("Free", snapshot.memFreeFraction, color: Theme.accent)
            textRow("Total", snapshot.memTotalText)
            textRow("Cached", WidgetSnapshot.gbText(snapshot.memCached))
            textRow("Avail", WidgetSnapshot.gbText(snapshot.memAvailable))
        }
    }

    /// Label, then a bar with the value inside.
    private func barRow(
        _ label: String, _ fraction: Double?, color: Color? = nil, value: String? = nil
    ) -> some View {
        HStack(spacing: sizes.gap) {
            rowLabel(label)
            BarView(
                fraction: fraction ?? 0,
                color: color,
                label: value ?? WidgetSnapshot.percentText(fraction),
                height: sizes.bar,
                labelFont: .dot(sizes.value)
            )
        }
    }

    private func textRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: sizes.gap) {
            rowLabel(label)
            Text(value).lineLimit(1)
        }
    }

    private func rowLabel(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Theme.text)
            .lineLimit(1)
            .frame(width: sizes.labelWidth, alignment: .leading)
    }
}

/// Text and bar sizes per widget family, in points. Doto glyphs are 0.6 em
/// wide: "12.3/16.0 GB" plus its label must fit a 150 pt column.
private struct Sizes {
    var label: CGFloat      // row labels, text rows, section titles, processes
    var labelWidth: CGFloat
    var gap: CGFloat        // between a label and its bar or value
    var bar: CGFloat        // bar height
    var value: CGFloat      // value inside a bar
    var header: CGFloat     // "Health ● 100"
    var subheader: CGFloat  // "up 1d 7h · as of 16:47"
    var spacing: CGFloat    // between the widget's blocks
    var trend: CGFloat      // sparkline height

    // The small widget has no subheader or trend row.
    static let small = Sizes(label: 13, labelWidth: 50, gap: 6, bar: 22, value: 12,
                             header: 15, subheader: 0, spacing: 12, trend: 0)
    static let medium = Sizes(label: 10, labelWidth: 40, gap: 4, bar: 12, value: 9,
                              header: 13, subheader: 10, spacing: 5, trend: 12)
    static let large = Sizes(label: 12, labelWidth: 48, gap: 6, bar: 18, value: 11,
                             header: 16, subheader: 11, spacing: 8, trend: 14)
}

private extension Font {
    /// Dot-matrix font bundled in the appex (Resources/Fonts, registered
    /// through ATSApplicationFontsPath); falls back to the system font.
    static func dot(_ size: CGFloat) -> Font {
        .custom("DotoRounded-Regular", size: size)
    }
}
