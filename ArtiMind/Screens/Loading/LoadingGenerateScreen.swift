import SwiftUI

struct LoadingGenerateScreen: View {
    var onComplete: () -> Void

    @State private var currentStep = 0
    @State private var completedSteps: Set<Int> = []

    private let steps = [
        "Creating your avatar...",
        "Adding actions to your avatar...",
        "Generating voice for your avatar..."
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Avatar circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .brown],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                // Title
                Text("We are creating avatar...")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                // Progress bar
                ProgressView(value: Double(completedSteps.count), total: Double(steps.count))
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .padding(.horizontal, 60)

                // Step list
                VStack(spacing: 14) {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack(spacing: 10) {
                            Text(steps[index])
                                .font(.subheadline)
                                .foregroundStyle(
                                    completedSteps.contains(index) ? .white :
                                    index == currentStep ? .white.opacity(0.8) :
                                    .gray.opacity(0.5)
                                )

                            Spacer()

                            if completedSteps.contains(index) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.body)
                            } else if index == currentStep {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                ProgressView()
                                    .tint(.gray.opacity(0.3))
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Loading")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .hideMainTabBar()
        .onAppear { startSteps() }
    }

    private func startSteps() {
        for (index, _) in steps.enumerated() {
            let startDelay = Double(index) * 1.8

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = index
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + 1.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    completedSteps.insert(index)
                }

                // Navigate when last step completes
                if index == steps.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}
