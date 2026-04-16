import SwiftUI

struct VoiceSelectScreen: View {
    @Binding var lovedOne: LovedOne
    var onContinue: () -> Void

    @State private var voiceService = VoiceService()
    @State private var library: [VoiceEmotion: [VoiceReference]] = [:]
    @State private var selectedTab = 0
    @State private var selectedEmotion: VoiceEmotion? = nil
    @State private var selectedRelationship: Relationship = .father
    @State private var navigateToRecreateMemory = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient.warmBackground
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

                // Tab picker
                Picker("Mode", selection: $selectedTab) {
                    Text("Library").tag(0)
                    Text("Upload Audio").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if selectedTab == 0 {
                    libraryTab
                } else {
                    uploadTab
                }

                Spacer(minLength: 0)

                // Relationship filter
                VStack(spacing: 12) {
                    Picker("Relationship", selection: $selectedRelationship) {
                        ForEach(Relationship.allCases) { rel in
                            Text(rel.displayName).tag(rel)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    // Continue button
                    LiquidGlassTextButton(
                        title: "Continue",
                        icon: "arrow.right",
                        font: .headline,
                        fontWeight: .semibold,
                        foregroundColor: lovedOne.selectedVoice != nil ? .primary : .secondary
                    ) {
                        if lovedOne.selectedVoice != nil {
                            navigateToRecreateMemory = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(lovedOne.selectedVoice != nil ? 1.0 : 0.5)
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
            // Reset selection if new relationship filter doesn't include current voice
            if let selected = lovedOne.selectedVoice, selected.relationship != selectedRelationship {
                lovedOne.selectedVoice = nil
                voiceService.stop()
            }
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
                        GlassCard(cornerRadius: 16) {
                            HStack {
                                Image(systemName: "waveform.slash")
                                    .foregroundStyle(.secondary)
                                Text("No voices available for this relationship")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        ForEach(voices) { voice in
                            VoiceRow(
                                voice: voice,
                                isSelected: lovedOne.selectedVoice == voice,
                                isPlaying: voiceService.isPlaying && voiceService.currentVoice == voice
                            ) {
                                // Play / stop toggle
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

    // MARK: - Upload Tab

    private var uploadTab: some View {
        VStack {
            Spacer()

            GlassCard(cornerRadius: 24) {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                            )
                            .foregroundStyle(.secondary.opacity(0.5))
                            .frame(height: 160)

                        VStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.secondary)

                            Text("Upload Audio")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text("MP3, WAV, or M4A up to 10MB")
                                .font(.caption)
                                .foregroundStyle(.secondary.opacity(0.7))
                        }
                    }

                    Text("Upload a voice recording of your loved one to create a personalized voice model.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Subviews

private struct EmotionCard: View {
    let emotion: VoiceEmotion
    let hasVoices: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: emotion.color.light),
                                Color(hex: emotion.color.dark)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(emotion.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .glassBackground(shape: .rounded(16), interactive: true)
            .opacity(hasVoices ? 1.0 : 0.4)
        }
        .disabled(!hasVoices)
    }
}

private struct VoiceRow: View {
    let voice: VoiceReference
    let isSelected: Bool
    let isPlaying: Bool
    let onPlayToggle: () -> Void
    let onSelect: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 14) {
            HStack(spacing: 14) {
                // Play / Stop button
                Button(action: onPlayToggle) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .glassBackground(shape: .circle, interactive: true)
                }

                // Voice info
                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.emotion.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(voice.relationship.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Select / checkmark
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? .green : .secondary)
                }
            }
        }
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
