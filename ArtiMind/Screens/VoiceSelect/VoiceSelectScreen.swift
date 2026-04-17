import SwiftUI
import UniformTypeIdentifiers

struct VoiceSelectScreen: View {
    @Binding var lovedOne: LovedOne
    var onContinue: () -> Void

    @State private var voiceService = VoiceService()
    @State private var library: [VoiceEmotion: [VoiceReference]] = [:]
    @State private var selectedEmotion: VoiceEmotion? = nil
    @State private var selectedRelationship: Relationship = .father
    @State private var navigateToRecreateMemory = false

    // Upload flow
    @State private var showUploadSheet = false
    @State private var showNameAlert = false
    @State private var uploadedFileURL: URL?
    @State private var uploadedVoiceName = ""
    @State private var userAddedVoices: [VoiceReference] = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)

                libraryTab

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

    // MARK: - Library Tab

    @ViewBuilder
    private var libraryTab: some View {
        if let emotion = selectedEmotion {
            voiceListView(for: emotion)
        } else {
            emotionGridView
        }
    }

    private var emotionGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(VoiceEmotion.allCases) { emotion in
                    EmotionCard(emotion: emotion, hasVoices: library[emotion] != nil) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEmotion = emotion
                        }
                    }
                }
                AddVoiceCard {
                    showUploadSheet = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func voiceListView(for emotion: VoiceEmotion) -> some View {
        VStack(spacing: 0) {
            // Back button + emotion title
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedEmotion = nil
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.primary)
                }

                Spacer()

                Label(emotion.displayName, systemImage: emotion.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 10) {
                    let voices = (library[emotion] ?? []).filter { $0.relationship == selectedRelationship }

                    if voices.isEmpty {
                        HStack {
                            Image(systemName: "waveform.slash")
                                .foregroundStyle(.gray)
                            Text("No voices available for this relationship")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.cardDark))
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(voices) { voice in
                            VoiceRow(
                                voice: voice,
                                isSelected: lovedOne.selectedVoice == voice,
                                isPlaying: voiceService.isPlaying && voiceService.currentVoice == voice
                            ) {
                                if voiceService.isPlaying && voiceService.currentVoice == voice {
                                    voiceService.stop()
                                } else {
                                    voiceService.play(voice)
                                }
                            } onSelect: {
                                lovedOne.selectedVoice = voice
                                voiceService.stop()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
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

private struct EmotionCard: View {
    let emotion: VoiceEmotion
    let hasVoices: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(emotion.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: emotion.color.light).opacity(0.20),
                                Color(hex: emotion.color.dark).opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: emotion.color.light).opacity(0.25), lineWidth: 0.5)
            )
            .opacity(hasVoices ? 1.0 : 0.4)
        }
        .disabled(!hasVoices)
    }
}

private struct AddVoiceCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.goldAccent)

                Text("Add Voice")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Upload your own recording")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.goldAccent.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color.goldAccent.opacity(0.4),
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            )
        }
    }
}

private struct VoiceRow: View {
    let voice: VoiceReference
    let isSelected: Bool
    let isPlaying: Bool
    let onPlayToggle: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onPlayToggle) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15), in: Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(voice.emotion.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(voice.relationship.displayName)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button(action: onSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .green : .gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardDark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.green.opacity(0.6) : Color.clear, lineWidth: 2)
        )
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
