import MoleWidgetCore
import SwiftUI
import WidgetKit

/// Sidebar widget content. Small: health + CPU/MEM bars.
/// Medium: the desktop widget's full S preset (CPU + Memory columns).
struct SystemStatusView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot

    private var healthColor: Color {
        if snapshot.healthScore >= 80 { return Theme.accent }
        if snapshot.healthScore >= 50 { return Theme.warning }
        return Theme.danger
    }

    var body: some View {
        switch family {
        case .systemMedium: medium
        default: small
        }
    }

    // MARK: - Small (unchanged from before: MetricRow-based)

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            healthLine
            MetricRow(
                label: "CPU",
                fraction: snapshot.cpuFraction ?? 0,
                value: WidgetSnapshot.percentText(snapshot.cpuFraction)
            )
            .font(.system(size: 11).weight(.medium).monospacedDigit())
            MetricRow(
                label: "Memory",
                fraction: snapshot.memFraction ?? 0,
                value: WidgetSnapshot.percentText(snapshot.memFraction)
            )
            .font(.system(size: 11).weight(.medium).monospacedDigit())
            Spacer(minLength: 0)
        }
    }

    // MARK: - Medium (full S preset)

    private var medium: some View {
        VStack(alignment: .leading, spacing: 5) {
            header
            HStack(alignment: .top, spacing: 12) {
                cpuColumn.frame(maxWidth: .infinity, alignment: .leading)
                memoryColumn.frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
    }

    private var healthLine: some View {
        HStack(spacing: 4) {
            Text("Health").fontWeight(.bold)
            Circle().fill(healthColor).frame(width: 7, height: 7)
            Text("\(snapshot.healthScore)")
            Spacer()
        }
        .font(.system(size: 12).weight(.medium))
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text("Health").fontWeight(.bold)
            Circle().fill(healthColor).frame(width: 7, height: 7)
            Text("\(snapshot.healthScore)")
            Spacer()
            Text("up \(snapshot.uptimeText) · \(snapshot.asOfText)")
                .font(.system(size: 9))
                .foregroundStyle(Theme.dim)
        }
        .font(.system(size: 12).weight(.medium))
    }

    private var cpuColumn: some View {
        VStack(alignment: .leading, spacing: 3) {
            columnTitle("CPU")
            CompactRow(label: "Total", fraction: snapshot.cpuFraction)
            if let temp = snapshot.temperature {
                CompactRow(
                    label: "Temp",
                    fraction: min(temp / 100, 1.0),
                    valueOverride: String(format: "%.0f°C", temp)
                )
            }
            ForEach(snapshot.topCores, id: \.index) { core in
                CompactRow(label: "Core\(core.index + 1)", fraction: core.usage)
            }
            textRow("Load", snapshot.loadText)
            HStack(spacing: 4) {
                compactLabel("Trend")
                SparklineView(values: snapshot.cpuHistory, color: Theme.accent)
                    .frame(height: 10)
            }
        }
    }

    private var memoryColumn: some View {
        VStack(alignment: .leading, spacing: 3) {
            columnTitle("Memory")
            CompactRow(label: "Used", fraction: snapshot.memFraction)
            CompactRow(label: "Free", fraction: snapshot.memFreeFraction, barColor: Theme.accent)
            textRow("Total", snapshot.memTotalText)
            textRow("Cached", WidgetSnapshot.gbText(snapshot.memCached))
            textRow("Avail", WidgetSnapshot.gbText(snapshot.memAvailable))
        }
    }

    private func columnTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Theme.dim)
    }

    private func textRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            compactLabel(label)
            Text(value)
                .font(.system(size: 9).weight(.medium))
                .monospacedDigit()
                .lineLimit(1)
        }
    }

    private func compactLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9).weight(.medium))
            .foregroundStyle(Theme.text)
            .lineLimit(1)
            .frame(width: 40, alignment: .leading)
    }
}

/// Dense metric row: 40 pt label, 4 pt gap, thin bar with inline value.
private struct CompactRow: View {
    let label: String
    let fraction: Double?
    var barColor: Color?
    var valueOverride: String?
    var height: CGFloat = 10

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9).weight(.medium))
                .foregroundStyle(Theme.text)
                .lineLimit(1)
                .frame(width: 40, alignment: .leading)
            BarView(
                fraction: fraction ?? 0,
                color: barColor,
                label: valueOverride ?? WidgetSnapshot.percentText(fraction),
                height: height
            )
        }
    }
}
