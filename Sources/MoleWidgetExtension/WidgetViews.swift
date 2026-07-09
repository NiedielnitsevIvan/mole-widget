import MoleWidgetCore
import SwiftUI
import WidgetKit

/// Sidebar widget content. Small: health + CPU/MEM bars.
/// Medium adds disk and an uptime/freshness footer.
struct SystemStatusView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot

    private var healthColor: Color {
        if snapshot.healthScore >= 80 { return Theme.accent }
        if snapshot.healthScore >= 50 { return Theme.warning }
        return Theme.danger
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("Health").fontWeight(.bold)
                Circle().fill(healthColor).frame(width: 7, height: 7)
                Text("\(snapshot.healthScore)")
                Spacer()
            }
            .font(.system(size: 12).weight(.medium))

            row("CPU", snapshot.cpuFraction)
            row("Memory", snapshot.memFraction)

            if family == .systemMedium {
                row("Disk", snapshot.diskFraction)
                HStack {
                    Text("up \(snapshot.uptimeText)")
                    Spacer()
                    Text(snapshot.asOfText)
                }
                .font(.system(size: 10))
                .foregroundStyle(Theme.dim)
            }
            Spacer(minLength: 0)
        }
    }

    private func row(_ label: String, _ fraction: Double?) -> some View {
        MetricRow(
            label: label,
            fraction: fraction ?? 0,
            value: WidgetSnapshot.percentText(fraction)
        )
        .font(.system(size: 11).weight(.medium).monospacedDigit())
    }
}
