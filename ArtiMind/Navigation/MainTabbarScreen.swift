import SwiftUI

struct MainTabbarScreen: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .home) {
                NavigationStack {
                    HomeScreen()
                }
            } label: {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }

            Tab(value: .lovedOnes) {
                NavigationStack {
                    LovedOnesListScreen()
                }
            } label: {
                Label(AppTab.lovedOnes.title, systemImage: AppTab.lovedOnes.icon)
            }

            Tab(value: .settings) {
                NavigationStack {
                    SettingsScreen()
                }
            } label: {
                Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
            }
        }
    }
}
