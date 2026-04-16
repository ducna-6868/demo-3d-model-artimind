import SwiftUI

@main
struct ArtiMindApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
    }
}

@Observable
final class AppState {
    var hasCompletedOnboarding = false
    var selectedLovedOne: LovedOne?
    var currentFlow: AppFlow = .splash
}

enum AppFlow {
    case splash
    case onboarding
    case main
}
