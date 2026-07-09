import SwiftUI

/// Horizontal capacity bar: filled portion on a dimmed track, with an
/// optional value label rendered inside the bar, right-aligned.
public struct BarView: View, Equatable {
    let fraction: Double
    var color: Color?
    var label: String?
    var height: CGFloat

    public init(fraction: Double, color: Color? = nil, label: String? = nil, height: CGFloat = 16) {
        self.fraction = fraction
        self.color = color
        self.label = label
        self.height = height
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
                    Text(label)
                        .font(.system(size: height >= 14 ? 10 : 8, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .padding(.trailing, 4)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height * 5 / 16))
    }
}
