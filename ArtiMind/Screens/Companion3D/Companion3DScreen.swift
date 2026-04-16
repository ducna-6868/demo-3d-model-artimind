import SwiftUI
import SceneKit

// MARK: - SceneKit UIViewRepresentable

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if uiView.scene !== scene {
            uiView.scene = scene
        }
    }
}

// MARK: - Companion3DScreen

struct Companion3DScreen: View {
    let lovedOne: LovedOne
    var onDismiss: (() -> Void)? = nil

    @State private var messages: [CompanionMessage] = []
    @State private var messageText: String = ""
    @State private var scene: SCNScene? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil
    @FocusState private var isInputFocused: Bool

    private let mockResponses = [
        "I'm so happy you're here with me.",
        "Tell me more, I'm listening.",
        "That reminds me of something wonderful.",
        "You always knew how to make me smile.",
        "I've missed you. Let's just sit here for a while.",
        "Every day with you was a gift.",
        "You haven't changed at all — still wonderful.",
        "I love hearing your voice.",
        "Just knowing you're here means everything.",
        "Share more with me — I want to remember everything."
    ]

    var body: some View {
        ZStack {
            LinearGradient.companion3DBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top: 3D scene
                ZStack(alignment: .top) {
                    SceneKitView(scene: scene)
                        .frame(maxWidth: .infinity)
                        .frame(height: 340)
                        .clipShape(RoundedRectangle(cornerRadius: 0))

                    // Companion name overlay
                    VStack {
                        Spacer()
                        Text(lovedOne.name.isEmpty ? "Your Companion" : lovedOne.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .glassBackground(shape: .rounded(20))
                            .padding(.bottom, 16)
                    }
                    .frame(height: 340)
                }

                // Bottom: Chat + actions
                VStack(spacing: 0) {
                    // Messages list
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        }
                        .onAppear { scrollProxy = proxy }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Input bar
                    HStack(spacing: 10) {
                        TextField("Say something…", text: $messageText)
                            .focused($isInputFocused)
                            .font(.body)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .glassBackground(shape: .rounded(22))
                            .submitLabel(.send)
                            .onSubmit { sendMessage() }

                        LiquidGlassIconButton(
                            icon: "paperplane.fill",
                            title: nil,
                            iconFont: .body,
                            foregroundColor: .white,
                            size: 44
                        ) {
                            sendMessage()
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    // Action bar
                    HStack(spacing: 12) {
                        LiquidGlassIconButton(
                            icon: "camera.fill",
                            title: "Photo",
                            foregroundColor: .white
                        ) {
                            // Take photo action
                        }

                        LiquidGlassIconButton(
                            icon: "circle.lefthalf.filled",
                            title: "Background",
                            foregroundColor: .white
                        ) {
                            // Background action
                        }

                        LiquidGlassIconButton(
                            icon: "mic.fill",
                            title: "Voice",
                            foregroundColor: .white
                        ) {
                            // Voice chat action
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .padding(.top, 4)
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 0)
            }
        }
        .hideMainTabBar()
        .onAppear {
            scene = SceneService.shared.loadScene()
            // Welcome message
            let welcome = CompanionMessage(
                content: "Hello… I'm so glad you came. What would you like to talk about?",
                isUser: false
            )
            messages.append(welcome)
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Send message

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let userMsg = CompanionMessage(content: trimmed, isUser: true)
        messages.append(userMsg)
        messageText = ""
        isInputFocused = false

        // Mock companion response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response = mockResponses.randomElement() ?? "I hear you."
            let companionMsg = CompanionMessage(content: response, isUser: false)
            withAnimation(.easeOut(duration: 0.3)) {
                messages.append(companionMsg)
            }
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: CompanionMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 48) }

            Text(message.content)
                .font(.body)
                .foregroundStyle(message.isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isUser
                        ? AnyShapeStyle(Color.purple.opacity(0.7))
                        : AnyShapeStyle(.ultraThinMaterial)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: message.isUser ? 18 : 18,
                        style: .continuous
                    )
                )

            if !message.isUser { Spacer(minLength: 48) }
        }
    }
}
