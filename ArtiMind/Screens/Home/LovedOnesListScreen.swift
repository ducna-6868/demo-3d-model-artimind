import SwiftUI

struct LovedOnesListScreen: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    heroSection
                    lovedOnesSection
                    featuresSection
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Loved Ones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("+ PRO")
                    .font(.caption.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.goldAccent, in: Capsule())
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("They're still")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text("here,")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text("with you.")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(Color.warmWhite.opacity(0.7))
                }
            }

            Text("One photo is all it takes. Your companion learns to\nmove, speak, and feel present — whenever you need them.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardDark)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Loved Ones Section

    private var lovedOnesSection: some View {
        VStack(spacing: 20) {
            Text("Your Loved Ones")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Who do you miss")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Text("the most?")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(Color.warmWhite.opacity(0.6))
                }

                Text("Pick a photo of someone you love. We'll bring them\nto life with gestures, voice, and a familiar warmth.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                NavigationLink(destination: UploadPhotoScreen()) {
                    Text("Add a Loved One")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 12) {
            Text("What Loved Ones can do")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                FeatureCard(
                    icon: "hand.wave.fill",
                    iconColor: .yellow,
                    title: "Gestures & Emotes",
                    subtitle: "Wave, hand on chest, friendly smile...",
                    badge: "Ready",
                    badgeColor: .green
                )

                FeatureCard(
                    icon: "waveform",
                    iconColor: .purple,
                    title: "Voice & Speech",
                    subtitle: "Hear them in a warm, familiar tone",
                    badge: "Pro",
                    badgeColor: Color.goldAccent,
                    badgeIcon: "sparkles"
                )

                FeatureCard(
                    icon: "bubble.left.fill",
                    iconColor: .green,
                    title: "Text Conversations",
                    subtitle: "Chat, share memories, ask questions",
                    badge: "Soon",
                    badgeColor: .gray
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let badge: String
    let badgeColor: Color
    var badgeIcon: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                if let badgeIcon {
                    Image(systemName: badgeIcon)
                        .font(.caption2)
                }
                Text(badge)
                    .font(.caption.bold())
            }
            .foregroundStyle(badgeColor == .gray ? .gray : (badgeColor == .green ? .green : .black))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(badgeColor.opacity(badgeColor == .gray ? 0.2 : 0.9))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardDark)
        )
    }
}
