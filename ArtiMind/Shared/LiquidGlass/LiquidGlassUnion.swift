import SwiftUI

struct LiquidGlassUnionModifier: ViewModifier {
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        content
            .glassEffectUnion(id: "glass-union", namespace: namespace)
    }
}

extension View {
    func liquidGlassUnion(namespace: Namespace.ID) -> some View {
        modifier(LiquidGlassUnionModifier(namespace: namespace))
    }
}
