import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        switch appState.currentFlow {
        case .splash:
            SplashScreen()
        case .onboarding:
            OnboardingScreen()
        case .main:
            MainTabbarScreen()
        }
    }
}
