import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case lovedOnes
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .lovedOnes: return "Loved Ones"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .lovedOnes: return "heart.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
