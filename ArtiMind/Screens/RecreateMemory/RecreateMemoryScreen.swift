import SwiftUI
import PhotosUI

struct RecreateMemoryScreen: View {
    @Binding var lovedOne: LovedOne
    var onContinue: () -> Void

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var memoryText: String = ""
    @State private var navigateToLoading = false
    @FocusState private var isTextFocused: Bool

    private let thumbnailColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ZStack {
            LinearGradient.warmBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Recreate Memory")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Share memories so your companion feels real")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Upload Media section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upload Media")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)

                        GlassCard(cornerRadius: 20) {
                            VStack(spacing: 16) {
                                if lovedOne.memoryMedia.isEmpty {
                                    // Empty state with + button
                                    PhotosPicker(
                                        selection: $selectedItems,
                                        maxSelectionCount: 10,
                                        matching: .images
                                    ) {
                                        VStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(
                                                        style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                                                    )
                                                    .foregroundStyle(.secondary.opacity(0.4))
                                                    .frame(height: 140)

                                                VStack(spacing: 10) {
                                                    Image(systemName: "plus.circle")
                                                        .font(.system(size: 36, weight: .light))
                                                        .foregroundStyle(.secondary)

                                                    Text("Add Photos")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            Text("Add photos you shared together — up to 10 images")
                                                .font(.caption)
                                                .foregroundStyle(.secondary.opacity(0.7))
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                } else {
                                    // Thumbnail grid + add more
                                    LazyVGrid(columns: thumbnailColumns, spacing: 8) {
                                        ForEach(lovedOne.memoryMedia.indices, id: \.self) { index in
                                            Image(uiImage: lovedOne.memoryMedia[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 90)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(alignment: .topTrailing) {
                                                    Button {
                                                        lovedOne.memoryMedia.remove(at: index)
                                                    } label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.title3)
                                                            .foregroundStyle(.white)
                                                            .background(Color.black.opacity(0.4), in: Circle())
                                                    }
                                                    .padding(4)
                                                }
                                        }

                                        // Add more cell
                                        if lovedOne.memoryMedia.count < 10 {
                                            PhotosPicker(
                                                selection: $selectedItems,
                                                maxSelectionCount: 10 - lovedOne.memoryMedia.count,
                                                matching: .images
                                            ) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .strokeBorder(
                                                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                                        )
                                                        .foregroundStyle(.secondary.opacity(0.4))
                                                        .frame(height: 90)

                                                    Image(systemName: "plus")
                                                        .font(.title2)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Tell us something section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tell us something about you two")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)

                        GlassCard(cornerRadius: 20) {
                            TextEditor(text: $lovedOne.memoryText)
                                .focused($isTextFocused)
                                .frame(minHeight: 140)
                                .scrollContentBackground(.hidden)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .overlay(alignment: .topLeading) {
                                    if lovedOne.memoryText.isEmpty {
                                        Text("Share a favorite memory, an inside joke, or something they always said…")
                                            .font(.body)
                                            .foregroundStyle(.secondary.opacity(0.6))
                                            .allowsHitTesting(false)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Continue button
                    LiquidGlassTextButton(
                        title: "Continue",
                        icon: "arrow.right",
                        font: .headline,
                        fontWeight: .semibold,
                        foregroundColor: .primary
                    ) {
                        navigateToLoading = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationDestination(isPresented: $navigateToLoading) {
            LoadingGenerateScreen {
                onContinue()
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var images: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                await MainActor.run {
                    lovedOne.memoryMedia.append(contentsOf: images)
                    selectedItems = []
                }
            }
        }
    }
}
