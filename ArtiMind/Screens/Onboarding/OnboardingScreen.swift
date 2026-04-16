import SwiftUI

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        icon: "photo.fill",
        title: "Upload a Photo",
        description: "Start by adding a photo of your loved one. We'll detect their face and use it to create a lifelike 3D companion."
    ),
    OnboardingPage(
        icon: "waveform",
        title: "Choose a Voice",
        description: "Select a warm, expressive voice that feels right. Each voice carries a unique emotion crafted to feel personal and close."
    ),
    OnboardingPage(
        icon: "person.and.background.dotted",
        title: "Meet Your Companion",
        description: "Your 3D companion is ready to speak, remember, and reconnect. Experience the presence of someone you love, anytime."
    )
]

struct OnboardingScreen: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            LinearGradient.darkVibrant
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)

                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        LiquidGlassTextButton(
                            title: "Get Started",
                            icon: "sparkles",
                            font: .headline,
                            fontWeight: .semibold,
                            foregroundColor: .white
                        ) {
                            appState.hasCompletedOnboarding = true
                            appState.currentFlow = .main
                        }
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        LiquidGlassTextButton(
                            title: "Next",
                            icon: "chevron.right",
                            font: .headline,
                            fontWeight: .semibold,
                            foregroundColor: .white
                        ) {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .animation(.easeInOut, value: currentPage)
                .padding(.bottom, 48)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            GlassCard(cornerRadius: 28) {
                VStack(spacing: 20) {
                    Image(systemName: page.icon)
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                    Text(page.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer()
        }
    }
}
