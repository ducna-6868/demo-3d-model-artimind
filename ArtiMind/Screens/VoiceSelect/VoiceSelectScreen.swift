import SwiftUI
import UniformTypeIdentifiers

struct VoiceSelectScreen: View {
    @Binding var lovedOne: LovedOne
    var onContinue: () -> Void

    @State private var voiceService = VoiceService()
    @State private var library: [VoiceEmotion: [VoiceReference]] = [:]
    @State private var selectedRelationship: Relationship = .father
    @State private var navigateToRecreateMemory = false

    // Upload flow
    @State private var showUploadSheet = false
    @State private var showNameAlert = false
    @State private var uploadedFileURL: URL?
    @State private var uploadedVoiceName = ""
    @State private var userAddedVoices: [VoiceReference] = []

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose a Voice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Pick the tone that feels like them")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, 20)
                .padding(.bottom, 16)

                emotionListView

                Spacer(minLength: 0)

                // Relationship filter
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Relationship.allCases) { rel in
                                Button {
                                    selectedRelationship = rel
                                } label: {
                                    Text(rel.displayName)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(selectedRelationship == rel ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedRelationship == rel ? Color.goldAccent : Color.cardDark)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Continue button
                    Button {
                        if lovedOne.selectedVoice != nil {
                            navigateToRecreateMemory = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                            Text("Continue")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundStyle(lovedOne.selectedVoice != nil ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(lovedOne.selectedVoice != nil ? Color.goldAccent : Color.cardDark)
                        )
                    }
                    .padding(.horizontal, 24)
                    .disabled(lovedOne.selectedVoice == nil)
                }
                .padding(.bottom, 32)
                .padding(.top, 12)
            }
        }
        .navigationDestination(isPresented: $navigateToRecreateMemory) {
            RecreateMemoryScreen(lovedOne: $lovedOne, onContinue: onContinue)
        }
        .onAppear {
            library = voiceService.loadVoiceLibrary()
        }
        .onChange(of: selectedRelationship) { _, _ in
            if let selected = lovedOne.selectedVoice, selected.relationship != selectedRelationship {
                lovedOne.selectedVoice = nil
                voiceService.stop()
            }
        }
        .fileImporter(
            isPresented: $showUploadSheet,
            allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                if let persisted = persistAudioFile(url) {
                    uploadedFileURL = persisted
                    uploadedVoiceName = ""
                    showNameAlert = true
                }
            }
        }
        .alert("Name your voice", isPresented: $showNameAlert) {
            TextField("E.g. Dad's Warm Voice", text: $uploadedVoiceName)
            Button("Save") {
                saveUploadedVoice()
            }
            Button("Cancel", role: .cancel) {
                uploadedFileURL = nil
            }
        } message: {
            Text("Give this voice a memorable name.")
        }
    }

    // MARK: - Emotion List View

    private var emotionListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(VoiceEmotion.allCases) { emotion in
                    if let voice = voice(for: emotion, relationship: selectedRelationship) {
                        VoiceCardRow(
                            emotion: emotion,
                            voice: voice,
                            isSelected: lovedOne.selectedVoice == voice,
                            isPlaying: voiceService.isPlaying && voiceService.currentVoice == voice,
                            onPlayToggle: {
                                if voiceService.isPlaying && voiceService.currentVoice == voice {
                                    voiceService.stop()
                                } else {
                                    voiceService.play(voice)
                                }
                            },
                            onSelect: {
                                lovedOne.selectedVoice = voice
                                voiceService.stop()
                            }
                        )
                    }
                }
                AddVoiceCard { showUploadSheet = true }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Helpers

    private func voice(for emotion: VoiceEmotion, relationship: Relationship) -> VoiceReference? {
        library[emotion]?.first(where: { $0.relationship == relationship })
    }

    // MARK: - Upload Helpers

    private func persistAudioFile(_ sourceURL: URL) -> URL? {
        let hasAccess = sourceURL.startAccessingSecurityScopedResource()
        defer { if hasAccess { sourceURL.stopAccessingSecurityScopedResource() } }
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destURL = docsDir.appendingPathComponent(UUID().uuidString + "." + sourceURL.pathExtension)
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            return destURL
        } catch {
            return nil
        }
    }

    private func saveUploadedVoice() {
        guard let url = uploadedFileURL else { return }
        let trimmed = uploadedVoiceName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let newVoice = VoiceReference(
            emotion: .warmLoving,
            relationship: selectedRelationship,
            fileName: trimmed,
            url: url
        )
        userAddedVoices.append(newVoice)
        library[.warmLoving, default: []].append(newVoice)
        uploadedFileURL = nil
        uploadedVoiceName = ""
    }
}

// MARK: - Subviews

private struct VoiceCardRow: View {
    let emotion: VoiceEmotion
    let voice: VoiceReference
    let isSelected: Bool
    let isPlaying: Bool
    let onPlayToggle: () -> Void
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Left: play button (separate gesture)
                Button(action: onPlayToggle) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle().fill(Color.black.opacity(0.35))
                        )
                }
                .buttonStyle(.plain)

                // Middle: emotion name
                Text(emotion.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Right: selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.goldAccent : .white.opacity(0.55))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Solid dark base — ensures contrast with white text
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardDark)

                    // Emotion-tinted gradient layer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: emotion.color.light).opacity(0.35),
                                    Color(hex: emotion.color.dark).opacity(0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.goldAccent : Color(hex: emotion.color.light).opacity(0.4),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AddVoiceCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color.goldAccent)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Voice")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Upload your own recording")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.goldAccent.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color.goldAccent.opacity(0.6),
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Hex Helper

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
