import SwiftUI

struct GlassButtonBackgroundModifier: ViewModifier {
    var backgroundColor: Color = .clear
    var opacity: Double = 1.0
    var style: GlassStyle = .regular
    var shape: ShapeType = .rounded(16)
    var enableBorder: Bool = false
    var borderColor: Color = .white
    var borderLineWidth: CGFloat = 1
    var interactive: Bool = false

    func body(content: Content) -> some View {
        content
            .background(backgroundColor.opacity(opacity))
            .modifier(GlassShapeModifier(shape: shape, interactive: interactive))
            .overlay {
                if enableBorder {
                    borderOverlay
                }
            }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch shape {
        case .circle:
            Circle().stroke(borderColor, lineWidth: borderLineWidth)
        case .capsule:
            Capsule().stroke(borderColor, lineWidth: borderLineWidth)
        case .rounded(let radius):
            RoundedRectangle(cornerRadius: radius).stroke(borderColor, lineWidth: borderLineWidth)
        }
    }
}

private struct GlassShapeModifier: ViewModifier {
    let shape: ShapeType
    let interactive: Bool

    func body(content: Content) -> some View {
        switch shape {
        case .circle:
            if interactive {
                content.glassEffect(.regular.interactive(), in: .circle)
            } else {
                content.glassEffect(.regular, in: .circle)
            }
        case .capsule:
            if interactive {
                content.glassEffect(.regular.interactive(), in: .capsule)
            } else {
                content.glassEffect(.regular, in: .capsule)
            }
        case .rounded(let radius):
            if interactive {
                content.glassEffect(.regular.interactive(), in: .rect(cornerRadius: radius))
            } else {
                content.glassEffect(.regular, in: .rect(cornerRadius: radius))
            }
        }
    }
}

extension View {
    nonisolated func glassBackground(
        backgroundColor: Color = .clear,
        opacity: Double = 1.0,
        style: GlassStyle = .regular,
        shape: ShapeType = .rounded(16),
        enableBorder: Bool = false,
        borderColor: Color = .white,
        borderLineWidth: CGFloat = 1,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassButtonBackgroundModifier(
            backgroundColor: backgroundColor,
            opacity: opacity,
            style: style,
            shape: shape,
            enableBorder: enableBorder,
            borderColor: borderColor,
            borderLineWidth: borderLineWidth,
            interactive: interactive
        ))
    }
}
