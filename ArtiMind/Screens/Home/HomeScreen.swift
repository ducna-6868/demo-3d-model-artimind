import SwiftUI

struct HomeScreen: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.goldAccent, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("ArtiMind")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Hero Card
                    NavigationLink(destination: UploadPhotoScreen()) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .foregroundStyle(Color.goldAccent)
                                Text("Create Companion")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                Spacer()
                            }

                            Text("Transform a photo into a living, breathing 3D companion that speaks with warmth and love.")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack {
                                Image(systemName: "sparkles")
                                Text("Start Creating")
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.goldAccent, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.cardDark)
                        )
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)

                    // Stats Row
                    HStack(spacing: 12) {
                        StatCard(icon: "waveform", iconColor: .purple, title: "12 Voices", subtitle: "Available")
                        StatCard(icon: "cube.transparent", iconColor: .cyan, title: "3D Model", subtitle: "Powered")
                    }
                    .padding(.horizontal, 20)

                    // Recent Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title)
                                .foregroundStyle(.gray.opacity(0.5))
                            Text("No recent activity")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.cardDark)
                        )
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

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardDark)
        )
    }
}
