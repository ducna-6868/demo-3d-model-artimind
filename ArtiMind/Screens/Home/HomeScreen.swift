import SwiftUI

struct HomeScreen: View {
    @Environment(AppState.self) private var appState
    @State private var navigateToUpload = false

    var body: some View {
        ZStack {
            LinearGradient.pastelBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("ArtiMind")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Hero Card
                    NavigationLink(destination: UploadPhotoScreen()) {
                        GlassCard(cornerRadius: 24) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                        .foregroundStyle(.purple)
                                    Text("Create Companion")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }

                                Text("Transform a photo into a living, breathing 3D companion that speaks with warmth and love.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Start Creating")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .glassBackground(
                                    backgroundColor: .purple,
                                    opacity: 0.8,
                                    shape: .rounded(14),
                                    interactive: true
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)

                    // Stats Row
                    HStack(spacing: 12) {
                        GlassCard(cornerRadius: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: "waveform")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                Text("12 Voices")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text("Available")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        GlassCard(cornerRadius: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: "cube.transparent")
                                    .font(.title2)
                                    .foregroundStyle(.indigo)
                                Text("3D Model")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text("Powered")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Recent Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 20)

                        GlassCard(cornerRadius: 20) {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title)
                                    .foregroundStyle(.tertiary)
                                Text("No recent activity")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
    }
}
