import SwiftUI

struct SplashScreen: View {
    @Environment(AppState.self) private var appState
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient.darkVibrant
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "brain")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, isActive: isAnimating)
                    .scaleEffect(isAnimating ? 1.0 : 0.7)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimating)

                VStack(spacing: 8) {
                    Text("ArtiMind")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)

                    Text("Reconnect with those you love")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 12)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)
                }
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    if appState.hasCompletedOnboarding {
                        appState.currentFlow = .main
                    } else {
                        appState.currentFlow = .onboarding
                    }
                }
            }
        }
    }
}
