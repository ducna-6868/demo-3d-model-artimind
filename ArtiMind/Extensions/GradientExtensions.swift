import SwiftUI

extension LinearGradient {
    static var pastelBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.90, blue: 1.0),
                Color(red: 0.88, green: 0.92, blue: 1.0),
                Color(red: 0.92, green: 0.96, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warmBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.93, blue: 0.88),
                Color(red: 0.98, green: 0.88, blue: 0.92),
                Color(red: 0.95, green: 0.90, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var darkVibrant: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.05, blue: 0.18),
                Color(red: 0.12, green: 0.08, blue: 0.25),
                Color(red: 0.05, green: 0.10, blue: 0.20)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var companion3DBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.03, blue: 0.12),
                Color(red: 0.10, green: 0.06, blue: 0.20),
                Color(red: 0.03, green: 0.08, blue: 0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    func hideMainTabBar() -> some View {
        self.toolbarVisibility(.hidden, for: .tabBar)
    }

    func showMainTabBar() -> some View {
        self.toolbarVisibility(.visible, for: .tabBar)
    }
}
