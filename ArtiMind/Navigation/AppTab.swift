import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case lovedOne
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .lovedOne: return "Loved One"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .lovedOne: return "heart.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
