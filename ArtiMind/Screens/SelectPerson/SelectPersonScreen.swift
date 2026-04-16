import SwiftUI

struct SelectPersonScreen: View {
    @Environment(AppState.self) private var appState

    @State var lovedOne: LovedOne
    var onContinue: (() -> Void)? = nil

    @State private var selectedIndex: Int? = nil
    @State private var navigateToVoiceSelect = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient.warmBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(lovedOne.detectedFaces) { face in
                            FaceCell(
                                face: face,
                                isSelected: selectedIndex == face.index
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedIndex = face.index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

                // Continue button
                LiquidGlassTextButton(
                    title: "Continue",
                    icon: "arrow.right",
                    font: .headline,
                    fontWeight: .semibold,
                    foregroundColor: selectedIndex != nil ? .primary : .secondary
                ) {
                    guard selectedIndex != nil else { return }
                    lovedOne.selectedFaceIndex = selectedIndex
                    navigateToVoiceSelect = true
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .disabled(selectedIndex == nil)
            }
        }
        .navigationTitle("Select Person")
        .navigationBarTitleDisplayMode(.inline)
        .hideMainTabBar()
        .navigationDestination(isPresented: $navigateToVoiceSelect) {
            VoiceSelectScreen(lovedOne: $lovedOne) {
                onContinue?()
            }
        }
    }
}

private struct FaceCell: View {
    let face: DetectedFace
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                GlassCard(cornerRadius: 20) {
                    VStack(spacing: 8) {
                        Image(uiImage: face.image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Text("Person \(face.index + 1)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isSelected ? Color.purple : Color.clear,
                            lineWidth: 2.5
                        )
                )

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(.purple)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .padding(10)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
