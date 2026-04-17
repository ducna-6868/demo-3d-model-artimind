import SwiftUI
import SceneKit

// MARK: - SceneKit Model View

struct ModelView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true

        if let url = Bundle.main.url(forResource: "companion", withExtension: "scn") {
            do {
                let scene = try SCNScene(url: url)

                // Apply texture from bundled PNG
                if let texURL = Bundle.main.url(forResource: "model_texture", withExtension: "png"),
                   let texImage = UIImage(contentsOfFile: texURL.path) {
                    scene.rootNode.enumerateChildNodes { node, _ in
                        if let geo = node.geometry {
                            for mat in geo.materials {
                                mat.diffuse.contents = texImage
                                mat.lightingModel = .physicallyBased
                            }
                        }
                    }
                }

                // Camera: head/shoulder portrait, balanced framing
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.camera?.fieldOfView = 28
                cameraNode.camera?.zNear = 0.1
                cameraNode.position = SCNVector3(0, 1.6, 2.0)
                cameraNode.look(at: SCNVector3(0, 1.45, 0))
                scene.rootNode.addChildNode(cameraNode)

                // Idle breathing animation
                let breatheIn = SCNAction.scale(to: 1.005, duration: 2.0)
                breatheIn.timingMode = .easeInEaseOut
                let breatheOut = SCNAction.scale(to: 0.995, duration: 2.0)
                breatheOut.timingMode = .easeInEaseOut
                let breath = SCNAction.sequence([breatheIn, breatheOut])
                scene.rootNode.runAction(SCNAction.repeatForever(breath))

                scnView.scene = scene
                scnView.pointOfView = cameraNode
            } catch {
                loadPlaceholder(into: scnView)
            }
        } else {
            loadPlaceholder(into: scnView)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func loadPlaceholder(into scnView: SCNView) {
        let scene = SCNScene()
        let sphere = SCNSphere(radius: 0.4)
        sphere.firstMaterial?.diffuse.contents = UIColor.purple.withAlphaComponent(0.5)
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 1.45, 0)
        scene.rootNode.addChildNode(node)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 28
        camera.position = SCNVector3(0, 1.6, 2.0)
        camera.look(at: SCNVector3(0, 1.45, 0))
        scene.rootNode.addChildNode(camera)

        scnView.scene = scene
        scnView.pointOfView = camera
    }
}

// MARK: - Companion3DScreen

struct Companion3DScreen: View {
    let lovedOne: LovedOne

    @Environment(\.dismiss) private var dismiss

    @State private var messages: [CompanionMessage] = []
    @State private var messageText = ""
    @State private var showChat = false
    @State private var isInCall = false
    @State private var isHolding = false
    @State private var holdStartTime: Date? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var presencePulse: Bool = false
    @FocusState private var isInputFocused: Bool

    private let mockResponses = [
        "I'm so happy you're here with me.",
        "Tell me more, I'm listening.",
        "That reminds me of something wonderful.",
        "You always knew how to make me smile.",
        "Every day with you was a gift.",
        "I love hearing your voice.",
        "Just knowing you're here means everything."
    ]

    var body: some View {
        ZStack {
            // Background — radial gradient base
            RadialGradient(
                colors: [
                    Color(red: 0.09, green: 0.07, blue: 0.15),
                    Color(red: 0.03, green: 0.02, blue: 0.08)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 700
            )
            .ignoresSafeArea()

            // Full-screen 3D model — only this layer ignores safe area
            ModelView()
                .ignoresSafeArea()

            // Overlay layer — stays inside safe area naturally
            overlayLayer
        }
        .toolbar(.hidden, for: .navigationBar)
        .hideMainTabBar()
        .onAppear {
            messages.append(CompanionMessage(
                content: "Hello… I'm so glad you came.",
                isUser: false
            ))
            // Start presence pulse
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                presencePulse = true
            }
        }
    }

    // MARK: - Overlay Layer (all UI on top of model)

    private var overlayLayer: some View {
        VStack(spacing: 0) {
            // Top bar — sits at top of safe area, no extra padding needed
            topBar
                .padding(.top, 8)

            Spacer()

            // Right-side buttons — positioned with spacer
            HStack {
                Spacer()
                rightSideButtonsColumn
                    .padding(.trailing, 14)
                    .padding(.bottom, showChat ? 0 : 60)
            }

            // Chat overlay
            if showChat {
                GeometryReader { geo in
                    chatOverlay(screenHeight: geo.size.height + 200)
                }
                .frame(maxHeight: 240)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Bottom section: pill + input bar stacked, no overlap
            bottomSection
                .padding(.bottom, 8)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .glassBackground(shape: .circle, interactive: true)
            }
            .contentShape(Rectangle())

            // Presence dot + name + subtitle
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    // Presence dot with pulse
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.35))
                            .frame(width: 14, height: 14)
                            .scaleEffect(presencePulse ? 1.5 : 1.0)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }

                    Text(lovedOne.name.isEmpty ? "Your Loved One" : lovedOne.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Text("Here with you")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.7))
                    .padding(.leading, 20) // align under name, past dot
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Right Side Buttons (column only, no positioning math)

    private var rightSideButtonsColumn: some View {
        VStack(spacing: 12) {
            GlassSideButton(icon: "arrow.triangle.2.circlepath") { }

            GlassSideButton(icon: "gearshape.fill") { }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showChat.toggle()
                    if !showChat { isInputFocused = false }
                }
            } label: {
                Image(systemName: showChat ? "bubble.left.fill" : "bubble.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(showChat ? Color.goldAccent : .white.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .glassBackground(shape: .circle, interactive: true)
            }
        }
    }

    // MARK: - Chat Overlay

    private func chatOverlay(screenHeight: CGFloat) -> some View {
        let maxHeight = screenHeight * 0.38

        return ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        HStack(alignment: .bottom, spacing: 8) {
                            if msg.isUser {
                                Spacer(minLength: 40)
                            } else {
                                // Companion avatar
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.goldAccent, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .alignmentGuide(.bottom) { d in d[.bottom] }
                            }

                            Group {
                                if let seconds = msg.voiceDurationSeconds {
                                    voiceBubble(seconds: seconds)
                                } else {
                                    Text(msg.content)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .glassBackground(
                                            backgroundColor: msg.isUser ? Color.goldAccent : .clear,
                                            opacity: msg.isUser ? 0.15 : 1.0,
                                            shape: .rounded(18),
                                            enableBorder: msg.isUser,
                                            borderColor: Color.white.opacity(0.18),
                                            borderLineWidth: 0.5
                                        )
                                }
                            }
                            .id(msg.id)

                            if !msg.isUser {
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .frame(maxHeight: maxHeight)
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Voice Message Bubble

    @ViewBuilder
    private func voiceBubble(seconds: Int) -> some View {
        HStack(spacing: 10) {
            // Play button
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Static mini waveform
            HStack(spacing: 2) {
                ForEach([6, 10, 14, 8, 12, 16, 10, 6, 14, 8, 12, 10, 16, 6, 10, 14, 8, 12, 10, 6], id: \.self) { h in
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 2, height: CGFloat(h))
                }
            }
            .frame(height: 18)

            // Duration label
            Text("0:\(String(format: "%02d", seconds))")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.goldAccent.opacity(0.22),
                            Color.goldAccent.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Bottom Section (pill + input bar, no overlap)

    private var bottomSection: some View {
        VStack(spacing: 12) {
            // Live Call pill — only shown when chat is hidden AND not holding
            if !showChat && !isHolding {
                liveCallPill
                    .transition(.scale.combined(with: .opacity))
            }

            // Swap interior: normal bar OR recording pill.
            // DragGesture lives on the outer VStack so it persists through the swap.
            ZStack {
                if isHolding {
                    recordingPill
                        .transition(.opacity.combined(with: .scale))
                        .padding(.horizontal, 14)
                } else {
                    bottomBar
                        .transition(.opacity)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isHolding)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: showChat)
        // Gesture attached to OUTER VStack — survives the bottomBar ↔ recordingPill swap
        .simultaneousGesture(holdGesture)
    }

    // MARK: - Hold Gesture (attached to outer container, not micButton)

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if !isHolding {
                    // Only start recording when touch originates in mic button region
                    // Mic button is leftmost in bottomBar: x < 64 covers 42pt button + padding
                    if value.startLocation.x < 64 && value.startLocation.y >= 0 {
                        startHoldRecording()
                    }
                }
                if isHolding {
                    dragOffset = value.translation
                    if value.translation.height < -80 { commitRecording() }
                    if value.translation.width < -80 { cancelRecording() }
                }
            }
            .onEnded { _ in
                if isHolding { stopHoldRecording() }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    dragOffset = .zero
                }
            }
    }

    // MARK: - Live Call Pill

    private var liveCallPill: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isInCall.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isInCall ? "waveform.circle.fill" : "waveform")
                    .font(.callout)
                    .symbolEffect(.pulse, isActive: isInCall)
                Text(isInCall ? "In call" : "Start talking")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isInCall ? Color.goldAccent : .white)
            .padding(.horizontal, 28)
            .padding(.vertical, 13)
            .glassBackground(
                backgroundColor: .clear,
                opacity: 1.0,
                shape: .capsule,
                enableBorder: isInCall,
                borderColor: isInCall ? Color.goldAccent : .clear,
                borderLineWidth: 1,
                interactive: true
            )
        }
    }

    // MARK: - Recording Pill (Grok-style)

    private var recordingPill: some View {
        VStack(spacing: 6) {
            // "Swipe up to send" hint above pill
            Text("˄  Swipe up to send")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))

            ZStack {
                // Pill background gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.25, blue: 0.2),
                                Color(red: 0.05, green: 0.1, blue: 0.12)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                HStack(spacing: 0) {
                    // Cancel button
                    Button {
                        cancelRecording()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(.leading, 12)

                    Spacer()

                    // Waveform dots
                    waveformDots

                    Spacer()

                    // Send button (checkmark)
                    Button {
                        commitRecording()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color(red: 0.05, green: 0.15, blue: 0.12))
                        }
                    }
                    .padding(.trailing, 8)
                }
                .padding(.vertical, 8)
            }
            .frame(height: 64)

            // "Swipe left to cancel" hint below pill
            Text("◂  Swipe left to cancel")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
        }
        // Offset driven by dragOffset state (updated by micButton's DragGesture above).
        // No separate DragGesture here — gesture lives on micButton so it survives the
        // bottomBar → recordingPill overlay transition without being destroyed.
        .offset(x: dragOffset.width < 0 ? dragOffset.width * 0.4 : 0,
                y: dragOffset.height < 0 ? dragOffset.height * 0.4 : 0)
    }

    // MARK: - Waveform Dots

    private var waveformDots: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<40, id: \.self) { index in
                    let phase = t * 4.0 + Double(index) * 0.3
                    let heightMultiplier = sin(phase) * 0.5 + 0.5
                    let dotHeight = 3.0 + heightMultiplier * 13.0
                    // Fade in from left edge
                    let edgeFade = min(1.0, Double(index) / 6.0)
                    let opacity = 0.2 + edgeFade * 0.5

                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.white.opacity(opacity))
                        .frame(width: 2.5, height: dotHeight)
                }
            }
            .frame(height: 20)
        }
    }

    // MARK: - Bottom Bar (input row only)

    private var bottomBar: some View {
        HStack(spacing: 10) {
            // Mic button — hold = voice message, tap = no-op
            micButton

            LiquidGlassIconButton(
                icon: "camera.fill",
                title: nil,
                iconFont: .subheadline,
                foregroundColor: .white,
                shape: .circle,
                size: 42
            ) { }

            // Text field + send
            HStack(spacing: 0) {
                TextField("Message…", text: $messageText)
                    .focused($isInputFocused)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .onSubmit { sendMessage() }
                    .padding(.leading, 14)
                    .padding(.vertical, 12)

                if !messageText.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.black)
                            .padding(.trailing, 8)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .glassBackground(shape: .capsule)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: messageText.isEmpty)
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Mic Button (hold = voice message, tap = no-op)

    private var micButton: some View {
        Image(systemName: isHolding ? "waveform.circle.fill" : "mic")
            .font(.subheadline)
            .foregroundStyle(isHolding ? Color.red : .white)
            .scaleEffect(isHolding ? 1.25 : 1.0)
            .frame(width: 42, height: 42)
            .background(
                Circle()
                    .fill(Color.red.opacity(isHolding ? 0.25 : 0.0))
                    .scaleEffect(isHolding ? 1.6 : 1.0)
                    .animation(
                        isHolding
                            ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                            : .default,
                        value: isHolding
                    )
            )
            // interactive: false — visual only, avoids iOS 26 glassEffect swallowing gesture
            .glassBackground(
                backgroundColor: isHolding ? .red : .clear,
                opacity: isHolding ? 0.2 : 1.0,
                shape: .circle,
                interactive: false
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
            // contentShape ensures the full 42×42 circle hit-tests correctly
            .contentShape(Circle())
    }

    // MARK: - Recording Helpers

    private func startHoldRecording() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isHolding = true
            holdStartTime = Date()
            dragOffset = .zero
        }
    }

    private func stopHoldRecording() {
        let duration = holdStartTime.map { Date().timeIntervalSince($0) } ?? 0
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isHolding = false
            dragOffset = .zero
        }
        holdStartTime = nil

        guard duration >= 0.5 else { return }

        let seconds = Int(duration)
        if !showChat {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { showChat = true }
        }
        messages.append(CompanionMessage(content: "", isUser: true, voiceDurationSeconds: seconds))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let resp = mockResponses.randomElement() ?? "I hear you."
            withAnimation { messages.append(CompanionMessage(content: resp, isUser: false)) }
        }
    }

    private func commitRecording() {
        guard isHolding else { return }
        let duration = holdStartTime.map { Date().timeIntervalSince($0) } ?? 0
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isHolding = false
            dragOffset = .zero
        }
        holdStartTime = nil

        let seconds = max(1, Int(duration))
        if !showChat {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { showChat = true }
        }
        messages.append(CompanionMessage(content: "", isUser: true, voiceDurationSeconds: seconds))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let resp = mockResponses.randomElement() ?? "I hear you."
            withAnimation { messages.append(CompanionMessage(content: resp, isUser: false)) }
        }
    }

    private func cancelRecording() {
        guard isHolding else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isHolding = false
            dragOffset = .zero
        }
        holdStartTime = nil
    }

    // MARK: - Send Message

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if !showChat {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { showChat = true }
        }
        messages.append(CompanionMessage(content: trimmed, isUser: true))
        messageText = ""
        isInputFocused = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let resp = mockResponses.randomElement() ?? "I hear you."
            withAnimation { messages.append(CompanionMessage(content: resp, isUser: false)) }
        }
    }
}

// MARK: - Glass Side Button

private struct GlassSideButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 44, height: 44)
                .glassBackground(shape: .circle, interactive: true)
        }
    }
}
