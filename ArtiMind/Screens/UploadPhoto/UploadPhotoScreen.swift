import SwiftUI
import PhotosUI

struct UploadPhotoScreen: View {
    @Environment(AppState.self) private var appState

    @State private var lovedOne = LovedOne()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isDetecting = false
    @State private var showNoFaceAlert = false
    @State private var showCameraSheet = false

    @State private var navigateToVoiceSelect = false
    @State private var navigateToSelectPerson = false
    @State private var navigateToCompanion = false

    var body: some View {
        ZStack {
            LinearGradient.warmBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Photo preview / placeholder
                    photoArea
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Action buttons
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose from Library")
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.primary)
                            .glassBackground(shape: .rounded(16), interactive: true)
                        }
                        .buttonStyle(.plain)

                        LiquidGlassTextButton(
                            title: "Take Photo",
                            icon: "camera",
                            foregroundColor: .primary
                        ) {
                            showCameraSheet = true
                        }
                    }
                    .padding(.horizontal, 20)

                    if isDetecting {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(.purple)
                            Text("Detecting faces…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Upload Photo")
        .navigationBarTitleDisplayMode(.inline)
        .hideMainTabBar()
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadAndDetect(from: newItem) }
        }
        .alert("No Face Detected", isPresented: $showNoFaceAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't find a face in the selected photo. Please try a different image with a clear, visible face.")
        }
        .navigationDestination(isPresented: $navigateToVoiceSelect) {
            VoiceSelectScreen(lovedOne: $lovedOne) {
                appState.selectedLovedOne = lovedOne
                navigateToCompanion = true
            }
        }
        .navigationDestination(isPresented: $navigateToSelectPerson) {
            SelectPersonScreen(lovedOne: lovedOne, onContinue: {
                appState.selectedLovedOne = lovedOne
                navigateToCompanion = true
            })
        }
        .navigationDestination(isPresented: $navigateToCompanion) {
            Companion3DScreen(lovedOne: lovedOne)
        }
        .sheet(isPresented: $showCameraSheet) {
            CameraPickerView { image in
                showCameraSheet = false
                Task { await handleImage(image) }
            }
        }
    }

    // MARK: - Photo Area

    @ViewBuilder
    private var photoArea: some View {
        GlassCard(cornerRadius: 24) {
            ZStack {
                if let photo = lovedOne.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.rectangle.badge.plus")
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(.tertiary)

                        Text("No photo selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                            .foregroundStyle(.tertiary)
                    )
                }
            }
        }
    }

    // MARK: - Face Detection

    private func loadAndDetect(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await handleImage(image)
    }

    private func handleImage(_ image: UIImage) async {
        lovedOne.photo = image
        isDetecting = true
        defer { isDetecting = false }

        let faces = await FaceDetectionService.detectFaces(in: image)
        lovedOne.detectedFaces = faces

        switch faces.count {
        case 0:
            showNoFaceAlert = true
        case 1:
            lovedOne.selectedFaceIndex = 0
            navigateToVoiceSelect = true
        default:
            navigateToSelectPerson = true
        }
    }
}

// MARK: - Camera Picker

private struct CameraPickerView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        init(onImagePicked: @escaping (UIImage) -> Void) { self.onImagePicked = onImagePicked }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

