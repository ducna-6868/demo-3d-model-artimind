import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        List {
            Section("Account") {
                Label("Profile", systemImage: "person.fill")
                Label("Privacy", systemImage: "lock.fill")
            }

            Section("Companion") {
                Label("Voice Settings", systemImage: "waveform")
                Label("3D Model Quality", systemImage: "cube.fill")
            }

            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle.fill")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                Label("Rate App", systemImage: "star.fill")
                Label("Privacy Policy", systemImage: "doc.text.fill")
            }
        }
        .navigationTitle("Settings")
    }
}
