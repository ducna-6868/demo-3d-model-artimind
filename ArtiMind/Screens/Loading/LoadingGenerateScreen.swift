import SwiftUI

struct LoadingGenerateScreen: View {
    var onComplete: () -> Void

    @State private var progress: Double = 0
    @State private var isAnimating = false
    @State private var currentStepIndex = 0

    private let steps = [
        "Analyzing your memories…",
        "Sculpting facial features…",
        "Applying voice signature…",
        "Bringing them to life…",
        "Final touches…"
    ]

    var body: some View {
        ZStack {
            LinearGradient.pastelBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Shimmer glass card
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.15),
                                    Color.blue.opacity(0.10),
                                    Color.pink.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 240, height: 320)
                        .glassBackground(shape: .rounded(32))

                    VStack(spacing: 24) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 64, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.pulse, isActive: isAnimating)

                        VStack(spacing: 6) {
                            Text("Creating Your")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text("Companion...")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .shadow(color: .purple.opacity(0.2), radius: 24, x: 0, y: 12)

                // Progress section
                VStack(spacing: 16) {
                    // Step text
                    Text(steps[currentStepIndex])
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .animation(.easeInOut, value: currentStepIndex)
                        .id(currentStepIndex)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    // Progress bar
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .tint(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                            .padding(.horizontal, 48)

                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Spacer()
            }
        }
        .hideMainTabBar()
        .onAppear {
            isAnimating = true
            startProgress()
        }
    }

    private func startProgress() {
        let totalDuration: Double = 5.0
        let stepDuration = totalDuration / Double(steps.count)

        // Animate progress from 0 to 1 over 5 seconds
        withAnimation(.linear(duration: totalDuration)) {
            progress = 1.0
        }

        // Update step text at intervals
        for (index, _) in steps.enumerated() {
            let delay = Double(index) * stepDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStepIndex = index
                }
            }
        }

        // Navigate when complete
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            onComplete()
        }
    }
}
