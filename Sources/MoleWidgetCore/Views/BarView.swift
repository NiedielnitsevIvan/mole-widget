import SwiftUI

/// Horizontal capacity bar: filled portion on a dimmed track, with an
/// optional value label rendered inside the bar, right-aligned.
public struct BarView: View, Equatable {
    let fraction: Double
    var color: Color?
    var label: String?
    var height: CGFloat
    var labelFont: Font?

    public init(
        fraction: Double, color: Color? = nil, label: String? = nil,
        height: CGFloat = 16, labelFont: Font? = nil
    ) {
        self.fraction = fraction
        self.color = color
        self.label = label
        self.height = height
        self.labelFont = labelFont
    }

    public var body: some View {
        let clamped = min(max(fraction, 0), 1)
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Theme.dim.opacity(0.25))
                HStack {
                    Rectangle()
                        .fill(color ?? Theme.barColor(for: clamped))
                        .frame(width: geo.size.width * clamped)
                    Spacer(minLength: 0)
                }
                if let label {
                    // Dark over the fill, primary over the track: white text on
                    // a yellow fill is unreadable in dark mode.
                    labelText(label).foregroundStyle(Color.primary)
                    labelText(label).foregroundStyle(Color.black.opacity(0.85))
                        .mask(alignment: .leading) {
                            Rectangle().frame(width: geo.size.width * clamped)
                        }
                        .accessibilityHidden(true)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height * 5 / 16))
    }

    private func labelText(_ label: String) -> some View {
        Text(label)
            .font(labelFont ?? .system(size: height >= 14 ? 10 : 8, weight: .semibold))
            .monospacedDigit()
            .lineLimit(1)
            .padding(.trailing, 4)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
