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
            Color.appBackground
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

                        Text("The more you share, the more they feel like home.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Photos of moments section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photos of moments")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)

                        GlassCard {
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
                                                    .foregroundStyle(.white.opacity(0.25))
                                                    .frame(height: 140)

                                                VStack(spacing: 10) {
                                                    Image(systemName: "plus.circle")
                                                        .font(.system(size: 36, weight: .light))
                                                        .foregroundStyle(.white.opacity(0.75))

                                                    Text("Add photos")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.white.opacity(0.75))
                                                }
                                            }

                                            Text("Moments you shared together · up to 10 photos")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.55))
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                    .tint(Color.white)
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
                                                        .foregroundStyle(.white.opacity(0.25))
                                                        .frame(height: 90)

                                                    Image(systemName: "plus")
                                                        .font(.title2)
                                                        .foregroundStyle(.white.opacity(0.75))
                                                }
                                            }
                                            .tint(Color.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Tell us about them section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tell us about them")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)

                        GlassCard {
                            TextEditor(text: $lovedOne.memoryText)
                                .focused($isTextFocused)
                                .frame(minHeight: 140)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .font(.body)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .overlay(alignment: .topLeading) {
                                    if lovedOne.memoryText.isEmpty {
                                        Text("A memory you'll never forget — maybe a story, a joke, or a saying only they used…")
                                            .font(.body)
                                            .foregroundStyle(.white.opacity(0.35))
                                            .allowsHitTesting(false)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Continue button
                    Button {
                        navigateToLoading = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                            Text("Continue")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.goldAccent)
                        )
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
