import SwiftUI

struct MainTabbarScreen: View {
    @State private var selectedTab: AppTab = .lovedOne

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .home) {
                NavigationStack {
                    HomeScreen()
                }
            } label: {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }

            Tab(value: .lovedOne) {
                NavigationStack {
                    LovedOnesListScreen()
                }
            } label: {
                Label(AppTab.lovedOne.title, systemImage: AppTab.lovedOne.icon)
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
